"""
REST API endpoints for Authentication.

Best practices:
  • OAuth2PasswordRequestForm strictly requires x-www-form-urlencoded data.
  • Dependencies handle DB lifecycle and User extraction.
  • Return proper HTTP 201 Created for registration.
  • BackgroundTasks used to dispatch emails without slowing down the HTTP response.
"""
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.api import deps
from app.schemas.auth import UserCreate, UserResponse, Token, OTPVerify, GoogleLogin
from app.services import auth_service
from app.services.email_service import send_verification_email
from app.core.security import create_access_token
from app.models.user import User

router = APIRouter()


from app.database import AsyncSessionLocal
import uuid

async def _dispatch_otp_email(user_id: uuid.UUID, user_email: str, user_name: str):
    """Internal helper to securely generate an OTP and dispatch the email."""
    # Open an isolated session for background processing!
    async with AsyncSessionLocal() as bg_db:
        # Generate the 6 digit code and store its hash in the DB
        otp_code = await auth_service.generate_and_store_otp(bg_db, user_id)
        
    # Send the actual email (this runs asynchronously in a fast thread)
    await send_verification_email(to_email=user_email, token=otp_code, user_name=user_name)


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(
    user_in: UserCreate,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db)
) -> Any:
    """Register a new user in Acadex and send them a verification email code."""
    existing_user = await auth_service.get_user_by_email(db, email=user_in.email)
    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="A user with this email address already exists.",
        )
    
    # 1. Create the user unverified
    user = await auth_service.create_user(db, user_in=user_in)
    
    # 2. Instantly schedule the database token + SMTP email work to the background!
    # This avoids closing the main AsyncSession prematurely.
    background_tasks.add_task(_dispatch_otp_email, user.id, user.email, user.name)
    
    return user


@router.post("/verify-otp", response_model=Token)
async def verify_otp(
    payload: OTPVerify,
    db: AsyncSession = Depends(get_db)
) -> Any:
    """
    Validate the 6-digit code sent to the email.
    If valid, marks the user as verified and instantly returns a JWT (Auto-Login).
    """
    user = await auth_service.get_user_by_email(db, email=payload.email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    if user.is_verified:
        raise HTTPException(status_code=400, detail="User is already verified")
        
    # Strictly check the cryptographic validity of the code
    is_valid = await auth_service.verify_and_consume_otp(db, user.id, payload.otp_code)
    
    if not is_valid:
        raise HTTPException(status_code=400, detail="Invalid or expired verification code")
        
    # Code was perfect! Send back the JWT Bearer token to skip the login screen
    return {
        "access_token": create_access_token(data={"sub": str(user.id)}),
        "token_type": "bearer"
    }


@router.post("/login", response_model=Token)
async def login(
    db: AsyncSession = Depends(get_db),
    form_data: OAuth2PasswordRequestForm = Depends()
) -> Any:
    """
    OAuth2 compatible token login.
    Note: 'username' field strictly receives the email address.
    """
    user = await auth_service.authenticate_user(
        db, email=form_data.username, password=form_data.password
    )
    if not user:
        raise HTTPException(
            status_code=400, 
            detail="Incorrect email or password."
        )
    if not user.is_active:
        raise HTTPException(
            status_code=400, 
            detail="Inactive user account."
        )
        
    # Added during Phase 2.5: Enforce Email Verification!
    if not user.is_verified:
        raise HTTPException(
            status_code=403, 
            detail="Please verify your email address to log in."
        )
    
    # Send back the signed JWT Token
    return {
        "access_token": create_access_token(data={"sub": str(user.id)}),
        "token_type": "bearer"
    }


@router.post("/google/login", response_model=Token)
async def google_login(
    payload: GoogleLogin,
    db: AsyncSession = Depends(get_db)
) -> Any:
    """
    Exchange a Google ID Token for an Acadex JWT.
    Validates the token's signature and audience before auto-registering the user.
    """
    # 1. Verify the cryptographic authenticity of the token
    google_data = await auth_service.verify_google_id_token(payload.id_token)
    if not google_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired Google identity token."
        )
    
    # 2. Get or create a verified Acadex user for this identity
    user = await auth_service.get_or_create_google_user(db, google_data)
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Inactive user account."
        )

    # 3. Issue the standard Acadex JWT signed for this user's UID
    return {
        "access_token": create_access_token(data={"sub": str(user.id)}),
        "token_type": "bearer"
    }


@router.get("/me", response_model=UserResponse)
async def read_current_user(
    current_user: User = Depends(deps.get_current_user)
) -> Any:
    """Get current authenticated user profile."""
    return current_user
