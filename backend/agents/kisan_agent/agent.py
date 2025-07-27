
"""Demonstration of Project Kisan Agent using Agent Development Kit"""
from agents.kisan_agent import prompt
from google.adk.agents import Agent
from agents.kisan_agent.sub_agents.government_schemes_agent.agent import scheme_agent
from agents.kisan_agent.sub_agents.market_analyzer_agent.agent import market_agent
from agents.kisan_agent.sub_agents.plant_health_support_agent.agent import disease_agent
from agents.kisan_agent.sub_agents.weather_agent.agent import weather_agent


root_agent = Agent(
    model="gemini-2.5-flash",
    name="root_agent",
    description="",
    instruction=prompt.ROOT_AGENT_INSTR,
    sub_agents=[
        scheme_agent,
        market_agent,
        weather_agent,
        disease_agent
    ],
)
