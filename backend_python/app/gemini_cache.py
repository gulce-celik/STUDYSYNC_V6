"""In-memory Gemini result cache and call throttling."""

from __future__ import annotations

import hashlib
import json
import time
from typing import Any

from app.config import GEMINI_CACHE_TTL_SECONDS, GEMINI_COOLDOWN_SECONDS, GEMINI_MIN_INTERVAL_SECONDS
from app.models import PlannerContextIn

_cache: dict[str, tuple[float, tuple[dict[str, str], str]]] = {}
_last_api_call_at: float = 0.0
_cooldown_until: float = 0.0


def build_cache_key(
    ctx: PlannerContextIn,
    reserve_ids: list[str],
    buddy_id: str,
) -> str:
    payload: dict[str, Any] = {
        "studentName": ctx.studentName,
        "studyGoal": ctx.studyGoal,
        "preferredTime": ctx.preferredTime,
        "preferredDays": ctx.preferredDays,
        "responsibilityScore": ctx.responsibilityScore,
        "enrolledCourses": sorted(ctx.enrolledCourses or []),
        "courseRatings": sorted((ctx.courseRatings or {}).items()),
        "scheduleBlocks": [
            (b.day, b.timeSlot, b.type, b.label) for b in (ctx.scheduleBlocks or [])
        ],
        "reserveIds": reserve_ids,
        "buddyId": buddy_id,
    }
    raw = json.dumps(payload, sort_keys=True, ensure_ascii=True)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def get_cached(key: str) -> tuple[dict[str, str], str] | None:
    entry = _cache.get(key)
    if entry is None:
        return None
    expires_at, value = entry
    if time.monotonic() >= expires_at:
        _cache.pop(key, None)
        return None
    return value


def set_cached(key: str, value: tuple[dict[str, str], str]) -> None:
    _cache[key] = (time.monotonic() + GEMINI_CACHE_TTL_SECONDS, value)


def should_skip_api_call(*, cache_miss: bool = False) -> bool:
    """Skip only on quota/auth cooldown. Min-interval is not applied on cache miss (e.g. profile prefs changed)."""
    now = time.monotonic()
    if now < _cooldown_until:
        return True
    if cache_miss:
        return False
    if _last_api_call_at and (now - _last_api_call_at) < GEMINI_MIN_INTERVAL_SECONDS:
        return True
    return False


def mark_api_call_started() -> None:
    global _last_api_call_at
    _last_api_call_at = time.monotonic()


def mark_api_failure(retryable: bool) -> None:
    global _cooldown_until
    if not retryable:
        _cooldown_until = time.monotonic() + GEMINI_COOLDOWN_SECONDS


def mark_api_success() -> None:
    global _cooldown_until
    _cooldown_until = 0.0
