
"""Demonstration of Project Kisan Agent using Agent Development Kit"""
import prompt
from google.adk.agents import Agent
from sub_agents.government_schemes_agent.agent import scheme_agent
from sub_agents.market_analyzer_agent.agent import market_agent
from sub_agents.plant_disease_detector_agent.agent import disease_agent
from ..tools.weather_tool import weather_agent


root_agent = Agent(
    model="gemini-2.5-flash",
    name="root_agent",
    description="",
    instruction=prompt.ROOT_AGENT_INSTR,
    sub_agents=[
        scheme_agent,
        market_agent,
        weather_agent,
    ],
)