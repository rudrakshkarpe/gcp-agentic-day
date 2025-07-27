import base64
import io
from fastapi import FastAPI, File, Form, UploadFile, HTTPException
from fastapi.responses import JSONResponse, StreamingResponse
import httpx
from pydantic import BaseModel
import uvicorn
from google.cloud import texttospeech, speech
from vertexai import agent_engines
from agents.kisan_agent.agent import root_agent
import os
import vertexai

# --- FastAPI App Initialization ---
app = FastAPI(
    title="Chat API with Text and Speech Processing",
    description="An API that accepts text or audio, processes it, and returns text and speech.",
    version="1.0.0",
)

vertexai.init(
    project='kisan-project-gcp',
    location='europe-west4',
    staging_bucket='kisan-project-gcp-kisan-sessions'
)
# --- Pydantic Models for Response ---
class ChatResponse(BaseModel):
    text_response: str
    audio_response_base64: str

# --- Placeholder Functions for Gemini/Vertex AI ---

async def recognize_speech_to_text(audio_bytes: bytes) -> str:
    """
    Simulates a call to the Gemini/Vertex AI Speech-to-Text API.
    In a real implementation, you would use the Google Cloud client library.
    """
    print("--- Sending audio to Gemini STT (Simulated) ---")
    # This is a placeholder. A real implementation would look like this:
    #    
    client = speech.SpeechClient()
    audio = speech.RecognitionAudio(content=audio_bytes)
    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.MP4,
        sample_rate_hertz=44100,
        language_code=os.getenv("SPEECH_LANGUAGE", "kn-IN"),
    )
    response = client.recognize(config=config, audio=audio)
    if not response.results:
        raise HTTPException(status_code=400, detail="Could not transcribe audio.")
    return response.results[0].alternatives[0].transcript


async def synthesize_text_to_speech(text: str) -> bytes:
    """
    Simulates a call to the Gemini/Vertex AI Text-to-Speech API.
    In a real implementation, you would use the Google Cloud client library.
    """
    print(f"--- Sending text to Gemini TTS (Simulated): '{text}' ---")
    # This is a placeholder. A real implementation would look like this:
    #
    
    client = texttospeech.TextToSpeechClient()
    synthesis_input = texttospeech.SynthesisInput(text=text)
    voice = texttospeech.VoiceSelectionParams(
        language_code=os.getenv("TTS_LANGUAGE", "kn-IN"), 
        name=os.getenv("TTS_VOICE", "kn-IN-Standard-A")
    )
    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3
    )
    response = client.synthesize_speech(
        input=synthesis_input, voice=voice, audio_config=audio_config
    )
    return response.audio_content


# --- External API Call Function ---
from vertexai.preview import reasoning_engines
def run_vertex_agent_local(text:str):

    final_response = ""

    app = reasoning_engines.AdkApp(
    agent=root_agent,
    enable_tracing=True,
    )

    session = app.create_session(user_id="u_456")

    for event in app.stream_query(
        user_id="u_456",
        session_id=session.id,
        message=text,
    ):
        if event.get("content") and event.get("content", {}).get("parts"):
            final_response = event["content"]["parts"][0].get("text", "")
        
    return final_response


def run_vertex_agent_deployed(text: str) -> str:
    app = agent_engines.get("projects/683449264474/locations/europe-west4/reasoningEngines/7436428147207176192")

    session = app.create_session(user_id="u_456")
    print("Break 2")
    for event in app.stream_query(
        user_id="u_456",
        session_id=session['id'],
        message=text,
    ):
        if event.get("content") and event.get("content", {}).get("parts"):
            final_response = event["content"]["parts"][0].get("text", "")
    
    print("Break 3")
    return final_response


async def call_external_api(text: str) -> str:
    """
    Makes a POST request to the external API.
    """
    print(f"--- Calling External API with text: '{text}' ---")
    try:
        # This is a placeholder. In a real scenario, the API would do something.
        # We'll just echo the text back in a structured way.
        print("Break 1")
        response_final = run_vertex_agent_deployed(text)
        return response_final
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"External API processing failed: {exc}")


# --- API Endpoint ---

