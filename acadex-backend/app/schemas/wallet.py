from typing import Optional
from pydantic import BaseModel, ConfigDict
from datetime import datetime
from uuid import UUID

class TransactionBase(BaseModel):
    amount: int
    transaction_type: str # e.g. "credit", "debit"
    description: Optional[str] = None
    reference: Optional[str] = None
    status: str # e.g. "pending", "completed", "failed"

class TransactionCreate(TransactionBase):
    pass

class TransactionResponse(TransactionBase):
    id: UUID
    user_id: UUID
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class CreditBalance(BaseModel):
    user_id: UUID
    balance: int
