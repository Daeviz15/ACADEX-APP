import os
import sys

base_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(base_dir)

from app.core.config import settings
from google import genai

def list_models():
    print("Testing API Key models...")
    client = genai.Client(api_key=settings.GEMINI_API_KEY)
    
    try:
        available_models = [m.name for m in client.models.list() if "generateContent" in m.supported_actions]
        print(f"Available generateContent models: {available_models}")
    except Exception as e:
        print(f"List methods using v0.2.0 client via `client.models.list()` failed: {e}")
        try:
             # Try fallback API style
             available_models = [m.name for m in client.models.list_models()]
             print(f"Models via fallback list(): {available_models}")
        except Exception as e2:
             print(f"Fallback list() failed: {e2}")

if __name__ == "__main__":
    list_models()
