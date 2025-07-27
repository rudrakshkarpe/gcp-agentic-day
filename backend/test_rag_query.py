import os
import vertexai
from vertexai.preview import rag
from google.adk.tools.retrieval.vertex_ai_rag_retrieval import VertexAiRagRetrieval
from dotenv import load_dotenv
import traceback

load_dotenv()

def test_rag_query():
    print("🧪 TESTING RAG QUERY - EXACT APPLICATION SIMULATION")
    print("=" * 60)
    
    # Initialize exactly like the application
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
    location = os.getenv("GOOGLE_CLOUD_LOCATION")
    rag_corpus = os.getenv("RAG_CORPUS")
    
    print(f"📋 Project: {project_id}")
    print(f"📍 Location: {location}")
    print(f"📚 RAG Corpus: {rag_corpus}")
    
    try:
        # Initialize Vertex AI
        vertexai.init(project=project_id, location=location)
        print("✅ Vertex AI initialized")
        
        # Create RAG tool exactly like in government_schemes_agent/agent.py
        print("\n🔧 Creating RAG retrieval tool...")
        ask_vertex_retrieval = VertexAiRagRetrieval(
            name='retrieve_rag_govt_schemes',
            description=(
                'Use this tool to retrieve reference materials and documentation for agricultural government scheme questions from the RAG corpus.'
            ),
            rag_resources=[
                rag.RagResource(
                    rag_corpus=rag_corpus
                )
            ],
            similarity_top_k=6,
            vector_distance_threshold=0.6,
        )
        print("✅ RAG retrieval tool created successfully")
        
        # Test actual query
        print("\n🔍 Testing actual RAG query...")
        test_query = "What are the government schemes available for farmers?"
        
        try:
            # This should trigger the exact same operation that's failing
            result = ask_vertex_retrieval.run(test_query)
            print("✅ RAG query executed successfully!")
            print(f"📝 Result preview: {str(result)[:200]}...")
            
        except Exception as query_error:
            print(f"❌ RAG query failed: {query_error}")
            print(f"🔍 Error type: {type(query_error).__name__}")
            traceback.print_exc()
            
            # Check if this is the same error as reported
            if "403" in str(query_error) and "PERMISSION_DENIED" in str(query_error):
                print("🎯 THIS IS THE SAME ERROR!")
                print("The issue occurs during actual query execution, not tool creation")
            
    except Exception as e:
        print(f"❌ Setup error: {e}")
        traceback.print_exc()

def test_direct_rag_api():
    """Test using the RAG API directly"""
    print("\n🔬 TESTING DIRECT RAG API")
    print("-" * 40)
    
    try:
        from vertexai.preview.generative_models import GenerativeModel
        
        project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
        location = os.getenv("GOOGLE_CLOUD_LOCATION")
        rag_corpus = os.getenv("RAG_CORPUS")
        
        vertexai.init(project=project_id, location=location)
        
        # Test direct RAG query using Vertex AI API
        model = GenerativeModel("gemini-1.5-pro")
        
        print("🔍 Testing direct RAG retrieval...")
        
        # Create RAG retrieval config
        rag_retrieval_tool = rag.Retrieval(
            source=rag.VertexRagStore(
                rag_resources=[rag.RagResource(rag_corpus=rag_corpus)],
                similarity_top_k=3,
            ),
        )
        
        print("✅ RAG retrieval config created")
        
        # Test query
        response = model.generate_content(
            "What government schemes are available for farmers?",
            tools=[rag_retrieval_tool],
        )
        
        print("✅ Direct RAG query successful!")
        print(f"📝 Response: {response.text[:200]}...")
        
    except Exception as e:
        print(f"❌ Direct RAG API error: {e}")
        traceback.print_exc()

def main():
    test_rag_query()
    test_direct_rag_api()
    
    print("\n🎯 CONCLUSION")
    print("=" * 60)
    print("If the tests above work but your application still fails:")
    print("1. 🔄 Restart your application/server completely")
    print("2. 🧹 Clear any cached credentials or sessions")
    print("3. ⏱️  Wait a few more minutes for IAM propagation")
    print("4. 🔍 Check if error occurs during deployment vs runtime")

if __name__ == "__main__":
    main()
