"""
Government Schemes Agent using Google ADK
"""

from google.adk.agents import Agent
from typing import Dict, Any, List
import logging
from datetime import datetime

from .prompt import GOVERNMENT_SCHEMES_INSTRUCTION, ERROR_MESSAGES, RESPONSE_TEMPLATES, SAMPLE_SCHEMES

logger = logging.getLogger(__name__)


class GovernmentSchemesWrapper:
    """
    Wrapper for Government Schemes ADK Agent
    """
    
    def __init__(self):
        """Initialize the Government Schemes wrapper"""
        self.agent = government_schemes
    
    async def search_government_schemes(
        self,
        query: str,
        farmer_category: str = "small",
        location: str = "Karnataka",
        language: str = "kn"
    ) -> Dict[str, Any]:
        """
        Search for relevant government schemes
        
        Args:
            query: User's query about schemes
            farmer_category: Category of farmer (small/marginal/large)
            location: Location for region-specific schemes
            language: Response language (kn/hi/en)
            
        Returns:
            Dict containing relevant schemes information
        """
        try:
            logger.info(f"Searching schemes for query: {query}, category: {farmer_category}")
            
            # Generate schemes response
            response_text = self._generate_schemes_response(query, farmer_category, location, language)
            
            # Parse relevant schemes
            schemes_data = self._parse_schemes_response(query, farmer_category, language)
            
            return {
                "response": response_text,
                "query": query,
                "farmer_category": farmer_category,
                "location": location,
                "schemes": schemes_data.get("schemes", []),
                "total_schemes": len(schemes_data.get("schemes", [])),
                "tools_used": ["government_schemes"],
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Government schemes search error: {str(e)}")
            error_msg = self._get_error_message(language)
            return {
                "response": error_msg,
                "error": str(e),
                "tools_used": ["government_schemes"],
                "timestamp": datetime.now().isoformat()
            }
    
    def _generate_schemes_response(self, query: str, farmer_category: str, location: str, language: str) -> str:
        """
        Generate government schemes response in the specified language
        """
        templates = RESPONSE_TEMPLATES.get(language, RESPONSE_TEMPLATES["en"])
        
        # Sample schemes response
        response = f"""
{templates['schemes_header']}

{location} - {farmer_category.title()} ಕೃಷಿಕರಿಗಾಗಿ

1. {self._get_scheme_name("pm_kisan", language)}
   {templates['benefits']} ₹6000 ವಾರ್ಷಿಕ (₹2000 x 3 ಕಿಸ್ತುಗಳಲ್ಲಿ)
   {templates['eligibility']} 2 ಹೆಕ್ಟೇರ್‌ವರೆಗಿನ ಭೂಮಿ ಹೊಂದಿರುವ ಕೃಷಿಕರು
   {templates['application_process']}
   - ಆನ್‌ಲೈನ್: pmkisan.gov.in ನಲ್ಲಿ ನೋಂದಣಿ
   - ಆಫ್‌ಲೈನ್: ಹತ್ತಿರದ CSC ಕೇಂದ್ರದಲ್ಲಿ
   {templates['required_documents']}
   - ಆಧಾರ್ ಕಾರ್ಡ್
   - ಬ್ಯಾಂಕ್ ಪಾಸ್‌ಬುಕ್
   - ಭೂಮಿ ದಾಖಲೆಗಳು

2. {self._get_scheme_name("fasal_bima", language)}
   {templates['benefits']} ಬೆಳೆ ನಷ್ಟಕ್ಕೆ ವಿಮಾ ರಕ್ಷಣೆ
   {templates['eligibility']} ಎಲ್ಲಾ ಕೃಷಿಕರು (ಭೂಮಿ ಮಾಲೀಕರು ಮತ್ತು ಬಾಡಿಗೆದಾರರು)
   ಪ್ರೀಮಿಯಂ: ಖರೀಫ್ 2%, ರಬಿ 1.5%, ತೋಟಗಾರಿಕೆ 5%

3. {self._get_scheme_name("kisan_credit", language)}
   {templates['benefits']} ಕೃಷಿ ಸಾಲ ಸೌಲಭ್ಯ (ಕಡಿಮೆ ಬಡ್ಡಿ ದರದಲ್ಲಿ)
   {templates['eligibility']} ಭೂಮಿ ದಾಖಲೆಗಳಿರುವ ಎಲ್ಲಾ ಕೃಷಿಕರು
   ಸಾಲದ ಮಿತಿ: ₹3 ಲಕ್ಷ ವರೆಗೆ (ಭೂಮಿಯ ಮೇರೆಗೆ)

{templates['contact_info']}
{templates['helpline']} 155261 (PM-Kisan), 14447 (Crop Insurance)
ವೆಬ್‌ಸೈಟ್: pmkisan.gov.in, pmfby.gov.in

{templates['deadline']}
- PM-Kisan: ಯಾವುದೇ ಸಮಯದಲ್ಲಿ ಅರ್ಜಿ ಸಲ್ಲಿಸಬಹುದು
- ಫಸಲ್ ಬೀಮಾ: ಬಿತ್ತನೆಯ 7 ದಿನಗಳಲ್ಲಿ
        """
        
        # Add additional language-specific content
        if language == "kn":
            response += """

ಹೆಚ್ಚುವರಿ ಸಲಹೆಗಳು:
- ಅರ್ಜಿ ಸಲ್ಲಿಸುವ ಮೊದಲು ಎಲ್ಲಾ ದಾಖಲೆಗಳನ್ನು ಸಿದ್ಧಗೊಳಿಸಿ
- ಸರ್ಕಾರಿ ಕಚೇರಿಗಳಿಂದ ಮಾತ್ರ ಅರ್ಜಿ ಸಲ್ಲಿಸಿ
- ನಕಲಿ ಏಜೆಂಟ್‌ಗಳಿಂದ ಎಚ್ಚರಿಕೆ ವಹಿಸಿ
- ಯಾವುದೇ ಶುಲ್ಕ ಪಾವತಿಸದೆ ಅರ್ಜಿ ಸಲ್ಲಿಸಬಹುದು
            """
        
        return response.strip()
    
    def _parse_schemes_response(self, query: str, farmer_category: str, language: str) -> Dict[str, Any]:
        """
        Parse schemes response into structured data
        """
        schemes = []
        
        # Add relevant schemes based on query and category
        if "kisan" in query.lower() or "money" in query.lower():
            schemes.append({
                "id": "pm_kisan",
                "name": self._get_scheme_name("pm_kisan", language),
                "benefit": "₹6000 per year",
                "eligibility": "Small and marginal farmers (up to 2 hectares)",
                "website": "pmkisan.gov.in",
                "helpline": "155261",
                "priority": "high"
            })
        
        if "insurance" in query.lower() or "bima" in query.lower():
            schemes.append({
                "id": "fasal_bima",
                "name": self._get_scheme_name("fasal_bima", language),
                "benefit": "Crop insurance coverage",
                "eligibility": "All farmers",
                "website": "pmfby.gov.in",
                "helpline": "14447",
                "priority": "high"
            })
        
        if "loan" in query.lower() or "credit" in query.lower():
            schemes.append({
                "id": "kisan_credit",
                "name": self._get_scheme_name("kisan_credit", language),
                "benefit": "Credit facility up to ₹3 lakhs",
                "eligibility": "Farmers with land documents",
                "website": "kcc.gov.in",
                "helpline": "1800-180-1551",
                "priority": "medium"
            })
        
        # If no specific schemes match, return all major schemes
        if not schemes:
            schemes = [
                {
                    "id": "pm_kisan",
                    "name": self._get_scheme_name("pm_kisan", language),
                    "benefit": "₹6000 per year",
                    "eligibility": "Small and marginal farmers",
                    "website": "pmkisan.gov.in",
                    "helpline": "155261",
                    "priority": "high"
                },
                {
                    "id": "fasal_bima",
                    "name": self._get_scheme_name("fasal_bima", language),
                    "benefit": "Crop insurance coverage",
                    "eligibility": "All farmers",
                    "website": "pmfby.gov.in",
                    "helpline": "14447",
                    "priority": "high"
                },
                {
                    "id": "kisan_credit",
                    "name": self._get_scheme_name("kisan_credit", language),
                    "benefit": "Credit facility",
                    "eligibility": "Farmers with land documents",
                    "website": "kcc.gov.in",
                    "helpline": "1800-180-1551",
                    "priority": "medium"
                }
            ]
        
        return {"schemes": schemes}
    
    def _get_scheme_name(self, scheme_id: str, language: str) -> str:
        """
        Get scheme name in the specified language
        """
        scheme_data = SAMPLE_SCHEMES.get(scheme_id, {})
        name_data = scheme_data.get("name", {})
        return name_data.get(language, scheme_id.replace("_", " ").title())
    
    def _get_error_message(self, language: str) -> str:
        """
        Get error message in appropriate language
        """
        return ERROR_MESSAGES.get(language, ERROR_MESSAGES["en"])


# Create the ADK agent for government schemes
government_schemes = Agent(
    model="gemini-2.5-pro",
    name="government_schemes_agent",
    description="Specialized agent for helping farmers access government schemes and support programs.",
    instruction=GOVERNMENT_SCHEMES_INSTRUCTION,
)

# Create wrapper instance
government_schemes_wrapper = GovernmentSchemesWrapper()
