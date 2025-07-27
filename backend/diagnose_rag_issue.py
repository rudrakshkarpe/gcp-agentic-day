import os
import json
import time
from google.auth import default
from google.oauth2 import service_account
import vertexai
from vertexai.preview import rag
from dotenv import load_dotenv
import traceback

load_dotenv()

def main():
    print("🔍 COMPREHENSIVE RAG PERMISSION DIAGNOSTIC")
    print("=" * 60)
    
    # Step 1: Check Environment Configuration
    print("\n📋 STEP 1: ENVIRONMENT CONFIGURATION")
    print("-" * 40)
    
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
    location = os.getenv("GOOGLE_CLOUD_LOCATION")
    rag_corpus = os.getenv("RAG_CORPUS")
    creds_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    
    print(f"Project ID: {project_id}")
    print(f"Location: {location}")
    print(f"RAG Corpus: {rag_corpus}")
    print(f"Credentials Path: {creds_path}")
    
    # Step 2: Check Service Account Credentials
    print("\n🔑 STEP 2: SERVICE ACCOUNT VERIFICATION")
    print("-" * 40)
    
    try:
        # Check if credentials file exists
        if creds_path and os.path.exists(creds_path):
            print(f"✅ Credentials file exists: {creds_path}")
            
            # Load and check service account details
            with open(creds_path, 'r') as f:
                creds_data = json.load(f)
            
            sa_email = creds_data.get('client_email')
            sa_project = creds_data.get('project_id')
            
            print(f"📧 Service Account Email: {sa_email}")
            print(f"🏗️  Service Account Project: {sa_project}")
            
            if sa_project != project_id:
                print(f"⚠️  WARNING: Service account project ({sa_project}) != target project ({project_id})")
            
        else:
            print(f"❌ Credentials file not found: {creds_path}")
            
        # Test credential loading
        print("\n🔄 Testing credential loading...")
        credentials, project = default()
        print(f"✅ Credentials loaded successfully")
        print(f"📁 Detected project: {project}")
        
        if hasattr(credentials, 'service_account_email'):
            print(f"📧 Active service account: {credentials.service_account_email}")
        
    except Exception as e:
        print(f"❌ Credential loading error: {e}")
        traceback.print_exc()
    
    # Step 3: Initialize Vertex AI
    print("\n🚀 STEP 3: VERTEX AI INITIALIZATION")
    print("-" * 40)
    
    try:
        vertexai.init(project=project_id, location=location)
        print("✅ Vertex AI initialized successfully")
    except Exception as e:
        print(f"❌ Vertex AI initialization error: {e}")
        traceback.print_exc()
        return
    
    # Step 4: Test RAG Corpus Access
    print("\n📚 STEP 4: RAG CORPUS ACCESS TEST")
    print("-" * 40)
    
    if not rag_corpus:
        print("❌ RAG_CORPUS environment variable not set")
        return
    
    print(f"🎯 Testing access to: {rag_corpus}")
    
    try:
        # Test 1: List all corpora (basic permission test)
        print("\n🔍 Test 1: Listing all RAG corpora...")
        try:
            corpora = list(rag.list_corpora())
            print(f"✅ Successfully listed {len(corpora)} corpora")
            
            # Check if our corpus exists in the list
            target_corpus_id = rag_corpus.split('/')[-1]
            found_corpus = None
            
            for corpus in corpora:
                corpus_id = corpus.name.split('/')[-1]
                print(f"   📄 Found corpus: {corpus.display_name} (ID: {corpus_id})")
                
                if corpus_id == target_corpus_id:
                    found_corpus = corpus
                    print(f"   ✅ Target corpus found!")
            
            if not found_corpus:
                print(f"   ❌ Target corpus {target_corpus_id} not found in the list!")
                print("   💡 This might indicate the corpus doesn't exist or is in a different project/location")
                
        except Exception as e:
            print(f"❌ Failed to list corpora: {e}")
            traceback.print_exc()
        
        # Test 2: Direct corpus access
        print(f"\n🎯 Test 2: Direct access to target corpus...")
        try:
            # Try to get the specific corpus
            corpus = rag.get_corpus(name=rag_corpus)
            print(f"✅ Successfully accessed corpus: {corpus.display_name}")
            print(f"   📝 Description: {corpus.description}")
            print(f"   🕒 Created: {corpus.create_time}")
            
        except Exception as e:
            print(f"❌ Failed to access target corpus: {e}")
            traceback.print_exc()
        
        # Test 3: List files in corpus
        print(f"\n📁 Test 3: Listing files in corpus...")
        try:
            files = list(rag.list_files(corpus_name=rag_corpus))
            print(f"✅ Successfully listed {len(files)} files in corpus")
            
            for i, file in enumerate(files[:3]):  # Show first 3 files
                print(f"   📄 File {i+1}: {file.display_name}")
                
        except Exception as e:
            print(f"❌ Failed to list files in corpus: {e}")
            traceback.print_exc()
        
        # Test 4: Try a query (the actual failing operation)
        print(f"\n🔍 Test 4: Testing RAG query...")
        try:
            # This is the operation that's likely failing
            from google.adk.tools.retrieval.vertex_ai_rag_retrieval import VertexAiRagRetrieval
            
            rag_tool = VertexAiRagRetrieval(
                name='test_rag_retrieval',
                description='Test RAG retrieval',
                rag_resources=[rag.RagResource(rag_corpus=rag_corpus)],
                similarity_top_k=3,
                vector_distance_threshold=0.6,
            )
            
            print(f"✅ RAG retrieval tool created successfully")
            
            # Try a simple query
            print("   🔍 Testing query: 'government schemes'")
            # Note: We won't actually execute the query here as it might fail
            # but creating the tool tests the corpus access
            
        except Exception as e:
            print(f"❌ Failed to create RAG retrieval tool: {e}")
            traceback.print_exc()
    
    except Exception as e:
        print(f"❌ General RAG testing error: {e}")
        traceback.print_exc()
    
    # Step 5: Troubleshooting Recommendations
    print("\n💡 STEP 5: TROUBLESHOOTING RECOMMENDATIONS")
    print("-" * 40)
    
    print("Based on the diagnostic results above:")
    print("\n🔧 Potential Solutions:")
    print("1. Wait 5-10 minutes for IAM changes to fully propagate")
    print("2. Clear application default credentials cache:")
    print("   rm -rf ~/.config/gcloud/application_default_credentials.json")
    print("3. Restart your application/server")
    print("4. Verify the RAG corpus exists in the correct project/location")
    print("5. Check if the corpus was created with the same service account")
    
    print("\n🔍 Additional Checks:")
    print("1. Verify in GCP Console that the corpus exists:")
    print(f"   https://console.cloud.google.com/ai/generative/rag?project={project_id}")
    print("2. Check IAM permissions in GCP Console:")
    print(f"   https://console.cloud.google.com/iam-admin/iam?project={project_id}")
    print("3. Verify Vertex AI API is enabled:")
    print(f"   https://console.cloud.google.com/apis/library/aiplatform.googleapis.com?project={project_id}")

if __name__ == "__main__":
    main()
