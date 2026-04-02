import sys, os, asyncio
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from sqlalchemy import text, select, delete
from app.database import AsyncSessionLocal
from app.services.ai_quiz_service import generate_quiz_for_pq
from app.models.past_question import PastQuestion
from app.models.quiz import QuizQuestion

async def run():
    async with AsyncSessionLocal() as db:
        # 1. Delete Physics mock data from DB (cleaning up DB so it doesn't polute the UI)
        print("Cleaning up Physics mock data...")
        await db.execute(text("DELETE FROM quiz_questions WHERE question_text ILIKE '%physics%' OR explanation ILIKE '%physics%'"))
        await db.execute(text("DELETE FROM past_questions WHERE course_code ILIKE '%phy%' OR course_title ILIKE '%physics%'"))
        await db.commit()
        print("Deleted!")
        
        # 2. Pick exactly ONE image to process via OpenAI to test without ratelimits
        stmt = select(PastQuestion).where(
            PastQuestion.has_quiz == False # Make sure it doesn't already have one
        ).limit(1)
        
        result = await db.execute(stmt)
        pq = result.scalars().first()
        
        if pq:
            print(f"Processing Past Question {pq.id} ({pq.course_code} {pq.year})...")
            success = await generate_quiz_for_pq(str(pq.id), db)
            print(f"OpenAI OCR Success: {success}")
            
            try:
                data = json.loads(response_text)
                print(f"RAW JSON OUTPUT: {json.dumps(data, indent=2)}")
            except Exception as e:
                pass
            
            # Print out the structured JSON responses committed to DB
            stmt2 = select(QuizQuestion).where(QuizQuestion.past_question_id == pq.id)
            res2 = await db.execute(stmt2)
            questions = res2.scalars().all()
            print(f"Extracted {len(questions)} logical quiz questions.")
            
            for q in questions:
                print(f"Q: {q.question_text}")
                print(f"Options: {q.options}")
                print(f"Correct: {q.correct_answer}")
                print(f"Difficulty: {q.difficulty}")
                print("---")
        else:
            print("No unprocessed past question found with file attachments.")

if __name__ == "__main__":
    asyncio.run(run())
