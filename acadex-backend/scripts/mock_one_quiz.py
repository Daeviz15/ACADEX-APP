import asyncio
import uuid
import sys
import os

# Ensure the script can find the 'app' module
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import AsyncSessionLocal
from app.models.quiz import QuizQuestion
from app.models.past_question import PastQuestion
from sqlalchemy import select, update

# PHY201 2018_2019 ID from logs
PQ_ID = "05f58b17-9a68-4cf6-bcb5-d01e6a5fb2d7"

MOCK_QUESTIONS = [
    {
        "question_text": "A particle moves in a circle of radius 2m with a constant speed of 10m/s. What is its centripetal acceleration?",
        "options": ["5 m/s²", "20 m/s²", "50 m/s²", "100 m/s²"],
        "correct_answer": "50 m/s²",
        "explanation": "Centripetal acceleration a = v²/r. Here v = 10 and r = 2. So a = 10²/2 = 100/2 = 50 m/s².",
        "difficulty": "medium"
    },
    {
        "question_text": "Which of the following is a scalar quantity?",
        "options": ["Velocity", "Force", "Work", "Acceleration"],
        "correct_answer": "Work",
        "explanation": "Work is defined as the dot product of force and displacement (W = F · d), making it a scalar quantity. Velocity, Force, and Acceleration are all vectors.",
        "difficulty": "easy"
    },
    {
        "question_text": "The first law of thermodynamics is a statement of:",
        "options": ["Conservation of momentum", "Conservation of energy", "Conservation of mass", "The law of entropy"],
        "correct_answer": "Conservation of energy",
        "explanation": "The first law of thermodynamics states that energy cannot be created or destroyed, only transformed from one form to another.",
        "difficulty": "easy"
    },
    {
        "question_text": "A 5kg block is pulled with a force of 20N. If the surface is frictionless, what is its acceleration?",
        "options": ["2 m/s²", "4 m/s²", "5 m/s²", "10 m/s²"],
        "correct_answer": "4 m/s²",
        "explanation": "F = ma. So a = F/m = 20 / 5 = 4 m/s².",
        "difficulty": "easy"
    }
]

async def mock_quiz():
    async with AsyncSessionLocal() as session:
        # Check if PQ exists
        res = await session.execute(select(PastQuestion).where(PastQuestion.id == PQ_ID))
        pq = res.scalar_one_or_none()
        
        if not pq:
            print(f"PQ with ID {PQ_ID} not found. Searching for any PQ...")
            res = await session.execute(select(PastQuestion).limit(1))
            pq = res.scalar_one_or_none()
            if not pq:
                print("No Past Questions found in DB.")
                return
        
        print(f"Mocking quiz for PQ: {pq.course_code} ({pq.id})")
        
        # Clear existing quiz for this PQ to avoid duplicates
        from sqlalchemy import delete
        await session.execute(delete(QuizQuestion).where(QuizQuestion.past_question_id == pq.id))
        
        # Add mock questions
        for q in MOCK_QUESTIONS:
            quiz_q = QuizQuestion(
                past_question_id=pq.id,
                question_text=q["question_text"],
                options=q["options"],
                correct_answer=q["correct_answer"],
                explanation=q["explanation"],
                difficulty=q["difficulty"]
            )
            session.add(quiz_q)
        
        # Set has_quiz = True
        await session.execute(
            update(PastQuestion)
            .where(PastQuestion.id == pq.id)
            .values(has_quiz=True)
        )
        
        await session.commit()
        print(f"✅ Successfully mocked {len(MOCK_QUESTIONS)} questions for {pq.course_code}")

if __name__ == "__main__":
    asyncio.run(mock_quiz())
