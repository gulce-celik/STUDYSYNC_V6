# StudySync — Frontend Technical Documentation

---

## 1. Overview

StudySync has **two separate frontends** that share the same Spring Boot backend:

| Frontend | Technology | Purpose |
|---|---|---|
| **Web Prototype** | React 18 + Vite + TailwindCSS v4 | Desktop/browser demo, rendered as a phone mockup |
| **Mobile App** | Flutter (Dart, SDK ≥ 3.3) | Real Android/iOS app, connects to real backend |

Both frontends implement the same feature set: authentication, study-space reservation, QR check-in, study-buddy matching, course rating, lost-and-found, and weekly schedule.

---

## 2. Web Frontend (React/Vite)

### 2.1 Tech Stack & Dependencies

| Package | Version | Role |
|---|---|---|
| React | 18.3.1 | UI library |
| react-router | 7.13.0 | Client-side routing |
| Vite | 6.3.5 | Build tool / dev server |
| TailwindCSS | 4.1.12 | Utility CSS (via `@tailwindcss/vite`) |
| Radix UI | various | Headless accessible UI primitives |
| lucide-react | 0.487.0 | Icon library |
| sonner | 2.0.3 | Toast notifications |
| qrcode.react | 4.2.0 | QR code generation |
| react-hook-form | 7.55.0 | Form state management |
| recharts | 2.15.2 | Charts (admin stats) |
| motion | 12.23.24 | Animations |
| date-fns | 3.6.0 | Date utilities |
| react-dnd | 16.0.1 | Drag-and-drop (weekly schedule) |

**Build command:** `npm run dev` (Vite dev server)

---

### 2.2 Directory Structure

```
src/
├── main.tsx                  # Entry point — mounts <App /> into #root
├── app/
│   ├── App.tsx               # Root component: RouterProvider + Toaster
│   ├── Root.tsx              # Layout shell: phone frame + status bar + Navigation
│   ├── routes.ts             # createBrowserRouter config
│   ├── data/
│   │   └── mockData.ts       # All TypeScript interfaces + static mock data
│   ├── components/
│   │   ├── Navigation.tsx    # Bottom tab bar (5 tabs)
│   │   ├── ui/               # 48 Radix-UI-based shadcn components
│   │   └── figma/            # Figma-originated components
│   └── pages/                # 13 page components (one per route)
└── styles/
    ├── index.css             # Imports theme.css + tailwind.css
    ├── theme.css             # CSS custom properties (design tokens)
    ├── tailwind.css          # @import "tailwindcss"
    └── fonts.css             # Google Fonts import
```

---

### 2.3 Application Entry & Bootstrapping

**`src/main.tsx`**
```tsx
createRoot(document.getElementById("root")!).render(<App />);
```

**`src/app/App.tsx`**
- Renders `<RouterProvider router={router} />`
- Adds a global `<Toaster>` (sonner) at `top-center` with 2000ms duration

**`src/app/Root.tsx`** — Layout Shell
- Reads `useLocation()` to decide whether to show the `<Navigation>` bottom bar
- Navigation is **hidden** on: `/` (login), `/register`, `/onboarding`
- Wraps all pages in a **360×800px phone-frame mockup** (rounded corners, notch, status bar SVGs)
- Uses `<Outlet />` from react-router for nested page rendering
- Status bar shows hardcoded "9:41", battery, WiFi icons (demo aesthetic)

---

### 2.4 Routing

**File:** `src/app/routes.ts`

```
/                → Login (index)
/register        → Register
/onboarding      → Onboarding (3-step wizard)
/home            → Home dashboard
/reserve         → ReservationMap
/my-reservations → MyReservations
/study-buddy     → StudyBuddy
/profile         → Profile
/course-rating   → CourseRating
/lost-found      → LostFound
/weekly-schedule → WeeklySchedule
/*               → NotFound
```

All routes are children of `Root` (share the phone-frame layout). An `ErrorBoundary` is set at the root level.

**Auth guard:** There is **no programmatic route guard**. `Login.tsx` reads `localStorage.getItem('userRegistered')` to redirect to `/home` or `/onboarding` after "login." All protection is client-side and demo-only.

