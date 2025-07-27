import os
import jinja2

from google.adk.agents import Agent
from google.adk.tools.retrieval.vertex_ai_rag_retrieval import VertexAiRagRetrieval
from vertexai.preview import rag
from dotenv import load_dotenv
from google.adk.tools.agent_tool import AgentTool
from google.adk.tools import google_search


user_loc = "Karnataka"

this_dir = os.path.dirname(os.path.abspath(__file__))
prompt_template_path = os.path.join(this_dir, "prompt_templates")
prompt_template_loader = jinja2.FileSystemLoader(prompt_template_path)
jinja2_env = jinja2.Environment(loader=prompt_template_loader)

def get_prompt_template(template_name: str):
        preferred_template_filename = (
            f"{template_name}.jinja2"
        )
        return jinja2_env.get_template(preferred_template_filename)

google_search_agent_prompt = get_prompt_template("google_search_prompt").render()
rag_retrieval_agent_prompt = get_prompt_template("rag_retrieval_prompt").render()

# --- RAG Tool ---
# ask_vertex_retrieval = VertexAiRagRetrieval(
#     name='retrieve_rag_govt_schemes',
#     description=(
#         'Use this tool to retrieve reference materials and documentation for agricultural government scheme questions from the RAG corpus.'
#     ),
#     rag_resources=[
#         rag.RagResource(
#             rag_corpus="projects/683449264474/locations/europe-west4/ragCorpora/5764607523034234880"
#         )
#     ],
#     similarity_top_k=6,
#     vector_distance_threshold=0.6,
# )

# --- Google Search Tool ---
search_agent = Agent(
    name="google_search_agent",
    model="gemini-2.0-flash",
    description="Agent to answer questions using Google Search related to farmer agricultural scheme queries.",
    instruction=google_search_agent_prompt,
    tools=[google_search]
)

# --- RAG Agent ---
# rag_agent = Agent(
#     model='gemini-2.5-flash',
#     name='ask_rag_agent',
#     description="An agent that answers questions about agricultural government schemes using a specialized corpus.",
#     instruction=rag_retrieval_agent_prompt,
#     tools=[ask_vertex_retrieval]
# )

# --- Main Agent ---
scheme_agent = Agent(
    model='gemini-2.5-flash',
    name="Govt_Agricultural_Scheme_Agent", 
    description="This is the main government scheme retriever agent that provides the final information (with portal links) from both google search.",
    instruction="""
        You are an AI assistant that is the main government scheme retriever agent. Your task is to provide the final information on user query from google search.
        Understand the response and provide a concise answer that includes all relevant information. 
        Make sure to include the relevant scheme portal links received from the two tools. In case there is no link provided, give the default link as: "https://raitamitra.karnataka.gov.in/english".
        WHILE SUMMARIZING THE RESPONSE, MAKE SURE to keep all the provided links by the two tools AT THE END OF THE RESPONSE. ONLY ADD THE DEFAULT LINK IF NO SPECIFIC LINK WAS PROVIDED.
        DO NOT add in the reponse that no specific link was provided, just give the default link.

        Summarize the final answer in 500-600 words (make sure to always include links in the response). If the user asks to go in more detail, only then provide the detailed answer.
        """,
    tools=[AgentTool(agent=search_agent)])
