from uuid import UUID
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel

class ActivitySchema(BaseModel):
    id: UUID
    activity_type: str
    title: str
    status_text: Optional[str] = None
    progress: float
    created_at: datetime

    class Config:
        from_attributes = True

class MotivationSchema(BaseModel):
    quote: str
    author: str

    class Config:
        from_attributes = True

class ServiceSchema(BaseModel):
    id: str # ID used for hardcoded icons (e.g. 'academic_guidance')
    title: str
    subtitle: str

    class Config:
        from_attributes = True

class DashboardSummary(BaseModel):
    """Combined model for the primary screen fetch."""
    motivation: MotivationSchema
    last_activity: Optional[ActivitySchema] = None
