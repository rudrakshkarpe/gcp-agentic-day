# Kisan Backend Setup Guide

## 🚀 Quick Start

Your backend is now configured with Google ADK agents and ready to run! Follow these steps:

## 📋 Prerequisites

✅ **GCP Project Setup** - Complete  
✅ **Environment Configuration** - Complete  
✅ **Dependencies** - Listed in pyproject.toml  

## 🔧 Setup Steps

### 1. **Download Service Account Key**
You need to download the actual service account key from GCP Cloud Shell:

```bash
# In GCP Cloud Shell, download the key
cloudshell download kisan-service-account-key.json
```

Then place it in your backend directory:
```
kisan-project/backend/
├── .env
├── kisan-service-account-key.json  ← This file
└── ... other files
```

### 2. **Install Dependencies**
```bash
cd kisan-project/backend
uv sync
```

### 3. **Test Configuration**
```bash
# Test your setup
python test_setup.py
```

### 4. **Run Backend**
```bash
# Development mode
uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 5. **Verify Setup**
Visit: http://localhost:8000/health

Expected response:
```json
{
  "status": "healthy",
  "services": {
    "ai_agent": "running",
    "speech_service": "running",
    "vertex_ai": "connected",
    "cloud_storage": "connected",
    "gemini_model": "gemini-2.5-pro"
  }
}
```

## 🧪 API Testing

### Text Message
```bash
curl -X POST "http://localhost:8000/api/chat/text" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "farmer123",
    "message": "ಟೊಮೇಟೊ ಬೆಲೆ ಎಷ್ಟು?",
    "language": "kn"
  }'
```

### Voice Message (with audio file)
```bash
curl -X POST "http://localhost:8000/api/chat/voice" \
  -F "audio=@test_audio.wav" \
  -F "user_id=farmer123" \
  -F "language=kn-IN"
```

### Image Analysis
```bash
curl -X POST "http://localhost:8000/api/chat/image" \
  -F "image=@plant_image.jpg" \
  -F "user_id=farmer123" \
  -F "plant_type=tomato" \
  -F "symptoms_description=yellow spots"
```

## 🚀 Deploy to Cloud Run

```bash
# Deploy to GCP
./deploy.sh
```

## 📁 File Structure

Your backend now has:

```
backend/
├── .env                           # Your GCP configuration
├── kisan-service-account-key.json # GCP credentials (download needed)
├── agents/
│   ├── kisan_agent/              # Main ADK agent
│   │   ├── agent.py              # KisanAgentWrapper
│   │   ├── prompt.py             # Main prompts
│   │   └── sub_agents/           # Specialized agents
│   │       ├── plant_disease_detector_agent/
│   │       ├── market_analyzer_agent/
│   │       └── government_schemes_agent/
│   └── tools/                    # Shared tools
│       ├── speech_tools.py
│       └── storage_tools.py
├── services/
│   ├── ai_service.py             # ADK integration
│   └── speech_service.py
├── config/
│   └── settings.py               # Enhanced configuration
└── main.py                       # FastAPI app
```

## 🔍 Troubleshooting

### Common Issues:

1. **Service Account Key Missing**
   ```
   Error: Could not load service account key
   ```
   → Download `kisan-service-account-key.json` from GCP Cloud Shell

2. **Import Errors**
   ```
   ModuleNotFoundError: No module named 'google.adk'
   ```
   → Run: `uv sync` to install dependencies

3. **GCP Authentication Error**
   ```
   Error: Could not authenticate with GCP
   ```
   → Verify your service account key is valid and in the right location

4. **Port Already in Use**
   ```
   Error: Port 8000 is already in use
   ```
   → Change port: `uv run uvicorn main:app --port 8001`

## 📊 Features Available

✅ **Multi-language Chat** (Kannada, Hindi, English)  
✅ **Plant Disease Detection** with image analysis  
✅ **Market Price Analysis** with recommendations  
✅ **Government Schemes** search and guidance  
✅ **Voice Interactions** (Speech-to-Text & Text-to-Speech)  
✅ **Real-time Responses** with Gemini 2.5 Pro  
✅ **Google ADK Integration** for specialized agents  

## 🎯 Next Steps

1. **Download Service Account Key** from GCP
2. **Run `uv sync`** to install dependencies
3. **Test with `python test_setup.py`**
4. **Start backend** with uvicorn
5. **Test API endpoints**
6. **Connect Flutter frontend**

Your Kisan AI backend is ready! 🌱🚀