---

### 2.5 Data Layer — `mockData.ts`

The entire web app runs off **static mock data** — there are no real API calls.

#### TypeScript Interfaces (Domain Models)

```ts
interface User {
  id: string;
  name: string;
  email: string;
  universityEmail: string;
  nickname?: string;            // Used for group reservation invites
  responsibilityScore: number;  // 0–100, gates reservation ability (< 70 = blocked)
  reservationCount: number;
  department?: string;
  year?: number;
  courses?: string[];
  major?: string;
  studyPreference?: 'Morning Person' | 'Afternoon' | 'Night Owl';
  studyStyle?: 'Silent study' | 'Discussion-based study' | 'Problem solving together';
  preferredTopics?: string[];
}

interface Workspace {
  id: string;           // e.g. "desk-1", "group-2"
  type: 'individual' | 'group';
  capacity: number;     // 1 for individual, 4–6 for group
  status: 'available' | 'occupied';
  x: number;            // SVG coordinate
  y: number;            // SVG coordinate
}

interface Reservation {
  id: string;
  userId: string;
  workspaceId: string;
  date: string;         // ISO date "YYYY-MM-DD"
  slot: string;         // e.g. "10:00 - 12:00"
  status: 'active' | 'pending' | 'completed' | 'cancelled' | 'no-show';
  checkedIn: boolean;
  course?: string;
  isGroupReservation: boolean;
  participants?: string[];
  qrCode?: string;      // QR payload string
}

interface TimeSlot {
  id: string;
  label: string;        // Human-readable, used as select option value
  start: string;
  end: string;
  period: 'morning' | 'class' | 'evening' | 'night';
}

interface Course {
  id: string;
  code: string;         // e.g. "CSE344"
  name: string;
  department: string;
  difficultyRating: number;
  ratingCount: number;
  topics: string[];
}

interface LostItem {
  id: string;
  workspaceId: string;
  description: string;
  reportedBy: string;
  reportedAt: string;   // ISO datetime
  expiresAt: string;    // 24h after report
}

interface GroupInvitation {
  id: string;
  reservationId: string;
  fromUserId: string;
  toNickname: string;
  workspaceId: string;
  date: string;
  slot: string;
  status: 'pending' | 'accepted' | 'rejected' | 'expired';
  createdAt: string;
  expiresAt: string;    // 10 minutes after createdAt
}

interface ScoreHistory {
  id: string;
  date: string;
  action: string;       // e.g. "successful_checkin", "no_show"
  scoreChange: number;  // +5, +3, -10, +8
  description: string;
}

// Weekly Schedule
type ScheduleBlockType = 'lesson' | 'club' | 'busy' | null;
interface WeeklyScheduleBlock {
  day: 'Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri';
  timeSlot: string;    // e.g. "09-10"
  type: ScheduleBlockType;
  label?: string;      // Course code or activity name
}
```

#### Static Data Exports

| Export | Type | Description |
|---|---|---|
| `currentUser` | `User` | Logged-in user (Ahmet Yılmaz, score 75) |
| `workspaces` | `Workspace[]` | 24 individual desks + 4 group rooms |
| `timeSlots` | `TimeSlot[]` | 8 slots: 06:00–02:00 |
| `courses` | `Course[]` | 6 courses (CSE344, CSE331, CSE312, CSE211, MATH301, IE202) |
| `mockReservations` | `Reservation[]` | 3 sample reservations |
| `mockLostItems` | `LostItem[]` | 2 lost items |
| `mockStudyBuddies` | array | 3 buddy profiles with matchScore |
| `mockInvitations` | `GroupInvitation[]` | 1 pending group invitation |
| `scoreHistory` | `ScoreHistory[]` | 5 history entries |
| `departments` | array | 3 departments |
| `yearLevels` | array | Years 1–4 |
| `weeklyTimeSlots` | `string[]` | "09-10" … "19-20" |
| `userWeeklySchedule` | `WeeklyScheduleBlock[]` | Pre-filled lesson blocks |
| `adminStats` | object | Dashboard statistics |
| `upcomingReservations` | derived | Filtered from mockReservations |

