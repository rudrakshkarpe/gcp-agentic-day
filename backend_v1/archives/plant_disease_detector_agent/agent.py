"""
Plant Disease Detection Agent using Google ADK
"""

from google.adk.agents import Agent
from typing import Dict, Any
import base64
import logging

from .prompt import PLANT_DISEASE_DETECTOR_INSTRUCTION, ERROR_MESSAGES, RESPONSE_TEMPLATES

logger = logging.getLogger(__name__)


class PlantDiseaseDetectorWrapper:
    """
    Wrapper for Plant Disease Detector ADK Agent
    """
    
    def __init__(self):
        """Initialize the Plant Disease Detector wrapper"""
        self.agent = plant_disease_detector
    
    async def analyze_plant_image(
        self,
        image_data: str,
        message: str,
        user_id: str,
        plant_type: str = "",
        symptoms: str = "",
        language: str = "kn"
    ) -> Dict[str, Any]:
        """
        Analyze plant image for disease detection using ADK agent
        
        Args:
            image_data: Base64 encoded image data
            message: User's message about the plant
            user_id: User identifier
            plant_type: Type of plant (optional)
            symptoms: Reported symptoms (optional)
            language: Response language (kn/hi/en)
            
        Returns:
            Dict containing diagnosis results
        """
        try:
            logger.info(f"Analyzing plant image for user: {user_id}")
            
            # Build the analysis prompt
            analysis_prompt = self._build_analysis_prompt(
                message, plant_type, symptoms, language
            )
            
            # In production, this would use the ADK agent's image analysis capabilities
            # For now, providing a structured mock response
            response_text = self._generate_diagnosis_response(language, plant_type)
            
            # Parse the response
            diagnosis_data = self._parse_diagnosis_response(response_text, language)
            
            return {
                "diagnosis": response_text,
                "disease_name": diagnosis_data.get("disease_name", "Leaf Spot Disease"),
                "severity": diagnosis_data.get("severity", "moderate"),
                "treatment": diagnosis_data.get("treatment", []),
                "organic_remedies": diagnosis_data.get("organic_remedies", []),
                "chemical_treatment": diagnosis_data.get("chemical_treatment", []),
                "prevention": diagnosis_data.get("prevention", []),
                "confidence": diagnosis_data.get("confidence", 0.85),
                "tools_used": ["plant_disease_detector"],
                "response": response_text
            }
            
        except Exception as e:
            logger.error(f"Plant disease analysis error: {str(e)}")
            error_msg = self._get_error_message(language)
            return {
                "diagnosis": error_msg,
                "error": str(e),
                "confidence": 0.0,
                "tools_used": ["plant_disease_detector"],
                "response": error_msg
            }
    
    def _build_analysis_prompt(
        self, 
        message: str, 
        plant_type: str, 
        symptoms: str, 
        language: str
    ) -> str:
        """
        Build the analysis prompt for image diagnosis
        """
        prompt_parts = [PLANT_DISEASE_DETECTOR_INSTRUCTION]
        
        if plant_type:
            prompt_parts.append(f"Plant Type: {plant_type}")
        
        if symptoms:
            prompt_parts.append(f"Reported Symptoms: {symptoms}")
        
        prompt_parts.append(f"User Message: {message}")
        
        # Language instruction
        language_instructions = {
            "kn": "Respond in Kannada. Provide diagnosis in clear, simple Kannada that farmers can understand.",
            "hi": "Respond in Hindi. Use simple Hindi that farmers can understand.",
            "en": "Respond in English. Use simple language that farmers can understand."
        }
        
        prompt_parts.append(language_instructions.get(language, language_instructions["en"]))
        
        return "\n\n".join(prompt_parts)
    
    def _generate_diagnosis_response(self, language: str, plant_type: str = "") -> str:
        """
        Generate a diagnosis response in the specified language
        """
        templates = RESPONSE_TEMPLATES.get(language, RESPONSE_TEMPLATES["en"])
        
        # Sample diagnosis response structure
        response = f"""
{templates['analysis_header']}

{templates['disease_detected']} Leaf Spot Disease
{templates['confidence']} High
{templates['severity']} Moderate

{templates['organic_treatment']}
- Apply neem oil spray (1:10 ratio with water)
- Use copper-based fungicide spray
- Remove affected leaves and dispose properly
- Improve air circulation around plants

{templates['chemical_treatment']}
- Mancozeb-based fungicide
- Follow manufacturer's dosage instructions

{templates['prevention']}
- Regular plant inspection
- Proper spacing between plants
- Avoid overhead watering
- Maintain soil drainage
        """
        
        # Add Kannada translation for local farmers
        if language == "kn":
            response += """

ಸಾವಯವ ಚಿಕಿತ್ಸೆಯ ವಿವರಗಳು:
- ಬೇವಿನ ಎಣ್ಣೆ ಸಿಂಪಿಸುವುದು (1:10 ಅನುಪಾತದಲ್ಲಿ ನೀರಿನೊಂದಿಗೆ)
- ತಾಮ್ರದ ಆಧಾರಿತ ಶಿಲೀಂಧ್ರನಾಶಕ
- ಬಾಧಿತ ಎಲೆಗಳನ್ನು ತೆಗೆದುಹಾಕಿ ಸರಿಯಾಗಿ ವಿಲೇವಾರಿ ಮಾಡಿ
- ಸಸ್ಯಗಳ ಸುತ್ತ ಗಾಳಿಯ ಪ್ರವಾಹವನ್ನು ಸುಧಾರಿಸಿ
            """
        
        return response.strip()
    
    def _parse_diagnosis_response(self, response_text: str, language: str) -> Dict[str, Any]:
        """
        Parse the diagnosis response into structured data
        """
        return {
            "disease_name": "Leaf Spot Disease",
            "severity": "moderate",
            "treatment": [
                "Apply neem oil spray",
                "Remove affected leaves",
                "Improve air circulation",
                "Use copper-based fungicide"
            ],
            "organic_remedies": [
                "Neem oil spray (1:10 ratio)",
                "Copper-based fungicide",
                "Remove affected parts",
                "Improve ventilation"
            ],
            "chemical_treatment": [
                "Mancozeb-based fungicide",
                "Follow manufacturer's instructions"
            ],
            "prevention": [
                "Regular plant inspection",
                "Proper plant spacing",
                "Avoid overhead watering",
                "Maintain soil drainage"
            ],
            "confidence": 0.85
        }
    
    def _get_error_message(self, language: str) -> str:
        """
        Get error message in appropriate language
        """
        return ERROR_MESSAGES.get(language, ERROR_MESSAGES["en"])


# Create the ADK agent for plant disease detection
plant_disease_detector = Agent(
    model="gemini-2.5-pro",
    name="plant_disease_detector_agent",
    description="Specialized agent for detecting and diagnosing plant diseases from images.",
    instruction=PLANT_DISEASE_DETECTOR_INSTRUCTION,
)

# Create wrapper instance
plant_disease_detector_wrapper = PlantDiseaseDetectorWrapper()
