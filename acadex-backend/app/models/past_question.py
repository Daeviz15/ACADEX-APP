"""
Past Questions model — metadata for uploaded past exam papers.

Best practices:
  • Composite index on (university, course_code) for filtered searches
  • Text fields for flexible content
  • Year as Integer for range queries
"""
import uuid
from sqlalchemy import Column, String, Integer, DateTime, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.database import Base


class PastQuestion(Base):
    """Past exam paper metadata and content."""
    __tablename__ = "past_questions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    university = Column(String(200), nullable=False, index=True)
    course_code = Column(String(20), nullable=False, index=True)
    course_title = Column(String(200), nullable=False)
    year = Column(Integer, nullable=False)
    semester = Column(String(20), nullable=True)        # first, second
    file_url = Column(Text, nullable=True)              # link to PDF/image
    content_text = Column(Text, nullable=True)           # extracted text for search
    question_count = Column(Integer, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
