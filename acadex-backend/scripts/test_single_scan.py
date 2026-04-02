"""Single-exam rescan test to validate exhaustive extraction with sub-questions."""
import sys, os, asyncio
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from sqlalchemy import select, text
from app.database import AsyncSessionLocal
from app.services.ai_quiz_service import generate_quiz_for_pq
from app.models.past_question import PastQuestion

async def run():
    # Find the specific exam
    async with AsyncSessionLocal() as db:
        result = await db.execute(
            select(PastQuestion).where(
                PastQuestion.course_code == "CSC201",
                PastQuestion.year == "2019_2020"
            )
        )
        pq = result.scalars().first()
        
        if not pq:
            print("ERROR: CSC201 2019_2020 not found!")
            return
            
        print(f"Target: {pq.course_code} {pq.year}")
        print(f"Cloudinary URLs: {len(pq.file_urls)} pages")
        for url in pq.file_urls:
            print(f"  -> {url[:80]}...")
        print(f"has_quiz: {pq.has_quiz}")
        print()
    
    # Run the AI extraction
    print("Starting AI extraction with improved prompt...")
    async with AsyncSessionLocal() as session:
        success = await generate_quiz_for_pq(str(pq.id), session)
    
    if not success:
        print("FAILED to generate quiz!")
        return
    
    print("SUCCESS! Now verifying results...\n")
    
    # Verify
    async with AsyncSessionLocal() as db:
        res = await db.execute(text("""
            SELECT question_text, question_type, difficulty
            FROM quiz_questions 
            WHERE past_question_id = :pq_id
            ORDER BY question_type, id
        """), {"pq_id": str(pq.id)})
        rows = res.all()
        
        obj_count = 0
        theory_count = 0
        
        print(f"Total questions extracted: {len(rows)}")
        print("=" * 70)
        
        for i, row in enumerate(rows):
            q_type = row[1]
            if q_type == 'objective':
                obj_count += 1
            else:
                theory_count += 1
            # Truncate long text for display
            text_preview = row[0][:90] + "..." if len(row[0]) > 90 else row[0]
            print(f"  [{q_type:>9}] [{row[2]:>6}] {text_preview}")
        
        print("=" * 70)
        print(f"Objective: {obj_count} | Theory: {theory_count} | Total: {len(rows)}")
        print(f"\nPrevious scan had: 8 questions (4 obj + 4 theory)")
        print(f"New scan has:      {len(rows)} questions ({obj_count} obj + {theory_count} theory)")

if __name__ == "__main__":
    asyncio.run(run())
