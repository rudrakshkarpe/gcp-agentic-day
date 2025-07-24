"""
Prompts for Market Analyzer Agent
"""

MARKET_ANALYZER_INSTRUCTION = """
You are a market analysis agent specializing in agricultural commodity prices and trends.

Your responsibilities:
1. Provide current market prices for crops and agricultural products
2. Analyze price trends and forecasts
3. Suggest optimal selling times
4. Compare prices across different markets/locations
5. Advise on crop selection based on market demand

When providing market information:
- Include current prices from reliable sources
- Mention price variations by location when relevant
- Provide context about seasonal price patterns
- Suggest strategies for better price realization
- Consider transportation and storage costs
- Advise on quality requirements that affect pricing

Response should include:
- Current market prices (wholesale/retail)
- Price trend (increasing/stable/decreasing)
- Best selling locations/markets
- Quality factors affecting price
- Timing recommendations
- Storage and transportation advice

Always respond in the farmer's preferred language and provide actionable market insights.
Consider the farmer's location and scale of operation when giving advice.
"""

# Language-specific error messages
ERROR_MESSAGES = {
    "kn": "ಮಾರುಕಟ್ಟೆ ಬೆಲೆ ಮಾಹಿತಿ ಪಡೆಯುವಲ್ಲಿ ದೋಷ ಸಂಭವಿಸಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.",
    "hi": "बाजार मूल्य जानकारी प्राप्त करने में त्रुटि हुई। कृपया पुनः प्रयास करें।",
    "en": "Error getting market price information. Please try again."
}

# Response templates for different languages
RESPONSE_TEMPLATES = {
    "kn": {
        "market_header": "ಮಾರುಕಟ್ಟೆ ವಿಶ್ಲೇಷಣೆ:",
        "current_price": "ಪ್ರಸ್ತುತ ಬೆಲೆ:",
        "price_trend": "ಬೆಲೆ ಪ್ರವೃತ್ತಿ:",
        "best_markets": "ಉತ್ತಮ ಮಾರುಕಟ್ಟೆಗಳು:",
        "quality_factors": "ಗುಣಮಟ್ಟದ ಅಂಶಗಳು:",
        "selling_advice": "ಮಾರಾಟದ ಸಲಹೆ:",
        "storage_tips": "ಶೇಖರಣಾ ಸಲಹೆಗಳು:"
    },
    "hi": {
        "market_header": "बाजार विश्लेषण:",
        "current_price": "वर्तमान मूल्य:",
        "price_trend": "मूल्य प्रवृत्ति:",
        "best_markets": "सर्वोत्तम बाजार:",
        "quality_factors": "गुणवत्ता कारक:",
        "selling_advice": "बिक्री सलाह:",
        "storage_tips": "भंडारण सुझाव:"
    },
    "en": {
        "market_header": "Market Analysis:",
        "current_price": "Current Price:",
        "price_trend": "Price Trend:",
        "best_markets": "Best Markets:",
        "quality_factors": "Quality Factors:",
        "selling_advice": "Selling Advice:",
        "storage_tips": "Storage Tips:"
    }
}

# Sample commodity data for common crops
COMMODITY_DATA = {
    "tomato": {
        "kn": "ಟೊಮೇಟೊ",
        "hi": "टमाटर",
        "en": "Tomato"
    },
    "onion": {
        "kn": "ಈರುಳ್ಳಿ",
        "hi": "प्याज",
        "en": "Onion"
    },
    "potato": {
        "kn": "ಆಲೂಗಡ್ಡೆ",
        "hi": "आलू",
        "en": "Potato"
    },
    "rice": {
        "kn": "ಅಕ್ಕಿ",
        "hi": "चावल",
        "en": "Rice"
    },
    "wheat": {
        "kn": "ಗೋಧಿ",
        "hi": "गेहूं",
        "en": "Wheat"
    }
}
