"""
Quiz models — questions, attempts, and leaderboard.

Best practices:
  • UUID PKs across all tables for consistency
  • Foreign keys with ON DELETE CASCADE for data integrity
  • Composite indexes on (user_id, quiz_id) for fast lookups
  • JSONB for flexible answer storage
"""
import uuid
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, Text, Boolean
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.database import Base


class QuizCategory(Base):
    """Subject categories for quizzes (e.g. Mathematics, Physics)."""
    __tablename__ = "quiz_categories"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(100), unique=True, nullable=False)
    icon = Column(String(50), nullable=True)
    description = Column(Text, nullable=True)

    questions = relationship("QuizQuestion", back_populates="category", cascade="all, delete-orphan")

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class QuizQuestion(Base):
    """Individual quiz questions."""
    __tablename__ = "quiz_questions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    category_id = Column(UUID(as_uuid=True), ForeignKey("quiz_categories.id", ondelete="CASCADE"), nullable=False, index=True)
    question_text = Column(Text, nullable=False)
    options = Column(JSONB, nullable=False)     # ["A", "B", "C", "D"]
    correct_answer = Column(String(10), nullable=False)
    explanation = Column(Text, nullable=True)
    difficulty = Column(String(20), default="medium")  # easy, medium, hard

    category = relationship("QuizCategory", back_populates="questions")

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class QuizAttempt(Base):
    """Records each user's quiz session."""
    __tablename__ = "quiz_attempts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    category_id = Column(UUID(as_uuid=True), ForeignKey("quiz_categories.id", ondelete="CASCADE"), nullable=False, index=True)
    score = Column(Integer, nullable=False, default=0)
    total_questions = Column(Integer, nullable=False)
    time_taken_seconds = Column(Integer, nullable=True)
    answers = Column(JSONB, nullable=True)  # {question_id: selected_answer}

    user = relationship("User")
    category = relationship("QuizCategory")

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
