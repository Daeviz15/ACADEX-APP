import sys, os, asyncio
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__))))
from app.core.config import settings
from google import genai

async def run():
    gemini_client = genai.Client(api_key=settings.GEMINI_API_KEY)
    try:
        response = await gemini_client.aio.models.generate_content(
            model='gemini-2.0-flash',
            contents='Say hello'
        )
        print("Response:", response.text)
    except Exception as e:
        print("ERROR:", e)

asyncio.run(run())
