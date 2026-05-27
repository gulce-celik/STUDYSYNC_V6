"""Gemini enrichment for scored planner candidates."""

from __future__ import annotations

import json

import google.api_core.exceptions as google_exceptions
import google.generativeai as genai

from app.config import GEMINI_API_KEY, GEMINI_MODEL, GEMINI_MODEL_FALLBACK
from app.gemini_cache import (
    build_cache_key,
    get_cached,
    mark_api_call_started,
    mark_api_failure,
    mark_api_success,
    set_cached,
    should_skip_api_call,
)
from app.models import PlannerContextIn
from app.scoring import PlannerCandidate, default_buddy_message, default_reserve_message, find_nearest_exam


def is_configured() -> bool:
    return bool(GEMINI_API_KEY)


def enrich_with_gemini(
    ctx: PlannerContextIn,
    reserve_candidates: list[PlannerCandidate],
    buddy_candidate: PlannerCandidate,
) -> tuple[dict[str, str], str] | None:
    if not is_configured():
        return None

    reserve_ids = [c.id for c in reserve_candidates[:3]]
    cache_key = build_cache_key(ctx, reserve_ids, buddy_candidate.id)

    cached = get_cached(cache_key)
    if cached is not None:
        print("Gemini cache hit — skipping API call")
        return cached

    if should_skip_api_call(cache_miss=True):
        print("Gemini throttled (quota cooldown) — using scoring fallback")
        return None

    mark_api_call_started()
    result, retryable_failure = _call_gemini(GEMINI_MODEL, ctx, reserve_candidates, buddy_candidate)
    if result is not None:
        mark_api_success()
        set_cached(cache_key, result)
        return result

    if retryable_failure and GEMINI_MODEL_FALLBACK and GEMINI_MODEL_FALLBACK != GEMINI_MODEL:
        result, _ = _call_gemini(
            GEMINI_MODEL_FALLBACK, ctx, reserve_candidates, buddy_candidate
        )
        if result is not None:
            mark_api_success()
            set_cached(cache_key, result)
            return result

    mark_api_failure(retryable=retryable_failure)
    return None


def _call_gemini(
    model_name: str,
    ctx: PlannerContextIn,
    reserve_candidates: list[PlannerCandidate],
    buddy_candidate: PlannerCandidate,
) -> tuple[tuple[dict[str, str], str] | None, bool]:
    """Returns (result, retryable_failure)."""
    try:
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel(model_name)
        prompt = _build_prompt(ctx, reserve_candidates, buddy_candidate)
        response = model.generate_content(
            prompt,
            generation_config=genai.GenerationConfig(
                temperature=0.35,
                response_mime_type="application/json",
            ),
        )
        text = response.text or ""
        parsed = json.loads(text)
        reserve_messages: dict[str, str] = {}
        for item in parsed.get("reserveSuggestions", []):
            item_id = item.get("id", "")
            message = item.get("message", "")
            if item_id and message:
                reserve_messages[item_id] = message
        buddy_message = parsed.get("buddySuggestion", {}).get("message", "")
        if not reserve_messages and not buddy_message:
            print(f"Gemini ({model_name}) returned empty messages")
            return None, True
        print(f"Gemini enrichment OK via model: {model_name}")
        return (reserve_messages, buddy_message), False
    except (
        google_exceptions.InvalidArgument,
        google_exceptions.PermissionDenied,
        google_exceptions.ResourceExhausted,
        google_exceptions.Unauthenticated,
    ) as exc:
        print(f"Gemini enrichment failed ({model_name}, no retry): {exc}")
        return None, False
    except Exception as exc:
        print(f"Gemini enrichment failed ({model_name}, retryable): {exc}")
        return None, True


def _build_prompt(
    ctx: PlannerContextIn,
    reserve_candidates: list[PlannerCandidate],
    buddy_candidate: PlannerCandidate,
) -> str:
    nearest_exam = find_nearest_exam(ctx.scheduleBlocks)
    lines = [
        "You are StudySync campus study planner for Yeditepe University students.",
        "Use ONLY the provided data. Return strict JSON with keys reserveSuggestions (max 2) and buddySuggestion.",
        "Each item: {id, message}. Messages max 180 chars, English, actionable.",
        "Do not invent courses or times outside candidates.",
        "",
        "Student context:",
        f"- name: {ctx.studentName}",
        f"- studyGoal: {ctx.studyGoal or ''}",
        f"- preferredTime: {ctx.preferredTime or ''}",
        f"- preferredDays: {ctx.preferredDays or ''}",
        f"- responsibilityScore: {ctx.responsibilityScore}",
    ]
    if ctx.courseRatings:
        ratings_str = ", ".join(f"{k}={v}/5" for k, v in sorted(ctx.courseRatings.items()))
        lines.append(f"- courseDifficultyRatings (5=hardest): {ratings_str}")
    if nearest_exam is not None:
        lines.append(f"- nearestExam: {nearest_exam.course_code} on {nearest_exam.exam_date.isoformat()}")
    lines.append("\nReserve candidates (pick up to 2 by id):")
    for candidate in reserve_candidates[:3]:
        lines.append(
            f"- id={candidate.id} score={candidate.score} course={candidate.course_code} "
            f"day={candidate.weekday} slot={candidate.slot_label} date={candidate.date_iso} "
            f"reason={candidate.scoring_reason}"
        )
    lines.append("\nBuddy candidate:")
    lines.append(
        f"- id={buddy_candidate.id} score={buddy_candidate.score} course={buddy_candidate.course_code} "
        f"day={buddy_candidate.weekday} slot={buddy_candidate.slot_label} reason={buddy_candidate.scoring_reason}"
    )
    lines.append(
        '\nJSON schema example: {"reserveSuggestions":[{"id":"reserve-...","message":"..."}],'
        '"buddySuggestion":{"id":"buddy-...","message":"..."}}'
    )
    return "\n".join(lines)


def fallback_messages(
    ctx: PlannerContextIn,
    reserve_candidates: list[PlannerCandidate],
    buddy_candidate: PlannerCandidate,
) -> tuple[dict[str, str], str]:
    nearest_exam = find_nearest_exam(ctx.scheduleBlocks)
    reserve_messages = {
        c.id: default_reserve_message(c, ctx) for c in reserve_candidates[:2]
    }
    buddy_message = default_buddy_message(buddy_candidate, nearest_exam)
    return reserve_messages, buddy_message
