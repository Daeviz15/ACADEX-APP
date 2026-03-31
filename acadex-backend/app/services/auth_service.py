"""
Authentication service layer.

Best practices:
  • Raw database operations belong here, not in the API routers.
  • Return fully populated ORM objects (like User) back to the APIs.
  • OTPs are securely hashed with bcrypt just like passwords.
"""
import uuid
import secrets
from typing import Optional
from datetime import datetime, timedelta, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.models.user import User
from app.models.otp import VerificationToken
from app.schemas.auth import UserCreate
from app.core.security import hash_password, verify_password
from app.core.config import settings
from google.oauth2 import id_token
from google.auth.transport import requests


async def get_user_by_email(db: AsyncSession, email: str) -> Optional[User]:
    """Retrieve a user securely by exact email match."""
    result = await db.execute(select(User).where(User.email == email))
    return result.scalars().first()


async def create_user(db: AsyncSession, user_in: UserCreate) -> User:
    """Create a new unverified user with a hashed password."""
    user = User(
        email=user_in.email,
        name=user_in.name,
        hashed_password=hash_password(user_in.password),
        is_verified=False,
        wallet_balance=50000, # e.g. 500.00 Naira welcome bonus
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


async def authenticate_user(db: AsyncSession, email: str, password: str) -> Optional[User]:
    """Verify email exists and plaintext password matches the bcrypt hash."""
    user = await get_user_by_email(db, email=email)
    if not user:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user


async def generate_and_store_otp(db: AsyncSession, user_id: uuid.UUID) -> str:
    """Generates a cryptographically secure 6-digit OTP, hashes it, and stores it."""
    # Blacklist/Delete prior active OTPs for this user to prevent spam
    # Using raw SQL text for complex deletes since AsyncPG is strict
    from sqlalchemy import text
    await db.execute(text("DELETE FROM verification_tokens WHERE user_id = :uid"), {"uid": user_id})
    
    # Generate 6 completely random secure numbers String (e.g., '049281')
    otp_code = "".join([str(secrets.randbelow(10)) for _ in range(6)])
    
    # Store the bcrypt hash (so DB admins cannot see OTPs)
    token_entry = VerificationToken(
        user_id=user_id,
        hashed_token=hash_password(otp_code),
        purpose="email_verification",
        expires_at=datetime.now(timezone.utc) + timedelta(minutes=15)
    )
    
    db.add(token_entry)
    await db.commit()
    return otp_code


async def verify_and_consume_otp(db: AsyncSession, user_id: uuid.UUID, otp_code: str) -> bool:
    """Checks if the OTP is correct, unexpired, and then invalidates it."""
    result = await db.execute(
        select(VerificationToken).where(
            VerificationToken.user_id == user_id,
            VerificationToken.purpose == "email_verification"
        )
    )
    token_entry = result.scalars().first()
    
    if not token_entry:
        return False
    
    await db.refresh(token_entry)
        
    # Check expiry
    if token_entry.expires_at < datetime.now(timezone.utc):
        return False
        
    # Check cryptographic hash match
    if not verify_password(otp_code, token_entry.hashed_token):
        return False
        
    # Valid! Destroy the token so it cannot be reused
    await db.delete(token_entry)
    
    # Mark user as officially verified
    user = await db.execute(select(User).where(User.id == user_id))
    user_obj: Optional[User] = user.scalars().first()
    if user_obj is not None:
        user_obj.is_verified = True
        
    await db.commit()
    return True


async def verify_google_id_token(token: str) -> Optional[dict]:
    """
    Cryptographically verifies the authenticity of a Google ID Token.
    Returns the decoded claims (email, name, etc.) if valid.
    """
    try:
        # Verifies the JWT signature, audience (our Client ID), and expiration
        idinfo = id_token.verify_oauth2_token(token, requests.Request(), settings.GOOGLE_CLIENT_ID)
        return idinfo
    except Exception as e:
        # PROFESSIONAL LOGGING: Capture the exact reason for token rejection
        # Common causes: Expired tokens, audience mismatch (ClientID), or malformed signatures.
        print(f"GOOGLE TOKEN VERIFICATION FAILED: {str(e)}")
        return None


async def get_or_create_google_user(db: AsyncSession, google_data: dict) -> User:
    """
    Retrieves an existing user by email or creates a new one 
    if this is their first time logging in via Google.
    """
    email = google_data['email']
    user = await get_user_by_email(db, email=email)
    
    # Extract identity from Google claims
    # Fallback to email username if names are empty
    name_from_google = google_data.get('name') or google_data.get('given_name') or email.split('@')[0]
    picture_from_google = google_data.get('picture')

    if not user:
        # Auto-provision new account for Google identity
        user = User(
            email=email,
            name=name_from_google,
            avatar_url=picture_from_google,
            # Generate a massive random password for security consistency
            hashed_password=hash_password(secrets.token_urlsafe(32)), 
            is_verified=True, # Google has already verified this email
            wallet_balance=50000,
        )
        db.add(user)
    else:
        # PROFESSIONAL SYNC: Refresh profile if it was a placeholder or missing
        # We replace the name if it is literally 'string' (case-insensitive)
        current_name = str(user.name).lower()
        if (current_name == "string") or not user.name:
            user.name = name_from_google
        
            # Always update picture if it was missing or is still a Google placeholder
            # We PROTECT custom uploads (/static/) from being overwritten
            is_custom_avatar = user.avatar_url and "/static/" in user.avatar_url
            if not is_custom_avatar and picture_from_google:
                user.avatar_url = picture_from_google
            
    # Commit changes and refresh object from DB
    await db.commit()
    await db.refresh(user)
    
    return user
