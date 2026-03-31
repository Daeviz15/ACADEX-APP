"""
Authentication schemas using Pydantic.

Best practices:
  • EmailStr validates valid email formatting.
  • Separate Create and Response schemas prevent over-posting vulnerabilities.
  • from_attributes=True allows Pydantic to read directly from SQLAlchemy ORM models.
"""
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, EmailStr


class Token(BaseModel):
    """Payload sent back to the client after successful login."""
    access_token: str
    token_type: str = "bearer"


class TokenPayload(BaseModel):
    """Internal schema for validating the decoded JWT."""
    sub: Optional[str] = None


class UserCreate(BaseModel):
    """Payload expected when a user registers."""
    name: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    """Payload expected for custom JSON login (if not using OAuth2 form data)."""
    email: EmailStr
    password: str


class OTPVerify(BaseModel):
    """Payload expected when verifying an account."""
    email: EmailStr
    otp_code: str


class GoogleLogin(BaseModel):
    """Payload received from Google Sign-In on the mobile app."""
    id_token: str


class UserResponse(BaseModel):
    """Safe data returned to the client (never includes password)."""
    id: UUID
    name: str
    email: EmailStr
    avatar_url: Optional[str] = None
    banner_url: Optional[str] = None
    wallet_balance: int
    is_active: bool
    is_verified: bool

    class Config:
        from_attributes = True
