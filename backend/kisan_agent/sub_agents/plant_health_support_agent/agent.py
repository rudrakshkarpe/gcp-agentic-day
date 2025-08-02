from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool
from google.genai.types import GenerateContentConfig
from kisan_agent.sub_agents.plant_health_support_agent import prompt
from kisan_agent.sub_agents.plant_health_support_agent.tools import _load_precreated_user_profile
from kisan_agent.sub_agents.plant_health_support_agent.sub_agents.plant_disease_detection_agent.agent import plant_specialised_disease_detector_agent
from kisan_agent.sub_agents.plant_health_support_agent.sub_agents.plant_treatment_plant_agent.agent import plant_treatment_plan_generator_agent

# This is the main entry point for the Kisan Agent.
# Add your main agent logic her

# TODO: decide the questions to be asked to the User
disease_agent = Agent(
    model="gemini-2.5-flash",
    name="plant_health_support_agent",
    description="""A Plant Health Support Agent that using the services of multiple sub agents for helping farmers identify and manage plant diseases using images and descriptions of symptoms. It provides actionable advice on treatment and prevention.""",
    instruction=prompt.PLANT_HEALTH_SUPPORT_AGENT_INSTRUCTION,
    tools=[
        AgentTool(agent=plant_specialised_disease_detector_agent),
        AgentTool(agent=plant_treatment_plan_generator_agent)
    ]
)
