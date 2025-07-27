import os
import json
from dotenv import load_dotenv

load_dotenv()

class Settings:
    # GCP Configuration
    GCP_PROJECT_ID: str = os.getenv("GOOGLE_CLOUD_PROJECT", "")
    GCP_PROJECT_NUMBER: str = os.getenv("GCP_PROJECT_NUMBER", "")
    GCP_REGION: str = os.getenv("GCP_REGION", "asia-south1")
    GOOGLE_APPLICATION_CREDENTIALS: str = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "")
    
    # Storage Configuration
    UPLOAD_BUCKET: str = os.getenv("UPLOAD_BUCKET", "kisan-uploads-bucket")
    
    # Firebase Configuration
    FIREBASE_PROJECT_ID: str = os.getenv("FIREBASE_PROJECT_ID", "")
    
    # API Endpoints
    VERTEX_AI_ENDPOINT: str = f"https://{os.getenv('GCP_REGION', 'asia-south1')}-aiplatform.googleapis.com"
    SPEECH_TO_TEXT_ENDPOINT: str = "https://speech.googleapis.com/v1/speech:recognize"
    TEXT_TO_SPEECH_ENDPOINT: str = "https://texttospeech.googleapis.com/v1/text:synthesize"
    
    # Model Configuration - Updated to use Gemini 2.5 Pro
    GEMINI_MODEL: str = os.getenv("GEMINI_MODEL", "gemini-2.5-pro")
    SPEECH_LANGUAGE: str = os.getenv("SPEECH_LANGUAGE", "kn-IN")
    TTS_LANGUAGE: str = os.getenv("TTS_LANGUAGE", "kn-IN")
    TTS_VOICE: str = os.getenv("TTS_VOICE", "kn-IN-Standard-A")
    
    # Additional Model Settings
    GEMINI_TEMPERATURE: float = float(os.getenv("GEMINI_TEMPERATURE", "0.7"))
    GEMINI_MAX_TOKENS: int = int(os.getenv("GEMINI_MAX_TOKENS", "8192"))
    GEMINI_TOP_P: float = float(os.getenv("GEMINI_TOP_P", "0.8"))
    
    # App Configuration
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    
    # Security & Performance
    MAX_UPLOAD_SIZE: int = int(os.getenv("MAX_UPLOAD_SIZE", "10485760"))  # 10MB
    REQUEST_TIMEOUT: int = int(os.getenv("REQUEST_TIMEOUT", "30"))
    MAX_CONCURRENT_REQUESTS: int = int(os.getenv("MAX_CONCURRENT_REQUESTS", "100"))
    
    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = int(os.getenv("RATE_LIMIT_PER_MINUTE", "60"))
    RATE_LIMIT_BURST: int = int(os.getenv("RATE_LIMIT_BURST", "10"))
    
    # Logging & Monitoring
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    ENABLE_METRICS: bool = os.getenv("ENABLE_METRICS", "true").lower() == "true"
    
    # Speech Enhancement
    SPEECH_ENHANCEMENT: bool = os.getenv("SPEECH_ENHANCEMENT", "true").lower() == "true"
    NOISE_REDUCTION: bool = os.getenv("NOISE_REDUCTION", "true").lower() == "true"
    
    # CORS Configuration
    @property
    def ALLOWED_ORIGINS(self) -> list:
        """Parse ALLOWED_ORIGINS from environment variable"""
        origins_env = os.getenv("ALLOWED_ORIGINS", '["*"]')
        try:
            # Try to parse as JSON first
            origins = json.loads(origins_env)
            if isinstance(origins, list):
                return origins
        except (json.JSONDecodeError, TypeError):
            # Fallback to comma-separated string
            if "," in origins_env:
                return [origin.strip() for origin in origins_env.split(",")]
        
        # Default CORS origins for development
        if self.DEBUG:
            return [
                "http://localhost:3000",
                "http://localhost:8080", 
                "http://localhost:8081",
                "https://*.web.app",
                "https://*.firebaseapp.com",
                "*"  # Allow all in development
            ]
        else:
            # Production CORS - more restrictive
            return [
                f"https://{self.GCP_PROJECT_ID}.web.app",
                f"https://{self.GCP_PROJECT_ID}.firebaseapp.com",
                "https://kisan-ai.com"  # Your production domain
            ]
    
    # Validation Methods
    def validate_gcp_config(self) -> bool:
        """Validate that required GCP configuration is present"""
        required_fields = [
            self.GCP_PROJECT_ID,
            self.GOOGLE_APPLICATION_CREDENTIALS,
            self.UPLOAD_BUCKET,
            self.FIREBASE_PROJECT_ID
        ]
        return all(field for field in required_fields)
    
    def get_vertex_ai_location(self) -> str:
        """Get the full Vertex AI location path"""
        return f"projects/{self.GCP_PROJECT_ID}/locations/{self.GCP_REGION}"
    
    def get_storage_bucket_url(self) -> str:
        """Get the full storage bucket URL"""
        return f"gs://{self.UPLOAD_BUCKET}"
    
    def is_production(self) -> bool:
        """Check if running in production environment"""
        return self.ENVIRONMENT.lower() == "production"
    
    def is_development(self) -> bool:
        """Check if running in development environment"""
        return self.ENVIRONMENT.lower() == "development"

# Create settings instance
settings = Settings()

# Validate configuration on import
if not settings.validate_gcp_config():
    import warnings
    warnings.warn(
        "GCP configuration incomplete. Please check your .env file and ensure all required fields are set.",
        UserWarning
    )
