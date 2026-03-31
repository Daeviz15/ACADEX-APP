"""
Verification Token model — for storing 6-digit OTPs safely.

Best practices:
  • Separate table to keep the main `users` table clean and fast.
  • Hashed tokens to prevent leaks.
  • Strict expiration timestamp (15 minutes).
"""
import uuid
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.database import Base


class VerificationToken(Base):
    """Temporary standard tokens sent to users via email/SMS."""
    __tablename__ = "verification_tokens"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # We store the bcrypt hash of the 6 digits, NOT the plain integer.
    hashed_token = Column(String(255), nullable=False)
    
    # For tracking if this is an email verification, password reset, etc.
    purpose = Column(String(50), default="email_verification", nullable=False)
    
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    user = relationship("User")
