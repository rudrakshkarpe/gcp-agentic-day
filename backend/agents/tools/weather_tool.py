# Load environment variables from .env file
import os
import aiohttp
from dotenv import load_dotenv
load_dotenv()

async def get_current_weather(city: str) -> dict:
    """
    Retrieves the current weather report for a specified city.

    Args:
        city (str): The name of the city (e.g., "New York", "London", "Tokyo").

    Returns:
        dict: A dictionary containing the weather information.
              Includes a 'status' key ('success' or 'error').
              If 'success', includes a 'report' key with weather details.
              If 'error', includes an 'error_message' key.
    """
    print(f"--- Tool: get_current_weather called for city: {city} ---")

    # --- Mock Weather Data (for demonstration) ---
    city_normalized = city.lower().replace(" ", "")
    mock_weather_db = {
        "abc": {"status": "success", "report": "The weather in New York is sunny with a temperature of 25°C."},
        "xyz": {"status": "success", "report": "It's cloudy in London with a temperature of 15°C and light drizzle."},
        "lmn": {"status": "success", "report": "Tokyo is experiencing light rain and a temperature of 18°C."},
        "opq": {"status": "success", "report": "The weather in Thane is humid with a temperature of 30°C and scattered clouds."},
        "rst": {"status": "success", "report": "Mumbai is hot and humid with a temperature of 32°C and clear skies."},
    }

    if city_normalized in mock_weather_db:
        return mock_weather_db[city_normalized]
    else:
        WEATHER_API_KEY = os.getenv("WEATHER_API_KEY") # Get your API key from .env
        if not WEATHER_API_KEY:
            return {"status": "error", "error_message": "Weather API key not configured."}
        
        try:
            url = f" http://api.weatherapi.com/v1/current.json?key={WEATHER_API_KEY}&q={city}"
            async with aiohttp.ClientSession() as session:
                async with session.get(url) as response:
                    response.raise_for_status() # Raise an exception for HTTP errors
                    data = await response.json()
                    # Process data and return structured weather report
                    temperature = data["current"]["temp_c"]
                    description = data["current"]["condition"]["text"].lower()
                    return {"status": "success", "report": f"The weather in {city} is {description} with a temperature of {temperature}°C."}
        except aiohttp.ClientError as e:
            return {"status": "error", "error_message": f"Failed to connect to weather service: {e}"}
        except Exception as e:
            return {"status": "error", "error_message": f"An unexpected error occurred: {e}"}