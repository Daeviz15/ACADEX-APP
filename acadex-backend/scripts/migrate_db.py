import sys, os, asyncio
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from sqlalchemy import text
from app.database import AsyncSessionLocal
import logging

logging.basicConfig(level=logging.INFO)

async def run():
    async with AsyncSessionLocal() as db:
        try:
            await db.execute(text("ALTER TABLE quiz_questions ADD COLUMN question_type VARCHAR(20) NOT NULL DEFAULT 'objective'"))
            await db.commit()
            print("Migration successful: added question_type column.")
        except Exception as e:
            print("Migration failed (might already exist?):", e)

if __name__ == "__main__":
    asyncio.run(run())
