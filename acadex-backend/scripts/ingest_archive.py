import os
import shutil
import uuid
import sys
from pathlib import Path

# Fix python path to allow imports from app
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

import asyncio
from app.database import AsyncSessionLocal
from app.models.past_question import PastQuestion

import select
from sqlalchemy import select

def extract_course_title(filename: str) -> str:
    """Guess the course title from the filename by stripping numbers and extensions."""
    base = os.path.splitext(filename)[0]
    # Remove trailing digits and common keywords
    for word in ["1st", "2nd", "first", "second", "semester", "page", "test", "ca"]:
        base = base.lower().replace(word, "")
    
    # Clean up leftovers
    while base and (not base[-1].isalnum() or base[-1].isdigit()):
        base = base[:-1]
    title = base.strip().capitalize()
    return title if title else "Unknown Title"

def extract_semester(filename: str) -> str:
    """Detect if '1st' or '2nd' semester is mentioned in the filename."""
    fn = filename.lower()
    if any(x in fn for x in ["1st", "first"]):
        return "1st"
    if any(x in fn for x in ["2nd", "second"]):
        return "2nd"
    return None

def extract_level(course_code: str) -> int:
    """Guess academic level from course code (e.g. GET201 -> 200)."""
    # Find first digit in the code
    for char in course_code:
        if char.isdigit():
            # Multiply the first digit by 100 to get the level
            return int(char) * 100
    return None

async def ingest_archive():
    print("Starting Past Questions Ingestion (Upsert Mode)...")
    
    # Paths
    backend_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    archive_dir = os.path.abspath(os.path.join(backend_dir, "..", "Acadex pastquestions archive"))
    uploads_dir = os.path.join(backend_dir, "uploads", "archive")
    
    print(f"Reading from: {archive_dir}")
    print(f"Uploading to: {uploads_dir}")
    print("-" * 40)
    
    os.makedirs(uploads_dir, exist_ok=True)
    
    if not os.path.exists(archive_dir):
        print("Archive directory not found! Exiting.")
        return
        
    async with AsyncSessionLocal() as db:
        try:
            # Loop over DEPARTMENTS (e.g. GENERAL, MATHS, COMPUTER SCIENCE)
            for dept_name in os.listdir(archive_dir):
                dept_path = os.path.join(archive_dir, dept_name)
                if not os.path.isdir(dept_path): continue
                    
                # Loop over COURSES (e.g. GET201)
                for course_code in os.listdir(dept_path):
                    course_path = os.path.join(dept_path, course_code)
                    if not os.path.isdir(course_path): continue
                        
                    # Loop over YEARS (e.g. 2016_2017)
                    for year_str in os.listdir(course_path):
                        year_path = os.path.join(course_path, year_str)
                        if not os.path.isdir(year_path): continue
                        
                        files = [f for f in os.listdir(year_path) if os.path.isfile(os.path.join(year_path, f))]
                        if not files: continue
                        
                        # Sort files so page 1 comes before page 2
                        files.sort()
                        
                        # Detect Semester from the first filename
                        semester = extract_semester(files[0])
                        course_title = extract_course_title(files[0])
                        level = extract_level(course_code)
                        
                        # Check if this paper already exists in DB
                        stmt = select(PastQuestion).where(
                            PastQuestion.course_code == course_code,
                            PastQuestion.year == year_str,
                            PastQuestion.department == dept_name
                        )
                        result = await db.execute(stmt)
                        existing_pq = result.scalar_one_or_none()
                        
                        pq_id = existing_pq.id if existing_pq else uuid.uuid4()
                        file_urls = []
                        
                        status_str = "Updating" if existing_pq else "Creating"
                        print(f"{status_str}: {dept_name} -> {course_code} -> {year_str} ({len(files)} pages) Level {level}")
                        
                        page_num = 1
                        for file_name in files:
                            ext = os.path.splitext(file_name)[1]
                            new_file_name = f"{pq_id}_page{page_num}{ext}"
                            
                            original_path = os.path.join(year_path, file_name)
                            new_path = os.path.join(uploads_dir, new_file_name)
                            
                            # Copy file (overwrites if update)
                            shutil.copy2(original_path, new_path)
                            file_urls.append(f"/static/archive/{new_file_name}")
                            page_num += 1
                            
                        if existing_pq:
                            # Update existing
                            existing_pq.semester = semester
                            existing_pq.file_urls = file_urls
                            existing_pq.course_title = course_title
                            existing_pq.level = level
                        else:
                            # Create new
                            new_pq = PastQuestion(
                                id=pq_id,
                                department=dept_name,
                                university="Acadex University",
                                course_code=course_code,
                                course_title=course_title,
                                year=year_str,
                                semester=semester,
                                level=level,
                                file_urls=file_urls,
                                question_count=0
                            )
                            db.add(new_pq)
                
            await db.commit()
            print("-" * 40)
            print("Ingestion complete!")
            
        except Exception as e:
            await db.rollback()
            print(f"An error occurred: {e}")

if __name__ == "__main__":
    asyncio.run(ingest_archive())
