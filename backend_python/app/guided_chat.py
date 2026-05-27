"""Guided schedule assistant — button-only topics, one Gemini call per topic+course."""

from __future__ import annotations

import hashlib
import json
import time

import google.api_core.exceptions as google_exceptions
import google.generativeai as genai

from app.config import GEMINI_API_KEY, GEMINI_MODEL
from app.models import GuidedChatRequestIn, GuidedChatResponseOut

_CACHE: dict[str, tuple[float, str]] = {}
_CACHE_TTL_SECONDS = 900
_COOLDOWN_UNTIL = 0.0

TOPIC_LABELS: dict[str, str] = {
    "exam_study": "How to study for the exam",
    "youtube": "YouTube learning resources",
    "books": "Book recommendations",
    "careers": "Career & internship opportunities",
    "projects": "Project ideas",
}

VALID_TOPICS = frozenset(TOPIC_LABELS.keys())


def answer_guided_chat(req: GuidedChatRequestIn) -> GuidedChatResponseOut:
    topic = (req.topic or "").strip()
    if topic not in VALID_TOPICS:
        return GuidedChatResponseOut(
            message="Unknown topic. Please pick one of the suggested options.",
            source="invalid",
            topic=topic,
            courseCode=req.courseCode,
        )

    cache_key = _cache_key(req.courseCode, topic)
    cached = _get_cached(cache_key)
    if cached is not None:
        return GuidedChatResponseOut(
            message=cached,
            source="cache",
            topic=topic,
            courseCode=req.courseCode,
        )

    if not GEMINI_API_KEY:
        return _fallback_response(req, topic, "scoring")

    if _in_cooldown():
        return _fallback_response(req, topic, "scoring")

    gemini_text = _call_gemini(req, topic)
    if gemini_text:
        _set_cached(cache_key, gemini_text)
        return GuidedChatResponseOut(
            message=gemini_text,
            source="gemini",
            topic=topic,
            courseCode=req.courseCode,
        )
    return _fallback_response(req, topic, "scoring")


def _cache_key(course_code: str, topic: str) -> str:
    raw = f"{course_code.upper()}|{topic}"
    return hashlib.sha256(raw.encode()).hexdigest()


def _get_cached(key: str) -> str | None:
    entry = _CACHE.get(key)
    if entry is None:
        return None
    expires_at, text = entry
    if time.monotonic() >= expires_at:
        _CACHE.pop(key, None)
        return None
    return text


def _set_cached(key: str, text: str) -> None:
    _CACHE[key] = (time.monotonic() + _CACHE_TTL_SECONDS, text)


def _in_cooldown() -> bool:
    return time.monotonic() < _COOLDOWN_UNTIL


def _mark_cooldown() -> None:
    global _COOLDOWN_UNTIL
    _COOLDOWN_UNTIL = time.monotonic() + 300


def _call_gemini(req: GuidedChatRequestIn, topic: str) -> str | None:
    try:
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel(GEMINI_MODEL)
        prompt = _build_prompt(req, topic)
        response = model.generate_content(
            prompt,
            generation_config=genai.GenerationConfig(
                temperature=0.4,
                max_output_tokens=320,
            ),
        )
        text = (response.text or "").strip()
        if len(text) < 20:
            return None
        return text[:1200]
    except (
        google_exceptions.InvalidArgument,
        google_exceptions.PermissionDenied,
        google_exceptions.ResourceExhausted,
        google_exceptions.Unauthenticated,
    ):
        _mark_cooldown()
        return None
    except Exception:
        return None


def _build_prompt(req: GuidedChatRequestIn, topic: str) -> str:
    topic_title = TOPIC_LABELS[topic]
    exam_line = ""
    if req.nearestExamCourse and req.nearestExamDate:
        exam_line = f"\n- Upcoming exam: {req.nearestExamCourse} on {req.nearestExamDate}"
    rating_line = ""
    if req.difficultyRating is not None:
        rating_line = f"\n- Student difficulty rating for this course: {req.difficultyRating}/5 (5=hardest)"
    return f"""You are StudySync study coach for Yeditepe University students.
Answer ONLY about course {req.courseCode} ({req.courseName or 'university course'}).
Topic: {topic_title}
Keep answer practical, max 6 short bullet points or 2 short paragraphs, English.
Do not mention other courses. No generic fluff.

Student context:
- Name: {req.studentName}
- Study goal: {req.studyGoal or 'not set'}{exam_line}{rating_line}

Write helpful, specific guidance for the topic."""


def _fallback_response(req: GuidedChatRequestIn, topic: str, source: str) -> GuidedChatResponseOut:
    code = req.courseCode
    name = req.courseName or code
    templates: dict[str, str] = {
        "exam_study": (
            f"For {code} ({name}): review lecture notes weekly, solve past exam questions under timed "
            f"conditions, and focus on topics you rated as difficult. Form a small study group 5–7 days "
            f"before the exam."
        ),
        "youtube": (
            f"Search YouTube for '{name} lecture series' and '{code} tutorial'. Prefer university-level "
            f"playlists with problem-solving walkthroughs. Watch at 1.25x and pause to redo examples."
        ),
        "books": (
            f"Check your course syllabus for the official textbook. For {code}, add one reference book "
            f"with exercises and use the library or open-access lecture notes for extra practice."
        ),
        "careers": (
            f"With {code} skills, look for internships in software, data, or engineering roles that list "
            f"this subject. Update LinkedIn, attend campus career days, and ask professors about alumni paths."
        ),
        "projects": (
            f"Project ideas for {code}: build a small app or report that applies one major topic from class; "
            f"document your design, tests, and what you learned. Keep scope feasible in 2–3 weeks."
        ),
    }
    return GuidedChatResponseOut(
        message=templates.get(topic, f"Study tips for {code} will appear when AI is available."),
        source=source,
        topic=topic,
        courseCode=req.courseCode,
    )
