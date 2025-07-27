import vertexai
from vertexai import agent_engines
from vertexai.preview.reasoning_engines import AdkApp
import time
import os
from dotenv import load_dotenv
from agents.kisan_agent.agent import root_agent
import json

load_dotenv()

# Configuration
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", "kisan-project-gcp")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "europe-west4")
BUCKET = "kisan-project-gcp-kisan-sessions"
RAG_CORPUS = os.getenv("RAG_CORPUS", "projects/kisan-project-gcp/locations/europe-west4/ragCorpora/5764607523034234880")
WEATHER_API_KEY = os.getenv("WEATHER_API_KEY", "a1842e06b07c424fbcf115112252207")

def initialize_vertex_ai():
    """Initialize Vertex AI with project settings."""
    vertexai.init(
        project=PROJECT_ID,
        location=LOCATION,
        staging_bucket=f"gs://{BUCKET}",
    )
    print(f"✅ Initialized Vertex AI for project: {PROJECT_ID}")

def get_service_account_email():
    """Get the service account email from the JSON key file."""
    try:
        creds_path = "./kisan-service-account-key.json"
        with open(creds_path, 'r') as f:
            creds_data = json.load(f)
        return creds_data.get('client_email')
    except Exception as e:
        print(f"❌ Error reading service account: {e}")
        return None

def list_all_agent_engines():
    """List all agent engines in the project."""
    print("\n🔍 Listing all existing agent engines...")
    try:
        engines = list(agent_engines.list())
        print(f"Found {len(engines)} agent engines:")
        
        for engine in engines:
            print(f"  - Name: {engine.display_name}")
            print(f"    Resource: {engine.resource_name}")
            print(f"    State: {engine.state}")
            print(f"    Created: {engine.create_time}")
            print("    " + "-" * 50)
        
        return engines
    except Exception as e:
        print(f"❌ Error listing engines: {e}")
        return []

def delete_agent_engine(resource_name):
    """Delete a specific agent engine."""
    try:
        print(f"🗑️  Deleting agent engine: {resource_name}")
        operation = agent_engines.delete(name=resource_name)
        
        # Wait for deletion to complete
        print("⏳ Waiting for deletion to complete...")
        while not operation.done():
            time.sleep(5)
            print("   Still deleting...")
        
        if operation.exception():
            print(f"❌ Deletion failed: {operation.exception()}")
            return False
        else:
            print(f"✅ Successfully deleted: {resource_name}")
            return True
            
    except Exception as e:
        print(f"❌ Error deleting engine {resource_name}: {e}")
        return False

def cleanup_all_kisan_agents():
    """Delete all agent engines with 'Kisan' or 'Project-Kisan' in the name."""
    engines = list_all_agent_engines()
    
    kisan_engines = [
        engine for engine in engines 
        if any(keyword.lower() in engine.display_name.lower() 
               for keyword in ['kisan', 'project-kisan'])
    ]
    
    if not kisan_engines:
        print("✅ No Kisan-related agent engines found to delete.")
        return True
    
    print(f"\n🧹 Found {len(kisan_engines)} Kisan-related engines to delete:")
    for engine in kisan_engines:
        print(f"  - {engine.display_name} ({engine.resource_name})")
    
    # Delete each engine
    all_deleted = True
    for engine in kisan_engines:
        success = delete_agent_engine(engine.resource_name)
        if not success:
            all_deleted = False
    
    # Wait a bit more for complete cleanup
    if all_deleted:
        print("⏳ Waiting 30 seconds for complete cleanup...")
        time.sleep(30)
    
    return all_deleted

