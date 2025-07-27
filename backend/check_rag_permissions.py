import json
import os
from dotenv import load_dotenv

load_dotenv()

def get_service_account_email():
    """Get the service account email from the JSON key file."""
    creds_path = "./kisan-service-account-key.json"
    with open(creds_path, 'r') as f:
        creds_data = json.load(f)
    return creds_data.get('client_email')

def check_rag_permissions():
    """Check if the service account has RAG permissions."""
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
    sa_email = get_service_account_email()
    
    print(f"Project ID: {project_id}")
    print(f"Service Account: {sa_email}")
    print(f"RAG Corpus: {os.getenv('RAG_CORPUS')}")
    
    print("\n" + "="*50)
    print("REQUIRED IAM PERMISSIONS FOR RAG:")
    print("="*50)
    print("Your service account needs one of these roles:")
    print("1. roles/aiplatform.user (Vertex AI User)")
    print("2. roles/aiplatform.admin (Vertex AI Administrator)")
    print("3. Custom role with 'aiplatform.ragCorpora.query' permission")
    
    print("\n" + "="*50)
    print("STEPS TO FIX IN GOOGLE CLOUD CONSOLE:")
    print("="*50)
    print("1. Go to: https://console.cloud.google.com/iam-admin/iam")
    print(f"2. Find service account: {sa_email}")
    print("3. Click 'Edit' (pencil icon)")
    print("4. Add role: 'Vertex AI User' or 'Vertex AI Administrator'")
    print("5. Save changes")
    
    print("\n" + "="*50)
    print("OR USE GCLOUD COMMAND (if you have gcloud CLI):")
    print("="*50)
    print(f"gcloud projects add-iam-policy-binding {project_id} \\")
    print(f"    --member='serviceAccount:{sa_email}' \\")
    print(f"    --role='roles/aiplatform.user'")
    
    print("\n" + "="*50)
    print("VERIFICATION:")
    print("="*50)
    print("After updating IAM permissions:")
    print("1. Wait 1-2 minutes for permissions to propagate")
    print("2. Test your application again")
    print("3. The 403 PERMISSION_DENIED error should be resolved")

if __name__ == "__main__":
    check_rag_permissions()
