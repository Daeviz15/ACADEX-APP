import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from app.core.config import settings
from app.database import Base
from app.models.activity import UserActivity
from app.models.motivation import Motivation
from app.models.user import User
from app.models.wallet import Transaction

async def init_db():
    print("Initializing new database tables...")
    engine = create_async_engine(settings.async_database_url, echo=True, future=True)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("Database tables created successfully!")

if __name__ == "__main__":
    asyncio.run(init_db())