def create_fresh_deployment():
    """Create a fresh deployment with correct configuration."""
    print("\n🚀 Creating fresh deployment...")
    
    # Environment variables for deployment
    env_vars = {
        "GOOGLE_CLOUD_PROJECT": PROJECT_ID,
        "GOOGLE_CLOUD_LOCATION": LOCATION,
        "GOOGLE_CLOUD_STORAGE_BUCKET": BUCKET,
        "RAG_CORPUS": RAG_CORPUS,
        "WEATHER_API_KEY": WEATHER_API_KEY
    }
    
    print("📋 Deployment configuration:")
    for key, value in env_vars.items():
        print(f"  {key}: {value}")
    
    try:
        app = AdkApp(
            agent=root_agent,
            enable_tracing=True,
            env_vars=env_vars,
        )

        # Create with timestamp to ensure uniqueness
        timestamp = str(int(time.time()))
        display_name = f"Project-Kisan-ADK-{timestamp}"
        
        print(f"🔨 Creating agent engine: {display_name}")
        
        remote_agent = agent_engines.create(  
            app,
            display_name=display_name,
            description=f"AgentEngine Deployment - Clean Deploy {timestamp}",                    
            requirements=[
                "google-adk (==1.7.0)",
                "google-genai (==1.27.0)",
                "bs4 (==0.0.2)",
                "absl-py (>=2.2.1,<3.0.0)",
                "pydantic (>=2.10.6,<3.0.0)",
                "requests (>=2.32.3,<3.0.0)",
                "google-cloud-texttospeech (==2.27.0)",
                "google-cloud-speech (==2.33.0)",
                "google-cloud-aiplatform",
                "cloudpickle",   
                "jinja2==3.1.6",
                "llama-index==0.12.50"
            ],
            extra_packages=[
                "./agents",
            ],
        )
        
        print(f"✅ Successfully created: {remote_agent.resource_name}")
        print(f"📝 Display name: {display_name}")
        
        return remote_agent
        
    except Exception as e:
        print(f"❌ Error creating deployment: {e}")
        return None

def verify_deployment(remote_agent):
    """Verify the deployment is working correctly."""
    print("\n🔍 Verifying deployment...")
    
    try:
        # Check if agent is accessible
        resource_name = remote_agent.resource_name
        retrieved_agent = agent_engines.get(resource_name)
        
        print(f"✅ Agent accessible: {retrieved_agent.display_name}")
        print(f"📊 State: {retrieved_agent.state}")
        
        if retrieved_agent.state.name == "ACTIVE":
            print("✅ Deployment is ACTIVE and ready to use!")
            return True
        else:
            print(f"⚠️  Deployment state: {retrieved_agent.state}")
            return False
            
    except Exception as e:
        print(f"❌ Verification failed: {e}")
        return False

def check_iam_permissions():
    """Check if service account has required permissions."""
    print("\n🔑 Checking IAM permissions...")
    
    sa_email = get_service_account_email()
    if not sa_email:
        print("❌ Could not retrieve service account email")
        return False
    
    print(f"📧 Service Account: {sa_email}")
    print(f"🎯 RAG Corpus: {RAG_CORPUS}")
    
    print("\n⚠️  IMPORTANT: Ensure your service account has these roles:")
    print("   • roles/aiplatform.user (Vertex AI User)")
    print("   • roles/aiplatform.admin (Vertex AI Administrator)")
    print(f"\n🔗 IAM Console: https://console.cloud.google.com/iam-admin/iam?project={PROJECT_ID}")
    
    return True

def main():
    """Main cleanup and redeployment process."""
    print("🧹 KISAN PROJECT - COMPLETE CLEANUP AND REDEPLOYMENT")
    print("=" * 60)
    
    # Step 1: Initialize
    initialize_vertex_ai()
    
    # Step 2: Check IAM permissions first
    if not check_iam_permissions():
        print("❌ Please fix IAM permissions before proceeding")
        return False
    
    # Step 3: Cleanup existing deployments
    print("\n" + "=" * 60)
    print("STEP 1: CLEANUP EXISTING DEPLOYMENTS")
    print("=" * 60)
    
    if not cleanup_all_kisan_agents():
        print("❌ Cleanup failed, but continuing with deployment...")
    
    # Step 4: Create fresh deployment
    print("\n" + "=" * 60)
    print("STEP 2: CREATE FRESH DEPLOYMENT")
    print("=" * 60)
    
    remote_agent = create_fresh_deployment()
    if not remote_agent:
        print("❌ Deployment failed!")
        return False
    
    # Step 5: Verify deployment
    print("\n" + "=" * 60)
    print("STEP 3: VERIFY DEPLOYMENT")
    print("=" * 60)
    
    if verify_deployment(remote_agent):
        print("\n🎉 SUCCESS! Clean deployment completed successfully!")
        print(f"🚀 Agent Resource: {remote_agent.resource_name}")
        print("\n📋 Next steps:")
        print("1. Update your application to use the new agent resource")
        print("2. Test your RAG corpus functionality")
        print("3. Monitor logs for any remaining issues")
        return True
    else:
        print("⚠️  Deployment created but verification failed")
        return False

if __name__ == "__main__":
    success = main()
    if success:
        print("\n✅ All operations completed successfully!")
    else:
        print("\n❌ Some operations failed. Check the logs above.")
