"""Guided schedule assistant — button-only topics, one Gemini call per topic+course."""

from __future__ import annotations

import hashlib
import re
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
    # v6 — rich books fallback + formats
    raw = f"v6|{course_code.upper()}|{topic}"
    return hashlib.sha256(raw.encode()).hexdigest()


def _trim_incomplete_tail(text: str) -> str:
    """Drop a last line cut off mid-sentence by token limit."""
    lines = text.split("\n")
    while lines:
        last = lines[-1].strip()
        if not last:
            lines.pop()
            continue
        complete = bool(re.search(r"[.!?:\)]\s*$", last)) or len(last) < 48
        if complete:
            break
        lines.pop()
    return "\n".join(lines).strip()


def _sanitize_gemini_text(text: str) -> str:
    """Strip truncated markdown (e.g. trailing ###) and empty hash-only lines."""
    text = text.strip()
    if not text:
        return text

    lines: list[str] = []
    for raw in text.replace("\r\n", "\n").split("\n"):
        line = raw.rstrip()
        stripped = line.strip()
        if re.fullmatch(r"#+", stripped):
            continue
        line = re.sub(r"\s*#{1,3}\s*$", "", line).rstrip()
        if line.strip():
            lines.append(line)

    text = "\n".join(lines).strip()
    text = re.sub(r"\*\*?\s*$", "", text).rstrip()
    while text and re.search(r"\s*#{1,3}\s*$", text):
        text = re.sub(r"\s*#{1,3}\s*$", "", text).rstrip()
    return _trim_incomplete_tail(text)


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
                temperature=0.35,
                max_output_tokens=1024,
            ),
        )
        text = _sanitize_gemini_text((response.text or "").strip())
        if len(text) < 20:
            return None
        return text[:2800]
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


def _topic_instructions(topic: str, course_code: str, course_name: str) -> str:
    code = course_code.upper()
    name = course_name or course_code
    if topic == "youtube":
        dept_hint = "CS/software engineering" if code.startswith("CSE") else (
            "mathematics/statistics" if code.startswith("MATH") else "this subject area"
        )
        return f"""
Topic rules (YouTube — follow strictly):
- After at most one short greeting sentence, use ONLY markdown bullet lines starting with "* ".
- Name at least 4 real YouTube channels. Example line: * **Neso Academy** — FA & TOC videos for {code}.
- Prefer channels for {dept_hint} (e.g. Neso Academy, Computerphile, freeCodeCamp where relevant).
- End with one bullet: * **Search** — two exact YouTube search phrases for {code}.
- Do NOT use ### or ## headings. Do NOT write long paragraphs without "* " bullets.
- No invented channel names."""
    if topic == "books":
        return f"""
Topic rules (books):
- After one short intro sentence, give exactly 4 lines starting with "* ".
- REQUIRED format: * **Book title** by Author — One sentence on why it helps {code} ({name}).
- Use real, well-known textbooks for this subject; include the official syllabus book if you know it.
- Example: * **Operating System Concepts** by Silberschatz — Covers processes, memory, and file systems for OS courses."""
    if topic == "exam_study":
        return """
Topic rules (exam study):
- After one short intro sentence, use ONLY lines starting with "* " (no ### headings).
- At least 5 bullets: week or step plan for this course; bold the step title in each line."""
    if topic == "careers":
        return """
Topic rules (careers):
- Max 5 lines starting with "* ", each under 110 characters, complete sentences.
- 3 internship role types + 2 action steps (portfolio, office hours). No long paragraphs."""
    if topic == "projects":
        return f"""
Topic rules (projects):
- After one short intro (1 sentence), give exactly 4 lines starting with "* ".
- REQUIRED format for every bullet: * **Project title** — One or two sentences: what it is, which {code} topic it covers, and deliverable (demo, report, or tests) in 2–3 weeks.
- The project title MUST be wrapped in **double asterisks**; use an em dash (—) before the description.
- Example: * **RISC-V pipeline simulator** — Model a 5-stage pipeline in Verilog, show hazard handling, and submit a README with waveforms.
- Tie ideas to {name}; use syllabus-level concepts, not generic advice."""
    return ""


def _build_prompt(req: GuidedChatRequestIn, topic: str) -> str:
    topic_title = TOPIC_LABELS[topic]
    exam_line = ""
    if req.nearestExamCourse and req.nearestExamDate:
        exam_line = f"\n- Upcoming exam: {req.nearestExamCourse} on {req.nearestExamDate}"
    rating_line = ""
    if req.difficultyRating is not None:
        rating_line = f"\n- Student difficulty rating for this course: {req.difficultyRating}/5 (5=hardest)"
    extra = _topic_instructions(topic, req.courseCode, req.courseName or "")
    if topic == "projects":
        length_rule = (
            "LENGTH: Intro + exactly 4 bullets in the **Title** — description format; "
            "each description 1–2 complete sentences (~120–220 chars). Finish every sentence."
        )
    elif topic == "books":
        length_rule = (
            "LENGTH: Intro + exactly 4 bullets in **Book title** by Author — reason format; "
            "complete sentences only."
        )
    else:
        length_rule = (
            "LENGTH: At most 6 bullet lines; each line must be a complete sentence ending with . or !"
        )
    return f"""You are StudySync study coach for Yeditepe University students.
Answer ONLY about course {req.courseCode} ({req.courseName or 'university course'}).
Topic: {topic_title}
Keep answer practical, English, friendly.
FORMAT: Use lines starting with "* " for lists; use **bold** for names/titles. Never end with ### or ##.
{length_rule}
Do not mention other courses. No generic fluff.
{extra}

Student context:
- Name: {req.studentName}
- Study goal: {req.studyGoal or 'not set'}{exam_line}{rating_line}

Write helpful, specific guidance for the topic."""


