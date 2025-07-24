from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool
import asyncio
from google.adk.tools.google_search_tool import google_search
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from tools import scrape_agmarknet_trigger
import prompt
from google.genai import types
# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

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
    description="An agent which will perform google search on user query.",
    disallow_transfer_to_parent=True,
    disallow_transfer_to_peers=True,
    instruction=f"Extract wholesale commodity prices for commodity and place mentioned by user in query. Perform google search using provided tool to extract mandi data.",
    tools=[   
        google_search
        ]
)

root_agent = Agent(
    model = "gemini-2.5-flash",
    name="market_reserach_agent",
    description="This is main market analyzer angent.",
    instruction = prompt.MARKET_ANALYZER_INSTRUCTION,
    tools = [ 
        AgentTool(agent= sub_market_agent), AgentTool(agent = search_agent), 
    ]
)

# --- Agent Interaction Function ---
async def call_agent_async(query: str, runner, user_id, session_id):
    print(f"\n>>> User Query: {query}")
    content = types.Content(role='user', parts=[types.Part(text=query)])
    final_response_text = "Agent did not produce a final response."
    
    async for event in runner.run_async(user_id=user_id, session_id=session_id, new_message=content):
        if event.is_final_response():
            if event.content and event.content.parts:
                final_response_text = event.content.parts[0].text
            elif event.actions and event.actions.escalate:
                final_response_text = f"Agent escalated: {event.error_message or 'No specific message.'}"
            break
 
    print(f"<<< Agent Response: {final_response_text}")
 
# --- Main Run Function ---
async def run_conversation():
    # Use async for session creation
    session_service = InMemorySessionService()
    APP_NAME = "market_scheme"
    USER_ID = "user_1"
    SESSION_ID = "session_001"
 
    await session_service.create_session(
        app_name=APP_NAME,
        user_id=USER_ID,
        session_id=SESSION_ID
    )
 
    print(f"Session created: App='{APP_NAME}', User='{USER_ID}', Session='{SESSION_ID}'")
 
    runner = Runner(agent=root_agent, app_name=APP_NAME, session_service=session_service)
    print(f"Runner created for agent '{runner.agent.name}'.")
    import time
    start_time = time.time()
    await call_agent_async("what is price of potato today in Mumbai and Nagpur?",
                           runner=runner,
                           user_id=USER_ID,
                           session_id=SESSION_ID)
    print("Execution time: ---",time.time() - start_time)
 
# # --- Run Entry Point ---
# if __name__ == "__main__":
#     asyncio.run(run_conversation())