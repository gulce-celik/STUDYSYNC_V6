# StudySync — AI özellikleri (tek rehber)

Bu dosya **yerel test**, **canlı deploy (Render + Neon)** ve **backend ekibi** için tek kaynaktır.  
Eski dosyalar birleştirildi: `LOCAL_AI_TEST.md`, `BACKEND_AI_CANLI_DEPLOY.md`, `ai-render-deploy.md`.

---

## 1) Ne yaptık? (özet)

| Özellik | Flutter | Java API | Python |
|--------|---------|----------|--------|
| Home / Reserve / Buddy AI kartları | `GET /ai/suggestions` | `AiPlannerService` → DB’den schedule, ratings, enrolled, prefs | `/planner/suggestions` — scoring + isteğe bağlı Gemini |
| Haftalık program — Study Assistant (sohbet) | Tam ekran chat, buton akışı (yazı yok) | `GET /ai/guided-chat/courses`, `POST /ai/guided-chat` | `/planner/guided-chat` — cache + Gemini |
| Profil dersleri | Kayıt + Edit → `PUT /auth/me/courses` | `user_enrolled_courses` (Neon/H2) | — |
| Ders kataloğu | `GET /courses` (Edit, rating) | `course_catalog` tablosu | — |

**Ders kuralı (AI):** Sadece **sistem kataloğundaki** dersler + kullanıcının **kayıtlı (enrolled)** veya **sunucuya kayıtlı takvim** blokları. Mock takvim blokları chat’e girmez; sync edilmediyse sadece profil dersleri geçerli.

**Gemini yanıtı:** `source: gemini` | `cache` | `scoring` | `scoring-fallback` (Python/Java kapalı veya kota).

---

## 2) AI nasıl çalışır? (SQL + scoring + Gemini)

AI **tek bir “sihirli kutu” değil** — üç katmanlı çalışır:

```
┌─────────────────────────────────────────────────────────────┐
│  1) SQL (Neon / H2) — Java okur, gerçek kullanıcı verisi   │
└───────────────────────────────┬─────────────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────┐
│  2) Scoring — deterministik puanlama (Python; Java yedek)   │
│     Hangi ders, hangi gün/saat, kaç puan — burada belli     │
└───────────────────────────────┬─────────────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────┐
│  3) Gemini — sadece metin zenginleştirme (isteğe bağlı)     │
│     Kart mesajı / Study Assistant cevabı daha insani        │
└─────────────────────────────────────────────────────────────┘
```

**Önemli:** Gemini **karar vermez** (hangi slot, hangi ders). Önce scoring adayları seçer; Gemini yalnızca açıklama/metin yazar. Python veya key yoksa scoring şablon metinleri kullanılır — app yine çalışır.

### 2.1 Veritabanından okunan alanlar

Java, her AI isteğinde kullanıcıyı DB’den yükler (`JwtAuthenticationFilter` + repository). Flutter mock verisi **AI’ya gitmez**.

