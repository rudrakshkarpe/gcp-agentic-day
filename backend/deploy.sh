#!/bin/bash

# Kisan AI Backend Deployment Script for Google Cloud Run

set -e

# Configuration
PROJECT_ID=${GOOGLE_CLOUD_PROJECT:-"your-project-id"}
REGION=${GCP_REGION:-"asia-south1"}
SERVICE_NAME="kisan-backend"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

echo "🚀 Deploying Kisan AI Backend to Cloud Run..."
echo "Project: ${PROJECT_ID}"
echo "Region: ${REGION}"
echo "Service: ${SERVICE_NAME}"

# Check if gcloud is authenticated
if ! gcloud auth list --filter="status:ACTIVE" | grep -q "ACTIVE"; then
    echo "❌ Please authenticate with Google Cloud: gcloud auth login"
    exit 1
fi

# Set project
gcloud config set project ${PROJECT_ID}

# Enable required APIs
echo "📋 Enabling required APIs..."
gcloud services enable \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    artifactregistry.googleapis.com

# Build and submit to Cloud Build
echo "🔨 Building Docker image..."
gcloud builds submit --tag ${IMAGE_NAME} .

# Deploy to Cloud Run
echo "🚢 Deploying to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
    --image ${IMAGE_NAME} \
    --platform managed \
    --region ${REGION} \
    --allow-unauthenticated \
    --memory 2Gi \
    --cpu 2 \
    --concurrency 100 \
    --max-instances 10 \
    --set-env-vars="GOOGLE_CLOUD_PROJECT=${PROJECT_ID}" \
    --set-env-vars="GCP_REGION=${REGION}" \
    --set-env-vars="PORT=8000"

# Get service URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --region=${REGION} --format="value(status.url)")

echo "✅ Deployment completed!"
echo "🌐 Service URL: ${SERVICE_URL}"
echo "🔍 Health Check: ${SERVICE_URL}/health"

# Test the deployment
echo "🧪 Testing deployment..."
if curl -f "${SERVICE_URL}/health" > /dev/null 2>&1; then
    echo "✅ Health check passed!"
else
    echo "❌ Health check failed. Please check the logs:"
    echo "   gcloud logs tail --service=${SERVICE_NAME} --project=${PROJECT_ID}"
fi

echo "📱 Ready to connect Flutter app to: ${SERVICE_URL}"
