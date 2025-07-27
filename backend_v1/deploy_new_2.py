# %%
# from .agents.kisan_agent.agent import root_agent
from agents.kisan_agent.agent import root_agent

from google.adk.sessions import VertexAiSessionService

import vertexai
from vertexai import agent_engines
from vertexai.preview.reasoning_engines import AdkApp


# %%
project_id = "kisan-project-gcp"
location = "europe-west4"
bucket = "kisan-project-gcp-kisan-sessions"

# %%
print(f"PROJECT: {project_id}")
print(f"LOCATION: {location}")
print(f"BUCKET: {bucket}")

# if not project_id:
#     print("Missing required environment variable: GOOGLE_CLOUD_PROJECT")
#     return
# elif not location:
#     print("Missing required environment variable: GOOGLE_CLOUD_LOCATION")
#     return
# elif not bucket:
#     print("Missing required environment variable: GOOGLE_CLOUD_STORAGE_BUCKET")
#     return

vertexai.init(
    project=project_id,
    location=location,
    staging_bucket=f"gs://{bucket}",
)


def session_builder():
    from google.adk.sessions import InMemorySessionService

    return InMemorySessionService()



# %%
def create(env_vars: dict[str, str]) -> None:
    """Creates a new deployment."""
    print(env_vars)



    app = AdkApp(
        agent=root_agent,
        enable_tracing=True,
        env_vars=env_vars,
        # session_service_builder=session_builder(),
    )

    remote_agent = agent_engines.create(  
        app,
        display_name="Project-Kisan-ADK",
        description="AgentEngine Deployment",                    
        requirements=[
            "google-adk (==1.7.0)",
            "google-genai (==1.27.0)",
            "bs4 (==0.0.2)",
            "absl-py (>=2.2.1,<3.0.0)",
            "pydantic (>=2.10.6,<3.0.0)",
            "requests (>=2.32.3,<3.0.0)",
            "google-cloud-texttospeech (==2.27.0)",
            "google-cloud-speech (==2.33.0)",
            "google-cloud-aiplatform", # <-- ADD THIS LINE
            "cloudpickle",   
            "jinja2==3.1.6",
            "llama-index==0.12.50"
        ],
        extra_packages=[
            "./agents",  # The main package
        ],
    )
    print(f"Created remote agent: {remote_agent.resource_name}")

# %%
if __name__ == "__main__":
    env_vars = {
        "GOOGLE_CLOUD_PROJECT": project_id,
        "GOOGLE_CLOUD_LOCATION": location,
        "GOOGLE_CLOUD_STORAGE_BUCKET": bucket,
    }
    create(env_vars)
    # delete("projects/kisan-project-gcp/locations/europe-west4/reasoningEngines/Project-Kisan-ADK")

# %%



