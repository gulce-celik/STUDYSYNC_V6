# StudySync Implementation Status

## Completed in this step

- Added shared contract file: `docs/api-contract-v1.md`
- Created Flutter skeleton in `mobile_flutter/`
  - Theme and app shell
  - Home and Reservation screens
  - API client and reservation API adapter
- Created Spring Boot skeleton in `backend_java/`
  - Boot app + config
  - Health, Auth, Dashboard, Reservation, Check-in endpoints
- Expanded Flutter module shell with:
  - `Home`, `Reserve`, `Bookings`, `Study Buddy`, `Profile` tabs
  - feature API adapters for `courses`, `lost-found`, `study-buddy`
- Expanded Java backend with typed DTO + service layer:
  - `CourseController`, `LostFoundController`, `StudyBuddyController`
  - DTO records replacing loose map responses in reservation flows
- Product decision persisted:
  - `docs/decision-cancellation-scoring.md` (accepted combined cancellation/no-show policy)
  - Reservation cancel endpoint supports optional timing payload for scoring evaluation
- **Auth + Figma-aligned UI (2026-04-07)**:
  - `AuthController` + `AuthScope`: app opens on **Login** (Yeditepe `@std.yeditepe.edu.tr` validation), then **BottomNavShell**; Profile has **Sign out**
  - **Login** screen matches React/Figma bundle: gradient hero, white card, mail/lock fields, gradient CTA
  - **Reserve Space** matches `ReservationMap.tsx` + analysis rules: SVG-scale map (desks + group rooms), filters, legend, Mon/Fri advance booking vs instant desks (`desk-2`, `desk-15`), lost-item yellow state, expandable bottom form (type, date, slot, course, group nicknames, study-buddy toggle), scoring hints (+3 / −10)
  - Mock layout data in `reservation_mock_data.dart` (parity with `src/app/data/mockData.ts`)
- **Home + navigation parity (2026-04-07)**:
  - `AppTabController` + `BottomNavShell`: Home **Quick Actions** (Reserve / Bookings / Buddy) switch bottom tabs without breaking shell state
  - **Home** reworked toward `Home.tsx`: hero + responsibility badge, study tip card, **gradient** quick-action tiles (5), upcoming list + QR check-in callout + “View All”, **Group Invitations** with accept/reject
  - `home_mock_data.dart` mirrors upcoming reservations + invitations from `mockData.ts`
- **New Flutter screens** (React/Figma parity, mock-first):
  - `WeeklyScheduleScreen` + `schedule_mock_data.dart` — grid + slot editor (lesson/club/busy)
  - `CourseRatingScreen` — search, difficulty stars, topics, AI hint, submit flow (aligns with `POST /courses/{code}/rating` when wired)
  - `LostFoundScreen` — info banner, report sheet, optional map (same desk geometry as reserve), list — aligns with `GET`/`POST /lost-found`
- **Profile**: navigates to Weekly Schedule, Course Ratings, Lost & Found
- **Backend + contract**: `GET/PUT /api/v1/schedule/weekly` documented in `api-contract-v1.md`; Java `ScheduleController`, `ScheduleService`, DTOs (`WeeklyScheduleBlockDto`, `WeeklyScheduleResponseDto`, `WeeklySchedulePutRequestDto`)
- **Backend Java (2026-04-07 güncellemesi)**: İş mantığı bilinçli olarak sadeleştirildi; controller/service dosyalarında
  **ne yapılması gerektiği Javadoc / yorum** olarak anlatılıyor. Çoğu liste uç noktası şimdilik **boş** döner; mobil
  taraf mock’a düşer. Giriş uç noktası minimal **stub token** döndürmeye devam eder (JWT’ye çevrilmeli).
  Maven: bu ortamda `winget` ile resmi Apache Maven paketi bulunamadı — [Maven indirme](https://maven.apache.org/download.cgi)
  veya IDE (IntelliJ / Eclipse) ile derleme önerilir.

- **Bookings / Buddy / map / home (2026-04-07)**:
  - `MyBookingsScreen`: tabs (Active / History), `GET /reservations/me`, cancel → `POST .../cancel` (+ zaman gövdesi), QR sheet → `POST /checkin/verify`; mock `bookings_mock_data.dart`
  - `StudyBuddyScreen`: course + `slotId` → `GET /study-buddies/suggestions`, mock fallback `study_buddy_mock_data.dart`
  - `ReservationMapScreen`: tarih/slot/tip değişince `GET /reservations/workspaces`; doluysa sunucu koordinatları, değilse mevcut mock harita
  - `HomeScreen`: `GET /dashboard/home` ile sorumluluk rozeti (hata → mock)
  - `DashboardApi`, `CheckInApi`; `ReservationDetail` modeli + `ReservationApi` genişletmesi
  - `AppConfig` yorumu: USB yükleme ≠ API adresi; fiziksel Android için `API_BASE`

- **Flutter ↔ Java wiring (2026-04-07)**:
  - `AuthSession` + `ApiClient` interceptor: Bearer token after login
  - `AppConfig.baseUrl`: Android `10.0.2.2`, else `localhost`; optional `API_BASE` define
  - `LoginScreen` → `AuthApi` `POST /auth/login` → `AuthController.establishSession`
  - `WeeklyScheduleScreen` → `ScheduleApi` `GET/PUT /schedule/weekly` (fallback mock if offline); toolbar sync + refresh
  - `CourseRatingScreen` → `GET /courses`, `POST /courses/{code}/rating` (fallback list if offline)
  - `LostFoundScreen` → `GET/POST /lost-found` (fallback list if offline)
  - Contract doc updated with client base URL + Bearer note

## Next implementation order

1. Flutter: extend reservation map / my bookings to prefer `ReservationApi` where endpoints are ready; secure token storage (`flutter_secure_storage`)
2. Java request DTO classes (replace remaining map bodies on POSTs where needed)
3. Reservation domain rules: slot overlap, daily limit, Mon/Fri booking windows (server-side)
4. QR check-in rules and responsibility score persistence
5. Persistence layer (PostgreSQL + JPA)
