import os

from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "").strip()
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.5-flash-lite").strip()
GEMINI_MODEL_FALLBACK = os.getenv("GEMINI_MODEL_FALLBACK", "gemini-2.0-flash-lite").strip()
# Throttle Gemini: cache hits avoid API; min interval + cooldown protect free-tier quota
GEMINI_CACHE_TTL_SECONDS = int(os.getenv("GEMINI_CACHE_TTL_SECONDS", "600"))
GEMINI_MIN_INTERVAL_SECONDS = int(os.getenv("GEMINI_MIN_INTERVAL_SECONDS", "60"))
GEMINI_COOLDOWN_SECONDS = int(os.getenv("GEMINI_COOLDOWN_SECONDS", "300"))
# Render.com injects PORT; local dev uses AI_SERVICE_PORT or 8090
_default_port = os.getenv("PORT") or os.getenv("AI_SERVICE_PORT") or "8090"
AI_SERVICE_PORT = int(_default_port)
