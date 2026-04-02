import sys
import os
import asyncio
from sqlalchemy.orm import selectinload

# Add backend directory to Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from sqlalchemy.future import select
from app.database import AsyncSessionLocal
from app.models.past_question import PastQuestion
from app.services.cloudinary_service import upload_image_to_cloudinary

async def main():
    print("Starting Cloudinary Migration...")
    base_dir = os.path.dirname(os.path.dirname(__file__))

    async with AsyncSessionLocal() as session:
        stmt = select(PastQuestion)
        result = await session.execute(stmt)
        pqs = result.scalars().all()

        print(f"Found {len(pqs)} Past Questions to process.")
        
        updated_count = 0

        for pq in pqs:
            print(f"\nProcessing PQ: {pq.course_code} - {pq.year} (ID: {pq.id})")
            new_urls = []
            needs_update = False

            for url in pq.file_urls:
                # Check if it's already a Cloudinary URL
                if "res.cloudinary.com" in url:
                    print(f"  ⏭️ Already migrated: {url}")
                    new_urls.append(url)
                    continue

                # It's a local URL. Let's find the physical file
                normalized_url = url.replace('\\', '/')
                if normalized_url.startswith("/static/"):
                    relative_path = normalized_url.replace("/static/", "uploads/", 1)
                elif normalized_url.startswith("static/"):
                    relative_path = normalized_url.replace("static/", "uploads/", 1)
                else:
                    relative_path = normalized_url.lstrip("/")

                full_path = os.path.normpath(os.path.join(base_dir, relative_path))

                if not os.path.exists(full_path):
                    print(f"  ❌ File not found locally: {full_path}")
                    new_urls.append(url) # Keep the broken link just in case
                    continue

                # Upload to Cloudinary
                print(f"  Uploading: {full_path} ...", end="", flush=True)
                secure_url = await upload_image_to_cloudinary(full_path)
                
                if secure_url:
                    print(f" Success!")
                    new_urls.append(secure_url)
                    needs_update = True
                else:
                    print(f" FAILED!")
                    new_urls.append(url)

            if needs_update:
                pq.file_urls = new_urls
                updated_count += 1
                await session.commit()
                print(f"  Updated DB successfully for {pq.course_code}")

    print(f"\nMigration Complete! Updated {updated_count} rows.")

if __name__ == "__main__":
    asyncio.run(main())
