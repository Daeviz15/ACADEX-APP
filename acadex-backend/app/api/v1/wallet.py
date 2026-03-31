from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.database import get_db
from app.models.user import User
from app.schemas.wallet import CreditBalance, TransactionResponse, TransactionCreate
from app.services import wallet_service

router = APIRouter()

@router.get("/balance", response_model=CreditBalance)
async def get_balance(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Securely fetch the authenticated user's live Acadex Credit balance."""
    return await wallet_service.get_credit_balance(db, current_user.id)

@router.get("/transactions", response_model=List[TransactionResponse])
async def get_transactions(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve the sorted chronological history of the user's credits and expenditures."""
    return await wallet_service.get_transaction_history(db, current_user.id)

@router.post("/deposit", response_model=TransactionResponse)
async def simulate_deposit(
    amount: int,
    reference: str, # A dummy unique ID from the UI for now
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Simulates a successful Paystack bank transfer or card payment.
    Internally generates the transaction and updates the user's credit cache.
    """
    return await wallet_service.simulate_paystack_deposit(
        db=db, 
        user_id=current_user.id, 
        amount=amount, 
        reference=reference
    )