---

### 2.6 State Management

The web app uses **only React local state** (`useState`, `useEffect`) — no Redux, Zustand, or Context API for application data.

**localStorage usage (web):**
- `userRegistered` — whether the user has completed registration
- `onboardingComplete` — whether onboarding wizard finished
- `userDepartment`, `userYear`, `userCourses` — onboarding selections

**Dark mode** is applied by toggling the `.dark` class on `document.documentElement` directly from `Profile.tsx`.

---

### 2.7 Pages — Detailed Breakdown

#### `Login.tsx`
- **State:** `email`, `password`, `isLoading`
- **Logic:** Validates email against `@std.yeditepe.edu.tr` regex. Checks `localStorage('userRegistered')` to navigate to `/home` or `/onboarding`.
- **UI:** Gradient hero, card form with icon-prefixed inputs, sonner toasts.

#### `Register.tsx`
- Multi-field form: full name, email, password, department, year, courses.
- Saves `userRegistered=true` to localStorage on completion.
- Navigates to `/onboarding`.

#### `Onboarding.tsx`
- **3-step wizard** managed by local `step` state (1→2→3)
- Step 1: Department (dropdown from `departments` array)
- Step 2: Year (grid of year buttons)
- Step 3: Courses (multi-select dropdown from `courses` array, toggle array)
- Progress bar renders 3 segments colored by `step ≥ n`
- On complete: writes all selections to localStorage, navigates to `/home`

#### `Home.tsx`
- **State:** `invitations` (filtered pending from `mockInvitations`)
- Shows: hero stats (hardcoded 12h/8 sessions/3 buddies), quick action grid (5 buttons → navigate), upcoming reservations (top 2), group invitation cards with Accept/Reject handlers
- Accept/Reject removes invitation from state array via filter

#### `ReservationMap.tsx` *(most complex page)*
- **State:** `selectedDate`, `selectedSlot`, `selectedCourse`, `selectedWorkspace`, `reservationType`, `allowStudyBuddy`, `filterType`, `groupNicknames`, `nicknameInput`, `simulatedDay`, `showDayPicker`, `showFilters`
- **SVG Map:** Renders workspaces as SVG `<rect>` elements at their `(x, y)` coordinates
  - Individual desks: 35×50px rectangles in a 3×8 grid
  - Group rooms: 70×100px rectangles in a 1×4 row
- **Color logic (deterministic):** `(dateDay + slotIndex + workspaceNum) % 5` → 0 or 1 = occupied (red), else available (blue), lost item = yellow
- **Reservation window:** Only Monday and Friday allow advance booking; other days only "instant" desks (`desk-2`, `desk-15`) are bookable
- **Day picker:** Dropdown lets user simulate any day of the week (demo feature)
- **Group flow:** When `reservationType=group`, shows nickname input; validates nickname count equals `capacity - 1`
- **Score gate:** `responsibilityScore < 70` blocks reservation
- **Bottom sheet:** Collapsible form panel with date picker, time slot select, course select, group members, study buddy toggle, confirm button

#### `MyReservations.tsx`
- **State:** `selectedReservation`, `showQRCode`, `activeTab`
- Two tabs: Active & Upcoming | History
- QR Check-in: shows modal with `<QRCodeSVG>` (from `qrcode.react`), simulates 90% scan success rate via `Math.random()`

#### `StudyBuddy.tsx`
- **State:** filters (`selectedCourse`, `selectedYear`, `selectedPreference`), `searchResults`, `showFilters`, `showMyListing`, `showReportModal`, `reportingBuddy`, `reportReason`, `myListingCourse`, `myListingNote`
- Filter search returns filtered `mockStudyBuddies` array
- Report modal: requires reason text, warns against false reports
- "My Listing" form: posts study-buddy listing for a chosen course (simulated)
- Each buddy card shows: name, major, matchScore %, common courses (blue pills), common topics (purple pills), Connect/Email/Report buttons

