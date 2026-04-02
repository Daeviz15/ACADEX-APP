"""
Past Question Pydantic schemas — request/response contracts.

Best practices:
  • Separate input (create/update) schemas from output schemas
  • Use orm_mode (from_attributes) for direct SQLAlchemy → Pydantic conversion
  • Keep response payloads lean — only expose what the client needs
"""
from typing import Optional, List
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, ConfigDict


class PastQuestionOut(BaseModel):
    """Response schema for a single past question."""
    id: UUID
    department: Optional[str] = None
    course_code: str
    course_title: str
    year: str
    semester: Optional[str] = None
    level: Optional[int] = None
    file_urls: Optional[List[str]] = None
    question_count: Optional[int] = None
    has_quiz: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class PastQuestionFilters(BaseModel):
    """Available filter options derived from database contents."""
    departments: List[str]
    years: List[str]
    semesters: List[str]
    levels: List[int]
