import uuid
from sqlalchemy import Column, String, Text, Boolean, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.database import Base

class Motivation(Base):
    """
    Daily inspiration for students.
    Stored in DB to allow dynamic updates without app redeploys.
    """
    __tablename__ = "motivations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    quote = Column(Text, nullable=False)
    author = Column(String(100), default="Unknown", nullable=False)
    
    # Allows identifying quotes used recently or pinning for specific days
    is_active = Column(Boolean, default=True, nullable=False)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