#### `Profile.tsx`
- **State:** study preferences (5 fields), `darkMode`, `showPasswordModal`, password fields (3), visibility toggles (3)
- `studyPreferencesComplete` computed from all 5 fields being non-empty
- Score history rendered from `scoreHistory[]` with TrendingUp/Down icons
- Dark mode: toggles `.dark` on `document.documentElement`; "Auto" reads `window.matchMedia`
- Password change modal: validates length ≥ 6, new === confirm

#### `WeeklySchedule.tsx`
- Interactive 5-column (Mon–Fri) × 11-row (09–20) grid
- Drag-and-drop powered by `react-dnd` + HTML5 backend
- Block types: `lesson` (blue), `club` (green), `busy` (red), `null` (empty)
- Pre-populated from `userWeeklySchedule`

#### `CourseRating.tsx`
- Lists courses from `courses[]`
- Star rating UI for difficulty, with comment textarea
- Shows aggregated difficulty rating and rating count per course

#### `LostFound.tsx`
- Shows `mockLostItems[]` on a map overlay
- "Report Item" form: workspace selection + description
- Items expire 24h after reporting (displayed via `expiresAt`)

---

### 2.8 Navigation Component

**`src/app/components/Navigation.tsx`**

5-tab bottom bar using `<Link>` from react-router:

| Tab | Path | Icon |
|---|---|---|
| Home | `/home` | Home |
| Reserve | `/reserve` | MapPin |
| Schedule | `/weekly-schedule` | Calendar |
| Buddy | `/study-buddy` | Users |
| Profile | `/profile` | User |

Active tab is detected via `useLocation().pathname === item.path`. Active state applies `text-blue-600` and `bg-blue-50` background on icon container.

---

### 2.9 UI Component Library

`src/app/components/ui/` contains **48 shadcn-style components** built on Radix UI primitives. All are thin wrappers that apply Tailwind classes via `class-variance-authority` (CVA) and `tailwind-merge`.

Key components used in pages:
- `button.tsx` — variants: default, destructive, outline, secondary, ghost, link
- `input.tsx`, `textarea.tsx`, `select.tsx` — styled form controls  
- `dialog.tsx` — modal dialogs (built on `@radix-ui/react-dialog`)
- `card.tsx` — card container with Header, Content, Footer sub-components
- `badge.tsx` — status pills
- `tabs.tsx` — tab navigation
- `toast` — replaced by `sonner` library directly

---

### 2.10 Styling System

**CSS Architecture:**
1. `theme.css` — CSS custom properties (design tokens) for `:root` and `.dark`
2. `tailwind.css` — `@import "tailwindcss"` (Tailwind v4 syntax)
3. `index.css` — imports both above files

**Design Tokens (key variables):**
```css
--background: #ffffff              /* Page background */
--primary: #030213                 /* Dark navy */
--destructive: #d4183d             /* Red for errors */
--radius: 0.625rem                 /* Border radius base */
--muted: #ececf0                   /* Subtle backgrounds */
--border: rgba(0, 0, 0, 0.1)
```

**Dark mode:** `.dark` class on `<html>` swaps all CSS variables. Typography sizes (h1–h4, label, button, input) are defined in `@layer base`.

**Page-level gradients** used inline via Tailwind: `from-blue-500 via-purple-500 to-pink-500` is the primary brand gradient.

---

## 3. Mobile Frontend (Flutter)

### 3.1 Tech Stack & Dependencies

| Package | Version | Role |
|---|---|---|
| Flutter SDK | ≥ 3.3.0 | Framework |
| Dart | ≥ 3.3.0 | Language |
| `dio` | ^5.7.0 | HTTP client |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

**Run command:** `flutter run`

---

### 3.2 Directory Structure

