from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool
from google.genai.types import GenerateContentConfig
from plant_health_support_agent import prompt
from plant_health_support_agent.tools import save_plant_info, _load_precreated_user_profile
from plant_health_support_agent.sub_agents.plant_disease_detection_agent.agent import plant_specialised_disease_detector_agent
from plant_health_support_agent.sub_agents.plant_treatment_plant_agent.agent import plant_treatment_plan_generator_agent

# This is the main entry point for the Kisan Agent.
# Add your main agent logic her

root_agent = Agent(
    model="gemini-2.5-flash",
    name="plant_health_support_agent",
    description="""A Plant Health Support Agent that using the services of multiple sub agents for helping farmers identify and manage plant diseases using images and descriptions of symptoms. It provides actionable advice on treatment and prevention.""",
    instruction=prompt.PLANT_HEALTH_SUPPORT_AGENT_INSTRUCTION,
    sub_agents=[
        plant_specialised_disease_detector_agent,
        plant_treatment_plan_generator_agent,
    ],
    tools=[save_plant_info],
    before_agent_callback=_load_precreated_user_profile,
)
