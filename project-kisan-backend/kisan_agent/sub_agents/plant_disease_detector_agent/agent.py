from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool
from google.genai.types import GenerateContentConfig
import prompt

# This is the agent for detecting plant diseases.
# Add your plant disease detection logic here.

plant_disease_detector = Agent(
    model="gemini-2.5-flash",
    name="plant_disease_detector_agent",
    description="""Detects diseases in plants from images.""",
    instruction=prompt.PLANT_DISEASE_DETECTOR_INSTRUCTION,
)
