"""
Speech Tools for Kisan AI agents using Google Cloud APIs
"""

from google.cloud import texttospeech, speech
from google.cloud import storage
import asyncio
import io
import uuid
from typing import Optional

from config.settings import settings


class SpeechTools:
    """
    Speech tools for text-to-speech and speech-to-text operations
    """
    
    def __init__(self):
        """Initialize Speech Tools with GCP clients"""
        self.tts_client = texttospeech.TextToSpeechClient()
        self.stt_client = speech.SpeechClient()
        self.storage_client = storage.Client(project=settings.GCP_PROJECT_ID)
        
        # Voice configurations for different languages
        self.voice_configs = {
            "kn": {
                "language_code": "kn-IN",
                "name": "kn-IN-Standard-A",
                "ssml_gender": texttospeech.SsmlVoiceGender.FEMALE
            },
            "hi": {
                "language_code": "hi-IN", 
                "name": "hi-IN-Standard-A",
                "ssml_gender": texttospeech.SsmlVoiceGender.FEMALE
            },
            "en": {
                "language_code": "en-IN",
                "name": "en-IN-Standard-A", 
                "ssml_gender": texttospeech.SsmlVoiceGender.FEMALE
            },
            "ta": {
                "language_code": "ta-IN",
                "name": "ta-IN-Standard-A",
                "ssml_gender": texttospeech.SsmlVoiceGender.FEMALE
            },
            "te": {
                "language_code": "te-IN",
                "name": "te-IN-Standard-A", 
                "ssml_gender": texttospeech.SsmlVoiceGender.FEMALE
            }
        }
    
    async def text_to_speech(
        self, 
        text: str, 
        language: str = "kn", 
        user_id: str = None
    ) -> Optional[str]:
        """
        Convert text to speech and return audio URL
        """
        try:
            # Get voice configuration
            voice_config = self.voice_configs.get(language, self.voice_configs["kn"])
            
            # Prepare synthesis input
            synthesis_input = texttospeech.SynthesisInput(text=text)
            
            # Configure voice
            voice = texttospeech.VoiceSelectionParams(
                language_code=voice_config["language_code"],
                name=voice_config["name"],
                ssml_gender=voice_config["ssml_gender"]
            )
            
            # Configure audio
            audio_config = texttospeech.AudioConfig(
                audio_encoding=texttospeech.AudioEncoding.MP3,
                speaking_rate=0.9,  # Slightly slower for clarity
                pitch=0.0,
                volume_gain_db=0.0
            )
            
            # Generate speech
            response = self.tts_client.synthesize_speech(
                input=synthesis_input,
                voice=voice,
                audio_config=audio_config
            )
            
            # Upload to Cloud Storage
            audio_url = await self._upload_audio_to_storage(
                response.audio_content, 
                user_id or "anonymous",
                language
            )
            
            return audio_url
            
        except Exception as e:
            print(f"TTS Error: {str(e)}")
            return None
    
    async def speech_to_text(
        self, 
        audio_data: bytes, 
        language: str = "kn-IN"
    ) -> Optional[str]:
        """
        Convert speech to text
        """
        try:
            # Configure recognition
            config = speech.RecognitionConfig(
                encoding=speech.RecognitionConfig.AudioEncoding.WEBM_OPUS,
                sample_rate_hertz=48000,
                language_code=language,
                alternative_language_codes=["en-IN", "kn-IN", "hi-IN"],
                enable_automatic_punctuation=True,
                enable_word_confidence=True
            )
            
            # Create audio object
            audio = speech.RecognitionAudio(content=audio_data)
            
            # Perform recognition
            response = self.stt_client.recognize(config=config, audio=audio)
            
            # Extract transcript
            if response.results:
                transcript = response.results[0].alternatives[0].transcript
                return transcript.strip()
            
            return None
            
        except Exception as e:
            print(f"STT Error: {str(e)}")
            return None
    
    async def _upload_audio_to_storage(
        self, 
        audio_content: bytes, 
        user_id: str, 
        language: str
    ) -> Optional[str]:
        """
        Upload audio to Google Cloud Storage
        """
        try:
            # Generate unique filename
            audio_id = str(uuid.uuid4())
            blob_name = f"audio/{user_id}/{language}/{audio_id}.mp3"
            
            # Get bucket
            bucket = self.storage_client.bucket(settings.UPLOAD_BUCKET)
            blob = bucket.blob(blob_name)
            
            # Upload audio
            blob.upload_from_string(
                audio_content,
                content_type="audio/mpeg"
            )
            
            # Make blob publicly readable (optional - depends on your security requirements)
            blob.make_public()
            
            # Return public URL
            return blob.public_url
            
        except Exception as e:
            print(f"Storage upload error: {str(e)}")
            return None
    
    def get_supported_languages(self) -> list:
        """
        Get list of supported languages
        """
        return list(self.voice_configs.keys())
    
    def get_voice_info(self, language: str) -> dict:
        """
        Get voice information for a language
        """
        return self.voice_configs.get(language, self.voice_configs["kn"])
