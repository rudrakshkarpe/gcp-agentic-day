"""
Kisan Agent Package

Main AI agent for providing comprehensive farming assistance including:
- General agricultural guidance
- Plant disease detection
- Market price analysis
- Government scheme information
- Multi-language support (Kannada, Hindi, English)
"""

from .agent import KisanAgentWrapper, kisan_agent_wrapper

__all__ = ["KisanAgentWrapper", "kisan_agent_wrapper"]
