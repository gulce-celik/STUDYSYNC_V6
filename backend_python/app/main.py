from fastapi import FastAPI

from app.config import AI_SERVICE_PORT
from app.guided_chat import answer_guided_chat
from app.models import AiSuggestionsResponseOut, GuidedChatRequestIn, GuidedChatResponseOut, PlannerContextIn
from app.planner import build_suggestions

app = FastAPI(title="StudySync AI Planner", version="1.0.0")


@app.get("/health")
def health():
    return {"success": True, "service": "studysync-ai-python", "status": "UP"}


@app.post("/planner/suggestions", response_model=AiSuggestionsResponseOut)
def planner_suggestions(ctx: PlannerContextIn) -> AiSuggestionsResponseOut:
    return build_suggestions(ctx)


@app.post("/planner/guided-chat", response_model=GuidedChatResponseOut)
def planner_guided_chat(req: GuidedChatRequestIn) -> GuidedChatResponseOut:
    return answer_guided_chat(req)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host="0.0.0.0", port=AI_SERVICE_PORT, reload=True)
