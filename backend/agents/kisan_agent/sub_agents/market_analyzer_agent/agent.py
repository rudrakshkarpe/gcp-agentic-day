from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool
import asyncio
from google.adk.tools.google_search_tool import google_search
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from kisan_agent.sub_agents.market_analyzer_agent.tools import scrape_agmarknet_trigger
from kisan_agent.sub_agents.market_analyzer_agent import prompt
from google.genai import types
# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()


#sub market agent
sub_market_agent = Agent(
    model="gemini-2.5-flash",
    name="commodity_price",
    description="An agent that can scrap govt website and extract commodity prices in real time for all places",
    disallow_transfer_to_parent=True,
    disallow_transfer_to_peers=True,
    instruction= prompt.COMMODITY_PRICE_CALCULATOR,
    tools=[
        scrape_agmarknet_trigger
        ],
    output_key = "commodity_prices"
)
#Search agent
search_agent = Agent(
    model="gemini-2.5-flash",
    name="google_search",
    description="An agent which will perform google search on user query to extract prices for nearby places.",
    disallow_transfer_to_parent=True,
    disallow_transfer_to_peers=True,
    instruction=f"Extract wholesale commodity prices for commodity and place mentioned by user in query. Also extract information for nearby places. Perform google search using provided tool to extract mandi data.",
    tools=[   
        google_search
        ],
    output_key="market_prices_nearby"
)

market_agent = Agent(
    model = "gemini-2.5-flash",
    name="market_reserach_agent",
    description="This is main market analyzer angent.",
    instruction = prompt.MARKET_ANALYZER_INSTRUCTION,
    tools = [ 
        AgentTool(agent= sub_market_agent), AgentTool(agent = search_agent), 
    ]
)