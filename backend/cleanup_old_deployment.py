import vertexai
from vertexai import agent_engines
import time
import os
from dotenv import load_dotenv

load_dotenv()

# Configuration
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", "kisan-project-gcp")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "europe-west4")

# Old agent engine that's causing the issue
OLD_AGENT_ENGINE = "projects/683449264474/locations/europe-west4/reasoningEngines/2919317720954568704"

def initialize_vertex_ai():
    """Initialize Vertex AI with project settings."""
    vertexai.init(project=PROJECT_ID, location=LOCATION)
    print(f"✅ Initialized Vertex AI for project: {PROJECT_ID}")

def delete_specific_agent_engine(resource_name):
    """Delete a specific agent engine by resource name."""
    try:
        print(f"🗑️  Deleting old agent engine: {resource_name}")
        
        # Try to get the agent first to confirm it exists
        try:
            agent = agent_engines.get(resource_name)
            print(f"📋 Found agent: {agent.display_name}")
        except Exception as e:
            print(f"⚠️  Agent might not exist or already deleted: {e}")
            return True
        
        # Delete the agent
        operation = agent_engines.delete(name=resource_name)
        
        # Wait for deletion to complete
        print("⏳ Waiting for deletion to complete...")
        max_wait = 120  # 2 minutes max
        wait_time = 0
        
        while not operation.done() and wait_time < max_wait:
            time.sleep(10)
            wait_time += 10
            print(f"   Still deleting... ({wait_time}s)")
        
        if operation.done():
            if operation.exception():
                print(f"❌ Deletion failed: {operation.exception()}")
                return False
            else:
                print(f"✅ Successfully deleted: {resource_name}")
                return True
        else:
            print(f"⏳ Deletion is taking longer than expected, but operation started")
            return True
            
    except Exception as e:
        print(f"❌ Error deleting engine {resource_name}: {e}")
        return False

def list_current_agents():
    """List all current agent engines."""
    print("\n🔍 Current agent engines in your project:")
    try:
        engines = list(agent_engines.list())
        if not engines:
            print("   No agent engines found.")
            return
            
        for i, engine in enumerate(engines, 1):
            print(f"   {i}. {engine.display_name}")
            print(f"      Resource: {engine.resource_name}")
            print(f"      Created: {engine.create_time}")
            print("      " + "-" * 50)
            
    except Exception as e:
        print(f"❌ Error listing engines: {e}")

def main():
    """Main cleanup process."""
    print("🧹 CLEANUP OLD AGENT ENGINE")
    print("=" * 50)
    
    initialize_vertex_ai()
    
    # Show current state
    list_current_agents()
    
    # Delete the old problematic agent
    print(f"\n🎯 Targeting old agent engine for deletion:")
    print(f"   {OLD_AGENT_ENGINE}")
    
    success = delete_specific_agent_engine(OLD_AGENT_ENGINE)
    
    if success:
        print("\n✅ Cleanup completed!")
        print("\n📋 SUMMARY:")
        print("• Old agent engine deleted (or already gone)")
        print("• New agent engine is ready to use:")
        print("  projects/683449264474/locations/europe-west4/reasoningEngines/7436428147207176192")
        print("\n🚀 Your application should now use the new agent engine")
        print("🔑 Make sure IAM permissions are set for your service account:")
        print("   kisan-service-account@kisan-project-gcp.iam.gserviceaccount.com")
    else:
        print("❌ Cleanup failed, but new agent is still available")
    
    # Show final state
    print("\n" + "=" * 50)
    list_current_agents()

if __name__ == "__main__":
    main()
