from app.gemini_enricher import enrich_with_gemini, fallback_messages, is_configured
from app.models import AiSuggestionOut, AiSuggestionsResponseOut, PlannerContextIn
from app.scoring import (
    build_buddy_candidate,
    build_reserve_candidates,
    find_nearest_exam,
)


def build_suggestions(ctx: PlannerContextIn) -> AiSuggestionsResponseOut:
    reserve_candidates = build_reserve_candidates(ctx)
    top_reserve = reserve_candidates[0]
    nearest_exam = find_nearest_exam(ctx.scheduleBlocks)
    buddy_candidate = build_buddy_candidate(ctx, top_reserve, nearest_exam)

    gemini = enrich_with_gemini(ctx, reserve_candidates, buddy_candidate)
    if gemini is not None:
        reserve_messages, buddy_message = gemini
        source = "gemini"
    else:
        reserve_messages, buddy_message = fallback_messages(ctx, reserve_candidates, buddy_candidate)
        source = "scoring" if not is_configured() else "scoring"

    reserve_out: list[AiSuggestionOut] = []
    for candidate in reserve_candidates[:2]:
        message = reserve_messages.get(candidate.id) or fallback_messages(ctx, [candidate], buddy_candidate)[0][
            candidate.id
        ]
        reserve_out.append(_to_dto(candidate, "reserve", message))

    if not buddy_message:
        buddy_message = fallback_messages(ctx, reserve_candidates, buddy_candidate)[1]

    buddy_out = _to_dto(buddy_candidate, "buddy", buddy_message)
    return AiSuggestionsResponseOut(
        reserveSuggestions=reserve_out,
        buddySuggestion=buddy_out,
        source=source,
    )


def _to_dto(candidate, scope: str, message: str) -> AiSuggestionOut:
    return AiSuggestionOut(
        id=candidate.id,
        scope=scope,
        title="AI suggestion",
        message=message,
        courseCode=candidate.course_code,
        slotId=candidate.slot_id,
        slotLabel=candidate.slot_label,
        dateIso=candidate.date_iso,
        weekday=candidate.weekday,
        confidenceScore=candidate.score,
        reason=candidate.scoring_reason,
    )
