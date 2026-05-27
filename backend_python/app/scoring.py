"""Deterministic reserve/buddy candidate scoring from student context."""

from __future__ import annotations

import re
from dataclasses import dataclass
from datetime import date, datetime, timedelta

from app.models import PlannerContextIn, ScheduleBlockIn

COURSE_PATTERN = re.compile(r"([A-Z]{2,4})-?(\d{3})")

SCHEDULE_TO_RESERVATION: dict[str, tuple[str, str]] = {
    "09-10": ("slot-2", "09:00 - 11:00 (Class Time)"),
    "10-11": ("slot-2", "09:00 - 11:00 (Class Time)"),
    "11-12": ("slot-3", "11:00 - 13:00 (Class Time)"),
    "12-13": ("slot-3", "11:00 - 13:00 (Class Time)"),
    "13-14": ("slot-4", "13:00 - 15:00 (Class Time)"),
    "14-15": ("slot-4", "13:00 - 15:00 (Class Time)"),
    "15-16": ("slot-5", "15:00 - 17:00 (Class Time)"),
    "16-17": ("slot-5", "15:00 - 17:00 (Class Time)"),
    "17-18": ("slot-6", "17:00 - 20:00 (Evening 1)"),
    "18-19": ("slot-6", "17:00 - 20:00 (Evening 1)"),
    "19-20": ("slot-7", "20:00 - 23:00 (Evening 2)"),
}

DAY_TO_DOW = {"Mon": 0, "Tue": 1, "Wed": 2, "Thu": 3, "Fri": 4, "Sat": 5, "Sun": 6}
DOW_TO_DAY = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]


@dataclass
class ExamHint:
    course_code: str
    exam_date: date


@dataclass
class PlannerCandidate:
    id: str
    course_code: str
    slot_id: str
    slot_label: str
    date_iso: str
    weekday: str
    score: int
    scoring_reason: str


def find_nearest_exam(blocks: list[ScheduleBlockIn]) -> ExamHint | None:
    today = date.today()
    best: ExamHint | None = None
    for block in blocks:
        parsed = _parse_exam_label(block.label)
        if parsed is None or parsed.exam_date < today:
            continue
        if best is None or parsed.exam_date < best.exam_date:
            best = parsed
    return best


def build_reserve_candidates(ctx: PlannerContextIn) -> list[PlannerCandidate]:
    occupied = {f"{b.day}|{b.timeSlot}" for b in ctx.scheduleBlocks if b.day and b.timeSlot}
    nearest_exam = find_nearest_exam(ctx.scheduleBlocks)
    priority_course = _pick_priority_course(ctx, nearest_exam)
    day_candidates = _preferred_day_candidates(ctx.preferredDays)
    slot_candidates = _preferred_slot_candidates(ctx.preferredTime)
    today = date.today()

    scored: list[PlannerCandidate] = []
    for day in day_candidates:
        for schedule_slot in slot_candidates:
            if f"{day}|{schedule_slot}" in occupied:
                continue
            mapping = SCHEDULE_TO_RESERVATION.get(schedule_slot)
            if mapping is None:
                continue
            slot_id, slot_label = mapping
            target_date = _next_date_for_day(day, today)
            score = _score_reserve_slot(ctx, priority_course, day, schedule_slot, target_date, nearest_exam)
            reason = _build_scoring_reason(ctx, priority_course, nearest_exam)
            scored.append(
                PlannerCandidate(
                    id=f"reserve-{day}-{schedule_slot}-{priority_course}",
                    course_code=priority_course,
                    slot_id=slot_id,
                    slot_label=slot_label,
                    date_iso=target_date.isoformat(),
                    weekday=day,
                    score=score,
                    scoring_reason=reason,
                )
            )

    scored.sort(key=lambda c: c.score, reverse=True)
    if not scored:
        fallback_date = _next_date_for_day("Tue", today)
        scored.append(
            PlannerCandidate(
                id="reserve-fallback",
                course_code=priority_course,
                slot_id="slot-4",
                slot_label="13:00 - 15:00 (Class Time)",
                date_iso=fallback_date.isoformat(),
                weekday="Tue",
                score=40,
                scoring_reason="Default 2h study block when no free grid slot matches your preferences.",
            )
        )
    return scored[:5]


def build_buddy_candidate(
    ctx: PlannerContextIn, top_reserve: PlannerCandidate, nearest_exam: ExamHint | None
) -> PlannerCandidate:
    if nearest_exam is not None:
        weekday = DOW_TO_DAY[nearest_exam.exam_date.weekday()]
        return PlannerCandidate(
            id=f"buddy-{nearest_exam.course_code}-{weekday}",
            course_code=nearest_exam.course_code,
            slot_id=top_reserve.slot_id,
            slot_label=top_reserve.slot_label,
            date_iso=nearest_exam.exam_date.isoformat(),
            weekday=weekday,
            score=92,
            scoring_reason="Upcoming exam focus — match with peers revising the same course.",
        )
    return PlannerCandidate(
        id=f"buddy-{top_reserve.course_code}-{top_reserve.weekday}",
        course_code=top_reserve.course_code,
        slot_id=top_reserve.slot_id,
        slot_label=top_reserve.slot_label,
        date_iso=top_reserve.date_iso,
        weekday=top_reserve.weekday,
        score=min(88, top_reserve.score + 5),
        scoring_reason="Shared course and overlapping study window with your planner suggestion.",
    )


