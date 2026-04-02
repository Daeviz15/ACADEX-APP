"""
Past Questions model — metadata for uploaded past exam papers.

Best practices:
  • Composite index on (university, course_code) for filtered searches
  • Text fields for flexible content
  • Year as String for range queries (e.g. 2016_2017)
"""
import uuid
from sqlalchemy import Column, String, Integer, DateTime, Text, JSON, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.database import Base


class PastQuestion(Base):
    """Past exam paper metadata and content."""
    __tablename__ = "past_questions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    department = Column(String(100), nullable=True, index=True)
    university = Column(String(200), nullable=False, index=True)
    course_code = Column(String(20), nullable=False, index=True)
    course_title = Column(String(200), nullable=False)
    year = Column(String(20), nullable=False)
    semester = Column(String(20), nullable=True)        # 1st, 2nd
    level = Column(Integer, nullable=True, index=True)  # 100, 200, 300, 400, 500
    file_urls = Column(JSON, nullable=True)             # Array of links to images/PDFs
    content_text = Column(Text, nullable=True)          # extracted text for search
    question_count = Column(Integer, nullable=True)
    has_quiz = Column(Boolean, default=False, nullable=False)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
