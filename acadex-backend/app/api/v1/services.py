from typing import Any, List
from fastapi import APIRouter, Depends
from pydantic import BaseModel

from app.models.user import User
from app.api import deps

router = APIRouter()

class ServiceRecommendation(BaseModel):
    id: str
    title: str
    subtitle: str
    lottie: str
    icon: str
    placeholders: List[str]

@router.get("/recommended", response_model=List[ServiceRecommendation])
async def get_recommended_services(
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Returns the professional list of services for the 3D Carousel.
    In the future, this can be personalized based on the user's major.
    """
    return [
        {
            "id": "academic_guidance",
            "title": "Academic\nGuidance",
            "subtitle": "Expert academic advice",
            "lottie": "assets/lottie/dashboard/guidiance.json",
            "icon": "school_rounded",
            "placeholders": [
                "I need advice on selecting courses for next semester...",
                "How do I balance my study time?",
                "Preparing study plan for midterms..."
            ]
        },
        {
            "id": "custom_software",
            "title": "Custom\nSoftware",
            "subtitle": "Tailored software solutions",
            "lottie": "assets/lottie/dashboard/software.json",
            "icon": "code_rounded",
            "placeholders": [
                "I need a software for my final year project...",
                "Can you build a website for my business?",
                "I need a mobile app built to track inventory..."
            ]
        },
        {
            "id": "final_year_project",
            "title": "Final Year Project\nAssistance",
            "subtitle": "End-to-end project support",
            "lottie": "assets/lottie/dashboard/project.json",
            "icon": "engineering_rounded",
            "placeholders": [
                "How do I choose a topic for my project?",
                "I want you to handle my full project work.",
                "I need guidance on corrections from my supervisor..."
            ]
        },
        {
            "id": "assignment_assistance",
            "title": "Assignment\nAssistance",
            "subtitle": "Ace every assignment",
            "lottie": "assets/lottie/dashboard/assignment.json",
            "icon": "edit_document",
            "placeholders": [
                "I need assistance with a calculus assignment...",
                "Can you review my essay before I submit?",
                "I need help debugging a programming lab..."
            ]
        },
        {
            "id": "past_questions",
            "title": "Request Past\nQuestion",
            "subtitle": "Specific past question access",
            "lottie": "assets/lottie/documents.json",
            "icon": "quiz_rounded",
            "placeholders": [
                "MTH101 past questions for 2021/2022...",
                "Do you have PHY102 past questions?",
                "I need the last 5 years of ACC201 exams..."
            ]
        },
        {
            "id": "tutoring_mentorship",
            "title": "Tutoring &\nMentorship",
            "subtitle": "One-on-one guidance",
            "lottie": "assets/lottie/dashboard/guidiance_two.json",
            "icon": "people_alt_rounded",
            "placeholders": [
                "I need a tutor for introductory Python...",
                "Can I get a mentor for my career path?",
                "I need weekly tutoring for genetics..."
            ]
        }
    ]
