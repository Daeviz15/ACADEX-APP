from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from fastapi import HTTPException

from app.models.user import User
from app.models.wallet import Transaction
from app.schemas.wallet import CreditBalance

async def get_credit_balance(db: AsyncSession, user_id: UUID) -> CreditBalance:
    result = await db.execute(select(User).filter(User.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return CreditBalance(user_id=user.id, balance=user.wallet_balance)

async def get_transaction_history(db: AsyncSession, user_id: UUID):
    result = await db.execute(
        select(Transaction)
        .filter(Transaction.user_id == user_id)
        .order_by(Transaction.created_at.desc())
    )
    return result.scalars().all()

async def simulate_paystack_deposit(db: AsyncSession, user_id: UUID, amount: int, reference: str):
    # Retrieve user
    result = await db.execute(select(User).filter(User.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Check for duplicate reference
    existing_tx = await db.execute(select(Transaction).filter(Transaction.reference == reference))
    if existing_tx.scalars().first():
        raise HTTPException(status_code=400, detail="Transaction reference already processed.")

    # Create Transaction Record
    new_tx = Transaction(
        user_id=user_id,
        amount=amount,
        transaction_type="CREDIT_PURCHASE",
        status="SUCCESS",
        reference=reference,
        description=f"Purchased {amount} Acadex Credits via Paystack simulator"
    )
    
    # Update User Balance (Highly atomic within this transaction block)
    user.wallet_balance += amount
    
    db.add(new_tx)
    await db.commit()
    await db.refresh(new_tx)
    
    return new_tx
