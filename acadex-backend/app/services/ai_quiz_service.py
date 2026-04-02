import json
import logging
import os
import re
import aiofiles
import base64
from typing import Dict, Any, List

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
import openai

from app.models.past_question import PastQuestion
from app.models.quiz import QuizQuestion
from app.core.config import settings

logger = logging.getLogger(__name__)

# Initialize the OpenAI Async Client
try:
    openai_client = openai.AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
except Exception as e:
    logger.error(f"Failed to initialize OpenAI Client Check API Key. {e}")
    openai_client = None


async def generate_quiz_for_pq(pq_id: str, db: AsyncSession) -> bool:
    """
    Background worker function that downloads images associated with
    a past question, feeds them to OpenAI, extracts structured JSON
    questions, and persists them to the database.
    """
    if not openai_client:
        logger.error("OpenAI client not initialized.")
        return False

    # 1. Fetch the Past Question
    stmt = select(PastQuestion).where(PastQuestion.id == pq_id)
    result = await db.execute(stmt)
    pq = result.scalars().first()
    
    if not pq:
        logger.error(f"PastQuestion {pq_id} not found.")
        return False

    if not pq.file_urls or len(pq.file_urls) == 0:
        logger.error(f"PastQuestion {pq_id} has no files attached.")
        return False

    # 2. Define the Prompt & System content
    messages = [
        {
            "role": "system",
            "content": "You are an expert AI teacher and exam paper analyzer. You must ALWAYS respond with ONLY the requested JSON format, and absolutely no markdown code block wrappers or conversational text. You MUST extract every single question and sub-question from exam papers. If a question has parts like (a), (b), (c), or sub-parts like (i), (ii), (iii), each one MUST be a separate entry in your JSON output."
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text", 
                    "text": (
                        "You are analyzing university exam paper images. Your job is to extract EVERY SINGLE question into structured JSON.\n\n"
                        "CRITICAL RULES:\n"
                        "1. Extract ALL questions visible in the images. Do NOT skip any. If there are 30 questions, output 30 entries.\n"
                        "2. Sub-questions MUST be extracted as SEPARATE individual questions. NEVER combine sub-parts into one question. "
                        "For example, if Question 4a says 'Explain the following: i) Special Characters ii) Keywords iii) Models iv) Robustness v) Continue/Break', "
                        "you MUST create 5 SEPARATE entries: one for 'Q4a(i): Explain why Special Characters are not allowed as variable names', "
                        "one for 'Q4a(ii): Explain why Keywords are not used as variable names', etc. "
                        "Similarly, if Question 5b says 'Explain the following Concepts: Arrays, Functions, Local Variable, Global Variable', "
                        "create a SEPARATE entry for each concept. Prefix each with the parent question number like 'Q3(a): ...', 'Q4a(iii): ...'.\n"
                        "3. For multiple-choice/objective questions, put them in `objective_questions`.\n"
                        "4. For theory/essay/short-answer questions, put them in `theory_questions`.\n"
                        "5. If a question is objective, the `correct_answer` should be the letter (A, B, C, or D).\n"
                        "6. If a question is theory, the `correct_answer` must be a COMPREHENSIVE ideal answer (at least 2-3 sentences) that a grader would give full marks to.\n"
                        "7. The `options` array must contain exactly 4 options for objective questions. For theory questions, options should be an empty array [].\n"
                        "8. If the correct answer is not marked on the paper, infer the most likely correct answer.\n"
                        "9. NEVER output a single question that contains multiple concepts listed with i), ii), iii) or commas. ALWAYS split them into individual questions. "
                        "Each entry must be self-contained with enough context to be understood on its own without referring to the original exam paper.\n\n"
                        "IMPORTANT ABOUT BOTH ARRAYS:\n"
                        "- If the paper ONLY has objective questions, extract them all into `objective_questions`, then ALSO generate theory questions that test the same concepts into `theory_questions`.\n"
                        "- If the paper ONLY has theory questions, extract them all into `theory_questions`, then ALSO generate objective MCQ questions that test the same concepts into `objective_questions`.\n"
                        "- If the paper has BOTH types, extract each into the correct array.\n\n"
                        "Return ONLY a valid JSON object with this exact structure:\n"
                        "{\n"
                        "  \"objective_questions\": [\n"
                        "    {\n"
                        "      \"question_text\": \"Full text of the question with context\",\n"
                        "      \"options\": [\"Option A text\", \"Option B text\", \"Option C text\", \"Option D text\"],\n"
                        "      \"correct_answer\": \"A\",\n"
                        "      \"explanation\": \"Detailed step-by-step explanation\",\n"
                        "      \"difficulty\": \"easy|medium|hard\"\n"
                        "    }\n"
                        "  ],\n"
                        "  \"theory_questions\": [\n"
                        "    {\n"
                        "      \"question_text\": \"Full text of the theory question with context\",\n"
                        "      \"correct_answer\": \"Comprehensive ideal answer...\",\n"
                        "      \"difficulty\": \"easy|medium|hard\"\n"
                        "    }\n"
                        "  ]\n"
                        "}\n"
                    )
                }
            ]
        }
    ]

    # 3. Append Cloudinary URLs natively
    valid_images = 0
    
    for url in pq.file_urls:
        if not url.startswith("http"):
            logger.warning(f"Skipping non-HTTP URL inside production pipeline: {url}")
            continue
            
        messages[1]["content"].append({
            "type": "image_url",
            "image_url": {
                "url": url,
                "detail": "high"
            }
        })
        valid_images += 1

    if valid_images == 0:
        logger.error(f"No valid Cloudinary URLs found for PQ {pq_id}")
        return False

    # 4. Call OpenAI API
    try:
        response = await openai_client.chat.completions.create(
            model="gpt-4o-mini",
            messages=messages,
            response_format={"type": "json_object"},
            temperature=0.1,
            max_completion_tokens=16000,
            timeout=120.0
        )
        
        response_text = response.choices[0].message.content.strip()
        
        # Just in case the model ignores instructions and returns markdown JSON blocks
        if response_text.startswith("```json"):
            response_text = response_text[7:]
        if response_text.endswith("```"):
            response_text = response_text[:-3]
            
        data = json.loads(response_text)
    except Exception as e:
        logger.error(f"Failed to generate or parse OpenAI response: {e}")
        return False

    extracted_objective = data.get("objective_questions", [])
    extracted_theory = data.get("theory_questions", [])
    
    if not extracted_objective and not extracted_theory:
        logger.warning(f"OpenAI returned successfully but found no questions. RAW DATA: {data}")
        return False

    # 5. Post-process: Split grouped sub-questions into individual entries
    extracted_theory = _split_grouped_questions(extracted_theory)
    extracted_objective = _split_grouped_questions(extracted_objective)

    # 5. Save to Database
    try:
        # Delete any existing queries to prevent duplicates if regenerating
        await db.execute(delete(QuizQuestion).where(QuizQuestion.past_question_id == pq_id))
        
        # Insert Objective
        for q in extracted_objective:
            new_question = QuizQuestion(
                past_question_id=pq_id,
                question_text=q.get("question_text", ""),
                options=q.get("options", []),
                correct_answer=q.get("correct_answer", ""),
                explanation=q.get("explanation"),
                difficulty=q.get("difficulty", "medium"),
                question_type="objective"
            )
            db.add(new_question)

        # Insert Theory
        for q in extracted_theory:
            new_question = QuizQuestion(
                past_question_id=pq_id,
                question_text=q.get("question_text", ""),
                options=[], # Theory has no options
                correct_answer=q.get("correct_answer", ""),
                explanation=q.get("explanation"),
                difficulty=q.get("difficulty", "hard"),
                question_type="theory"
            )
            db.add(new_question)

        pq.has_quiz = True
        await db.commit()
        logger.info(f"Successfully generated {len(extracted_objective)} objective and {len(extracted_theory)} theory questions for PQ {pq_id}")
        return True
    except Exception as e:
        await db.rollback()
        logger.error(f"Failed to commit quiz questions to DB: {e}")
        return False


