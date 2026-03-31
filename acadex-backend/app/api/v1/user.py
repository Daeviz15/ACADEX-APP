import os
import uuid
from io import BytesIO
from typing import Annotated

from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from PIL import Image

from app.database import get_db
from app.models.user import User
from app.api.deps import get_current_user
from app.schemas.auth import UserResponse

router = APIRouter()

# ── Avatar Update Engine ──
@router.put("/me/avatar", response_model=UserResponse)
async def update_user_avatar(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Industry-standard avatar upload:
    - Resize to 400x400 (square crop)
    - Convert to WebP for massive bandwidth savings
    - Deterministic filenames to avoid storage bloat
    """
    # 1. Validation (Security/Type)
    if not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File must be an image."
        )
    
    # 2. Process Image (Pillow)
    try:
        contents = await file.read()
        img = Image.open(BytesIO(contents))
        
        # Professional Square Crop
        width, height = img.size
        size = min(width, height)
        left = (width - size) / 2
        top = (height - size) / 2
        right = (width + size) / 2
        bottom = (height + size) / 2
        img = img.crop((left, top, right, bottom))
        
        # Sub-sampling & Resize
        img = img.resize((400, 400), Image.Resampling.LANCZOS)
        
        # 3. Save to Disk (WebP)
        # We STRIP metadata (icc_profile, exif) to prevent 'unimplemented' decode errors on Android
        filename = f"{current_user.id}_avatar.webp"
        save_path = os.path.join("uploads", "avatars", filename)
        
        # Convert and save
        img.save(save_path, "WEBP", quality=85, icc_profile=None, exif=None)
        
        # Update DB with Cache Buster
        import time
        timestamp = int(time.time())
        avatar_url = f"/static/avatars/{filename}?v={timestamp}"
        current_user.avatar_url = avatar_url
        
        await db.commit()
        await db.refresh(current_user)
        
        return current_user
        
    except Exception as e:
        print(f"AVATAR ERROR: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error processing avatar image."
        )

# ── Banner Update Engine (3:2 Ratio) ──
@router.put("/me/banner", response_model=UserResponse)
async def update_user_banner(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Professional Profile Banner Pipeline:
    - Cinematic Landscape Crop (3:2)
    - Resize to 1200x800 for sharpness
    - Optimized WebP formatting
    - Instant Cache Busting (?v=...)
    """
    if not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File must be an image."
        )
    
    try:
        contents = await file.read()
        img = Image.open(BytesIO(contents))
        
        # Professional Landscape Crop (3:2 Target)
        width, height = img.size
        target_ratio = 1.5 # 3:2
        current_ratio = width / height
        
        if current_ratio > target_ratio:
            # Too wide: crop sides
            new_width = height * target_ratio
            left = (width - new_width) / 2
            right = (width + new_width) / 2
            img = img.crop((left, 0, right, height))
        else:
            # Too tall: crop top/bottom
            new_height = width / target_ratio
            top = (height - new_height) / 2
            bottom = (height + new_height) / 2
            img = img.crop((0, top, width, bottom))
            
        # High-Quality Resize
        img = img.resize((1200, 800), Image.Resampling.LANCZOS)
        
        # Save deterministic WebP
        # We STRIP metadata (icc_profile, exif) to prevent 'unimplemented' decode errors on Android
        filename = f"{current_user.id}_banner.webp"
        save_path = os.path.join("uploads", "avatars", filename) 
        img.save(save_path, "WEBP", quality=80, icc_profile=None, exif=None)
        
        # Update DB with Cache Buster
        import time
        timestamp = int(time.time())
        banner_url = f"/static/avatars/{filename}?v={timestamp}"
        current_user.banner_url = banner_url
        
        await db.commit()
        await db.refresh(current_user)
        
        return current_user
        
    except Exception as e:
        print(f"BANNER ERROR: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error processing banner image."
        )
