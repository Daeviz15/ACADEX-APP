"""
Service Request model — student support / academic service tickets.

Best practices:
  • status tracking for workflow (pending → in_progress → completed)
  • is_priority flag for urgent requests
  • Linked to user via FK
"""
import uuid
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.database import Base


class ServiceRequest(Base):
    """A student's request for an academic service."""
    __tablename__ = "service_requests"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    service_type = Column(String(100), nullable=False)  # e.g. "Custom Software", "AI Tutors"
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    status = Column(String(20), default="pending", nullable=False)  # pending, in_progress, completed, cancelled
    is_priority = Column(Boolean, default=False, nullable=False)

    user = relationship("User")

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
