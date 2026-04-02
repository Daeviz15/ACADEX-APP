import sys, os, asyncio
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from sqlalchemy import text
from app.database import AsyncSessionLocal
import json

async def run():
    async with AsyncSessionLocal() as db:
        res = await db.execute(text("SELECT question_text, question_type, options FROM quiz_questions WHERE question_text LIKE '%Explain the concept of data types%' LIMIT 1"))
        row = res.fetchone()
        if row:
            print(f"Type: {row[1]}, Options: {row[2]}, Text: {row[0]}")
        else:
            print("Not found")

if __name__ == "__main__":
    asyncio.run(run())
