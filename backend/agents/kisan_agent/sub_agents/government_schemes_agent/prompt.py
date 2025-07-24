"""
Prompts for Government Schemes Agent
"""

GOVERNMENT_SCHEMES_INSTRUCTION = """
You are a government schemes specialist agent that helps farmers access relevant support programs.

Your role includes:
1. Identifying applicable government schemes based on farmer profile
2. Explaining eligibility criteria and application processes
3. Helping with required documentation
4. Providing contact information for local offices
5. Tracking application status when possible

Focus areas:
- Subsidies for seeds, fertilizers, equipment
- Crop insurance schemes
- Loan and credit facilities
- Training and skill development programs
- Direct benefit transfer schemes
- Organic farming certifications
- Solar pump subsidies
- Soil health programs

When recommending schemes:
- Match schemes to farmer's specific needs (crop type, land size, category)
- Explain eligibility clearly in simple terms
- Provide step-by-step application guidance
- Include relevant deadlines and timelines
- Suggest local contacts for assistance
- Mention required documents upfront
- Provide helpline numbers and websites

Response should include:
- Relevant scheme names and benefits
- Eligibility criteria
- Application process steps
- Required documents
- Contact information (helplines, websites, local offices)
- Timeline and deadlines

Always respond in the farmer's preferred language and break down complex procedures into simple steps.
Prioritize schemes most relevant to the farmer's category (small/marginal/large) and location.
"""

# Language-specific error messages
ERROR_MESSAGES = {
    "kn": "ಸರ್ಕಾರಿ ಯೋಜನೆಗಳ ಮಾಹಿತಿ ಪಡೆಯುವಲ್ಲಿ ದೋಷ ಸಂಭವಿಸಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.",
    "hi": "सरकारी योजनाओं की जानकारी प्राप्त करने में त्रुटि हुई। कृपया पुनः प्रयास करें।",
    "en": "Error getting government schemes information. Please try again."
}

# Response templates for different languages
RESPONSE_TEMPLATES = {
    "kn": {
        "schemes_header": "ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು:",
        "eligibility": "ಅರ್ಹತೆ:",
        "benefits": "ಪ್ರಯೋಜನಗಳು:",
        "application_process": "ಅರ್ಜಿ ಪ್ರಕ್ರಿಯೆ:",
        "required_documents": "ಅಗತ್ಯ ದಾಖಲೆಗಳು:",
        "contact_info": "ಸಂಪರ್ಕ ಮಾಹಿತಿ:",
        "deadline": "ಅಂತಿಮ ದಿನಾಂಕ:",
        "helpline": "ಸಹಾಯವಾಣಿ:"
    },
    "hi": {
        "schemes_header": "सरकारी योजनाएं:",
        "eligibility": "पात्रता:",
        "benefits": "लाभ:",
        "application_process": "आवेदन प्रक्रिया:",
        "required_documents": "आवश्यक दस्तावेज:",
        "contact_info": "संपर्क जानकारी:",
        "deadline": "अंतिम तिथि:",
        "helpline": "हेल्पलाइन:"
    },
    "en": {
        "schemes_header": "Government Schemes:",
        "eligibility": "Eligibility:",
        "benefits": "Benefits:",
        "application_process": "Application Process:",
        "required_documents": "Required Documents:",
        "contact_info": "Contact Information:",
        "deadline": "Deadline:",
        "helpline": "Helpline:"
    }
}

# Sample scheme data
SAMPLE_SCHEMES = {
    "pm_kisan": {
        "name": {
            "kn": "ಪ್ರಧಾನಮಂತ್ರಿ ಕಿಸಾನ್ ಸಮ್ಮಾನ್ ನಿಧಿ",
            "hi": "प्रधानमंत्री किसान सम्मान निधि",
            "en": "PM Kisan Samman Nidhi"
        },
        "benefit": "₹6000 per year",
        "eligibility": "Small and marginal farmers",
        "website": "pmkisan.gov.in"
    },
    "fasal_bima": {
        "name": {
            "kn": "ಪ್ರಧಾನಮಂತ್ರಿ ಫಸಲ್ ಬೀಮಾ ಯೋಜನೆ",
            "hi": "प्रधानमंत्री फसल बीमा योजना",
            "en": "PM Fasal Bima Yojana"
        },
        "benefit": "Crop insurance coverage",
        "eligibility": "All farmers",
        "website": "pmfby.gov.in"
    },
    "kisan_credit": {
        "name": {
            "kn": "ಕಿಸಾನ್ ಕ್ರೆಡಿಟ್ ಕಾರ್ಡ್",
            "hi": "किसान क्रेडिट कार्ड",
            "en": "Kisan Credit Card"
        },
        "benefit": "Credit facility for farming",
        "eligibility": "All farmers with land documents",
        "website": "kcc.gov.in"
    }
}
