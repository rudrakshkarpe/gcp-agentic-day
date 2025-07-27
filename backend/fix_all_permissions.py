import os
import json
from dotenv import load_dotenv

load_dotenv()

def main():
    print("🔧 COMPLETE PERMISSION FIX GUIDE")
    print("=" * 60)
    
    # Get service account details
    try:
        with open("./kisan-service-account-key.json", 'r') as f:
            creds_data = json.load(f)
        
        sa_email = creds_data.get('client_email')
        project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
        
        print(f"📧 Service Account: {sa_email}")
        print(f"🏗️  Project: {project_id}")
        
        print("\n🎯 IDENTIFIED ISSUES:")
        print("1. ✅ RAG corpus permissions: WORKING (local agent successful)")
        print("2. ❌ Cloud Trace permissions: MISSING")
        print("3. ❌ Service Usage Consumer: MISSING")
        
        print("\n🔧 REQUIRED IAM ROLES TO ADD:")
        print("=" * 40)
        
        required_roles = [
            ("Vertex AI User", "roles/aiplatform.user", "✅ You already have this"),
            ("Vertex AI Administrator", "roles/aiplatform.admin", "✅ You already have this"),
            ("Service Usage Consumer", "roles/serviceusage.serviceUsageConsumer", "❌ MISSING - Required for Cloud Trace"),
            ("Cloud Trace User", "roles/cloudtrace.user", "❌ MISSING - Required for telemetry")
        ]
        
        for name, role, status in required_roles:
            print(f"• {name}")
            print(f"  Role: {role}")
            print(f"  Status: {status}")
            print()
        
        print("🌐 ADD ROLES IN GOOGLE CLOUD CONSOLE:")
        print("=" * 40)
        print(f"1. Go to: https://console.cloud.google.com/iam-admin/iam?project={project_id}")
        print(f"2. Find: {sa_email}")
        print("3. Click 'Edit' (pencil icon)")
        print("4. Add these roles:")
        print("   • Service Usage Consumer")
        print("   • Cloud Trace User")
        print("5. Save changes")
        
        print("\n💻 OR USE GCLOUD COMMANDS:")
        print("=" * 40)
        print("# Add Service Usage Consumer role")
        print(f"gcloud projects add-iam-policy-binding {project_id} \\")
        print(f"    --member='serviceAccount:{sa_email}' \\")
        print(f"    --role='roles/serviceusage.serviceUsageConsumer'")
        print()
        print("# Add Cloud Trace User role")
        print(f"gcloud projects add-iam-policy-binding {project_id} \\")
        print(f"    --member='serviceAccount:{sa_email}' \\")
        print(f"    --role='roles/cloudtrace.user'")
        
        print("\n🎉 GOOD NEWS:")
        print("=" * 40)
        print("✅ Your RAG corpus permissions are working!")
        print("✅ Local agent successfully queries government schemes")
        print("✅ No need to recreate RAG corpus or agent deployments")
        print("✅ Just need to add the missing service permissions")
        
        print("\n🔍 VERIFICATION STEPS:")
        print("=" * 40)
        print("After adding the IAM roles:")
        print("1. Wait 2-3 minutes for propagation")
        print("2. Test your application again")
        print("3. The Cloud Trace errors should disappear")
        print("4. Deployed agent should work properly")
        
        print("\n⚡ QUICK FIX ALTERNATIVE:")
        print("=" * 40)
        print("If you want to disable tracing temporarily:")
        print("1. Set enable_tracing=False in your deployment")
        print("2. This will avoid Cloud Trace permission requirements")
        print("3. But adding proper permissions is recommended")
        
    except Exception as e:
        print(f"❌ Error reading service account file: {e}")

if __name__ == "__main__":
    main()
