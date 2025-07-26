import asyncio
import base64
import json
import logging
from typing import Dict, List, Optional, Any

try:
    from google.cloud.aiplatform_v1.types import Content, Part
except ImportError:
    # Fallback for when Google AI Platform is not available
    Content = None
    Part = None

from kisan_agent.agent import kisan_agent_wrapper
from config.settings import settings

logger = logging.getLogger(__name__)

class KisanAIAgent:
    """
    Kisan AI Agent using Google ADK agents
    Updated to use the new agent structure with prompts.py
    """
    
    def __init__(self):
        # Use the new Google ADK agent wrapper
        self.agent_wrapper = kisan_agent_wrapper
    
    def _get_system_prompt(self) -> str:
        """System instruction for the AI agent"""
        return """
        ನೀವು ಕೃಷಿ ಮಿತ್ರ, ಭಾರತೀಯ ರೈತರಿಗಾಗಿ AI ಸಹಾಯಕ.
        ಯಾವಾಗಲೂ ಸರಳ ಕನ್ನಡದಲ್ಲಿ ಉತ್ತರಿಸಿ.
        ನಿಖರವಾದ, ವ್ಯಾವಹಾರಿಕ ಸಲಹೆ ನೀಡಿ.
        ಲಭ್ಯವಿರುವ ಸಾಧನಗಳನ್ನು ಬಳಸಿ ನೈಜ-ಸಮಯದ ಮಾಹಿತಿ ನೀಡಿ.
        
        You are Krishi Mitra, an AI assistant for Indian farmers.
        Always respond in simple Kannada language.
        Provide accurate, practical advice using available tools for real-time information.
        
        Available tools:
        1. diagnose_plant_disease - Analyze plant images for disease diagnosis
        2. get_market_prices - Get current commodity market prices
        3. search_government_schemes - Find relevant government schemes
        
        Be helpful, accurate, and always prioritize farmer welfare.
        """
    
    async def process_message(self, 
                            message: str, 
                            user_id: str,
                            conversation_history: List[Dict] = None,
                            user_context: Dict = None) -> Dict[str, Any]:
        """
        Process a text message and return AI response using Google ADK agent
        """
        try:
            # Use the Google ADK agent wrapper
            return await self.agent_wrapper.process_message(
                message=message,
                user_id=user_id,
                conversation_history=conversation_history,
                user_context=user_context,
                language=user_context.get("language", "kn") if user_context else "kn"
            )
            
        except Exception as e:
            logger.error(f"AI processing error: {str(e)}")
            error_response = "ಕ್ಷಮಿಸಿ, ತಾಂತ್ರಿಕ ಸಮಸ್ಯೆ ಇದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ."
            return {
                "response": error_response,
                "tools_used": [],
                "error": str(e)
            }
    
    async def process_image_message(self, 
                                  image_data: str,
                                  message: str,
                                  user_id: str,
                                  plant_type: str = "",
                                  symptoms: str = "") -> Dict[str, Any]:
        """
        Process image for disease diagnosis using Google ADK agent
        """
        try:
            # Use the Google ADK agent wrapper for image processing
            return await self.agent_wrapper.process_image_message(
                image_data=image_data,
                message=message,
                user_id=user_id,
                plant_type=plant_type,
                symptoms=symptoms,
                language="kn"
            )
            
        except Exception as e:
            logger.error(f"Image processing error: {str(e)}")
            error_response = "ಚಿತ್ರ ವಿಶ್ಲೇಷಣೆಯಲ್ಲಿ ಸಮಸ್ಯೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ."
            return {
                "diagnosis": error_response,
                "error": str(e)
            }
    
    async def diagnose_plant_disease(self, 
                                   image_base64: str,
                                   plant_type: str = "",
                                   symptoms: str = "") -> Dict[str, Any]:
        """
        Tool: Diagnose plant disease from image using Gemini Vision
        """
        try:
            # Convert base64 to image part
            image_data = base64.b64decode(image_base64)
            image_part = Part.from_data(image_data, mime_type="image/jpeg")
            
            # Create diagnosis prompt
            prompt = f"""
            ಈ ಸಸ್ಯದ ಚಿತ್ರವನ್ನು ವಿಶ್ಲೇಷಿಸಿ ಮತ್ತು ರೋಗ/ಕೀಟ ಸಮಸ್ಯೆಯನ್ನು ಗುರುತಿಸಿ:
            
            ಸಸ್ಯದ ವಿಧ: {plant_type or 'ತಿಳಿದಿಲ್ಲ'}
            ಲಕ್ಷಣಗಳು: {symptoms or 'ಯಾವುದೇ ಹೆಚ್ಚುವರಿ ವಿವರಣೆ ಇಲ್ಲ'}
            
            ದಯವಿಟ್ಟು JSON ಸ್ವರೂಪದಲ್ಲಿ ಉತ್ತರಿಸಿ:
            {{
                "disease_name": "ರೋಗದ ಹೆಸರು",
                "severity": "ತೀವ್ರತೆ (ಕಡಿಮೆ/ಮಧ್ಯಮ/ಹೆಚ್ಚು)",
                "treatment": ["ಚಿಕಿತ್ಸಾ ವಿಧಾನಗಳು"],
                "organic_remedies": ["ಸಾವಯವ ಪರಿಹಾರಗಳು"],
                "chemical_treatment": ["ರಾಸಾಯನಿಕ ಚಿಕಿತ್ಸೆ"],
                "prevention": ["ತಡೆಗಟ್ಟುವ ಕ್ರಮಗಳು"],
                "confidence": 0.9
            }}
            
            Analyze this plant image and identify disease/pest problems.
            Plant type: {plant_type or 'unknown'}
            Symptoms: {symptoms or 'no additional description'}
            
            Please respond in JSON format with disease diagnosis and treatment advice in Kannada.
            """
            
            # Generate response using Gemini Vision
            response = self.model.generate_content([prompt, image_part])
            
            # Parse JSON response
            try:
                result = json.loads(response.text.strip().replace('```json', '').replace('```', ''))
                return result
            except json.JSONDecodeError:
                # Fallback if JSON parsing fails
                return {
                    "disease_name": "ಸಸ್ಯ ಸಮಸ್ಯೆ ಪತ್ತೆಯಾಗಿದೆ",
                    "severity": "ಮಧ್ಯಮ",
                    "treatment": ["ಸ್ಥಳೀಯ ಕೃಷಿ ಅಧಿಕಾರಿಯನ್ನು ಸಂಪರ್ಕಿಸಿ"],
                    "confidence": 0.7
                }
                
        except Exception as e:
            logger.error(f"Disease diagnosis error: {str(e)}")
            return {
                "disease_name": "ರೋಗ ಗುರುತಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ",
                "severity": "ತಿಳಿದಿಲ್ಲ",
                "treatment": ["ಕೃಷಿ ತಜ್ಞರನ್ನು ಸಂಪರ್ಕಿಸಿ"],
                "confidence": 0.5,
                "error": str(e)
            }
    
    async def get_market_prices(self, 
                              commodity: str,
                              location: str = "Karnataka") -> Dict[str, Any]:
        """
        Tool: Get current market prices for agricultural commodities
        """
        try:
            commodity_lower = commodity.lower()
            if commodity_lower in self.mock_market_data:
                data = self.mock_market_data[commodity_lower]
                
                # Generate selling recommendation
                trend_num = float(data["trend"].replace("%", "").replace("+", ""))
                if trend_num > 5:
                    recommendation = "ಈಗ ಮಾರಾಟ ಮಾಡುವುದು ಉತ್ತಮ - ಬೆಲೆ ಹೆಚ್ಚಾಗಿದೆ"
                elif trend_num < -5:
                    recommendation = "ಇನ್ನು ಸ್ವಲ್ಪ ಕಾಯಿರಿ - ಬೆಲೆ ಇಳಿದಿದೆ"
                else:
                    recommendation = "ಸಾಮಾನ್ಯ ಬೆಲೆ - ನಿಮ್ಮ ಅಗತ್ಯ ಅನುಸಾರ ಮಾರಾಟ ಮಾಡಿ"
                
                return {
                    "commodity": commodity,
                    "current_price": data["price"],
                    "unit": "ಕ್ವಿಂಟಾಲ್",
                    "market": f"{location} ಮಂಡಿ",
                    "trend": data["trend"],
                    "last_week_price": data["last_week"],
                    "recommendation": recommendation,
                    "best_selling_time": "ಬೆಳಿಗ್ಗೆ 6-10 ಗಂಟೆಯ ನಡುವೆ",
                    "updated_at": "ಇಂದು ಬೆಳಿಗ್ಗೆ"
                }
            else:
                return {"error": "ಈ ಸರಕಿನ ಮಾಹಿತಿ ಲಭ್ಯವಿಲ್ಲ"}
                
        except Exception as e:
            logger.error(f"Market price error: {str(e)}")
            return {"error": f"ಮಾರುಕಟ್ಟೆ ಬೆಲೆ ಪಡೆಯುವಲ್ಲಿ ಸಮಸ್ಯೆ: {str(e)}"}
    
    async def search_government_schemes(self, 
                                      query: str,
                                      farmer_category: str = "small") -> Dict[str, Any]:
        """
        Tool: Search relevant government schemes and subsidies
        """
        try:
            # Simple keyword matching for MVP
            query_keywords = query.lower().split()
            relevant_schemes = []
            
            for scheme in self.government_schemes:
                scheme_text = f"{scheme['name']} {scheme['description']}".lower()
                if any(keyword in scheme_text for keyword in query_keywords):
                    relevant_schemes.append(scheme)
            
            if relevant_schemes:
                top_scheme = relevant_schemes[0]  # Return most relevant
                return {
                    "scheme_name": top_scheme["name"],
                    "description": top_scheme["description_kannada"],
                    "eligibility": top_scheme["eligibility_kannada"],
                    "benefits": top_scheme["benefits_kannada"],
                    "application_process": top_scheme["application_process_kannada"],
                    "required_documents": top_scheme["documents_kannada"],
                    "contact_info": top_scheme["contact_info"],
                    "online_link": top_scheme.get("application_link", ""),
                    "deadline": top_scheme.get("deadline", "ಯಾವುದೇ ನಿರ್ದಿಷ್ಟ ದಿನಾಂಕವಿಲ್ಲ")
                }
            else:
                return {"error": "ಸಂಬಂಧಿತ ಯೋಜನೆಗಳು ಸಿಗಲಿಲ್ಲ"}
                
        except Exception as e:
            logger.error(f"Scheme search error: {str(e)}")
            return {"error": f"ಯೋಜನೆ ಹುಡುಕುವಲ್ಲಿ ಸಮಸ್ಯೆ: {str(e)}"}
    
    async def _analyze_and_call_tools(self, message: str, user_context: Dict) -> Dict[str, Any]:
        """Analyze message and call appropriate tools"""
        tools_called = []
        results = {}
        
        message_lower = message.lower()
        
        # Check for market price queries
        if any(word in message_lower for word in ["ಬೆಲೆ", "price", "market", "ಮಾರುಕಟ್ಟೆ"]):
            # Extract commodity from message (simplified)
            for commodity in self.mock_market_data.keys():
                if commodity in message_lower:
                    price_result = await self.get_market_prices(commodity, user_context.get("location", "Karnataka"))
                    results["market_price"] = price_result
                    tools_called.append("get_market_prices")
                    break
        
        # Check for scheme queries
        if any(word in message_lower for word in ["ಯೋಜನೆ", "scheme", "subsidy", "ಅನುದಾನ"]):
            scheme_result = await self.search_government_schemes(message)
            results["government_scheme"] = scheme_result
            tools_called.append("search_government_schemes")
        
        return {
            "tools_called": tools_called,
            "results": results
        }
    
    def _build_prompt_with_context(self, message: str, tools_response: Dict, user_context: Dict) -> str:
        """Build comprehensive prompt with tool results"""
        prompt = f"ರೈತರ ಪ್ರಶ್ನೆ: {message}\n\n"
        
        if tools_response.get("results"):
            prompt += "ಲಭ್ಯವಿರುವ ಮಾಹಿತಿ:\n"
            
            if "market_price" in tools_response["results"]:
                market_data = tools_response["results"]["market_price"]
                if "error" not in market_data:
                    prompt += f"ಮಾರುಕಟ್ಟೆ ಬೆಲೆ: {market_data.get('current_price')} ರೂ/{market_data.get('unit')}\n"
                    prompt += f"ಪ್ರವೃತ್ತಿ: {market_data.get('trend')}\n"
                    prompt += f"ಶಿಫಾರಸು: {market_data.get('recommendation')}\n\n"
            
            if "government_scheme" in tools_response["results"]:
                scheme_data = tools_response["results"]["government_scheme"]
                if "error" not in scheme_data:
                    prompt += f"ಸಂಬಂಧಿತ ಯೋಜನೆ: {scheme_data.get('scheme_name')}\n"
                    prompt += f"ವಿವರಣೆ: {scheme_data.get('description')}\n\n"
        
        prompt += f"\nರೈತರ ಸ್ಥಳ: {user_context.get('location', 'ಕರ್ನಾಟಕ')}\n"
        prompt += "\nಕೃಪಯಾ ಸರಳ ಕನ್ನಡದಲ್ಲಿ ಸಹಾಯಕವಾದ ಉತ್ತರ ನೀಡಿ."
        
        return prompt
    
    async def _generate_gemini_response(self, prompt: str, chat_history: List) -> str:
        """Generate response using Gemini model"""
        try:
            # Create content with chat history
            contents = chat_history + [Content(role="user", parts=[Part.from_text(prompt)])]
            
            response = self.model.generate_content(contents)
            return response.text.strip()
            
        except Exception as e:
            logger.error(f"Gemini generation error: {str(e)}")
            return "ಕ್ಷಮಿಸಿ, ಪ್ರತಿಕ್ರಿಯೆ ರಚಿಸುವಲ್ಲಿ ಸಮಸ್ಯೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ."
    
    def _build_chat_history(self, conversation_history: List[Dict]) -> List[Content]:
        """Convert conversation history to Gemini format"""
        contents = []
        for msg in conversation_history[-10:]:  # Last 10 messages
            role = "model" if msg["role"] == "assistant" else "user"
            contents.append(Content(role=role, parts=[Part.from_text(msg["content"])]))
        return contents
    
    def _format_treatment_advice(self, diagnosis: Dict) -> str:
        """Format treatment advice in Kannada"""
        advice = []
        if diagnosis.get("organic_remedies"):
            advice.extend([f"• {remedy}" for remedy in diagnosis["organic_remedies"]])
        if diagnosis.get("chemical_treatment"):
            advice.extend([f"• {treatment}" for treatment in diagnosis["chemical_treatment"]])
        return "\n".join(advice) if advice else "ಸ್ಥಳೀಯ ಕೃಷಿ ಅಧಿಕಾರಿಯನ್ನು ಸಂಪರ್ಕಿಸಿ"
    
    def _format_prevention_tips(self, diagnosis: Dict) -> str:
        """Format prevention tips in Kannada"""
        tips = diagnosis.get("prevention", [])
        return "\n".join([f"• {tip}" for tip in tips]) if tips else "ಮುಂದಿನ ಬಾರಿ ಎಚ್ಚರಿಕೆ ವಹಿಸಿ"
    
    def _load_mock_market_data(self) -> Dict[str, Any]:
        """Load mock market price data"""
        return {
            "tomato": {"price": 3200, "trend": "+8%", "last_week": 2950},
            "onion": {"price": 1800, "trend": "-5%", "last_week": 1900},
            "rice": {"price": 2500, "trend": "+2%", "last_week": 2450},
            "wheat": {"price": 2200, "trend": "0%", "last_week": 2200},
            "potato": {"price": 1500, "trend": "+12%", "last_week": 1340},
            "chili": {"price": 8000, "trend": "-3%", "last_week": 8240}
        }
    
    def _load_government_schemes(self) -> List[Dict[str, Any]]:
        """Load government schemes data"""
        return [
            {
                "name": "PM-KISAN",
                "description": "Pradhan Mantri Kisan Samman Nidhi",
                "description_kannada": "ಪ್ರಧಾನಮಂತ್ರಿ ಕಿಸಾನ್ ಸಮ್ಮಾನ್ ನಿಧಿ - ವರ್ಷಕ್ಕೆ ₹6000 ನೇರ ಹಣ ವರ್ಗಾವಣೆ",
                "eligibility_kannada": ["2 ಹೆಕ್ಟೇರ್ ವರೆಗಿನ ಭೂಮಿ ಇರಬೇಕು", "ಆಧಾರ್ ಕಾರ್ಡ್ ಅಗತ್ಯ"],
                "benefits_kannada": ["ವರ್ಷಕ್ಕೆ ₹6000 ಮೂರು ಕಂತುಗಳಲ್ಲಿ"],
                "application_process_kannada": ["ಆನ್‌ಲೈನ್ pmkisan.gov.in ನಲ್ಲಿ ಅರ್ಜಿ", "ಸ್ಥಳೀಯ CSC ಸೆಂಟರ್‌ನಲ್ಲಿ"],
                "documents_kannada": ["ಆಧಾರ್ ಕಾರ್ಡ್", "ಭೂಮಿ ದಾಖಲೆಗಳು", "ಬ್ಯಾಂಕ್ ಪಾಸ್‌ಬುಕ್"],
                "contact_info": "ಟೋಲ್ ಫ್ರೀ: 155261 / 1800115526",
                "application_link": "https://pmkisan.gov.in"
            },
            {
                "name": "Drip Irrigation Subsidy",
                "description": "Micro Irrigation Scheme",
                "description_kannada": "ಡ್ರಿಪ್ ಇರಿಗೇಶನ್ ಅನುದಾನ - 90% ವರೆಗೆ ಸಬ್ಸಿಡಿ",
                "eligibility_kannada": ["ಯಾವುದೇ ಗಾತ್ರದ ರೈತರು", "ಭೂ ದಾಖಲೆಗಳು ಇರಬೇಕು"],
                "benefits_kannada": ["SC/ST: 90% ಸಬ್ಸಿಡಿ", "ಸಣ್ಣ ರೈತರು: 80% ಸಬ್ಸಿಡಿ", "ಇತರರು: 70% ಸಬ್ಸಿಡಿ"],
                "application_process_kannada": ["ಕೃಷಿ ಇಲಾಖೆಯಲ್ಲಿ ಅರ್ಜಿ", "ತಾಂತ್ರಿಕ ಮೌಲ್ಯಮಾಪನ"],
                "documents_kannada": ["ಭೂ ದಾಖಲೆಗಳು", "ಆಧಾರ್ ಕಾರ್ಡ್", "ಬ್ಯಾಂಕ್ ಪಾಸ್‌ಬುಕ್", "ಫೋಟೋ"],
                "contact_info": "ಜಿಲ್ಲಾ ಕೃಷಿ ಅಧಿಕಾರಿ"
            }
        ]
