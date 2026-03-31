"""
Models package — import all models so SQLAlchemy Base.metadata
knows about every table before Alembic autogenerate runs.
"""
from app.database import Base

from app.models.user import User
from app.models.quiz import QuizCategory, QuizQuestion, QuizAttempt
from app.models.wallet import Transaction
from app.models.past_question import PastQuestion
from app.models.chat import ChatSession, ChatMessage
from app.models.service import ServiceRequest
from app.models.otp import VerificationToken

__all__ = [
    "Base",
    "User",
    "QuizCategory",
    "QuizQuestion",
    "QuizAttempt",
    "Transaction",
    "PastQuestion",
    "ChatSession",
    "ChatMessage",
    "ServiceRequest",
    "VerificationToken",
]
