from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool
from google.genai.types import GenerateContentConfig
from plant_health_support_agent.sub_agents.plant_disease_detection_agent import prompt


plant_specialised_disease_detector_agent = Agent(
    model="gemini-2.5-flash",
    name="plant_specialised_disease_detector_agent",
    description="""A specialized agent for diagnosing plant diseases based on images and descriptions of symptoms. It uses advanced image analysis and symptom matching to identify potential diseases.""",
    instruction=prompt.PLANT_DISEASE_DETECTOR_AGENT_INSTRUCTION,
    output_key="diagnosis",
    disallow_transfer_to_peers=True,
)