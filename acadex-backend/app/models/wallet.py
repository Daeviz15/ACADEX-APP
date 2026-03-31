"""
Wallet & Transaction models.

Best practices:
  • Immutable transaction log (append-only pattern)
  • Enum-like status via String constraints
  • Indexed user_id for fast balance lookups
"""
import uuid
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.database import Base


class Transaction(Base):
    """Immutable financial transaction log."""
    __tablename__ = "transactions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    amount = Column(Integer, nullable=False)             # in kobo (smallest unit)
    transaction_type = Column(String(20), nullable=False)  # credit, debit
    description = Column(Text, nullable=True)
    reference = Column(String(100), unique=True, nullable=True, index=True)
    status = Column(String(20), default="completed", nullable=False)  # pending, completed, failed

    user = relationship("User")

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
