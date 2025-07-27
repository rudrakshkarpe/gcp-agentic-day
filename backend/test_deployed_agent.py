import os
import vertexai
from vertexai import agent_engines
from dotenv import load_dotenv
import traceback

load_dotenv()

def test_deployed_agent():
    print("🚀 TESTING DEPLOYED AGENT ENGINE")
    print("=" * 50)
    
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
    location = os.getenv("GOOGLE_CLOUD_LOCATION")
    
    # Use the NEW agent engine
    new_agent_engine = "projects/683449264474/locations/europe-west4/reasoningEngines/7436428147207176192"
    
    print(f"📋 Project: {project_id}")
    print(f"📍 Location: {location}")
    print(f"🤖 Agent Engine: {new_agent_engine}")
    
    try:
        # Initialize Vertex AI
        vertexai.init(project=project_id, location=location)
        print("✅ Vertex AI initialized")
        
        # Get the deployed agent
        print("\n🔗 Connecting to deployed agent...")
        app = agent_engines.get(new_agent_engine)
        print("✅ Connected to deployed agent")
        
        # Create a session
        print("\n👤 Creating user session...")
        session = app.create_session(user_id="test_user_123")
        print("✅ Session created")
        
        # Test a government schemes query
        print("\n🔍 Testing government schemes query...")
        test_query = "What government schemes are available for farmers in Karnataka?"
        
        try:
            print(f"📝 Query: {test_query}")
            
            # This should trigger the exact same RAG operation that's failing
            for event in app.stream_query(
                user_id="test_user_123",
                session_id=session['id'],
                message=test_query,
            ):
                if event.get("content") and event.get("content", {}).get("parts"):
                    response_text = event["content"]["parts"][0].get("text", "")
                    if response_text:
                        print("✅ RAG query executed successfully in deployed agent!")
                        print(f"📝 Response preview: {response_text[:200]}...")
                        break
                        
        except Exception as query_error:
            print(f"❌ Deployed agent query failed: {query_error}")
            print(f"🔍 Error type: {type(query_error).__name__}")
            
            # Check if this is the 403 error
            if "403" in str(query_error) and "PERMISSION_DENIED" in str(query_error):
                print("🎯 FOUND THE 403 ERROR!")
                print("This confirms the issue is in the deployed agent context")
                
                # Check which RAG corpus is being referenced in the error
                if "ragCorpora" in str(query_error):
                    print("🔍 Error mentions ragCorpora - checking corpus ID...")
                    error_str = str(query_error)
                    if "5764607523034234880" in error_str:
                        print("✅ Error references the CORRECT corpus ID")
                        print("💡 This suggests a deployment context issue, not corpus ID issue")
                    elif "2305843009213693952" in error_str:
                        print("❌ Error references the OLD corpus ID")
                        print("💡 The deployed agent is still using cached configuration!")
                    
            traceback.print_exc()
            
    except Exception as e:
        print(f"❌ Setup error: {e}")
        traceback.print_exc()

def test_local_agent():
    print("\n🏠 TESTING LOCAL AGENT")
    print("=" * 30)
    
    try:
        from agents.kisan_agent.agent import root_agent
        from vertexai.preview.reasoning_engines import AdkApp
        
        # Test local agent (same as deployed but running locally)
        print("🔧 Creating local ADK app...")
        app = AdkApp(
            agent=root_agent,
            enable_tracing=True,
        )
        print("✅ Local ADK app created")
        
        # Create session
        session = app.create_session(user_id="test_user_local")
        print("✅ Local session created")
        
        # Test query
        print("\n🔍 Testing local agent query...")
        test_query = "What government schemes are available for farmers?"
        
        try:
            for event in app.stream_query(
                user_id="test_user_local",
                session_id=session.id,
                message=test_query,
            ):
                if event.get("content") and event.get("content", {}).get("parts"):
                    response_text = event["content"]["parts"][0].get("text", "")
                    if response_text:
                        print("✅ Local agent query successful!")
                        print(f"📝 Response preview: {response_text[:200]}...")
                        break
                        
        except Exception as local_error:
            print(f"❌ Local agent query failed: {local_error}")
            traceback.print_exc()
            
    except Exception as e:
        print(f"❌ Local agent setup error: {e}")
        traceback.print_exc()

def main():
    test_deployed_agent()
    test_local_agent()
    
    print("\n🎯 DIAGNOSIS SUMMARY")
    print("=" * 50)
    print("Based on the tests above:")
    print("1. If LOCAL agent works but DEPLOYED fails → Environment/caching issue")
    print("2. If both fail with 403 → Still a permission issue")
    print("3. If both work → Issue might be in your application context")
    print("4. Check which corpus ID appears in any error messages")

if __name__ == "__main__":
    main()