```
lib/
├── main.dart               # Entry: wraps app in AuthScope
├── app.dart                # StudySyncApp widget, MaterialApp config
├── core/
│   ├── auth/
│   │   ├── auth_controller.dart   # ChangeNotifier: login/logout/session
│   │   └── auth_scope.dart        # InheritedNotifier for auth state
│   ├── config/
│   │   └── app_config.dart        # baseUrl constant
│   ├── network/
│   │   ├── api_client.dart        # Dio singleton with JWT interceptor
│   │   ├── checkin_api.dart       # POST /checkin endpoint
│   │   └── dashboard_api.dart     # GET /dashboard endpoint
│   ├── planner/                   # (schedule planner logic)
│   ├── platform/                  # (platform-specific utilities)
│   ├── session/
│   │   └── auth_session.dart      # Singleton: stores tokens & user fields
│   ├── theme/
│   │   ├── app_theme.dart         # ThemeData light/dark definitions
│   │   └── theme_mode_controller.dart  # ChangeNotifier for ThemeMode
│   └── trust/
│       └── responsibility_ledger.dart  # Per-user daily reservation counter
├── features/
│   ├── auth/
│   │   ├── data/auth_api.dart      # POST /auth/login, GET /auth/me
│   │   └── presentation/login_screen.dart
│   ├── courses/
│   ├── home/
│   ├── lost_found/
│   ├── profile/
│   ├── reservation/
│   │   ├── data/
│   │   │   ├── reservation_api.dart       # Real API calls (Dio)
│   │   │   └── reservation_mock_data.dart # Fallback mock data
│   │   ├── domain/
│   │   │   └── reservation_models.dart    # Workspace, ReservationDetail models
│   │   └── presentation/
│   │       └── reservation_map_screen.dart  # Main reservation UI (56KB)
│   ├── reservations/
│   ├── schedule/
│   └── study_buddy/
└── shared/
    ├── navigation/
    └── widgets/
        └── bottom_nav_shell.dart   # Persistent bottom navigation
```

---

### 3.3 App Bootstrapping

**`main.dart`**
```dart
void main() {
  final auth = AuthController();
  runApp(AuthScope(notifier: auth, child: const StudySyncApp()));
}
```

**`app.dart`** — `StudySyncApp`
- Uses `ListenableBuilder` on `ThemeModeController` for reactive theme switching
- Uses `ListenableBuilder` on `auth` to switch between `LoginScreen` and `BottomNavShell`
- `MaterialApp` configured with `AppTheme.lightTheme` / `AppTheme.darkTheme`

---

### 3.4 Auth System

#### `AuthController` (ChangeNotifier)
- `_isLoggedIn` bool drives app-level routing
- `establishSession({accessToken, refreshToken, user})`:
  - Saves tokens to `AuthSession.instance`
  - Populates session fields from user map
  - Calls `ResponsibilityLedger.instance.resetForUser(uid)` to reset daily quota on user change
  - Calls `notifyListeners()`
- `refreshProfile()`: calls `AuthApi().getMe()` to refresh user data
- `logout()`: clears session, sets `_isLoggedIn = false`, notifies

#### `AuthScope` (InheritedNotifier)
- Wraps the widget tree to expose `AuthController` via `AuthScope.of(context)`

#### `AuthSession` (Singleton)
Fields stored in memory per session:
- `accessToken`, `refreshToken`
- `userId`, `userName`, `userNickname`, `userEmail`
- `userDepartment`, `userYear`, `userScore`
- `enrolledCourseCodes` (List<String>)

---

### 3.5 Network Layer

#### `ApiClient` (Singleton, Dio)
```dart
static final ApiClient instance = ApiClient._internal();
```
- Base URL from `AppConfig.baseUrl`
- Connect/receive timeout: 12 seconds
- `InterceptorsWrapper.onRequest`: reads `AuthSession.instance.accessToken` and injects `Authorization: Bearer <token>` header on every request

#### `ReservationApi` — API Methods

| Method | HTTP | Endpoint | Description |
|---|---|---|---|
| `getWorkspaces()` | GET | `/reservations/workspaces?date&slotId&type` | Available workspaces for a slot |
| `createReservation()` | POST | `/reservations` | Create individual or group reservation |
| `getMyReservations()` | GET | `/reservations/me` | Current user's reservations |
| `cancelReservation()` | POST | `/reservations/{id}/cancel` | Cancel with optional timestamps for score policy |

---

### 3.6 Domain Models (Flutter)

