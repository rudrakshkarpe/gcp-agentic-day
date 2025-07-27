# Load environment variables from .env file
"""Wrapper to Google Search Grounding with custom prompt."""
from google.adk.agents import Agent
from agents.kisan_agent.sub_agents.weather_agent.tool import get_current_weather
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types
import asyncio
from dotenv import load_dotenv
load_dotenv()


weather_agent = Agent(
    model="gemini-2.5-flash",
    name="weather_search_Agent",
    description="An agent providing current weather",
    instruction=""",
    You have been provided with current weather of city, and weather forecast of next 1 week. Collate and analyse this entire data and summarize a crisp weather report for
    farmers using their query. You have access to the tool - 'get_current_weather' which takes input as city name. Call this tool to extract information required to create final weather report.
    After weather data has been provided in summarized form ask them whether they would be interested to know below information based on this weather data and provide them with below options:
    Summarize report from all the dates and provide farmers with insighful information for:
        1. Strategic Planning and Crop Management
        2. Resource Management 
        3. Harvesting and Post-Harvest Operations
        4. Risk Mitigation and Disaster Preparedness

    ---- If we have user reponse from above three, then provide them with short summary based on provided weather report and how it would affect each of the above point.
    Summarize your response within 500 words.
    """,
    tools=[get_current_weather],
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
 
    runner = Runner(agent=weather_agent, app_name=APP_NAME, session_service=session_service)
    print(f"Runner created for agent '{runner.agent.name}'.")
    import time
    start_time = time.time()
    await call_agent_async("whats the weather in Delhi?",
                           runner=runner,
                           user_id=USER_ID,
                           session_id=SESSION_ID)
    print("Execution time: ---",time.time() - start_time)
 
# --- Run Entry Point ---
if __name__ == "__main__":
    asyncio.run(run_conversation())
