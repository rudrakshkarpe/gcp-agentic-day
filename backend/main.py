import asyncio
import base64
import uuid
import logging
from datetime import datetime
from typing import Dict, List, Optional
from fastapi import FastAPI, UploadFile, File, HTTPException, Form, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager

# Import our services and models
from config.settings import settings
from services.ai_service import KisanAIAgent
from services.speech_service import SpeechService
from models.requests import (
    TextMessageRequest, VoiceMessageRequest, ImageAnalysisRequest,
    UserContext, ConversationHistory
)
from models.responses import (
    ChatResponse, VoiceResponse, ImageDiagnosisResponse,
    ErrorResponse, HealthCheckResponse
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Global conversation storage (use Redis/Firestore for production)
conversations: Dict[str, Dict] = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize services on startup"""
    logger.info("Starting Kisan AI Backend...")
    
    # Initialize AI agent
    app.state.ai_agent = KisanAIAgent()
    app.state.speech_service = SpeechService()
    
    logger.info("Services initialized successfully!")
    yield
    
    # Cleanup if needed
    logger.info("Shutting down...")

# Create FastAPI app
app = FastAPI(
    title="Kisan AI Assistant",
    description="AI-powered farming assistant for Indian farmers",
    version="1.0.0",
    lifespan=lifespan
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Helper functions
def get_ai_agent() -> KisanAIAgent:
    return app.state.ai_agent

def get_speech_service() -> SpeechService:
    return app.state.speech_service

def get_or_create_conversation(user_id: str) -> Dict:
    """Get or create conversation state for user"""
    if user_id not in conversations:
        conversations[user_id] = {
            "conversation_id": str(uuid.uuid4()),
            "history": [],
            "context": {
                "location": "Karnataka",
                "language": "kn",
                "farming_type": "mixed",
                "land_size": "small"
            },
            "created_at": datetime.now(),
            "last_updated": datetime.now()
        }
    
    conversations[user_id]["last_updated"] = datetime.now()
    return conversations[user_id]

def add_to_conversation_history(user_id: str, role: str, content: str, tools_used: List[str] = None):
    """Add message to conversation history"""
    conversation = get_or_create_conversation(user_id)
    conversation["history"].append({
        "role": role,
        "content": content,
        "timestamp": datetime.now(),
        "tools_used": tools_used or []
    })
    
    # Keep only last 20 messages to prevent memory issues
    if len(conversation["history"]) > 20:
        conversation["history"] = conversation["history"][-20:]

# API Routes

@app.get("/", response_model=HealthCheckResponse)
async def root():
    """Health check endpoint"""
    return HealthCheckResponse(
        status="healthy",
        services={
            "ai_agent": "running",
            "speech_service": "running",
            "gemini_model": settings.GEMINI_MODEL
        }
    )

@app.get("/health", response_model=HealthCheckResponse)
async def health_check():
    """Detailed health check"""
    return HealthCheckResponse(
        status="healthy",
        services={
            "ai_agent": "running",
            "speech_service": "running",
            "vertex_ai": "connected",
            "cloud_storage": "connected",
            "gemini_model": settings.GEMINI_MODEL
        }
    )

@app.post("/api/chat/text", response_model=ChatResponse)
async def process_text_message(
    request: TextMessageRequest,
    ai_agent: KisanAIAgent = Depends(get_ai_agent)
):
    """Process text message through AI agent"""
    try:
        logger.info(f"Processing text message for user: {request.user_id}")
        
        # Get conversation context
        conversation = get_or_create_conversation(request.user_id)
        
        # Process message through AI agent
        response = await ai_agent.process_message(
            message=request.message,
            user_id=request.user_id,
            conversation_history=conversation["history"],
            user_context=conversation["context"]
        )
        
        # Add to conversation history
        add_to_conversation_history(request.user_id, "user", request.message)
        add_to_conversation_history(
            request.user_id, 
            "assistant", 
            response["response"], 
            response.get("tools_used", [])
        )
        
        return ChatResponse(
            response=response["response"],
            audio_url=response.get("audio_url"),
            tools_used=response.get("tools_used", []),
            conversation_id=conversation["conversation_id"],
            confidence=response.get("confidence")
        )
        
    except Exception as e:
        logger.error(f"Text message processing error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Message processing failed: {str(e)}")

@app.post("/api/chat/voice", response_model=VoiceResponse)
async def process_voice_message(
    audio: UploadFile = File(...),
    user_id: str = Form(...),
    language: str = Form(default="kn-IN"),
    ai_agent: KisanAIAgent = Depends(get_ai_agent),
    speech_service: SpeechService = Depends(get_speech_service)
):
    """Process voice message - STT -> AI Agent -> TTS"""
    try:
        logger.info(f"Processing voice message for user: {user_id}")
        
        # Read audio data
        audio_data = await audio.read()
        
        # Convert speech to text
        transcript = await speech_service.speech_to_text(audio_data, language)
        logger.info(f"Transcript: {transcript}")
        
        # Process text through AI agent
        conversation = get_or_create_conversation(user_id)
        response = await ai_agent.process_message(
            message=transcript,
            user_id=user_id,
            conversation_history=conversation["history"],
            user_context=conversation["context"]
        )
        
        # Add to conversation history
        add_to_conversation_history(user_id, "user", f"🎤 {transcript}")
        add_to_conversation_history(
            user_id, 
            "assistant", 
            response["response"], 
            response.get("tools_used", [])
        )
        
        return VoiceResponse(
            transcript=transcript,
            response=response["response"],
            audio_url=response.get("audio_url"),
            tools_used=response.get("tools_used", []),
            conversation_id=conversation["conversation_id"],
            confidence=response.get("confidence")
        )
        
    except Exception as e:
        logger.error(f"Voice message processing error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Voice processing failed: {str(e)}")

@app.post("/api/chat/image", response_model=ImageDiagnosisResponse)
async def process_image_diagnosis(
    image: UploadFile = File(...),
    user_id: str = Form(...),
    plant_type: str = Form(default=""),
    symptoms_description: str = Form(default=""),
    message: str = Form(default="ಈ ಸಸ್ಯದ ಸಮಸ್ಯೆಯನ್ನು ಗುರುತಿಸಿ"),
    ai_agent: KisanAIAgent = Depends(get_ai_agent)
):
    """Process plant disease diagnosis from image"""
    try:
        logger.info(f"Processing image diagnosis for user: {user_id}")
        
        # Read and encode image
        image_data = await image.read()
        image_base64 = base64.b64encode(image_data).decode()
        
        # Process image through AI agent
        response = await ai_agent.process_image_message(
            image_data=image_base64,
            message=message,
            user_id=user_id,
            plant_type=plant_type,
            symptoms=symptoms_description
        )
        
        # Add to conversation history
        add_to_conversation_history(user_id, "user", f"📷 ಸಸ್ಯದ ಚಿತ್ರ ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ ({plant_type})")
        add_to_conversation_history(user_id, "assistant", response["diagnosis"])
        
        return ImageDiagnosisResponse(
            diagnosis=response["diagnosis"],
            disease_name=response.get("disease_name"),
            severity=response.get("severity"),
            treatment=response.get("treatment", []),
            organic_remedies=response.get("organic_remedies", []),
            chemical_treatment=response.get("chemical_treatment", []),
            prevention=response.get("prevention", []),
            confidence=response.get("confidence", 0.8),
            audio_url=response.get("audio_url")
        )
        
    except Exception as e:
        logger.error(f"Image diagnosis error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Image analysis failed: {str(e)}")

@app.get("/api/chat/history/{user_id}")
async def get_conversation_history(user_id: str):
    """Get conversation history for user"""
    try:
        if user_id in conversations:
            conversation = conversations[user_id]
            return {
                "conversation_id": conversation["conversation_id"],
                "history": conversation["history"][-10:],  # Last 10 messages
                "context": conversation["context"],
                "last_updated": conversation["last_updated"]
            }
        else:
            return {
                "conversation_id": None,
                "history": [],
                "context": {},
                "message": "No conversation found"
            }
            
    except Exception as e:
        logger.error(f"History retrieval error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"History retrieval failed: {str(e)}")

@app.post("/api/user/context")
async def update_user_context(user_id: str, context: UserContext):
    """Update user context (location, farming type, etc.)"""
    try:
        conversation = get_or_create_conversation(user_id)
        conversation["context"].update(context.dict(exclude_unset=True))
        
        return {
            "message": "Context updated successfully",
            "context": conversation["context"]
        }
        
    except Exception as e:
        logger.error(f"Context update error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Context update failed: {str(e)}")

@app.get("/api/market/prices")
async def get_market_prices(
    commodity: str,
    location: str = "Karnataka",
    ai_agent: KisanAIAgent = Depends(get_ai_agent)
):
    """Get current market prices for a commodity"""
    try:
        price_data = await ai_agent.get_market_prices(commodity, location)
        return price_data
        
    except Exception as e:
        logger.error(f"Market price error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Market price retrieval failed: {str(e)}")

@app.get("/api/schemes/search")
async def search_schemes(
    query: str,
    farmer_category: str = "small",
    ai_agent: KisanAIAgent = Depends(get_ai_agent)
):
    """Search government schemes"""
    try:
        schemes_data = await ai_agent.search_government_schemes(query, farmer_category)
        return schemes_data
        
    except Exception as e:
        logger.error(f"Schemes search error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Schemes search failed: {str(e)}")

# Error handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    """Handle HTTP exceptions"""
    return JSONResponse(
        status_code=exc.status_code,
        content=ErrorResponse(
            error="HTTP Error",
            message=str(exc.detail),
            code=str(exc.status_code)
        ).dict()
    )

@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    """Handle general exceptions"""
    logger.error(f"Unhandled exception: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content=ErrorResponse(
            error="Internal Server Error",
            message="An unexpected error occurred",
            code="500"
        ).dict()
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )
