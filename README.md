# Kisan Kavach - AI-Powered Farming Assistant

Kisan Kavach is an intelligent farming assistant built with Google Cloud's Agent Development Kit (ADK) and Flutter. It provides farmers with AI-powered support for crop health monitoring, government scheme recommendations, market analysis, and weather information through voice and visual interactions in local languages.

## Project Demo

<!-- Add your project demo GIF here -->
![Kisan Kavach Demo](./assets/demo.gif)

<!-- Add screenshots of the mobile app -->
![Mobile App Screenshots](./assets/app-screenshots.png)

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Backend Setup](#backend-setup)
- [Frontend Setup](#frontend-setup)
- [Agent System](#agent-system)
- [API Documentation](#api-documentation)
- [Deployment](#deployment)
- [Development Guide](#development-guide)
- [Troubleshooting](#troubleshooting)

## Overview

Kisan Kavach leverages cutting-edge AI technology to assist farmers with:

- **Plant Disease Detection**: Upload crop images to identify diseases and get treatment recommendations
- **Government Schemes**: Find relevant agricultural schemes and subsidies
- **Market Analysis**: Get real-time crop prices and market trends
- **Weather Information**: Receive weather updates and farming advice
- **Multi-language Support**: Available in English and Kannada with voice interaction

## Architecture

### Backend Architecture

The backend is built using Google's Agent Development Kit (ADK) with a multi-agent system:

```
Root Agent (Intent Detection)
├── Government Schemes Agent
├── Market Analyzer Agent  
├── Plant Health Support Agent
│   ├── Plant Disease Detection Agent
│   └── Plant Treatment Agent
└── Weather Agent
```

**Key Components:**
- **FastAPI Server**: RESTful API with speech and image processing
- **Multi-Agent System**: Specialized agents for different farming domains
- **Google Cloud Integration**: Vertex AI, Speech-to-Text, Text-to-Speech
- **RAG System**: Document retrieval for government schemes

### Frontend Architecture

Cross-platform Flutter application with:
- **Multi-platform Support**: iOS, Android, and Web
- **Firebase Integration**: Authentication and cloud services
- **Voice Interface**: Record and playback in local languages
- **Camera Integration**: Plant disease detection through images
- **State Management**: Provider pattern for app state

## Features

### Core Capabilities
- Voice-based conversation in Kannada and English
- Image-based plant disease detection
- Real-time market price information
- Government scheme recommendations
- Weather forecasting and alerts
- Cross-platform mobile application

### Technical Features
- Multi-modal input (text, voice, images)
- Offline capability for basic features
- Cloud-based AI processing
- Secure authentication
- Multi-language localization

## Prerequisites

### Google Cloud Platform
- GCP Project with billing enabled
- Vertex AI API enabled
- Speech-to-Text API enabled
- Text-to-Speech API enabled
- Cloud Storage bucket
- Service account with appropriate permissions

### Firebase
- Firebase project
- Authentication enabled
- Firestore database
- Cloud Storage

### Development Tools
- Python 3.9+
- Flutter SDK 3.16+
- Node.js (for Firebase CLI)
- Git

## Backend Setup

### 1. Clone Repository
```bash
git clone <repository-url>
cd kisan-project/backend
```

### 2. Install Dependencies
```bash
# Using pip
pip install -r requirements.txt

# Or using uv (recommended)
pip install uv
uv sync
```

### 3. Configure Environment Variables

Create a `.env` file in the backend directory:

```env
# GCP Configuration
GOOGLE_CLOUD_PROJECT=your-gcp-project-id
GCP_PROJECT_NUMBER=your-project-number
GCP_REGION=asia-south1
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json

# Storage
UPLOAD_BUCKET=your-storage-bucket-name

# Firebase
FIREBASE_PROJECT_ID=your-firebase-project-id

# Model Configuration
GEMINI_MODEL=gemini-2.5-pro
SPEECH_LANGUAGE=kn-IN
TTS_LANGUAGE=kn-IN
TTS_VOICE=kn-IN-Standard-A

# App Configuration
DEBUG=true
HOST=0.0.0.0
PORT=8084
ENVIRONMENT=development

# Security
MAX_UPLOAD_SIZE=10485760
REQUEST_TIMEOUT=30
RATE_LIMIT_PER_MINUTE=60
```

### 4. Set Up Google Cloud Credentials

1. Create a service account in GCP Console
2. Download the JSON key file
3. Set the path in `GOOGLE_APPLICATION_CREDENTIALS`
4. Grant required permissions:
   - Vertex AI User
   - Speech Administrator
   - Storage Object Admin

### 5. Initialize Agent System

```bash
# Test the setup
python test_setup.py

# Start the development server
python main.py
```

The backend will be available at `http://localhost:8084`

## Frontend Setup

### 1. Navigate to Frontend Directory
```bash
cd frontend
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Configure Firebase

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login and configure:
```bash
firebase login
firebase use your-firebase-project-id
```

3. Generate Firebase configuration:
```bash
flutterfire configure
```

### 4. Update Configuration

Edit `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String baseUrl = 'http://localhost:8084'; // For development
  static const String apiVersion = 'v1';
  static const String appName = 'Kisan Kavach';
}
```

### 5. Platform-Specific Setup

#### iOS Setup
```bash
cd ios
pod install
cd ..
```

#### Android Setup
- Ensure `minSdkVersion` is 21 or higher in `android/app/build.gradle`
- Add internet permissions in `android/app/src/main/AndroidManifest.xml`

### 6. Run the Application

```bash
# For development
flutter run

# For specific platform
flutter run -d chrome  # Web
flutter run -d ios     # iOS
flutter run -d android # Android
```

## Agent System

### Root Agent
The main orchestrator that analyzes user queries and routes them to appropriate sub-agents:

```python
root_agent = Agent(
    model="gemini-2.5-flash",
    name="root_agent",
    instruction="Intent detection for agricultural queries",
    sub_agents=[scheme_agent, market_agent, weather_agent, disease_agent]
)
```

### Sub-Agents

1. **Government Schemes Agent**: RAG-based system for finding relevant schemes
2. **Market Analyzer Agent**: Real-time market data and price analysis
3. **Plant Health Support Agent**: Disease detection and treatment recommendations
4. **Weather Agent**: Weather information and agricultural advice

### Adding New Agents

1. Create agent directory: `backend/agents/kisan_agent/sub_agents/new_agent/`
2. Implement agent logic in `agent.py`
3. Define prompts in `prompt.py`
4. Add tools if needed in `tools.py`
5. Register in root agent

## API Documentation

### Main Endpoint
```
POST /api/chat_endpoint
```

**Request Body:**
```json
{
  "text": "What's the weather today?",
  "audio_file": "base64_encoded_audio",
  "image": "base64_encoded_image",
  "city": "Bangalore",
  "name": "John Farmer",
  "state": "Karnataka",
  "country": "India",
  "preferred_language": "kn"
}
```

**Response:**
```json
{
  "text_response": "Weather information...",
  "audio_response_base64": "base64_encoded_audio"
}
```

### Health Check
```
GET /
```

Returns API status and documentation link.

## Deployment

### Backend Deployment (Google Cloud Run)

1. Build Docker image:
```bash
docker build -t kisan-backend .
```

2. Push to Container Registry:
```bash
docker tag kisan-backend gcr.io/PROJECT_ID/kisan-backend
docker push gcr.io/PROJECT_ID/kisan-backend
```

3. Deploy to Cloud Run:
```bash
gcloud run deploy kisan-backend \
  --image gcr.io/PROJECT_ID/kisan-backend \
  --platform managed \
  --region asia-south1 \
  --allow-unauthenticated
```

### Frontend Deployment

#### Web Deployment (Firebase Hosting)
```bash
flutter build web
firebase deploy --only hosting
```

#### Mobile App Store Deployment

**Android (Google Play Store):**
```bash
flutter build appbundle
```

**iOS (App Store):**
```bash
flutter build ios
```

## Development Guide

### Adding New Features

1. **Backend**: Create new agents or extend existing ones
2. **Frontend**: Add new screens and services
3. **Testing**: Use the provided test files

### Code Structure

**Backend:**
- `agents/`: Agent implementations
- `services/`: External service integrations  
- `models/`: Data models
- `config/`: Configuration management

**Frontend:**
- `lib/screens/`: UI screens
- `lib/services/`: Business logic
- `lib/models/`: Data models
- `lib/widgets/`: Reusable UI components

### Testing

**Backend:**
```bash
python -m pytest
```

**Frontend:**
```bash
flutter test
```

## Troubleshooting

### Common Issues

1. **GCP Authentication Error**
   - Verify service account permissions
   - Check `GOOGLE_APPLICATION_CREDENTIALS` path

2. **Flutter Build Issues**
   - Run `flutter clean && flutter pub get`
   - Check platform-specific requirements

3. **API Connection Issues**
   - Verify backend is running
   - Check network connectivity
   - Validate API endpoints

### Getting Help

- Check the logs in `backend/logs/`
- Enable debug mode in `.env`
- Use Flutter DevTools for frontend debugging

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Google Cloud Platform for AI services
- Firebase for backend services
- Flutter team for the cross-platform framework
- Open source community for various libraries used

---

**Built with ❤️ for Indian farmers by The Agentic Troop using Google Agent Development Kit**
