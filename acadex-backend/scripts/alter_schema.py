import sys, os, asyncio
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from sqlalchemy import text
from app.database import AsyncSessionLocal

async def run():
    async with AsyncSessionLocal() as db:
        await db.execute(text("ALTER TABLE quiz_questions ALTER COLUMN correct_answer TYPE TEXT"))
        await db.commit()
        print("Schema altered successfully!")

if __name__ == "__main__":
    asyncio.run(run())
