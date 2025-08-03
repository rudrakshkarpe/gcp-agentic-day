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

### 5. Flutter SDK Installation

#### Install Flutter SDK

1. **Download Flutter SDK:**
   - Visit [Flutter.dev](https://flutter.dev/docs/get-started/install)
   - Download the appropriate version for your operating system
   - Extract to a permanent location (e.g., `/Users/[username]/development/flutter` on macOS)

2. **Add Flutter to PATH:**
   ```bash
   # Add to your shell profile (.bashrc, .zshrc, etc.)
   export PATH="$PATH:/path/to/flutter/bin"
   
   # Verify installation
   flutter --version
   ```

3. **Run Flutter Doctor:**
   ```bash
   flutter doctor
   ```
   This will show you what dependencies you need to install.

### 6. Android Development Setup

#### Android Studio Installation

1. **Download and Install Android Studio:**
   - Download from [developer.android.com](https://developer.android.com/studio)
   - Install with default settings
   - Launch Android Studio and complete the setup wizard

2. **Install Required SDKs:**
   - Open Android Studio → SDK Manager
   - Install Android SDK (API level 33 or higher recommended)
   - Install Android SDK Build-Tools
   - Install Android Emulator

3. **Configure Environment Variables:**
   ```bash
   # Add to your shell profile
   export ANDROID_HOME=$HOME/Library/Android/sdk  # macOS
   export ANDROID_HOME=$HOME/Android/Sdk          # Linux
   export PATH=$PATH:$ANDROID_HOME/emulator
   export PATH=$PATH:$ANDROID_HOME/tools
   export PATH=$PATH:$ANDROID_HOME/tools/bin
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   ```

#### Android Virtual Device (AVD) Setup

1. **Create AVD:**
   ```bash
   # Open AVD Manager
   android avd
   
   # Or from Android Studio: Tools → AVD Manager
   ```

2. **Recommended AVD Configuration:**
   - Device: Pixel 7 or Pixel 6
   - System Image: API 33 (Android 13) or higher
   - RAM: 4GB or more
   - Internal Storage: 6GB or more
   - Enable Hardware Acceleration (Intel HAXM/AMD)

3. **Start Emulator:**
   ```bash
   # List available AVDs
   flutter emulators
   
   # Launch specific emulator
   flutter emulators --launch <emulator-name>
   
   # Or start from Android Studio AVD Manager
   ```

#### Android Project Configuration

1. **Update Build Configuration:**
   Edit `android/app/build.gradle`:
   ```gradle
   android {
       compileSdkVersion 34
       ndkVersion flutter.ndkVersion
       
       defaultConfig {
           minSdkVersion 21  # Required minimum
           targetSdkVersion 34
           # ... other configurations
       }
   }
   ```

2. **Add Required Permissions:**
   Edit `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   ```

3. **Test Android Setup:**
   ```bash
   # With emulator running
   flutter run -d android
   
   # Or specify device
   flutter devices
   flutter run -d <device-id>
   ```

### 7. iOS Development Setup

#### Xcode Installation

1. **Install Xcode:**
   - Download from Mac App Store (requires macOS)
   - Or download from [developer.apple.com](https://developer.apple.com/xcode/)
   - Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

2. **Accept Xcode License:**
   ```bash
   sudo xcodebuild -license accept
   ```

3. **Verify Xcode Installation:**
   ```bash
   xcodebuild -version
   flutter doctor
   ```

#### iOS Simulator Setup

1. **Open iOS Simulator:**
   ```bash
   # Open Simulator app
   open -a Simulator
   
   # Or from Xcode: Xcode → Open Developer Tool → Simulator
   ```

2. **Install Additional Simulators:**
   - Xcode → Preferences → Components
   - Download required iOS versions (iOS 15.0+ recommended)
   - Or use Simulator → Device → Manage Devices

3. **Recommended Simulator Devices:**
   - iPhone 14 Pro (iOS 16.0+)
   - iPhone 13 (iOS 15.0+)  
   - iPad Pro (12.9-inch) for tablet testing

#### iOS Project Configuration

1. **Install CocoaPods:**
   ```bash
   # Install CocoaPods (Ruby gem manager)
   sudo gem install cocoapods
   
   # Navigate to iOS directory and install pods
   cd ios
   pod install
   cd ..
   ```

2. **Configure iOS Deployment Target:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner project → General
   - Set Deployment Target to iOS 12.0 or higher

3. **Apple Developer Account (for Physical Device):**
   - Sign up at [developer.apple.com](https://developer.apple.com)
   - Add your account in Xcode → Preferences → Accounts
   - Select your team in Runner → Signing & Capabilities

4. **Code Signing (for Physical Device):**
   - In Xcode, select Runner target
   - Go to Signing & Capabilities
   - Select your development team
   - Xcode will automatically create provisioning profiles

#### Running on iOS Device

1. **iOS Simulator:**
   ```bash
   # List available iOS simulators
   flutter emulators
   
   # Launch simulator
   flutter emulators --launch apple_ios_simulator
   
   # Run app on simulator
   flutter run -d ios
   ```

2. **Physical iOS Device:**
   ```bash
   # Connect device via USB
   # Trust computer on device when prompted
   
   # List connected devices
   flutter devices
   
   # Run on specific device
   flutter run -d <device-id>
   ```

### 8. Development Environment Verification

#### Flutter Doctor Checklist

Run `flutter doctor -v` and ensure all items show checkmarks:

- ✅ Flutter SDK (Channel stable, version 3.16.0+)
- ✅ Android toolchain - develop for Android devices
- ✅ Xcode - develop for iOS and macOS
- ✅ Chrome - develop for the web
- ✅ Android Studio
- ✅ VS Code (optional but recommended)
- ✅ Connected device

#### Common Setup Issues and Solutions

1. **Android License Issues:**
   ```bash
   flutter doctor --android-licenses
   # Accept all licenses
   ```

2. **iOS CocoaPods Issues:**
   ```bash
   cd ios
   rm Podfile.lock
   rm -rf Pods
   pod install
   cd ..
   ```

3. **Flutter SDK Issues:**
   ```bash
   flutter clean
   flutter pub get
   flutter doctor
   ```

4. **Performance Optimization:**
   ```bash
   # Enable hardware acceleration for Android emulator
   # In BIOS: Enable Intel VT-x or AMD-V
   
   # For iOS Simulator, ensure sufficient RAM allocation
   # Close unnecessary applications during development
   ```

### 9. Run the Application

#### Development Mode

```bash
# Install dependencies first
flutter pub get

# Run on available device (auto-detect)
flutter run

# Run with hot reload enabled (default in debug mode)
flutter run --hot

# Run in release mode (optimized performance)
flutter run --release
```

#### Platform-Specific Execution

```bash
# Web Development
flutter run -d chrome
flutter run -d web-server --web-port 8080

# Android Development  
flutter run -d android
flutter run -d <android-device-id>

# iOS Development
flutter run -d ios
flutter run -d <ios-device-id>
flutter run -d "iPhone 14 Pro Simulator"
```

#### Development Tools

```bash
# List all available devices/emulators
flutter devices

# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator-name>

# Enable debugging
flutter run --debug
flutter attach  # Attach to running app

# Build without running
flutter build apk      # Android APK
flutter build ios      # iOS build
flutter build web      # Web build
```

#### Troubleshooting Development Setup

1. **Clean and Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Reset Flutter Configuration:**
   ```bash
   flutter config --clear-features
   flutter doctor
   ```

3. **Update Flutter and Dependencies:**
   ```bash
   flutter upgrade
   flutter pub upgrade
   ```

4. **Platform-Specific Issues:**
   ```bash
   # Android: Clear Gradle cache
   cd android && ./gradlew clean && cd ..
   
   # iOS: Clean Xcode build
   cd ios && xcodebuild clean && cd ..
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
