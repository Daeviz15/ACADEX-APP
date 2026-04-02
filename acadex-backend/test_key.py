"""Quick diagnostic: test the Gemini API key directly via REST."""
import os, sys, httpx, json

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from app.core.config import settings

key = settings.GEMINI_API_KEY
print(f"Key (last 6): ...{key[-6:]}")

# Try a simple text-only request to test quota
url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={key}"
payload = {
    "contents": [{"parts": [{"text": "Say hello in one word."}]}]
}

print(f"POST {url[:80]}...")
r = httpx.post(url, json=payload, timeout=30)
print(f"Status: {r.status_code}")
print(f"Response: {r.text[:500]}")
