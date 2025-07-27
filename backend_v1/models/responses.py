from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime

class ChatResponse(BaseModel):
    response: str
    audio_url: Optional[str] = None
    tools_used: List[str] = []
    conversation_id: str
    confidence: Optional[float] = None
    timestamp: datetime = datetime.now()

class VoiceResponse(BaseModel):
    transcript: str
    response: str
    audio_url: Optional[str] = None
    tools_used: List[str] = []
    conversation_id: str
    confidence: Optional[float] = None

class ImageDiagnosisResponse(BaseModel):
    diagnosis: str
    disease_name: Optional[str] = None
    severity: Optional[str] = None
    treatment: List[str] = []
    organic_remedies: List[str] = []
    chemical_treatment: List[str] = []
    prevention: List[str] = []
    confidence: float = 0.0
    audio_url: Optional[str] = None

class MarketPriceResponse(BaseModel):
    commodity: str
    current_price: float
    unit: str
    market: str
    trend: str
    last_week_price: Optional[float] = None
    recommendation: str
    best_selling_time: Optional[str] = None
    updated_at: str

class GovernmentSchemeResponse(BaseModel):
    scheme_name: str
    description: str
    eligibility: List[str] = []
    benefits: List[str] = []
    application_process: List[str] = []
    required_documents: List[str] = []
    contact_info: Optional[str] = None
    online_link: Optional[str] = None
    deadline: Optional[str] = None

class ErrorResponse(BaseModel):
    error: str
    message: str
    code: Optional[str] = None
    timestamp: datetime = datetime.now()

class HealthCheckResponse(BaseModel):
    status: str
    timestamp: datetime = datetime.now()
    services: Dict[str, str] = {}
