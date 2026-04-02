"""
Past Questions API endpoints.

Best practices:
  • Server-side filtering via query params (composable AND logic)
  • ILIKE for case-insensitive search across course_code and course_title
  • Separate /filters endpoint so the Flutter app builds dynamic filter chips
  • All endpoints require JWT authentication
  • Results ordered by department, course_code, year for consistent display
"""
from typing import Any, Optional, List
import random
from fastapi import APIRouter, Depends, Query, BackgroundTasks, HTTPException
from sqlalchemy import select, func, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.user import User
from app.models.past_question import PastQuestion
from app.models.quiz import QuizQuestion
from app.api import deps
from app.schemas.past_question import PastQuestionOut, PastQuestionFilters
from app.schemas.quiz import QuizQuestionOut, TheoryGradingRequest, TheoryGradingResponse
from app.services.ai_quiz_service import generate_quiz_for_pq, grade_theory_answer
from app.database import AsyncSessionLocal
from uuid import UUID

router = APIRouter()


@router.get("", response_model=List[PastQuestionOut])
async def get_past_questions(
    department: Optional[str] = Query(None, description="Filter by department"),
    semester: Optional[str] = Query(None, description="Filter by semester (1st, 2nd)"),
    year: Optional[str] = Query(None, description="Filter by academic year (e.g. 2016_2017)"),
    level: Optional[int] = Query(None, description="Filter by level (100-500)"),
    search: Optional[str] = Query(None, description="Search course code or title"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Retrieve past questions with optional composable filters.
    All filters use AND logic. Search uses case-insensitive partial matching.
    """
    stmt = select(PastQuestion)

    # Apply filters (composable AND)
    if department:
        stmt = stmt.where(PastQuestion.department == department)
    if semester:
        stmt = stmt.where(PastQuestion.semester == semester)
    if year:
        stmt = stmt.where(PastQuestion.year == year)
    if level:
        stmt = stmt.where(PastQuestion.level == level)

    # Case-insensitive search across course_code and course_title
    if search:
        search_term = f"%{search.strip()}%"
        stmt = stmt.where(
            or_(
                PastQuestion.course_code.ilike(search_term),
                PastQuestion.course_title.ilike(search_term),
            )
        )

    # Consistent ordering: department → course_code → year (descending for newest first)
    stmt = stmt.order_by(
        PastQuestion.department,
        PastQuestion.course_code,
        PastQuestion.year.desc(),
    )

    result = await db.execute(stmt)
    return result.scalars().all()


@router.get("/filters", response_model=PastQuestionFilters)
async def get_past_question_filters(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Returns distinct filter values from the database.
    The Flutter app uses these to build dynamic filter chips
    instead of hardcoding filter options.
    """
    # Fetch distinct non-null values for each filterable column
    dept_result = await db.execute(
        select(PastQuestion.department)
        .where(PastQuestion.department.isnot(None))
        .distinct()
        .order_by(PastQuestion.department)
    )
    year_result = await db.execute(
        select(PastQuestion.year)
        .distinct()
        .order_by(PastQuestion.year.desc())
    )
    sem_result = await db.execute(
        select(PastQuestion.semester)
        .where(PastQuestion.semester.isnot(None))
        .distinct()
        .order_by(PastQuestion.semester)
    )
    level_result = await db.execute(
        select(PastQuestion.level)
        .where(PastQuestion.level.isnot(None))
        .distinct()
        .order_by(PastQuestion.level)
    )

    return PastQuestionFilters(
        departments=[row[0] for row in dept_result.all()],
        years=[row[0] for row in year_result.all()],
        semesters=[row[0] for row in sem_result.all()],
        levels=[row[0] for row in level_result.all()],
    )


async def generate_quiz_background_wrapper(pq_id: str):
    async with AsyncSessionLocal() as session:
        await generate_quiz_for_pq(pq_id, session)


@router.post("/{id}/generate-quiz", status_code=202)
async def trigger_quiz_generation(
    id: UUID,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Triggers the AI generation pipeline to extract a quiz from the PQ images.
    Runs asynchronously in the background.
    """
    pq = await db.get(PastQuestion, id)
    if not pq:
        raise HTTPException(status_code=404, detail="Past question not found")
        
    background_tasks.add_task(generate_quiz_background_wrapper, str(id))
    return {"message": "Quiz generation queued successfully."}


@router.get("/{id}/quiz", response_model=List[QuizQuestionOut])
async def get_past_question_quiz(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Retrieve all quiz questions generated for a specific past question.
    """
    stmt = select(QuizQuestion).where(QuizQuestion.past_question_id == id)
    result = await db.execute(stmt)
    questions = list(result.scalars().all())
    random.shuffle(questions)
    return questions


@router.post("/grade-theory", response_model=TheoryGradingResponse)
async def grade_theory_endpoint(
    req: TheoryGradingRequest,
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Grades a student's theory answer in real-time using AI and provides personalized feedback.
    """
    result = await grade_theory_answer(
        question_text=req.question_text,
        ideal_answer=req.ideal_answer,
        user_answer=req.user_answer,
        user_name=req.user_name
    )
    return result

