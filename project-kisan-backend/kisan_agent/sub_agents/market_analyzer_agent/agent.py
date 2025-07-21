from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool
from google.genai.types import GenerateContentConfig
import prompt

# This is the agent for analyzing market prices.
# Add your market analysis logic here.

market_analyzer = Agent(
    model="gemini-2.5-flash",
    name="market_analyzer_agent",
    description="""Analyzes current market prices for crops.""",
    instruction=prompt.MARKET_ANALYZER_INSTRUCTION,
)
