# StudySync AI Planner (Python)

Gemini + scoring service. Spring Boot (`backend_java`) bu servisi cagirir; Flutter dogrudan Python'a baglanmaz.

## Ekip icin kurulum (ilk kez)

### 1. `.env` dosyasini olustur

`.env` Git'e **gitmez**. Herkes kendi bilgisayarinda bir kez yapar:

**Windows (PowerShell):**

```powershell
cd backend_python
Copy-Item .env.example .env
notepad .env
```

**Mac / Linux:**

```bash
cd backend_python
cp .env.example .env
nano .env
```

### 2. Gemini API key ekle

1. Tarayicida ac: https://aistudio.google.com/apikey  
2. **Create API key** → key'i kopyala  
3. `.env` icinde su satiri duzenle:

```env
GEMINI_API_KEY=AIzaSy...buraya_yapistir
```

- Tirnak (`"`) kullanma  
- Bosluk birakma  
- Bu key'i **GitHub'a, Discord'a screenshot ile** gonderme  

`GEMINI_MODEL` ve `AI_SERVICE_PORT` satirlarini degistirmene gerek yok (varsayilanlar yeterli).

### 3. Python ortamini kur

```bash
cd backend_python
python -m venv .venv
```

**Windows:**

```powershell
.\.venv\Scripts\activate
pip install -r requirements.txt
```

**Mac/Linux:**

```bash
source .venv/bin/activate
pip install -r requirements.txt
```

### 4. Servisleri calistir (3 terminal)

| # | Klasor | Komut |
|---|--------|--------|
| 1 | `backend_python` | `uvicorn app.main:app --host 0.0.0.0 --port 8090 --reload` |
| 2 | `backend_java` | `.\mvnw.cmd spring-boot:run` (Windows) |
| 3 | `mobile_flutter` | `flutter run` |

Python kapaliysa mobil app **yine acilir**; AI kartlari Java fallback ile gelir (Gemini metni olmayabilir).

## Dogrulama

- Python saglik: http://localhost:8090/health  
- Java saglik: http://localhost:8080/api/v1/health  
- App'te Home → **AI Suggestions** karti gorunmeli  

## Canli ortam (Render)

`.env` dosyasi kullanilmaz. Render dashboard → **Environment** → ekle:

- `GEMINI_API_KEY`
- `AI_PYTHON_BASE_URL` (Python servisinin public URL'i)

Java servisinde: `AI_PYTHON_BASE_URL=https://...`

## Dosyalar

| Dosya | Git'e gider mi? | Aciklama |
|-------|-----------------|----------|
| `.env.example` | Evet | Sablon + talimatlar |
| `.env` | **Hayir** | Gercek API key (sadece senin PC) |
