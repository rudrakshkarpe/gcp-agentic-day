# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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