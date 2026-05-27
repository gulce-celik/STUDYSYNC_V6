from pydantic import BaseModel, Field


class ScheduleBlockIn(BaseModel):
    day: str
    timeSlot: str
    type: str | None = None
    label: str | None = None


class PlannerContextIn(BaseModel):
    studentName: str = ""
    studyGoal: str | None = None
    preferredTime: str | None = None
    preferredDays: str | None = None
    responsibilityScore: int = 75
    enrolledCourses: list[str] = Field(default_factory=list)
    courseRatings: dict[str, int] = Field(default_factory=dict)
    scheduleBlocks: list[ScheduleBlockIn] = Field(default_factory=list)


class AiSuggestionOut(BaseModel):
    id: str
    scope: str
    title: str = "AI suggestion"
    message: str
    courseCode: str
    slotId: str
    slotLabel: str
    dateIso: str
    weekday: str
    confidenceScore: int
    reason: str | None = None


class AiSuggestionsResponseOut(BaseModel):
    reserveSuggestions: list[AiSuggestionOut]
    buddySuggestion: AiSuggestionOut
    source: str


class GuidedChatRequestIn(BaseModel):
    courseCode: str
    courseName: str | None = None
    topic: str
    studentName: str = "Student"
    studyGoal: str | None = None
    difficultyRating: int | None = None
    nearestExamCourse: str | None = None
    nearestExamDate: str | None = None


class GuidedChatResponseOut(BaseModel):
    message: str
    source: str
    topic: str
    courseCode: str
