from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.database import get_db
from app.models.user import User
from app.api import deps
from app.models.activity import UserActivity
from app.models.motivation import Motivation
from pydantic import BaseModel
from uuid import UUID
from app.schemas.dashboard import DashboardSummary, ActivitySchema, MotivationSchema

class ActivityCreate(BaseModel):
    activity_type: str
    title: str
    status_text: Optional[str] = None
    progress: float
    interaction_id: Optional[UUID] = None

router = APIRouter()

@router.post("/activity", response_model=ActivitySchema)
async def log_activity(
    activity_in: ActivityCreate,
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Any:
    """
    Logs a new user interaction/activity (e.g. from Quiz or Chat).
    """
    new_activity = UserActivity(
        user_id=current_user.id,
        activity_type=activity_in.activity_type,
        title=activity_in.title,
        status_text=activity_in.status_text,
        progress=activity_in.progress,
        interaction_id=activity_in.interaction_id,
    )
    db.add(new_activity)
    await db.commit()
    await db.refresh(new_activity)
    return ActivitySchema.from_orm(new_activity)

@router.get("/summary", response_model=DashboardSummary)
async def get_dashboard_summary(
    current_user: User = Depends(deps.get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Any:
    """
    Consolidated Dashboard summary:
    1. Returns a random/daily active motivation quote.
    2. Returns the single most recent activity for the user.
    """
    # 1. Fetch Motivation (Random choice for variation)
    motivation_query = select(Motivation).where(Motivation.is_active == True)
    result = await db.execute(motivation_query)
    quotes = result.scalars().all()
    
    # Fallback if DB isn't seeded yet
    if not quotes:
        motivation = MotivationSchema(
            quote="Focus on your goal. Don't look in any direction but ahead.",
            author="Acadex"
        )
    else:
        # Simple selection (could be random.choice for excitement)
        import random
        selected = random.choice(quotes)
        motivation = MotivationSchema.from_orm(selected)

    # 2. Fetch Last Activity
    activity_query = (
        select(UserActivity)
        .where(UserActivity.user_id == current_user.id)
        .order_by(desc(UserActivity.created_at))
        .limit(1)
    )
    activity_result = await db.execute(activity_query)
    last_activity = activity_result.scalar_one_or_none()

    return DashboardSummary(
        motivation=motivation,
        last_activity=ActivitySchema.from_orm(last_activity) if last_activity else None
    )
