from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool
from google.genai.types import GenerateContentConfig
import prompt

# This is the main entry point for the Kisan Agent.
# Add your main agent logic here.

kisan_agent = Agent(
    model="gemini-2.5-flash",
    name="kisan_agent",
    description="""A helpful agent for farmers.""",
    instruction=prompt.KISAN_AGENT_INSTRUCTION,
)