**`Workspace`**
```dart
class Workspace {
  final String id;
  final String type;       // "individual" | "group"
  final int capacity;
  final String status;     // "available" | "occupied"
  final int x;             // Map coordinate
  final int y;
  factory Workspace.fromJson(Map<String, dynamic> json)
}
```

**`ReservationDetail`**
```dart
class ReservationDetail {
  final String id;
  final String workspaceId;
  final String date;
  final String slotId;
  final String slotLabel;
  final String status;        // "PENDING", "ACTIVE", etc.
  final String courseCode;
  final List<String> participants;
  final bool checkedIn;
  final String? qrPayload;
  bool get isGroup => participants.length > 1;
  factory ReservationDetail.fromJson(Map<String, dynamic> json)
}

enum ReservationType { individual, group }
```

---

### 3.7 Trust/Responsibility System

**`ResponsibilityLedger`** (Singleton)
- Tracks daily reservation counts **per userId** (not per device)
- `resetForUser(uid)` is called on login so quotas don't persist across user sessions
- This is the mobile-side enforcement mirror of the backend's `dailyReservations` check

**Score Rules (reflected in both frontends):**

| Event | Score Change |
|---|---|
| Successful check-in | +5 |
| Early cancellation (24h+) | +3 |
| Group check-in (all members) | +8 |
| No-show | -10 |
| Score below 70% | 1-week reservation ban |

---

## 4. Cross-Frontend Comparison

| Feature | Web (React) | Mobile (Flutter) |
|---|---|---|
| Auth | `localStorage` flags | Real JWT via `AuthController` + `AuthSession` |
| Data source | Static `mockData.ts` | Real API via `ReservationApi` + `ApiClient` (Dio) |
| State management | `useState` / `useEffect` | `ChangeNotifier` + `ListenableBuilder` |
| Routing | `react-router` v7 | `MaterialApp.home` switches on auth state |
| Dark mode | CSS class on `<html>` | `ThemeModeController` + `MaterialApp.themeMode` |
| Navigation | Bottom tab bar (5 tabs) | `BottomNavShell` widget |
| Workspace map | SVG `<rect>` elements | Flutter custom paint / canvas |
| QR code | `qrcode.react` SVG | Flutter QR package |
| Notifications | `sonner` toasts | Flutter SnackBar / dialogs |
| API quota enforcement | Client-side only (score check) | `ResponsibilityLedger` + backend enforcement |

---

## 5. Business Logic Summary

### Reservation Window Policy
- **Monday** → can book Tuesday–Friday
- **Friday** → can book Saturday–Monday
- **Other days** → only "instant" desks (cancelled slots) are bookable

### Group Reservation Flow
1. User selects a group workspace
2. Enters nicknames of other members (must equal `capacity - 1`)
3. System sends invitations to each nickname
4. Invitees have **10 minutes** to accept
5. All must accept or reservation is cancelled

### QR Check-In Flow
1. User opens their reservation → taps "Check In"
2. QR code modal displays the `qrCode` payload
3. Staff scans at entrance
4. Must check in within **15 minutes** of slot start
5. Late/no check-in → -10 score, slot marked as no-show

### Study Buddy Matching
- Matching factors: shared courses, shared topics, study style, time preference
- Match score is pre-computed (mock) or calculated backend-side
- Max **4 students** per study group
- Reporting: 5+ reports trigger admin review

---

## 6. Key Technical Patterns

### Web
- **No global state** — each page is self-contained with local `useState`
- **Derived data** — `upcomingReservations` is computed from `mockReservations` at module load time
- **Deterministic mock occupancy** — `(dateDay + slotIndex + workspaceNum) % 5` ensures consistent workspace colors without randomness
- **Phone mockup frame** — `Root.tsx` wraps everything in a `360×800px` div to simulate a mobile device in the browser

### Flutter
- **Singleton pattern** — `ApiClient.instance`, `AuthSession.instance`, `ResponsibilityLedger.instance`
- **InheritedNotifier** — `AuthScope` propagates `AuthController` down the widget tree without prop drilling
- **Graceful fallback** — `reservation_mock_data.dart` provides data when the backend returns empty lists
- **Interceptor-based auth** — JWT is injected at the `Dio` interceptor level, not per-request
