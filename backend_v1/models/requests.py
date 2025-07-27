from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class TextMessageRequest(BaseModel):
    user_id: str
    message: str
    language: Optional[str] = "kn"  # Kannada default
    
class VoiceMessageRequest(BaseModel):
    user_id: str
    language: Optional[str] = "kn-IN"

class ImageAnalysisRequest(BaseModel):
    user_id: str
    plant_type: Optional[str] = ""
    symptoms_description: Optional[str] = ""
    language: Optional[str] = "kn"

class MarketPriceRequest(BaseModel):
    commodity: str
    location: Optional[str] = "Karnataka"
    market_type: Optional[str] = "mandi"

class SchemeSearchRequest(BaseModel):
    query: str
    farmer_category: Optional[str] = "small"
    state: Optional[str] = "Karnataka"

class UserContext(BaseModel):
    location: Optional[str] = "Karnataka"
    language: Optional[str] = "kn"
    farming_type: Optional[str] = "mixed"
    land_size: Optional[str] = "small"

class ConversationHistory(BaseModel):
    role: str  # "user" or "assistant"
    content: str
    timestamp: datetime
    tool_calls: Optional[List[str]] = []
