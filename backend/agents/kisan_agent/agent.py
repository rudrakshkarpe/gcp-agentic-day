"""
Main Kisan Agent using Google ADK
"""

from google.adk.agents import Agent
from typing import Dict, Any, List, Optional
import logging

from .prompt import KISAN_AGENT_INSTRUCTION
from .sub_agents.plant_disease_detector_agent import plant_disease_detector_wrapper
from .sub_agents.market_analyzer_agent import market_analyzer_wrapper
from .sub_agents.government_schemes_agent import government_schemes_wrapper
from ..tools.speech_tools import SpeechTools
from ..tools.storage_tools import StorageTools

logger = logging.getLogger(__name__)


class KisanAgentWrapper:
    """
    Wrapper class for the ADK Kisan Agent to provide async methods
    """
    
    def __init__(self):
        """Initialize the Kisan Agent wrapper with ADK agent and tools"""
        # Initialize tools
        self.speech_tools = SpeechTools()
        self.storage_tools = StorageTools()
        
        # Initialize the ADK agent
        self.agent = kisan_agent
        
        # Initialize sub-agents
        self.plant_disease_detector = plant_disease_detector_wrapper
        self.market_analyzer = market_analyzer_wrapper
        self.government_schemes_agent = government_schemes_wrapper
    
    async def process_message(
        self, 
        message: str, 
        user_id: str,
        conversation_history: List[Dict] = None,
        user_context: Dict = None,
        language: str = "kn"
    ) -> Dict[str, Any]:
        """
        Process a text message through the main agent
        """
        try:
            logger.info(f"Processing message for user: {user_id}, language: {language}")
            
            # Build context
            context = self._build_context(conversation_history, user_context, language)
            
            # Check if this requires sub-agent delegation
            delegation_result = await self._check_delegation(message, language)
            
            if delegation_result:
                # Generate TTS for delegated responses if needed
                if language in ["kn", "hi", "ta", "te"] and not delegation_result.get("audio_url"):
                    audio_url = await self.speech_tools.text_to_speech(
                        delegation_result.get("response", ""), language, user_id
                    )
                    delegation_result["audio_url"] = audio_url
                
                return delegation_result
            
            # Process general farming query
            response_text = await self._process_general_query(message, context, language)
            
            # Generate audio if needed
            audio_url = None
            if language in ["kn", "hi", "ta", "te"]:
                audio_url = await self.speech_tools.text_to_speech(
                    response_text, language, user_id
                )
            
            return {
                "response": response_text,
                "audio_url": audio_url,
                "tools_used": ["main_agent"],
                "confidence": 0.9
            }
            
        except Exception as e:
            logger.error(f"Error processing message: {str(e)}")
            error_msg = self._get_error_message(language)
            return {
                "response": error_msg,
                "error": str(e),
                "tools_used": ["main_agent"],
                "confidence": 0.0
            }
    
    async def process_image_message(
        self,
        image_data: str,
        message: str,
        user_id: str,
        plant_type: str = "",
        symptoms: str = "",
        language: str = "kn"
    ) -> Dict[str, Any]:
        """
        Process an image message - delegate to plant disease detector
        """
        try:
            logger.info(f"Processing image message for user: {user_id}")
            return await self.plant_disease_detector.analyze_plant_image(
                image_data, message, user_id, plant_type, symptoms, language
            )
        except Exception as e:
            logger.error(f"Error processing image message: {str(e)}")
            error_msg = self._get_image_error_message(language)
            return {
                "response": error_msg,
                "error": str(e),
                "tools_used": ["plant_disease_detector"],
                "confidence": 0.0
            }
    
    async def get_market_prices(
        self, 
        commodity: str, 
        location: str = "Karnataka",
        language: str = "kn"
    ) -> Dict[str, Any]:
        """
        Get market prices - delegate to market analyzer
        """
        try:
            logger.info(f"Getting market prices for: {commodity} in {location}")
            return await self.market_analyzer.get_market_prices(
                commodity, location, language
            )
        except Exception as e:
            logger.error(f"Error getting market prices: {str(e)}")
            error_msg = self._get_market_error_message(language)
            return {
                "response": error_msg,
                "error": str(e),
                "tools_used": ["market_analyzer"],
                "confidence": 0.0
            }
    
    async def search_government_schemes(
        self,
        query: str,
        farmer_category: str = "small",
        location: str = "Karnataka",
        language: str = "kn"
    ) -> Dict[str, Any]:
        """
        Search government schemes - delegate to government schemes agent
        """
        try:
            logger.info(f"Searching government schemes for: {query}")
            return await self.government_schemes_agent.search_government_schemes(
                query, farmer_category, location, language
            )
        except Exception as e:
            logger.error(f"Error searching government schemes: {str(e)}")
            error_msg = self._get_schemes_error_message(language)
            return {
                "response": error_msg,
                "error": str(e),
                "tools_used": ["government_schemes_agent"],
                "confidence": 0.0
            }
    
    async def _check_delegation(self, message: str, language: str = "kn") -> Optional[Dict[str, Any]]:
        """
        Check if the message should be delegated to a sub-agent
        """
        message_lower = message.lower()
        
        # Market price keywords
        market_keywords = [
            "price", "ಬೆಲೆ", "cost", "market", "ಮಾರುಕಟ್ಟೆ", 
            "sell", "ಮಾರಾಟ", "rate", "ದರ", "ಮಾರುವಾಗ", "how much"
        ]
        
        # Government scheme keywords  
        scheme_keywords = [
            "scheme", "ಯೋಜನೆ", "subsidy", "ಸಬ್ಸಿಡಿ", "loan", "ಸಾಲ",
            "government", "ಸರ್ಕಾರ", "benefit", "ಪ್ರಯೋಜನ", "support", "ಸಹಾಯ",
            "pm kisan", "fasal bima", "credit card", "kisan credit"
        ]
        
        # Check for market price queries
        if any(keyword in message_lower for keyword in market_keywords):
            # Extract commodity name (basic extraction)
            commodity = self._extract_commodity_name(message)
            return await self.get_market_prices(commodity, "Karnataka", language)
        
        # Check for government scheme queries
        if any(keyword in message_lower for keyword in scheme_keywords):
            return await self.search_government_schemes(message, "small", "Karnataka", language)
        
        return None
    
    async def _process_general_query(self, message: str, context: str, language: str) -> str:
        """
        Process general farming queries using the main agent
        """
        # Build a comprehensive response for general farming queries
        if language == "kn":
            response = f"""
ನಮಸ್ಕಾರ! ನಾನು ಕಿಸಾನ್ AI ಸಹಾಯಕ. 

ನಿಮ್ಮ ಪ್ರಶ್ನೆ: "{message}"

ಸಾಮಾನ್ಯ ಕೃಷಿ ಸಲಹೆ:
- ಮಣ್ಣಿನ ಪರೀಕ್ಷೆ ನಿಯಮಿತವಾಗಿ ಮಾಡಿಸಿ
- ಸಾವಯವ ಗೊಬ್ಬರ ಬಳಸಿ
- ನೀರಿನ ಸಂರಕ್ಷಣೆ ಮಾಡಿ
- ಬೆಳೆ ಸರದಿ ಅನುಸರಿಸಿ

ಹೆಚ್ಚಿನ ಮಾಹಿತಿಗಾಗಿ:
📷 ಸಸ್ಯ ರೋಗಗಳಿಗೆ ಫೋಟೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ
💰 ಮಾರುಕಟ್ಟೆ ಬೆಲೆಗಳನ್ನು ಕೇಳಿ
🏛️ ಸರ್ಕಾರಿ ಯೋಜನೆಗಳ ಬಗ್ಗೆ ಕೇಳಿ
            """
        elif language == "hi":
            response = f"""
नमस्कार! मैं किसान AI सहायक हूं।

आपका प्रश्न: "{message}"

सामान्य कृषि सलाह:
- नियमित रूप से मिट्टी की जांच कराएं
- जैविक खाद का उपयोग करें
- पानी का संरक्षण करें
- फसल चक्र का पालन करें

अधिक जानकारी के लिए:
📷 पौधों की बीमारियों के लिए फोटो अपलोड करें
💰 बाजार की कीमतें पूछें
🏛️ सरकारी योजनाओं के बारे में पूछें
            """
        else:
            response = f"""
Hello! I'm Kisan AI Assistant.

Your question: "{message}"

General farming advice:
- Conduct regular soil testing
- Use organic fertilizers
- Practice water conservation
- Follow crop rotation

For more information:
📷 Upload photos for plant disease diagnosis
💰 Ask about market prices
🏛️ Inquire about government schemes
            """
        
        return response.strip()
    
    def _extract_commodity_name(self, message: str) -> str:
        """
        Extract commodity name from message (basic implementation)
        """
        # Common crop names in English and Kannada
        crops = {
            "rice": ["rice", "ಅಕ್ಕಿ", "paddy"],
            "wheat": ["wheat", "ಗೋಧಿ"],
            "tomato": ["tomato", "ಟೊಮೇಟೊ"],
            "onion": ["onion", "ಈರುಳ್ಳಿ"],
            "potato": ["potato", "ಆಲೂಗಡ್ಡೆ"],
            "chili": ["chili", "ಮೆಣಸಿನಕಾಯಿ", "pepper"],
            "sugarcane": ["sugarcane", "ಕಬ್ಬು"],
            "cotton": ["cotton", "ಹತ್ತಿ"],
            "banana": ["banana", "ಬಾಳೆಹಣ್ಣು"]
        }
        
        message_lower = message.lower()
        for commodity, keywords in crops.items():
            if any(keyword in message_lower for keyword in keywords):
                return commodity
        
        # Default to rice if no specific crop found
        return "rice"
    
    def _build_context(
        self, 
        conversation_history: List[Dict] = None,
        user_context: Dict = None,
        language: str = "kn"
    ) -> str:
        """
        Build context for the conversation
        """
        context_parts = []
        
        # Add user context
        if user_context:
            location = user_context.get("location", "Karnataka")
            farming_type = user_context.get("farming_type", "mixed")
            land_size = user_context.get("land_size", "small")
            
            context_parts.append(f"User Location: {location}")
            context_parts.append(f"Farming Type: {farming_type}")
            context_parts.append(f"Land Size: {land_size}")
            context_parts.append(f"Preferred Language: {language}")
        
        # Add recent conversation history
        if conversation_history:
            recent_messages = conversation_history[-3:]  # Last 3 messages
            for msg in recent_messages:
                role = msg.get("role", "user")
                content = msg.get("content", "")
                context_parts.append(f"{role}: {content[:50]}...")
        
        return "\n".join(context_parts)
    
    def _get_error_message(self, language: str) -> str:
        """Get general error message in appropriate language"""
        messages = {
            "kn": "ಕ್ಷಮಿಸಿ, ದೋಷ ಸಂಭವಿಸಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.",
            "hi": "क्षमा करें, एक त्रुटि हुई है। कृपया पुनः प्रयास करें।",
            "en": "Sorry, an error occurred. Please try again."
        }
        return messages.get(language, messages["en"])
    
    def _get_image_error_message(self, language: str) -> str:
        """Get image error message in appropriate language"""
        messages = {
            "kn": "ಚಿತ್ರ ವಿಶ್ಲೇಷಣೆಯಲ್ಲಿ ದೋಷ ಸಂಭವಿಸಿದೆ. ದಯವಿಟ್ಟು ಸ್ಪಷ್ಟವಾದ ಸಸ್ಯದ ಚಿತ್ರವನ್ನು ಪ್ರಯತ್ನಿಸಿ.",
            "hi": "छवि विश्लेषण में त्रुटि हुई। कृपया स्पष्ट पौधे की तस्वीर का प्रयास करें।",
            "en": "Error in image analysis. Please try with a clear plant image."
        }
        return messages.get(language, messages["en"])
    
    def _get_market_error_message(self, language: str) -> str:
        """Get market error message in appropriate language"""
        messages = {
            "kn": "ಮಾರುಕಟ್ಟೆ ಬೆಲೆ ಮಾಹಿತಿ ಪಡೆಯುವಲ್ಲಿ ದೋಷ ಸಂಭವಿಸಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.",
            "hi": "बाजार मूल्य जानकारी प्राप्त करने में त्रुटि हुई। कृपया पुनः प्रयास करें।",
            "en": "Error getting market price information. Please try again."
        }
        return messages.get(language, messages["en"])
    
    def _get_schemes_error_message(self, language: str) -> str:
        """Get schemes error message in appropriate language"""
        messages = {
            "kn": "ಸರ್ಕಾರಿ ಯೋಜನೆಗಳ ಮಾಹಿತಿ ಪಡೆಯುವಲ್ಲಿ ದೋಷ ಸಂಭವಿಸಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.",
            "hi": "सरकारी योजनाओं की जानकारी प्राप्त करने में त्रुटि हुई। कृपया पुनः प्रयास करें।",
            "en": "Error getting government schemes information. Please try again."
        }
        return messages.get(language, messages["en"])


# Create the actual ADK agent
kisan_agent = Agent(
    model="gemini-2.5-pro",
    name="kisan_agent",
    description="A comprehensive AI assistant for farmers providing agricultural guidance, disease detection, market prices, and government scheme information.",
    instruction=KISAN_AGENT_INSTRUCTION,
)

# Create wrapper instance
kisan_agent_wrapper = KisanAgentWrapper()
