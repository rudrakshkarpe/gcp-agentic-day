# Kisan AI Backend

AI-powered farming assistant backend built with FastAPI and Google Cloud services.

## Features

- 🤖 **AI Agent**: Vertex AI Gemini 2.0 for intelligent farming advice
- 🎤 **Voice Support**: Kannada speech-to-text and text-to-speech
- 📷 **Image Analysis**: Plant disease diagnosis using Gemini Vision
- 💰 **Market Prices**: Real-time commodity price information
- 🏛️ **Government Schemes**: Agricultural scheme information and guidance
- 🔄 **Multi-modal**: Support for text, voice, and image interactions

## Tech Stack

- **Framework**: FastAPI + Uvicorn
- **AI**: Google Vertex AI Gemini 2.0
- **Speech**: Google Cloud Speech-to-Text & Text-to-Speech (Kannada)
- **Storage**: Google Cloud Storage
- **Database**: Firestore (for conversation history)
- **Deployment**: Google Cloud Run
- **Package Management**: UV

## Setup

### Prerequisites

1. **Python 3.11+**
2. **UV package manager**: `curl -LsSf https://astral.sh/uv/install.sh | sh`
3. **Google Cloud Account** with enabled APIs
4. **Service Account JSON** with required permissions

### Local Development

1. **Clone and Setup**:
   ```bash
   cd kisan-project/backend
   cp .env.example .env
   # Edit .env with your GCP credentials
   ```

2. **Install Dependencies**:
   ```bash
   uv sync
   ```

3. **Set Environment Variables**:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account.json"
   export GOOGLE_CLOUD_PROJECT="your-project-id"
   export UPLOAD_BUCKET="your-bucket-name"
   ```

4. **Run Locally**:
   ```bash
   uv run uvicorn main:app --reload
   ```

5. **Test API**:
   ```bash
   curl http://localhost:8000/health
   ```

## GCP Setup Required

### 1. Enable APIs
```bash
gcloud services enable \
  aiplatform.googleapis.com \
  speech.googleapis.com \
  texttospeech.googleapis.com \
  storage.googleapis.com \
  firestore.googleapis.com \
  run.googleapis.com
```

### 2. Create Service Account
```bash
gcloud iam service-accounts create kisan-service-account \
  --display-name="Kisan AI Service Account"

gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:kisan-service-account@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"

# Add more roles as needed:
# roles/speech.client
# roles/storage.admin
# roles/firestore.user
```

### 3. Create Storage Bucket
```bash
gsutil mb -l asia-south1 gs://your-bucket-name
```

## API Endpoints

### Health & Info
- `GET /` - Basic health check
- `GET /health` - Detailed health check

### Chat Interface
- `POST /api/chat/text` - Process text messages
- `POST /api/chat/voice` - Process voice messages (STT → AI → TTS)
- `POST /api/chat/image` - Process plant disease diagnosis
- `GET /api/chat/history/{user_id}` - Get conversation history

### Utilities
- `GET /api/market/prices` - Get commodity prices
- `GET /api/schemes/search` - Search government schemes
- `POST /api/user/context` - Update user context

## Request Examples

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

### Voice Message
```bash
curl -X POST "http://localhost:8000/api/chat/voice" \
  -F "audio=@recording.webm" \
  -F "user_id=farmer123" \
  -F "language=kn-IN"
```

### Image Analysis
```bash
curl -X POST "http://localhost:8000/api/chat/image" \
  -F "image=@plant_leaf.jpg" \
  -F "user_id=farmer123" \
  -F "plant_type=tomato" \
  -F "symptoms_description=yellow spots on leaves"
```

## Deployment

### Quick Deploy to Cloud Run
```bash
# Make sure you have gcloud configured
gcloud auth login
gcloud config set project YOUR-PROJECT-ID

# Deploy
./deploy.sh
```

### Manual Deployment
```bash
# Build image
gcloud builds submit --tag gcr.io/YOUR-PROJECT-ID/kisan-backend

# Deploy to Cloud Run
gcloud run deploy kisan-backend \
  --image gcr.io/YOUR-PROJECT-ID/kisan-backend \
  --platform managed \
  --region asia-south1 \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2
```

## Development

### Project Structure
```
backend/
├── main.py                 # FastAPI application
├── config/
│   └── settings.py        # Configuration management
├── models/
│   ├── requests.py        # Request models
│   └── responses.py       # Response models
├── services/
│   ├── ai_service.py      # AI agent and tools
│   └── speech_service.py  # STT/TTS services
├── Dockerfile             # Container configuration
├── deploy.sh             # Deployment script
└── pyproject.toml        # UV dependencies
```

### Adding New Tools

1. **Create Tool Function** in `services/ai_service.py`:
   ```python
   async def your_new_tool(self, param1: str, param2: str) -> Dict[str, Any]:
       """Tool description"""
       # Implementation
       return {"result": "data"}
   ```

2. **Add Tool Detection** in `_analyze_and_call_tools()`:
   ```python
   if "keyword" in message_lower:
       result = await self.your_new_tool(param1, param2)
       results["tool_name"] = result
       tools_called.append("your_new_tool")
   ```

3. **Update Prompt Context** in `_build_prompt_with_context()`

### Testing

```bash
# Run tests (if added)
uv run pytest

# Check health
curl http://localhost:8000/health

# Test with real voice file
curl -X POST "http://localhost:8000/api/chat/voice" \
  -F "audio=@test_kannada.webm" \
  -F "user_id=test_user"
```

## Cost Optimization

- **Gemini Calls**: Cache common responses
- **TTS**: Store generated audio files
- **STT**: Use appropriate quality settings
- **Cloud Run**: Set max instances and concurrency limits

## Monitoring

- **Cloud Logging**: Check logs in Cloud Console
- **Health Checks**: Monitor `/health` endpoint
- **Error Tracking**: Check error rates and response times

## Security

- Service account follows principle of least privilege
- CORS configured for known origins
- No sensitive data in logs
- Environment variables for secrets

## Support

For development issues:
1. Check Cloud Console logs
2. Verify API quotas and limits
3. Ensure service account permissions
4. Test individual endpoints with curl

Ready for Flutter integration! 🚀