def _books_fallback_text(code: str, name: str) -> str:
    upper = code.upper()
    if upper.startswith("CSE331"):
        return (
            f"For {code} ({name}), these books are widely used:\n"
            f"* **Operating System Concepts** by Silberschatz, Galvin & Gagne — Core text for processes, "
            f"CPU scheduling, memory, and file systems.\n"
            f"* **Modern Operating Systems** by Tanenbaum & Bos — Clear explanations of concurrency and I/O.\n"
            f"* **Operating Systems: Three Easy Pieces** by Arpaci-Dusseau — Free online; great for virtualization and "
            f"scheduling with short chapters.\n"
            f"* **The C Programming Language** by Kernighan & Ritchie — Useful for systems labs and kernel-style C."
        )
    if upper.startswith("CSE323"):
        return (
            f"For {code} ({name}), consider:\n"
            f"* **Computer Organization and Design: RISC-V Edition** by Patterson & Hennessy — Datapath, pipeline, "
            f"and memory hierarchy.\n"
            f"* **Structured Computer Organization** by Tanenbaum — Broader architecture background.\n"
            f"* **Digital Design and Computer Architecture** by Harris & Harris — Verilog-friendly labs.\n"
            f"* Your course syllabus textbook — Always start there for exam alignment."
        )
    if upper.startswith("CSE344"):
        return (
            f"For {code} ({name}), consider:\n"
            f"* **Software Engineering** by Sommerville — Requirements, design, and lifecycle.\n"
            f"* **Clean Code** by Robert C. Martin — Practical coding standards for team projects.\n"
            f"* **The Pragmatic Programmer** by Hunt & Thomas — Professional habits and tooling.\n"
            f"* **Design Patterns** by Gamma et al. — Classic patterns used in SE courses."
        )
    return (
        f"For {code} ({name}), start with your syllabus textbook, then add:\n"
        f"* **A core textbook** for the subject — Work through end-of-chapter exercises weekly.\n"
        f"* **One reference with solved problems** — Use for exam-style practice.\n"
        f"* **Open-access lecture notes** — Search the library portal for {code}.\n"
        f"* **Course slides** — Combine slides with book chapters before each midterm."
    )


def _projects_fallback_text(code: str, name: str) -> str:
    upper = code.upper()
    if upper.startswith("CSE323"):
        return (
            f"For {code} ({name}), here are project ideas:\n"
            f"* **RISC-V single-cycle core** — Implement a minimal RV32I datapath in Verilog; "
            f"test add/load/store and document the datapath in a 2-page report.\n"
            f"* **Pipelined CPU lab** — Add a 5-stage pipeline, handle one hazard type, and compare CPI vs single-cycle in a short demo.\n"
            f"* **Cache simulator** — Model direct-mapped vs set-associative cache; plot miss rate vs size and explain results for {code}.\n"
            f"* **MMU & paging demo** — Simulate virtual-to-physical translation with a small page table and show TLB hit/miss stats."
        )
    if upper.startswith("CSE354"):
        return (
            f"For {code} ({name}), here are project ideas:\n"
            f"* **Regex-to-DFA builder** — Convert simple regex to NFA/DFA and test acceptance on sample strings; include a README.\n"
            f"* **CFG mini-parser** — Define a grammar for a tiny language and build a top-down or LR parser with test cases.\n"
            f"* **Pumping lemma write-up** — Pick one non-regular language and prove it with the pumping lemma (3–4 pages).\n"
            f"* **TM visualizer** — Simulate a Turing machine for palindromes or {code} and explain transitions in a short report."
        )
    return (
        f"For {code} ({name}), here are project ideas:\n"
        f"* **Syllabus topic demo** — Build a small app or simulator for one core lecture topic; include tests and a README.\n"
        f"* **Comparative study** — Compare two methods from class with metrics or proofs in a 2–3 page report.\n"
        f"* **Lab extension** — Extend a course lab with one new feature and document design trade-offs in slides.\n"
        f"* **Past-exam challenge set** — Solve three exam-style problems and explain each solution step-by-step."
    )


def _fallback_response(req: GuidedChatRequestIn, topic: str, source: str) -> GuidedChatResponseOut:
    code = req.courseCode
    name = req.courseName or code
    templates: dict[str, str] = {
        "exam_study": (
            f"For {code} ({name}): review lecture notes weekly, solve past exam questions under timed "
            f"conditions, and focus on topics you rated as difficult. Form a small study group 5–7 days "
            f"before the exam."
        ),
        "youtube": _sanitize_gemini_text(
            f"For {code} ({name}), try these channels:\n"
            f"* **Neso Academy** — theory lectures matching your syllabus topics\n"
            f"* **Computerphile** — intuitive concept explainers\n"
            f"* **freeCodeCamp** — long-form structured tutorials\n"
            f"* **Traversy Media** — practical project walkthroughs\n"
            f"* **Search** — \"{code} tutorial playlist\" and \"{code} past exam walkthrough\""
        ),
        "books": _sanitize_gemini_text(_books_fallback_text(code, name)),
        "careers": (
            f"With {code} skills, look for internships in software, data, or engineering roles that list "
            f"this subject. Update LinkedIn, attend campus career days, and ask professors about alumni paths."
        ),
        "projects": _sanitize_gemini_text(_projects_fallback_text(code, name)),
    }
    return GuidedChatResponseOut(
        message=templates.get(topic, f"Study tips for {code} will appear when AI is available."),
        source=source,
        topic=topic,
        courseCode=req.courseCode,
    )
