# Backend Logic Analysis & Bug Report

I've extensively investigated the `com.studysync.domain.service` tier which acts as the core business engine. 

While the Authentication (`AuthService`), Check-Ins (`CheckInService`), and aggregated user data calculations (`DashboardService`) we worked on earlier are absolutely robust and production-ready, the rest of the application skeleton contains significant intentionally stubbed logic (dummy data) left over from the initial project scaffolding phase that is legally "buggy" because it bypasses the database completely.

## Critical Issues & Unimplemented Logic (Bugs)

> [!WARNING]
> These issues natively disrupt the flow of data because the services do not query the database yet. They must be resolved before the Flutter app tries handling them.

1. **`ReservationService.java` is Stubbed & Hardcoded:**
   - **Hardcoded User:** `createReservation()` does not extract the user from the JWT `SecurityContextHolder`. It hardcodes `Long defaultUserId = 1L;`. You'll need to refactor this to read from `SecurityContext`.
   - **Empty Workspace Loading:** `getWorkspaces(...)` is completely stubbed and returns an empty `List.of()`. It does not reach out to the map/sensor data. 
   - **User Reservations Returns Nothing:** The `myReservations()` method is blank (`List.of()`). This breaks the profile page's ability to show history.
   - **Cancellation bypasses logic:** `cancelReservation()` just returns a dummy success message instead of extracting the reservation and transitioning its state to `CANCELLED`.
2. **`ScheduleService.java` Stores Memory Only:**
    - The `putWeekly()` and `getWeekly()` logic currently ignores the database `WeeklyScheduleBlockRepository`. Instead, it stores standard Java arrays directly in the JVM memory scope `private final List<WeeklyScheduleBlockDto> blocks`. This will wipe every time the server restarts and isn't horizontally scalable!
3. **`StudyBuddyService.java` is Missing its Engine:**
   - `getSuggestions()` returns an empty `List.of()`. The cross-referencing math calculating the match scores (`matchScore`) against course codes, departments, and overlapping schedules isn't implemented.
4. **`CourseService.java` relies on Stubs:**
   - Getting the courses lists and rating logic remains unconnected to the entity layer. 

---

# Frontend ↔ Backend Connection Brief (API Mapping)

The endpoints mapped out in your `@RestController` classes are completely designed to support the Flutter frontend flows. Below is a unified map of every connection. All paths are prefixed under `http://localhost:8080/api/v1/`.

### 1. Security & Authentication (Fully Functional)
The Flutter app *must* attach a generated JWT as a Bearer Token (`Authorization: Bearer <token>`) to access any endpoints outside of `/auth`.
- `POST /auth/register` — Validates Yeditepe domains, encrypts password, returns token.
- `POST /auth/login` — Compares encoded BCrypt hashes and returns token + session.
- `POST /auth/refresh` — Flushes a stale login for a new authentication token lifecycle.

### 2. Standard Operation & Profiles (Fully Functional)
- `GET /dashboard/home` — Used for the Home screen. Securely reads the user's score and dynamically fetches all of their Upcoming/Active reservations.
- `POST /checkin/verify` — Used by the Camera. Receives a QR code string, mathematically matches the policy to the reservation payload, and updates status to `COMPLETED` scoring `+5` points.

### 3. StudySync Reservations
- `GET /reservations/workspaces` — Fetch available library/lab slots.
- `POST /reservations` — Build a reservation. (Requires overlap bug fixes from above).
- `GET /reservations/me` — Fetch all reservations mapped solely to the user.
- `POST /reservations/{reservationId}/cancel` — Triggers the cancellation scoring logic metric. 

### 4. Campus Social & Support
- `GET /study-buddies/suggestions` — Generates a list of matching users (Requires StudyBuddyService implementation).
- `GET /courses` — Pulls course list for the "Classes" view.
- `POST /courses/{courseCode}/rating` — Rate difficulty/intensity of a syllabus.
- `GET /lost-found` & `POST /lost-found` — Queries or generates lost item desk tickets! (Needs real DB persistence mapping).

### 5. Timetable / Schedule 
- `GET /schedule/weekly` — Retrieves blocked hours.
- `PUT /schedule/weekly` — Overrides the current schedule blocks (Currently stuck in JVM memory bug mentioned above).

### 6. System
- `GET /reference/departments` — Dropdown UI reference list.
- `GET /health` — Check server pulse/liveness.
## --------------------------------