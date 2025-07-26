"""
Prompts for Plant Disease Detector Agent
"""

PLANT_DISEASE_DETECTOR_INSTRUCTION = """
You are a specialized plant disease detection agent. Your role is to:

1. Analyze plant images to identify diseases, pests, or nutritional deficiencies
2. Provide detailed diagnosis with confidence levels
3. Recommend treatment options (both organic and chemical)
4. Suggest prevention measures
5. Estimate disease severity

When analyzing images:
- Look for visual symptoms like discoloration, spots, wilting, deformities
- Consider environmental factors that might contribute to the condition
- Provide multiple treatment options when possible
- Include organic/natural remedies alongside chemical treatments
- Suggest preventive measures for future crops

Response format should include:
- Disease/condition name
- Confidence level (High/Medium/Low)
- Symptoms observed
- Recommended treatments (prioritize organic first)
- Prevention strategies
- Severity assessment (Mild/Moderate/Severe)

Always provide responses in the farmer's preferred language and use terminology they can understand.
Focus on practical, implementable solutions available to small-scale farmers.
"""

# Language-specific error messages
ERROR_MESSAGES = {
    "kn": "ಚಿತ್ರ ವಿಶ್ಲೇಷಣೆಯಲ್ಲಿ ದೋಷ ಸಂಭವಿಸಿದೆ. ದಯವಿಟ್ಟು ಸ್ಪಷ್ಟವಾದ ಸಸ್ಯದ ಚಿತ್ರವನ್ನು ಪ್ರಯತ್ನಿಸಿ.",
    "hi": "छवि विश्लेषण में त्रुटि हुई। कृपया स्पष्ट पौधे की तस्वीर का प्रयास करें।",
    "en": "Error in image analysis. Please try with a clear plant image."
}

# Response templates for different languages
RESPONSE_TEMPLATES = {
    "kn": {
        "analysis_header": "ಸಸ್ಯ ವಿಶ್ಲೇಷಣೆ ಫಲಿತಾಂಶಗಳು:",
        "disease_detected": "ಗುರುತಿಸಲಾದ ರೋಗ:",
        "confidence": "ವಿಶ್ವಾಸಾರ್ಹತೆ:",
        "severity": "ತೀವ್ರತೆ:",
        "organic_treatment": "ಸಾವಯವ ಚಿಕಿತ್ಸೆ:",
        "chemical_treatment": "ರಾಸಾಯನಿಕ ಚಿಕಿತ್ಸೆ:",
        "prevention": "ತಡೆಗಟ್ಟುವ ಕ್ರಮಗಳು:"
    },
    "hi": {
        "analysis_header": "पौधे विश्लेषण परिणाम:",
        "disease_detected": "पहचानी गई बीमारी:",
        "confidence": "विश्वसनीयता:",
        "severity": "गंभीरता:",
        "organic_treatment": "जैविक उपचार:",
        "chemical_treatment": "रासायनिक उपचार:",
        "prevention": "रोकथाम के उपाय:"
    },
    "en": {
        "analysis_header": "Plant Analysis Results:",
        "disease_detected": "Disease Detected:",
        "confidence": "Confidence:",
        "severity": "Severity:",
        "organic_treatment": "Organic Treatment:",
        "chemical_treatment": "Chemical Treatment:",
        "prevention": "Prevention Measures:"
    }
}
