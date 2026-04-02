"""
Quiz request/response schemas
"""
from typing import List, Optional
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, ConfigDict

class QuizQuestionOut(BaseModel):
    id: UUID
    category_id: Optional[UUID] = None
    past_question_id: Optional[UUID] = None
    question_text: str
    options: List[str]
    correct_answer: str
    explanation: Optional[str] = None
    difficulty: str
    question_type: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class TheoryGradingRequest(BaseModel):
    question_text: str
    ideal_answer: str
    user_answer: str
    user_name: str

class TheoryGradingResponse(BaseModel):
    score: int
    feedback: str
