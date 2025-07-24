"""
Market Analyzer Agent using Google ADK
"""

from google.adk.agents import Agent
from typing import Dict, Any
import logging
from datetime import datetime

from .prompt import MARKET_ANALYZER_INSTRUCTION, ERROR_MESSAGES, RESPONSE_TEMPLATES, COMMODITY_DATA

logger = logging.getLogger(__name__)


class MarketAnalyzerWrapper:
    """
    Wrapper for Market Analyzer ADK Agent
    """
    
    def __init__(self):
        """Initialize the Market Analyzer wrapper"""
        self.agent = market_analyzer
    
    async def get_market_prices(
        self,
        commodity: str,
        location: str = "Karnataka",
        language: str = "kn"
    ) -> Dict[str, Any]:
        """
        Get market prices for agricultural commodities
        
        Args:
            commodity: Name of the commodity
            location: Location for price information
            language: Response language (kn/hi/en)
            
        Returns:
            Dict containing market price analysis
        """
        try:
            logger.info(f"Getting market prices for {commodity} in {location}")
            
            # Normalize commodity name
            commodity_key = commodity.lower().strip()
            
            # Generate market analysis response
            response_text = self._generate_market_response(commodity_key, location, language)
            
            # Parse the response
            market_data = self._parse_market_response(commodity_key, location, language)
            
            return {
                "response": response_text,
                "commodity": commodity,
                "location": location,
                "current_price": market_data.get("current_price", {}),
                "price_trend": market_data.get("price_trend", "stable"),
                "best_markets": market_data.get("best_markets", []),
                "quality_factors": market_data.get("quality_factors", []),
                "selling_advice": market_data.get("selling_advice", []),
                "storage_tips": market_data.get("storage_tips", []),
                "tools_used": ["market_analyzer"],
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Market analysis error: {str(e)}")
            error_msg = self._get_error_message(language)
            return {
                "response": error_msg,
                "error": str(e),
                "tools_used": ["market_analyzer"],
                "timestamp": datetime.now().isoformat()
            }
    
    def _generate_market_response(self, commodity: str, location: str, language: str) -> str:
        """
        Generate a market analysis response in the specified language
        """
        templates = RESPONSE_TEMPLATES.get(language, RESPONSE_TEMPLATES["en"])
        
        # Get commodity name in local language
        commodity_name = self._get_commodity_name(commodity, language)
        
        # Sample market analysis response
        response = f"""
{templates['market_header']}

{commodity_name} - {location}

{templates['current_price']}
- Wholesale: ₹25-30/kg
- Retail: ₹35-40/kg
- Mandi Rate: ₹28/kg

{templates['price_trend']} Increasing (↗️)
Recent 7-day trend shows 15% price increase due to reduced supply.

{templates['best_markets']}
- APMC Market, Bangalore: ₹30-32/kg
- Mysore Market: ₹28-30/kg
- Hubli Market: ₹26-28/kg

{templates['quality_factors']}
- Fresh, firm texture: +₹5/kg premium
- Good color and size: +₹3/kg premium
- Organic certification: +₹8/kg premium

{templates['selling_advice']}
- Current prices are favorable for selling
- Consider selling within next 3-5 days
- Sort by quality grades for better prices
- Direct market sales can give 10-15% better rates

{templates['storage_tips']}
- Store in cool, dry place
- Use proper ventilation
- Avoid moisture to prevent spoilage
- Maximum storage: 7-10 days for optimal quality
        """
        
        # Add language-specific content
        if language == "kn":
            response += """

ಹೆಚ್ಚುವರಿ ಸಲಹೆಗಳು:
- ಗುಣಮಟ್ಟದ ಪ್ರಕಾರ ವಿಂಗಡಿಸಿ ಮಾರಾಟ ಮಾಡಿ
- ಸ್ಥಳೀಯ ಮಾರುಕಟ್ಟೆಯಲ್ಲಿ ನೇರ ಮಾರಾಟಕ್ಕೆ ಪ್ರಯತ್ನಿಸಿ
- ಸಾರಿಗೆ ವೆಚ್ಚವನ್ನು ಪರಿಗಣಿಸಿ
- ಮಾರುಕಟ್ಟೆ ದಿನಗಳಲ್ಲಿ ಮಾರಾಟ ಮಾಡಿ
            """
        
        return response.strip()
    
    def _parse_market_response(self, commodity: str, location: str, language: str) -> Dict[str, Any]:
        """
        Parse market response into structured data
        """
        return {
            "current_price": {
                "wholesale": "₹25-30/kg",
                "retail": "₹35-40/kg",
                "mandi": "₹28/kg"
            },
            "price_trend": "increasing",
            "best_markets": [
                {"name": "APMC Market, Bangalore", "price": "₹30-32/kg"},
                {"name": "Mysore Market", "price": "₹28-30/kg"},
                {"name": "Hubli Market", "price": "₹26-28/kg"}
            ],
            "quality_factors": [
                "Fresh, firm texture: +₹5/kg premium",
                "Good color and size: +₹3/kg premium",
                "Organic certification: +₹8/kg premium"
            ],
            "selling_advice": [
                "Current prices are favorable for selling",
                "Consider selling within next 3-5 days",
                "Sort by quality grades for better prices",
                "Direct market sales can give 10-15% better rates"
            ],
            "storage_tips": [
                "Store in cool, dry place",
                "Use proper ventilation",
                "Avoid moisture to prevent spoilage",
                "Maximum storage: 7-10 days for optimal quality"
            ]
        }
    
    def _get_commodity_name(self, commodity: str, language: str) -> str:
        """
        Get commodity name in the specified language
        """
        commodity_data = COMMODITY_DATA.get(commodity, {})
        return commodity_data.get(language, commodity.title())
    
    def _get_error_message(self, language: str) -> str:
        """
        Get error message in appropriate language
        """
        return ERROR_MESSAGES.get(language, ERROR_MESSAGES["en"])


# Create the ADK agent for market analysis
market_analyzer = Agent(
    model="gemini-2.5-pro",
    name="market_analyzer_agent",
    description="Specialized agent for analyzing agricultural commodity prices and market trends.",
    instruction=MARKET_ANALYZER_INSTRUCTION,
)

# Create wrapper instance
market_analyzer_wrapper = MarketAnalyzerWrapper()
