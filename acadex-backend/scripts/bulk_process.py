import sys, os, asyncio
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from sqlalchemy import select
from app.database import AsyncSessionLocal
from app.services.ai_quiz_service import generate_quiz_for_pq
from app.models.past_question import PastQuestion
import logging

logging.basicConfig(level=logging.WARNING)

async def run_bulk():
    async with AsyncSessionLocal() as db:
        stmt = select(PastQuestion.id, PastQuestion.course_code, PastQuestion.year, PastQuestion.file_urls).where(PastQuestion.has_quiz == False)
        result = await db.execute(stmt)
        pq_data = result.all()
        
        if not pq_data:
            print("All Past Questions in the DB have been processed and have quizzes!")
            return
            
        print(f"Found {len(pq_data)} unprocessed Past Questions. Beginning bulk AI extraction...")
        
    success_count = 0
    for idx, row in enumerate(pq_data):
        pq_id, course_code, year, file_urls = row
        print(f"[{idx+1}/{len(pq_data)}] Processing {course_code} {year}...")
        
        if not file_urls or len(file_urls) == 0:
            print(f"  -> Skipped (No image files attached)")
            continue
            
        async with AsyncSessionLocal() as session:
            success = await generate_quiz_for_pq(str(pq_id), session)
            
        if success:
            print(f"  -> Successfully generated quiz JSON!")
            success_count += 1
        else:
            print(f"  -> Failed to generate quiz.")
        
        await asyncio.sleep(1)
        
    print(f"\nCompleted Bulk Processing! Successfully parsed {success_count} new exams into Quizzes.")

if __name__ == "__main__":
    asyncio.run(run_bulk())
