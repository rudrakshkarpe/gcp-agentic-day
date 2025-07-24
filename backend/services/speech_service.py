import asyncio
import base64
import io
from typing import Optional
from google.cloud import speech
from google.cloud import texttospeech
from google.cloud import storage
from config.settings import settings
import logging

logger = logging.getLogger(__name__)

class SpeechService:
    def __init__(self):
        self.speech_client = speech.SpeechClient()
        self.tts_client = texttospeech.TextToSpeechClient()
        self.storage_client = storage.Client()
        self.bucket = self.storage_client.bucket(settings.UPLOAD_BUCKET)
    
    async def speech_to_text(self, audio_data: bytes, language_code: str = "kn-IN") -> str:
        """
        Convert speech audio to text using Google Cloud Speech-to-Text
        
        Args:
            audio_data: Raw audio bytes
            language_code: Language code (default: kn-IN for Kannada)
            
        Returns:
            Transcribed text in Kannada
        """
        try:
            # Configure audio settings
            audio = speech.RecognitionAudio(content=audio_data)
            config = speech.RecognitionConfig(
                encoding=speech.RecognitionConfig.AudioEncoding.WEBM_OPUS,
                sample_rate_hertz=48000,
                language_code=language_code,
                enable_automatic_punctuation=True,
                model="default",  # Use default model for Kannada
                use_enhanced=True
            )
            
            # Perform speech recognition
            response = self.speech_client.recognize(config=config, audio=audio)
            
            if response.results:
                # Get the most confident transcription
                transcript = response.results[0].alternatives[0].transcript
                confidence = response.results[0].alternatives[0].confidence
                
                logger.info(f"Speech recognition successful. Confidence: {confidence}")
                return transcript.strip()
            else:
                logger.warning("No speech recognition results")
                return "ಯಾವುದೇ ಮಾತು ಕೇಳಿಸಲಿಲ್ಲ"  # "No speech detected" in Kannada
                
        except Exception as e:
            logger.error(f"Speech-to-text error: {str(e)}")
            raise Exception(f"Speech recognition failed: {str(e)}")
    
    async def text_to_speech(self, text: str, language_code: str = "kn-IN") -> str:
        """
        Convert text to speech using Google Cloud Text-to-Speech
        
        Args:
            text: Text to convert to speech
            language_code: Language code (default: kn-IN for Kannada)
            
        Returns:
            URL of the generated audio file
        """
        try:
            # Configure voice settings
            voice = texttospeech.VoiceSelectionParams(
                language_code=language_code,
                name=settings.TTS_VOICE,  # kn-IN-Standard-A (female voice)
                ssml_gender=texttospeech.SsmlVoiceGender.FEMALE
            )
            
            # Configure audio format
            audio_config = texttospeech.AudioConfig(
                audio_encoding=texttospeech.AudioEncoding.MP3,
                speaking_rate=0.9,  # Slightly slower for clarity
                pitch=0.0,
                volume_gain_db=0.0
            )
            
            # Build synthesis input
            synthesis_input = texttospeech.SynthesisInput(text=text)
            
            # Perform text-to-speech
            response = self.tts_client.synthesize_speech(
                input=synthesis_input, 
                voice=voice, 
                audio_config=audio_config
            )
            
            # Save audio to Cloud Storage
            audio_filename = f"tts/{hash(text)}.mp3"
            blob = self.bucket.blob(audio_filename)
            blob.upload_from_string(response.audio_content, content_type="audio/mpeg")
            
            # Make blob publicly accessible
            blob.make_public()
            
            # Return public URL
            audio_url = blob.public_url
            logger.info(f"TTS audio generated: {audio_url}")
            return audio_url
            
        except Exception as e:
            logger.error(f"Text-to-speech error: {str(e)}")
            raise Exception(f"Text-to-speech failed: {str(e)}")
    
    async def upload_audio_file(self, audio_data: bytes, filename: str) -> str:
        """
        Upload audio file to Cloud Storage
        
        Args:
            audio_data: Raw audio bytes
            filename: Name for the audio file
            
        Returns:
            Public URL of uploaded file
        """
        try:
            blob = self.bucket.blob(f"uploads/audio/{filename}")
            blob.upload_from_string(audio_data, content_type="audio/webm")
            blob.make_public()
            
            return blob.public_url
            
        except Exception as e:
            logger.error(f"Audio upload error: {str(e)}")
            raise Exception(f"Audio upload failed: {str(e)}")
