#!/usr/bin/env python3
"""
Kisan Backend Setup Test Script
Tests your GCP configuration and dependencies before running the backend
"""

import os
import sys
import json
import asyncio
from pathlib import Path

# Add current directory to path to import our modules
sys.path.append(str(Path(__file__).parent))

def print_status(message: str, status: str = "INFO"):
    """Print colored status messages"""
    colors = {
        "INFO": "\033[94m",    # Blue
        "SUCCESS": "\033[92m", # Green
        "WARNING": "\033[93m", # Yellow
        "ERROR": "\033[91m",   # Red
        "RESET": "\033[0m"     # Reset
    }
    
    color = colors.get(status, colors["INFO"])
    reset = colors["RESET"]
    
    symbols = {
        "INFO": "ℹ️",
        "SUCCESS": "✅",
        "WARNING": "⚠️",
        "ERROR": "❌"
    }
    
    symbol = symbols.get(status, "ℹ️")
    print(f"{color}{symbol} {message}{reset}")

def test_env_file():
    """Test .env file configuration"""
    print_status("Testing .env file configuration...", "INFO")
    
    env_path = Path(".env")
    if not env_path.exists():
        print_status(".env file not found!", "ERROR")
        return False
    
    # Load environment variables
    from dotenv import load_dotenv
    load_dotenv()
    
    required_vars = [
        "GOOGLE_CLOUD_PROJECT",
        "GCP_PROJECT_NUMBER", 
        "GCP_REGION",
        "GOOGLE_APPLICATION_CREDENTIALS",
        "UPLOAD_BUCKET",
        "FIREBASE_PROJECT_ID"
    ]
    
    missing_vars = []
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        print_status(f"Missing environment variables: {', '.join(missing_vars)}", "ERROR")
        return False
    
    print_status("Environment variables configured correctly", "SUCCESS")
    return True

def test_service_account_key():
    """Test service account key file"""
    print_status("Testing service account key...", "INFO")
    
    from dotenv import load_dotenv
    load_dotenv()
    
    key_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "./kisan-service-account-key.json")
    
    if not os.path.exists(key_path):
        print_status(f"Service account key not found at: {key_path}", "ERROR")
        print_status("Please download it from GCP Cloud Shell", "WARNING")
        return False
    
    try:
        with open(key_path, 'r') as f:
            key_data = json.load(f)
        
        required_fields = ["type", "project_id", "private_key", "client_email"]
        for field in required_fields:
            if field not in key_data:
                print_status(f"Invalid service account key: missing {field}", "ERROR")
                return False
        
        if key_data.get("type") != "service_account":
            print_status("Invalid service account key: wrong type", "ERROR")
            return False
        
        print_status("Service account key is valid", "SUCCESS")
        return True
        
    except json.JSONDecodeError:
        print_status("Service account key is not valid JSON", "ERROR")
        return False
    except Exception as e:
        print_status(f"Error reading service account key: {e}", "ERROR")
        return False

def test_dependencies():
    """Test required dependencies"""
    print_status("Testing Python dependencies...", "INFO")
    
    required_packages = [
        "fastapi",
        "google.cloud.aiplatform",
        "google.cloud.speech",
        "google.cloud.texttospeech", 
        "google.cloud.storage",
        "google.cloud.firestore",
        "firebase_admin",
        "pydantic",
        "uvicorn"
    ]
    
    missing_packages = []
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        print_status(f"Missing packages: {', '.join(missing_packages)}", "ERROR")
        print_status("Run: uv sync", "WARNING")
        return False
    
    print_status("All required dependencies are installed", "SUCCESS")
    return True

def test_google_adk():
    """Test Google ADK availability"""
    print_status("Testing Google ADK...", "INFO")
    
    try:
        from google.adk.agents import Agent
        print_status("Google ADK is available", "SUCCESS")
        return True
    except ImportError:
        print_status("Google ADK not found", "ERROR")
        print_status("Run: uv sync", "WARNING")
        return False

