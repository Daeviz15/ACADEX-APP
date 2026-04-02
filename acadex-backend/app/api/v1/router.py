from fastapi import APIRouter
from app.api.v1 import (
    auth,
    wallet,
    user,
    dashboard,
    services,
    past_questions,
)

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(wallet.router, prefix="/wallet", tags=["Wallet"])
api_router.include_router(user.router, prefix="/users", tags=["Users"])
api_router.include_router(dashboard.router, prefix="/dashboard", tags=["Dashboard"])
api_router.include_router(services.router, prefix="/services", tags=["Services"])
api_router.include_router(past_questions.router, prefix="/past-questions", tags=["Past Questions"])