| Kullanıcı verisi | DB / API | Ne işe yarar? |
|------------------|----------|----------------|
| **Kayıtlı dersler (enrolled)** | `user_enrolled_courses` — kayıt + Profile Edit (`PUT /auth/me/courses`) | Öncelikli ders seçimi; Study Assistant’ta sorulabilir dersler |
| **Ders kataloğu** | `course_catalog` — `GET /courses` | Ders kodu → **ders adı** (Gemini prompt’ta); geçersiz kod reddedilir |
| **Haftalık takvim** | `weekly_schedule_blocks` — Schedule ekranı `PUT /schedule/weekly` ile sync | Dolu saatler (lesson/club/busy/**exam**); boş slotlara reserve önerisi |
| **Sınav blokları** | Takvimde `type=exam`, label: `EXAM:CSE331:2026-06-15` | En yakın sınav → **en yüksek öncelik**; buddy kartı sınav odaklı |
| **Ders zorluk oylaması** | `user_course_ratings` — `POST /courses/{code}/rating` (1–5 yıldız) | **5 = en zor**; zor dersler reserve önerisinde öne çıkar; chat’e zorluk bilgisi gider |
| **Study Buddy tercihleri** | `user_accounts`: `study_goal`, `preferred_time`, `preferred_days` — Profile (`PUT /auth/me/planner-preferences`) | Sabah/öğleden sonra/akşam slotları; hedef metinde geçer |
| **Responsibility score (katılım puanı)** | `user_accounts.responsibility_score` — QR **check-in**, iptal, **no-show** ile güncellenir | Skor &lt; 75 ise reserve adayına küçük bonus (+3); profilde görünür |

**Takvim blok tipleri** (`lesson`, `club`, `busy`, `exam`): hepsi o saati **dolu** sayar — AI reserve önerisi o slota koymaz.

**Study Assistant ders listesi:** `course_catalog` ∩ (`enrolled` ∪ takvimden çıkan kodlar). Profilde olmayan ve DB’de takvimde olmayan ders sorulamaz.

### 2.2 Home AI kartları (`GET /ai/suggestions`) — adım adım

1. Flutter JWT ile Java’ya istek atar.
2. Java SQL’den context toplar → Python `POST /planner/suggestions` body’si (`AiPlannerContextDto`).
3. **Scoring (Python `scoring.py`):**
   - Takvimde **boş** grid hücrelerini bulur.
   - **Öncelik dersi** seçer:
     - Varsa → en yakın **sınav** dersi
     - Yoksa → enrolled içinde **en yüksek yıldızlı (en zor)** ders
     - Yoksa → takvim etiketlerinden ders
   - Her aday slot için puan: sınav yakınlığı (+25 / +12), zorluk yıldızı, preferred time/day, study goal, düşük responsibility score.
   - En iyi 2 reserve + 1 buddy adayı çıkar.
4. **Gemini (`gemini_enricher.py`):** adayların `id` + context ile kısa mesaj yazar (cache ~10 dk, kota koruması).
5. Python yanıt döner (`source: gemini` veya `scoring`). Python down → Java aynı scoring mantığıyla `scoring-fallback`.

**Buddy kartı:** Yakın sınav varsa aynı derste çalışma arkadaşı önerisi; yoksa reserve ile aynı ders/saat hattı.

*Not:* Study Buddy **liste eşleştirmesi** (`StudyBuddyService`) ayrı SQL skoru — ortak enrolled dersler, yıl yakınlığı; AI kartı buddy **zaman/ders** önerir, eşleşme listesi başka endpoint.

### 2.3 Study Assistant (`guided-chat`) — adım adım

1. `GET /ai/guided-chat/courses` → kullanıcının sorabileceği katalog dersleri (kod + **ad**).
2. Kullanıcı ders + konu seçer (yazı yok): `exam_study`, `youtube`, `books`, `careers`, `projects`.
3. Java: katalogda ders var mı, enrolled/schedule’da mı kontrol eder.
4. Context: `courseName`, kullanıcının o derse **rating**’i, en yakın **sınav**, `study_goal`.
5. Python `POST /planner/guided-chat` → Gemini veya şablon cevap (cache ~15 dk).

### 2.4 Katıldı / check-in AI’yı nasıl etkiler?

Doğrudan “şu rezervasyona katıldı” satırı AI SQL’inde yok; **dolaylı** etki:

| Olay | Responsibility score | AI etkisi |
|------|---------------------|-----------|
| QR check-in (katıldım) | Artar | Yüksek skor → reserve bonusu **yok** (bonus skor &lt; 75 için) |
| Erken iptal | Küçük düşüş | Düşük skor → hafif öncelik artışı |
| No-show (gelmedi) | Belirgin düşüş | Aynı — düşük skorlu öğrenciye daha “disiplin” odaklı slot önerisi |

Profil skoru `GET /auth/me` ile güncellenir; bir sonraki AI isteğinde yeni değer kullanılır.

### 2.5 `source` alanı ne anlama gelir?

| `source` | Anlam |
|----------|--------|
| `gemini` | Scoring + Gemini metni (canlı key OK) |
| `cache` | Aynı ders/konu veya aynı profil kısa süre önce sorulmuş — API tekrar çağrılmadı |
| `scoring` | Python scoring; Gemini atlandı (key yok / throttle) |
| `scoring-fallback` | Java tarafında Python’a ulaşılamadı; aynı mantık Java’da |

---

## 3) Mimari

```
Flutter (JWT)
    │
    ▼
Java API (Render) ──► Neon PostgreSQL
    │                      • user_accounts, enrolled courses
    │                      • weekly_schedule_blocks, ratings
    │                      • course_catalog (kod + ders adı)
    ▼
Python AI (Render veya localhost:8090)
    • GEMINI_API_KEY (sadece burada / .env)
    • /planner/suggestions
    • /planner/guided-chat
```

- **SQL ve iş kuralları:** Java.
- **Metin zenginleştirme:** Python + Gemini (kota koruması: cache, min aralık, cooldown).
- **Flutter** canlıda varsayılan: `https://studysync-56nq.onrender.com/api/v1` (`app_config.dart`).

---

## 4) API uçları

| Method | Path | Açıklama |
|--------|------|----------|
| GET | `/ai/suggestions` | Reserve + Study Buddy öneri kartları |
| GET | `/ai/guided-chat/courses` | Chat’te seçilebilir dersler (katalog ∩ enrolled ∪ schedule) |
| POST | `/ai/guided-chat` | Body: `{ "courseCode": "CSE331", "topic": "exam_study" }` |
| PUT | `/auth/me/courses` | Profil ders güncelleme |
| GET | `/courses` | Tüm katalog (kayıt/edit listesi için) |

**Guided chat topic değerleri:** `exam_study`, `youtube`, `books`, `careers`, `projects`

---

## 5) Gemini API key — kim, nerede?

| Ortam | Key nereye yazılır | GitHub? |
|-------|-------------------|---------|
| **Yerel** | `backend_python/.env` → `GEMINI_API_KEY=...` | **Hayır** — `.gitignore` |
| **Canlı** | Render → Python Web Service → **Environment Variables** | **Hayır** — sadece panel |

**Key almak:** [Google AI Studio](https://aistudio.google.com/apikey) → Create API key.

**Önemli uyarılar:**
- Key’i **asla** repo’ya, Slack’e düz metin, ekran görüntüsüne koymayın.
- `backend_python/.env` commit edilmemeli (`.env.example` şablon olarak kalır).
- Kota biterse yeni key veya yeni Google Cloud projesi gerekir; model: `gemini-2.5-flash-lite` (fallback: `gemini-2.0-flash-lite`).

Java servisinde **GEMINI key yok** — sadece Python’a `AI_PYTHON_BASE_URL` ile bağlanır.

---

## 6) Yerel test (Neon’a yazmaz)

### Gereksinimler

- Python 3.11+, JDK 21, Flutter, Android emülatör
- `backend_python/.env` (`.env.example` kopyala, kendi key’ini yaz)

### 3 terminal

**1 — Python (8090)**

```powershell
cd backend_python
.\.venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8090 --reload
```

Kontrol: http://localhost:8090/health

**2 — Java (8080, profil `dev` → H2 bellek)**

```powershell
cd backend_java
.\mvnw.cmd spring-boot:run
```

Kontrol: http://localhost:8080/api/v1/health

**3 — Flutter (emülatör → local Java)**

```powershell
cd mobile_flutter
flutter run -d emulator-5554 --dart-define=API_BASE=http://10.0.2.2:8080/api/v1
```

`--dart-define` **olmadan** uygulama **canlı Render** Java’ya gider; local Python devreye girmez.

### Test kullanıcısı (H2 seed)

- Email: `alice.student@std.yeditepe.edu.tr`
- Şifre: `Password123!`

### Beklenen

- Home → AI kartları (`source: gemini` veya `scoring`)
- Schedule → mavi AI butonu → Study Assistant sohbet
- Profile → Edit courses → kayıt sonrası chat listesi güncellenir

---

## 7) Canlıya alma — backend ekibi (Render + Neon)

Mobil varsayılan API: `https://studysync-56nq.onrender.com/api/v1` — Flutter tarafında ekstra iş yok (store build hariç).

### 7.1 Neon

Java **prod** profili:

| Render env (Java) | Açıklama |
|-------------------|----------|
| `SPRING_PROFILES_ACTIVE` | `prod` |
| `DATABASE_URL` | Neon connection string |
| `DATABASE_USERNAME` | Neon user |
| `DATABASE_PASSWORD` | Neon password |

`ddl-auto: update` ile yeni kolonlar otomatik eklenir (`study_goal`, `preferred_time`, `preferred_days`, vb.).  
İlk deploy sonrası Neon console’dan `user_accounts`, `course_catalog`, `user_enrolled_courses` kontrol edin.

**Ders kataloğu:** `course_catalog` tablosu canlı DB’de dolu olmalı (ekibin seed/migration’ı). Kayıt ve AI bu tabloyu kullanır.

### 7.2 Render — YENİ Python Web Service

1. Render Dashboard → **New → Web Service**
2. Aynı GitHub repo, branch `main`
3. **Root Directory:** `backend_python`
4. **Environment:** Docker (`backend_python/Dockerfile`)

**Environment variables (Python servisi):**

| Key | Değer |
|-----|--------|
| `GEMINI_API_KEY` | Google AI Studio key (**repo’ya yazılmaz**) |
| `GEMINI_MODEL` | `gemini-2.5-flash-lite` |
| `GEMINI_MODEL_FALLBACK` | `gemini-2.0-flash-lite` (opsiyonel) |

Deploy URL örneği: `https://studysync-ai-xxxx.onrender.com`

```bash
curl -s https://studysync-ai-xxxx.onrender.com/health
# Beklenen: success true, service studysync-ai-python
```

### 7.3 Render — Mevcut Java servisi

**Yeni env ekle** (Settings → Environment):

| Key | Değer |
|-----|--------|
| `AI_PYTHON_BASE_URL` | `https://studysync-ai-xxxx.onrender.com` (**sonunda `/` yok**) |
| `AI_PYTHON_ENABLED` | `true` |

**Mevcut env’ler aynı kalsın:** `SPRING_PROFILES_ACTIVE=prod`, Neon `DATABASE_*`, `JWT_SECRET`, `BREVO_API_KEY`, vb.

Push veya **Manual Deploy** sonrası:

```bash
curl -s https://studysync-56nq.onrender.com/api/v1/health
# features içinde ai-planner olmalı

curl -s -H "Authorization: Bearer TOKEN" \
  https://studysync-56nq.onrender.com/api/v1/ai/suggestions

curl -s -H "Authorization: Bearer TOKEN" \
  https://studysync-56nq.onrender.com/api/v1/ai/guided-chat/courses
```

### 7.4 Bağlantı özeti

| Bileşen | Ne yapar | Env / ayar |
|---------|----------|------------|
| **Neon** | Kalıcı veri: kullanıcılar, dersler, takvim, katalog | Java Render’da `DATABASE_*` |
| **Java Render** | REST API, JWT, DB okur, Python’a proxy | `AI_PYTHON_BASE_URL`, `AI_PYTHON_ENABLED` |
| **Python Render** | Gemini + scoring | `GEMINI_API_KEY` |
| **Flutter** | Sadece Java URL’ine istek | Varsayılan canlı URL; local için `--dart-define` |

Python kapalıysa veya key yoksa: Java **scoring-fallback** döner — uygulama çökmez, Gemini metni olmayabilir.

---

## 8) Git — push öncesi kontrol

Push edilecek alanlar (örnek):

- `backend_java/` — `AiController`, `AiGuidedChatService`, `AiPlannerService`, `PythonAiPlannerClient`, planner prefs
- `backend_python/` — FastAPI, `guided_chat.py`, `gemini_enricher.py`, Dockerfile
- `mobile_flutter/` — planner, schedule AI screen, `guided_chat_api.dart`
- `docs/STUDYSYNC_AI.md` (bu dosya)

**Push etmeyin:** `backend_python/.env`, gerçek API key’ler.

---

## 9) Sorun giderme

| Belirti | Olası neden |
|---------|-------------|
| `/ai/suggestions` 404 | Java redeploy olmamış |
| `/ai/guided-chat` 400 Unknown course | Kod katalogda yok |
| `/ai/guided-chat` 400 schedule/enrolled | Ders profilde veya DB takvimde yok |
| `source: scoring-fallback` | `AI_PYTHON_BASE_URL` yanlış veya Python down |
| `source: scoring`, Gemini yok | `GEMINI_API_KEY` yok veya kota |
| Flutter local Python kullanmıyor | `API_BASE` dart-define eksik |
| Render cold start | İlk istek 30–60 sn; tekrar dene |

---

## 10) İlgili dosyalar

| Dosya | Açıklama |
|-------|----------|
| `backend_python/app/scoring.py` | Reserve/buddy puanlama mantığı |
| `backend_python/app/gemini_enricher.py` | Planner kartları Gemini metni |
| `backend_python/app/guided_chat.py` | Study Assistant cevapları |
| `backend_java/.../AiSuggestionScoringService.java` | Java scoring fallback |
| `backend_java/.../AiPlannerService.java` | SQL → Python context |
| `backend_java/.../AiGuidedChatService.java` | Guided chat doğrulama + katalog |
| `backend_python/.env.example` | Yerel key şablonu |
| `backend_java/src/main/resources/application.yml` | `app.ai.python.*` |
| `mobile_flutter/lib/core/config/app_config.dart` | Canlı / local API base |
| `docs/api-contract-v1.md` | Genel API sözleşmesi |