@app.post("/api/chat_endpoint")
async def chat_endpoint(text: str = Form(None), audio_file: UploadFile = File(None)):
    """
    This endpoint handles both text and audio chat requests.

    - **To send text:** Use a form field named `text`.
    - **To send audio:** Upload a file to a form field named `audio_file`.

    The endpoint processes the input, calls an external API, and returns
    both a text response and a synthesized audio response.
    """
    print("HIT ENDPOINT",text)
    # text = "whats weather in delhi today"
    input_text = ""

    # 1. Determine request type and get input text
    if audio_file:
        print("--- Received audio file ---")
        if not audio_file.content_type.startswith("audio/"):
            raise HTTPException(status_code=400, detail="Invalid file type. Please upload an audio file.")
        audio_bytes = await audio_file.read()
        try:
            input_text = await recognize_speech_to_text(audio_bytes)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Speech-to-Text processing failed: {e}")
    else: # if text
        print("--- Received text input ---")
        input_text = text

    # 2. Forward text to the external API
    external_api_response_text = await call_external_api(input_text)

    # 3. Pass the response to the TTS model
    try:
        final_audio_bytes = await synthesize_text_to_speech(external_api_response_text)
        print(external_api_response_text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Text-to-Speech processing failed: {e}")

    # 4. Prepare and return the final response
    # We can return the audio in two ways:
    # a) As a base64 string within a JSON object for clients that prefer it.
    # b) As a direct audio stream for browsers or clients that can play it.

    # For this example, we'll return a JSON response with the base64 audio
    # and also make the streaming audio available if requested via headers.
    # A more advanced implementation could use the 'Accept' header to decide.

    audio_base64 = base64.b64encode(final_audio_bytes).decode('utf-8')

    response_data = ChatResponse(
        text_response=external_api_response_text,
        audio_response_base64=audio_base64
    )

    # You could also return a streaming response directly like this:
    # return StreamingResponse(io.BytesIO(final_audio_bytes), media_type="audio/mpeg")

    return JSONResponse(content=response_data.dict())


@app.post("/api/image_chat_endpoint")
async def image_chat_endpoint(
    image_file: UploadFile = File(...),
    text: str = Form(...),
    plant_type: str = Form(""),
    symptoms: str = Form("")
):
    """
    This endpoint handles image analysis with text prompts for agricultural assistance.

    - **image_file:** Upload an image file (plant, crop, etc.)
    - **text:** Text prompt describing what you want to know about the image
    - **plant_type:** Optional plant type specification
    - **symptoms:** Optional symptoms description

    The endpoint processes the image and text, provides agricultural analysis,
    and returns both text response and synthesized audio response.
    """
    print("HIT IMAGE ENDPOINT", text)
    
    # 1. Validate image file
    if not image_file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Invalid file type. Please upload an image file.")
    
    # 2. Read image bytes
    try:
        image_bytes = await image_file.read()
        print(f"--- Received image file: {image_file.filename} ({len(image_bytes)} bytes) ---")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to read image file: {e}")
    
    # 3. Create comprehensive prompt for image analysis
    image_analysis_prompt = f"""Please analyze this agricultural image and provide detailed insights.

User Question: {text}
"""
    
    if plant_type:
        image_analysis_prompt += f"Plant Type: {plant_type}\n"
    if symptoms:
        image_analysis_prompt += f"Observed Symptoms: {symptoms}\n"
    
    image_analysis_prompt += """
Please provide:
1. What you can see in the image
2. Plant/crop identification if applicable
3. Health assessment
4. Any diseases or issues identified 
5. Recommended treatments or care
6. Prevention measures
7. General agricultural advice

Focus on being practical and actionable for farmers."""

    # 4. Forward prompt to the external API (without actual image processing for now)
    # Note: In a full implementation, you would encode the image and send it to a vision model
    try:
        external_api_response_text = await call_external_api(image_analysis_prompt)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Image analysis failed: {e}")

    # 5. Generate TTS response
    try:
        final_audio_bytes = await synthesize_text_to_speech(external_api_response_text)
        print("Generated TTS response for image analysis")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Text-to-Speech processing failed: {e}")

    # 6. Prepare and return the response
    audio_base64 = base64.b64encode(final_audio_bytes).decode('utf-8')

    # Structure response similar to ImageChatResponse format
    response_data = {
        "diagnosis": external_api_response_text,
        "text_response": external_api_response_text,  # For compatibility
        "audio_response_base64": audio_base64,
        "disease_name": None,  # Could be enhanced with specific disease detection
        "severity": None,
        "treatment": [],
        "organic_remedies": [],
        "chemical_treatment": [],
        "prevention": [],
        "confidence": None
    }

    return JSONResponse(content=response_data)


# --- Root endpoint for basic health check ---
@app.get("/")
def read_root():
    return {"message": "Chat API is running. Go to /docs for API documentation."}


# --- To run the app ---
# Command: uvicorn main:app --reload
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8084, reload=True)