async def test_gcp_connectivity():
    """Test GCP service connectivity"""
    print_status("Testing GCP connectivity...", "INFO")
    
    try:
        from config.settings import settings
        
        # Test basic configuration
        if not settings.validate_gcp_config():
            print_status("GCP configuration validation failed", "ERROR")
            return False
        
        print_status(f"Project ID: {settings.GCP_PROJECT_ID}", "INFO")
        print_status(f"Region: {settings.GCP_REGION}", "INFO")
        print_status(f"Storage Bucket: {settings.UPLOAD_BUCKET}", "INFO")
        print_status(f"Gemini Model: {settings.GEMINI_MODEL}", "INFO")
        
        # Test Google Cloud imports
        try:
            from google.cloud import aiplatform
            from google.cloud import speech
            from google.cloud import texttospeech
            from google.cloud import storage
            from google.cloud import firestore
            
            print_status("Google Cloud libraries imported successfully", "SUCCESS")
            return True
            
        except Exception as e:
            print_status(f"Error importing Google Cloud libraries: {e}", "ERROR")
            return False
        
    except Exception as e:
        print_status(f"Error testing GCP connectivity: {e}", "ERROR")
        return False

def test_agent_imports():
    """Test agent imports"""
    print_status("Testing agent imports...", "INFO")
    
    try:
        from agents.kisan_agent import kisan_agent_wrapper
        from agents.kisan_agent.sub_agents import (
            plant_disease_detector_wrapper,
            market_analyzer_wrapper,
            government_schemes_wrapper
        )
        from agents.tools.speech_tools import SpeechTools
        from agents.tools.storage_tools import StorageTools
        
        print_status("All agent modules imported successfully", "SUCCESS")
        return True
        
    except Exception as e:
        print_status(f"Error importing agents: {e}", "ERROR")
        return False

def test_fastapi_setup():
    """Test FastAPI setup"""
    print_status("Testing FastAPI setup...", "INFO")
    
    try:
        from main import app
        print_status("FastAPI app imported successfully", "SUCCESS")
        return True
        
    except Exception as e:
        print_status(f"Error importing FastAPI app: {e}", "ERROR")
        return False

async def main():
    """Run all tests"""
    print_status("🚀 Kisan Backend Setup Test", "INFO")
    print_status("=" * 50, "INFO")
    
    tests = [
        ("Environment Configuration", test_env_file),
        ("Service Account Key", test_service_account_key),
        ("Python Dependencies", test_dependencies),
        ("Google ADK", test_google_adk),
        ("GCP Connectivity", test_gcp_connectivity),
        ("Agent Imports", test_agent_imports),
        ("FastAPI Setup", test_fastapi_setup)
    ]
    
    results = []
    for test_name, test_func in tests:
        print()
        try:
            if asyncio.iscoroutinefunction(test_func):
                result = await test_func()
            else:
                result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print_status(f"Test '{test_name}' failed with error: {e}", "ERROR")
            results.append((test_name, False))
    
    print()
    print_status("=" * 50, "INFO")
    print_status("🧪 Test Results Summary", "INFO")
    print_status("=" * 50, "INFO")
    
    passed = 0
    total = len(results)
    
    for test_name, passed_test in results:
        status = "SUCCESS" if passed_test else "ERROR"
        print_status(f"{test_name}: {'PASSED' if passed_test else 'FAILED'}", status)
        if passed_test:
            passed += 1
    
    print()
    if passed == total:
        print_status(f"🎉 All tests passed! ({passed}/{total})", "SUCCESS")
        print_status("Your backend is ready to run!", "SUCCESS")
        print_status("Next step: uv run uvicorn main:app --reload", "INFO")
    else:
        print_status(f"❌ {total - passed} test(s) failed. ({passed}/{total})", "ERROR")
        print_status("Please fix the issues above before running the backend.", "WARNING")
        
        # Provide specific guidance
        if not any(name == "Service Account Key" and result for name, result in results):
            print()
            print_status("🔑 Service Account Key Issue:", "WARNING")
            print_status("Download from GCP Cloud Shell:", "INFO")
            print_status("cloudshell download kisan-service-account-key.json", "INFO")
        
        if not any(name == "Python Dependencies" and result for name, result in results):
            print()
            print_status("📦 Dependencies Issue:", "WARNING")
            print_status("Install dependencies:", "INFO")
            print_status("uv sync", "INFO")

if __name__ == "__main__":
    asyncio.run(main())
