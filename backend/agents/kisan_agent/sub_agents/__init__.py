"""
Kisan Agent Sub-Agents Package

This package contains specialized sub-agents for different farming-related tasks:
- Plant Disease Detector: Analyzes plant images for disease detection
- Market Analyzer: Provides market prices and trends analysis  
- Government Schemes: Helps farmers find relevant government support programs
"""

from .plant_disease_detector_agent import plant_disease_detector_wrapper
from .market_analyzer_agent import market_analyzer_wrapper
from .government_schemes_agent import government_schemes_wrapper

__all__ = [
    "plant_disease_detector_wrapper",
    "market_analyzer_wrapper", 
    "government_schemes_wrapper"
]
