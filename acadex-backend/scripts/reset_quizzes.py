"""
One-time script to reset all quiz data so we can rescan from Cloudinary.
- Sets has_quiz = False on all PastQuestions
- Deletes all existing QuizQuestion rows
"""
import sys, os, asyncio
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from sqlalchemy import text
from app.database import AsyncSessionLocal

async def main():
    async with AsyncSessionLocal() as db:
        # 1. Delete all old quiz questions
        result = await db.execute(text("DELETE FROM quiz_questions"))
        print(f"Deleted {result.rowcount} old quiz question rows.")

        # 2. Reset has_quiz flag on all past questions
        result2 = await db.execute(text("UPDATE past_questions SET has_quiz = false"))
        print(f"Reset has_quiz on {result2.rowcount} past question rows.")

        await db.commit()
        print("Done! All quizzes cleared. Ready for fresh Cloudinary-powered rescan.")

if __name__ == "__main__":
    asyncio.run(main())