def _split_grouped_questions(questions: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Post-processes AI-extracted questions to split grouped sub-questions
    into individual entries. Detects patterns like:
    - "i) ... ii) ... iii) ..."
    - "Explain the following: A, B, C, D"
    - "(a) ... (b) ... (c) ..."
    """
    result = []
    
    # Pattern to detect Roman numeral sub-parts: i) ... ii) ... iii) ...
    roman_pattern = re.compile(
        r'(?:^|[\s:])([ivxlcdm]+)\)\s*(.+?)(?=(?:\s+[ivxlcdm]+\)\s)|$)',
        re.IGNORECASE | re.DOTALL
    )
    
    for q in questions:
        text = q.get("question_text", "")
        answer = q.get("correct_answer", "")
        
        # Check for "Explain the following" + roman numerals pattern
        if re.search(r'(?:explain|discuss|define|describe)\s+(?:the\s+)?following', text, re.IGNORECASE):
            # Try splitting by roman numeral patterns: i) ii) iii) iv) v)
            parts = re.split(r'\s*(?:[ivxlcdm]+)\)\s*', text, flags=re.IGNORECASE)
            parts = [p.strip() for p in parts if p.strip() and len(p.strip()) > 5]
            
            if len(parts) > 1:
                # First part is the prefix (e.g. "Explain the following:")
                prefix = parts[0].rstrip(':').strip()
                sub_parts = parts[1:]
                
                # Try to split the answer similarly
                answer_parts = re.split(r'\s*(?:[ivxlcdm]+)\)\s*', answer, flags=re.IGNORECASE)
                answer_parts = [a.strip() for a in answer_parts if a.strip() and len(a.strip()) > 5]
                
                for idx, sub in enumerate(sub_parts):
                    sub_answer = answer_parts[idx] if idx < len(answer_parts) else answer
                    result.append({
                        **q,
                        "question_text": f"{prefix}: {sub}",
                        "correct_answer": sub_answer,
                    })
                logger.info(f"Split grouped question into {len(sub_parts)} individual entries")
                continue
        
        # Check for "Explain the following Concepts: A, B, C, D" pattern
        concept_match = re.search(
            r'(?:explain|discuss|define|describe)\s+(?:the\s+)?following\s*(?:concepts?\s*)?[:]\s*(.+)',
            text, re.IGNORECASE
        )
        if concept_match:
            concepts_str = concept_match.group(1)
            # Split by commas and "and"
            concepts = re.split(r'\s*,\s*|\s+and\s+', concepts_str)
            concepts = [c.strip().rstrip('.') for c in concepts if c.strip() and len(c.strip()) > 2]
            
            if len(concepts) >= 3:
                prefix_text = text[:concept_match.start() + len("Explain the following concepts")].strip().rstrip(':')
                for concept in concepts:
                    result.append({
                        **q,
                        "question_text": f"Explain the concept of {concept} in programming.",
                        "correct_answer": q.get("correct_answer", ""),
                    })
                logger.info(f"Split concept-list question into {len(concepts)} individual entries")
                continue
        
        # No splitting needed - keep as-is
        result.append(q)
    
    return result


async def grade_theory_answer(question_text: str, ideal_answer: str, user_answer: str, user_name: str) -> Dict[str, Any]:
    """
    Real-time AI grading for theory questions.
    Checks user's answer against the ideal answer logically, not just string matching.
    """
    if not openai_client:
        logger.error("OpenAI client not initialized.")
        return {"score": 0, "feedback": "AI grading is currently unavailable."}

    # Extract first name and format it nicely
    safe_name = "Scholar"
    if user_name:
        safe_name = user_name.split(" ")[0].capitalize()

    system_prompt = (
        "You are a friendly, encouraging, but academically strict exam grader for university students. "
        "Your job is to read a student's theory answer, compare it to the ideal correct answer, and grade it out of 100.\n\n"
        "RULES:\n"
        "1. Focus on FACTUAL logic and core concepts. Do not penalize if the student is concise but correct. "
        "For example, if the ideal answer lists 3 entrepreneurs, and the student lists 3 correct entrepreneurs (even if different from the ideal list), give full marks. "
        "If they capture the essence, they get high marks.\n"
        "2. Provide feedback that is passive, layman-friendly, and highly educational.\n"
        "3. Explicitly address the student by their name to make it personal.\n"
        "4. If they lose marks, suggest the BEST PRACTICE on how they could structure the answer to get maximum marks from a strict lecturer during a real exam.\n"
        "5. You MUST return your response in purely valid JSON format:\n"
        "{\n"
        '  "score": <integer from 0 to 100>,\n'
        '  "feedback": "<The personalized feedback string>"\n'
        "}\n"
    )

    user_prompt = (
        f"Student Name: {safe_name}\n"
        f"Question: {question_text}\n"
        f"Ideal Answer/Keywords: {ideal_answer}\n"
        f"Student's Answer: {user_answer}\n"
    )

    try:
        response = await openai_client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            response_format={"type": "json_object"},
            temperature=0.3,
            max_completion_tokens=500,
            timeout=10.0
        )
        
        response_text = response.choices[0].message.content.strip()
        data = json.loads(response_text)
        
        return {
            "score": data.get("score", 0),
            "feedback": data.get("feedback", "Could not generate feedback.")
        }
    except Exception as e:
        logger.error(f"Failed to grade theory answer: {e}")
        return {"score": 0, "feedback": "An error occurred while grading your answer. Please check your connection."}


