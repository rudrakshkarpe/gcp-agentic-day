from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool
from google.genai.types import GenerateContentConfig
import prompt

# This is the agent for providing information about government schemes.
# Add your government schemes logic here.

government_schemes = Agent(
    model="gemini-2.5-flash",
    name="government_schemes_agent",
    description="""Provides information about relevant government schemes for farmers.""",
    instruction=prompt.GOVERNMENT_SCHEMES_INSTRUCTION,
)
