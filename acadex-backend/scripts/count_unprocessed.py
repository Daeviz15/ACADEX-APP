import asyncio, sys, os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from sqlalchemy import select, func, text
from app.database import AsyncSessionLocal

async def run():
    async with AsyncSessionLocal() as db:
        res = await db.execute(text("SELECT count(*) FROM past_questions WHERE has_quiz = false"))
        print("Total left to process:", res.scalar())
asyncio.run(run())
