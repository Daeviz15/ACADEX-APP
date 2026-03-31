"""
FastAPI Dependency Injection bindings.

Best practices:
  • Extract repetitive code like token decoding and db lookups into dependencies.
  • Reusable `get_current_user` ensures protected routes are safe.
"""
import uuid
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.core.config import settings
from app.database import get_db
from app.models.user import User
from app.schemas.auth import TokenPayload

# Points Swagger UI to our login route so it can test our API natively!
oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_STR}/auth/login")


async def get_current_user(
    db: AsyncSession = Depends(get_db),
    token: str = Depends(oauth2_scheme)
) -> User:
    """
    Standard dependency to inject the current authenticated User into any endpoint.
    If the JWT is missing, invalid, or expired, it throws a standard 401.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # 1. Verify the cryptographic signature and token expiry
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        token_data = TokenPayload(sub=str(payload.get("sub")))
        if token_data.sub is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    try:
        user_uuid = uuid.UUID(token_data.sub)
    except ValueError:
        raise credentials_exception

    # 2. Look up the user in the database
    result = await db.execute(select(User).where(User.id == user_uuid))
    user = result.scalars().first()
    
    if user is None:
        raise credentials_exception
    
    # 3. Prevent banned/deactivated accounts from acting
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user account")
        
    return user
