from google.adk.tools import ToolContext
from google.genai import types
from google.adk.sessions.state import State
from google.adk.agents.callback_context import CallbackContext
from typing import Dict, Any
import json
 

# def save_plant_image(
#     tool_context: ToolContext, 
#     image_bytes: bytes, 

# ):
#     """Save an image for using later in the diagnosis process.
    
#     Args:
#         image_bytes: The bytes of the image to be saved.
#         tool_context: The ADK tool context.

#     Returns:
#         A status message.
#     """
#     mime_type ="image/png"
#     filename = f"plant_disease_image.{mime_type.split('/')[1]}"

#     image_artifact = types.Part.from_data(
#         data=image_bytes,
#         mime_type=mime_type
#     )

#     try:
#         version = tool_context.save_artifact(filename=filename, artifact=image_artifact)
#         tool_context.state["image_upload_status"] = "UPLOADED"
#         print(f"Successfully saved image artifact '{filename}' as version {version}.")
#         # The event generated after this callback will contain a delta like:
#         # event.actions.artifact_delta == {filename: version}
#         return {"status": f"Image saved successfully as {filename} with version {version}."}
#     except ValueError as e:
#         print(f"Error saving image artifact: {e}. Is ArtifactService configured in Runner?")
#         return {"status": f"Failed to save image: {e}"}
#     except Exception as e:
#         # Handle potential storage errors (e.g., GCS permissions)
#         print(f"An unexpected error occurred during image artifact save: {e}")
#         return {"status": f"Failed to save image: {e}"}


def save_plant_info(
    tool_context: ToolContext, 
    key: str, 
    value: str
):
    """ 
    Save plant information in the tool context state.

    Args:
        key: the label indexing the memory to store the value. It should be one of the following: ['plant_name', 'disease_symptoms', 'pesticides_used'].
        value: the information to be stored.
        tool_context: The ADK tool context.

    Returns:
        A status message.
    """
    try:
        tool_context.state[key] = value

        current_plant_info = tool_context.state.get("plant_info", {})
        current_plant_info[key] = value
        tool_context.state["plant_info"] = current_plant_info

        print("Plant information saved successfully.")
        return {"status": f'Stored "{key}": "{value}"'}
    except Exception as e:
        print(f"An error occurred while saving plant information: {e}")
        return {"status": f"Failed to store {key}: {e}"}
    

def _set_initial_states(source: Dict[str, Any], target: State | dict[str, Any]):
    """
    Setting the initial session state given a JSON object of states.

    Args:
        source: A JSON object of states.
        target: The session state object to insert into.
    """
    try:
        target.update(source)
    except Exception as e:
        print(f"An error occurred while setting initial states: {e}")


def _load_precreated_user_profile(callback_context: CallbackContext):
    """
    Sets up the initial state.
    Set this as a callback as before_agent_call of the root_agent.
    This gets called before the system instruction is contructed.

    Args:
        callback_context: The callback context.
    """    
    data = {}
    INITIAL_STATE_PATH = "plant_health_support_agent/initial_data.json"
    with open(INITIAL_STATE_PATH, "r") as file:
        data = json.load(file)
        print(f"\nLoading Initial State: {data}\n")

    _set_initial_states(data["state"], callback_context.state)