def default_reserve_message(candidate: PlannerCandidate, ctx: PlannerContextIn) -> str:
    slot_short = candidate.slot_label.split(" (")[0]
    goal_suffix = f" Matches your {ctx.studyGoal} goal." if ctx.studyGoal else ""
    return f"{candidate.weekday} {slot_short} • Study {candidate.course_code} for 2 hours.{goal_suffix}"


def default_buddy_message(candidate: PlannerCandidate, nearest_exam: ExamHint | None) -> str:
    if nearest_exam is not None:
        return (
            f"AI Suggestion: You have a {nearest_exam.course_code} exam on "
            f"{nearest_exam.exam_date.isoformat()}. Find a study buddy for a focused revision session."
        )
    slot_short = candidate.slot_label.split(" (")[0]
    return (
        f"AI Suggestion: Try matching with a buddy for {candidate.course_code} around "
        f"{candidate.weekday} {slot_short}."
    )


def _pick_priority_course(ctx: PlannerContextIn, nearest_exam: ExamHint | None) -> str:
    if nearest_exam is not None:
        return nearest_exam.course_code
    enrolled = [_normalize_code(c) for c in ctx.enrolledCourses if c]
    enrolled = [c for c in enrolled if c]
    if enrolled:
        rated = [c for c in enrolled if c in ctx.courseRatings]
        if rated:
            # Higher star rating = harder course in StudySync (5 = Very Hard).
            return max(rated, key=lambda c: ctx.courseRatings[c])
        return enrolled[0]
    for block in ctx.scheduleBlocks:
        extracted = _extract_course_code(block.label)
        if extracted:
            return extracted
    return "CSE344"


def _score_reserve_slot(
    ctx: PlannerContextIn,
    course: str,
    day: str,
    schedule_slot: str,
    target_date: date,
    nearest_exam: ExamHint | None,
) -> int:
    score = 50
    if nearest_exam is not None:
        days = (nearest_exam.exam_date - date.today()).days
        if days <= 7:
            score += 25
        elif days <= 14:
            score += 12
        if course.upper() == nearest_exam.course_code.upper():
            score += 10
    rating = ctx.courseRatings.get(course.upper())
    if rating is not None:
        score += max(0, rating - 1) * 5
    if _matches_preferred_time(ctx.preferredTime, schedule_slot):
        score += 8
    if _matches_preferred_days(ctx.preferredDays, day):
        score += 6
    if ctx.studyGoal:
        score += 4
    if ctx.responsibilityScore < 75:
        score += 3
    return min(100, score)


def _build_scoring_reason(ctx: PlannerContextIn, course: str, nearest_exam: ExamHint | None) -> str:
    parts: list[str] = []
    if nearest_exam is not None:
        parts.append(f"Exam {nearest_exam.course_code} on {nearest_exam.exam_date.isoformat()}")
    rating = ctx.courseRatings.get(course.upper())
    if rating is not None:
        parts.append(f"your difficulty rating {rating}/5")
    if ctx.studyGoal:
        parts.append(f"goal: {ctx.studyGoal}")
    return "; ".join(parts) if parts else "Free slot aligned with your weekly schedule."


def _preferred_slot_candidates(preferred_time: str | None) -> list[str]:
    if not preferred_time:
        return ["14-15", "13-14", "11-12"]
    match preferred_time.strip().lower():
        case "morning":
            return ["09-10", "10-11", "11-12"]
        case "afternoon":
            return ["13-14", "14-15", "15-16"]
        case "evening":
            return ["17-18", "18-19", "19-20"]
        case _:
            return ["14-15", "13-14", "11-12"]


def _preferred_day_candidates(preferred_days: str | None) -> list[str]:
    if preferred_days and preferred_days.strip().lower() == "weekend":
        return ["Fri", "Thu", "Wed"]
    return ["Tue", "Wed", "Thu", "Fri", "Mon"]


def _matches_preferred_time(preferred_time: str | None, schedule_slot: str) -> bool:
    if not preferred_time:
        return False
    return schedule_slot in _preferred_slot_candidates(preferred_time)


def _matches_preferred_days(preferred_days: str | None, day: str) -> bool:
    if not preferred_days:
        return True
    if preferred_days.strip().lower() == "weekend":
        return day in {"Fri", "Sat", "Sun"}
    return True


def _next_date_for_day(short_day: str, today: date) -> date:
    target = DAY_TO_DOW.get(short_day, 1)
    delta = (target - today.weekday()) % 7
    if delta == 0:
        delta = 7
    return today + timedelta(days=delta)


def _parse_exam_label(label: str | None) -> ExamHint | None:
    if not label or not label.startswith("EXAM:"):
        return None
    parts = label.split(":")
    if len(parts) < 3:
        return None
    code = parts[1].strip().upper()
    if not code:
        return None
    raw = parts[2].strip()[:10]
    try:
        exam_date = date.fromisoformat(raw)
    except ValueError:
        return None
    return ExamHint(course_code=code, exam_date=exam_date)


def _extract_course_code(label: str | None) -> str | None:
    if not label:
        return None
    match = COURSE_PATTERN.search(label.upper())
    if not match:
        return None
    return f"{match.group(1)}{match.group(2)}"


def _normalize_code(code: str) -> str:
    return code.strip().upper()
