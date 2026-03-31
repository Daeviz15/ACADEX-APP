import asyncio
from app.database import AsyncSessionLocal
from app.models.user import User
from sqlalchemy.future import select

async def check_user():
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(User).where(User.email == 'daeviz17@gmail.com'))
        user = result.scalars().first()
        if user:
            print(f"USER: {user.id}, EMAIL: {user.email}, NAME: '{user.name}', AVATAR: {user.avatar_url}")
        else:
            print("USER NOT FOUND")

if __name__ == "__main__":
    asyncio.run(check_user())
