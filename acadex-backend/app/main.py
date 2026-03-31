"""
Acadex API — FastAPI application entry point.

Best practices:
  • Lifespan context manager for clean startup/shutdown
  • CORS middleware configured for Flutter dev
  • Versioned API router (v1)
"""
import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import settings


def ensure_uploads_dir():
    """Ensure the uploads storage exists."""
    os.makedirs("uploads/avatars", exist_ok=True)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown hooks."""
    # ── Startup ──
    print(f"[START] {settings.PROJECT_NAME} v{settings.VERSION} starting up...")
    ensure_uploads_dir()
    yield
    # ── Shutdown ──
    print(f"[STOP] {settings.PROJECT_NAME} shutting down...")


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan,
)

# ── CORS — allow Flutter app (web/mobile) ──
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Lock down in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Static Files (Uploaded Avatars) ──
app.mount("/static", StaticFiles(directory="uploads"), name="static")


# ── Health Check ──
@app.get("/health", tags=["Health"])
async def health_check():
    return {"status": "healthy", "version": settings.VERSION}


# ── Import and include versioned routers ──
from app.api.v1.router import api_router
app.include_router(api_router, prefix=settings.API_V1_STR)
