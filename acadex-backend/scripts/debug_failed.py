import sys, os, asyncio
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from sqlalchemy import select
from app.database import AsyncSessionLocal
from app.services.ai_quiz_service import generate_quiz_for_pq
from app.models.past_question import PastQuestion
import logging

logging.basicConfig(level=logging.DEBUG)

async def run():
    async with AsyncSessionLocal() as db:
        stmt = select(PastQuestion).where(PastQuestion.has_quiz == False)
        result = await db.execute(stmt)
        pqs = result.scalars().all()
        print(f"Found {len(pqs)} failed/unprocessed PQs.")
        
        for pq in pqs:
            print(f"Debug PQ {pq.id} - Files: {pq.file_urls}")
            # Try running
            success = await generate_quiz_for_pq(str(pq.id), db)
            print("Success:", success)

if __name__ == "__main__":
    asyncio.run(run())
