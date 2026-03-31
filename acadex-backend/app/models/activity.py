import uuid
from sqlalchemy import Column, String, DateTime, ForeignKey, Float, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.database import Base

class UserActivity(Base):
    """
    Tracks user engagements across the platform for the Dashboard.
    Supports 'Last Activity' logic for the home screen.
    """
    __tablename__ = "user_activities"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # activity_type: 'chat', 'quiz', 'service_request'
    activity_type = Column(String(50), nullable=False)
    
    title = Column(String(200), nullable=False)
    status_text = Column(String(100), nullable=True) # e.g. "In Progress", "8/10 Score"
    
    # Progress from 0.0 to 1.0 (e.g. 0.65 for 65% completion)
    progress = Column(Float, default=0.0, nullable=False)
    
    # Optional metadata (JSON-like string if needed, or simple text)
    interaction_id = Column(UUID(as_uuid=True), nullable=True) # Link to Chat ID or Quiz ID
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    user = relationship("User")
