from google.auth import default
import vertexai
from vertexai.preview import rag
import os
from dotenv import load_dotenv, set_key
from vertexai.preview.rag import TransformationConfig, ChunkingConfig

# Load environment variables from .env file
load_dotenv()

# --- Configurations ---
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
if not PROJECT_ID:
    raise ValueError("GOOGLE_CLOUD_PROJECT environment variable not set.")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION")
if not LOCATION:
    raise ValueError("GOOGLE_CLOUD_LOCATION environment variable not set.")

CORPUS_DISPLAY_NAME = "Government_Schemes_corpus"
CORPUS_DESCRIPTION = "Corpus containing government agricultural schemes document"
ENV_FILE_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".env"))

# Local PDF files to upload
PDF_FILES = [
    r"C:\Users\V115864\OneDrive - United Airlines\Documents\gcp-project-kisan\gcp-agentic-day\backend\agents\kisan_agent\sub_agents\government_schemes_agent\prepare_corpus\documents\agriwelfare_links.pdf",
    r"C:\Users\V115864\OneDrive - United Airlines\Documents\gcp-project-kisan\gcp-agentic-day\backend\agents\kisan_agent\sub_agents\government_schemes_agent\prepare_corpus\documents\Karnataka Agri Schemes 24-25.pdf",
    r"C:\Users\V115864\OneDrive - United Airlines\Documents\gcp-project-kisan\gcp-agentic-day\backend\agents\kisan_agent\sub_agents\government_schemes_agent\prepare_corpus\documents\Schemes for Welfare of Farmers.pdf"
]

def initialize_vertex_ai():
    credentials, _ = default()
    vertexai.init(project=PROJECT_ID, location=LOCATION, credentials=credentials)

def create_or_get_corpus():
    embedding_model_config = rag.EmbeddingModelConfig(
        publisher_model="publishers/google/models/text-embedding-005"
    )
    for corpus in rag.list_corpora():
        if corpus.display_name == CORPUS_DISPLAY_NAME:
            print(f"Found existing corpus: {CORPUS_DISPLAY_NAME}")
            return corpus
    corpus = rag.create_corpus(
        display_name=CORPUS_DISPLAY_NAME,
        description=CORPUS_DESCRIPTION,
        embedding_model_config=embedding_model_config,
    )
    print(f"Created new corpus: {CORPUS_DISPLAY_NAME}")
    return corpus

def upload_files_to_corpus(corpus_name, file_paths):
    for file_path in file_paths:
        if not os.path.exists(file_path):
            print(f"File not found: {file_path}")
            continue
        display_name = os.path.basename(file_path)
        print(f"Uploading {display_name}...")
        try:

            transformation_config = TransformationConfig(
                chunking_config=ChunkingConfig(
                    chunk_size=512,
                    chunk_overlap=100,
                ),
            )

            rag.upload_file(
                corpus_name=corpus_name,
                path=file_path,
                display_name=display_name,
                description="Uploaded via script",
                transformation_config=transformation_config,
            )
            print(f"Uploaded {display_name} successfully.")
        except Exception as e:
            print(f"Failed to upload {display_name}: {e}")

def update_env_file(corpus_name):
    try:
        set_key(ENV_FILE_PATH, "RAG_CORPUS", corpus_name)
        print(f"Updated .env file with RAG_CORPUS={corpus_name}")
    except Exception as e:
        print(f"Error updating .env file: {e}")

def list_corpus_files(corpus_name):
    files = rag.list_files(corpus_name=corpus_name)
    print(f"\nFiles in corpus '{corpus_name}':")
    for f in files:
        print(f" - {f.display_name} ({f.name})")

def main():
    initialize_vertex_ai()
    corpus = create_or_get_corpus()
    update_env_file(corpus.name)
    upload_files_to_corpus(corpus.name, PDF_FILES)
    list_corpus_files(corpus.name)

if __name__ == "__main__":
    main()
 