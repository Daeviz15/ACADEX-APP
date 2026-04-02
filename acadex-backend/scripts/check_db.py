import sys, os, asyncio
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from sqlalchemy import text
from app.database import AsyncSessionLocal
import logging

logging.basicConfig(level=logging.INFO)

async def run():
    async with AsyncSessionLocal() as db:
        res = await db.execute(text("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='quiz_questions';
        """))
        cols = [r[0] for r in res.fetchall()]
        print("Columns in quiz_questions:", cols)
        
if __name__ == "__main__":
    asyncio.run(run())
