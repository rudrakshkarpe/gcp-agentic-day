from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool
from google.genai.types import GenerateContentConfig
from kisan_agent.sub_agents.plant_health_support_agent.sub_agents.plant_treatment_plant_agent import prompt
from google.adk.tools import google_search


plant_treatment_plan_generator_agent = Agent(
    model="gemini-2.5-flash",
    name="plant_treatment_plan_generator_agent",
    description="""
    A specialized agent for generating treatment plans for identified plant diseases. It takes into account the specific disease, the plant type, and the local farming practices to create a tailored treatment plan.

    Summarize the final response in 500 or less words. If the user asks for a detailed answer, only then provide the detailed answer.
    """,
    instruction=prompt.PLANT_TREATMENT_PLAN_GENERATOR_AGENT_INSTRUCTION,
    output_key="treatment_plan",
    disallow_transfer_to_peers=True,
    # tools=[google_search]
)