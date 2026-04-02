import asyncio
import sys
import os
import logging

# Add the backend root to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import select
from app.database import AsyncSessionLocal
from app.models.past_question import PastQuestion
from app.services.ai_quiz_service import generate_quiz_for_pq

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

MAX_RETRIES = 3
RETRY_DELAY_SECONDS = 45  # Wait between retries (rate limit cooldown)

async def generate_all_missing_quizzes():
    async with AsyncSessionLocal() as session:
        stmt = select(PastQuestion).where(PastQuestion.has_quiz == False).limit(1)
        result = await session.execute(stmt)
        pqs = result.scalars().all()
        
        logger.info(f"Found {len(pqs)} past questions needing quiz generation.")
        
        for pq in pqs:
            if not pq.file_urls:
                continue
            
            for attempt in range(1, MAX_RETRIES + 1):
                logger.info(f"[Attempt {attempt}/{MAX_RETRIES}] Generating quiz for PQ: {pq.course_code} {pq.year} - {pq.id}")
                success = await generate_quiz_for_pq(str(pq.id), session)
                if success:
                    logger.info(f"✅ Success for {pq.course_code}")
                    break
                else:
                    if attempt < MAX_RETRIES:
                        logger.warning(f"⏳ Waiting {RETRY_DELAY_SECONDS}s before retry...")
                        await asyncio.sleep(RETRY_DELAY_SECONDS)
                    else:
                        logger.error(f"❌ Failed for {pq.course_code} after {MAX_RETRIES} attempts")
                
        logger.info("Batch generation complete.")

if __name__ == "__main__":
    asyncio.run(generate_all_missing_quizzes())
