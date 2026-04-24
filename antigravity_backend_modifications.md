# Antigravity Backend Modifications Summary

This document provides a detailed overview of all modifications made by Antigravity to the **StudySync** backend to resolve startup errors, implement security, and bridge business logic for the upcoming demo.

---

## 🛠️ Infrastructure & Security

### [pom.xml](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/pom.xml)
- **What it does:** Added the `jjwt` library dependencies (api, impl, jackson).
- **Why:** Enables cryptographic signing and parsing of JSON Web Tokens, replacing stubbed session logic with a real stateless REST security model.

### [SecurityConfig.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/config/SecurityConfig.java)
- **What it does:** Configured the `SecurityFilterChain` to use stateless session management and integrated the custom JWT filter.
- **Why:** Locks all API endpoints (excluding `/auth/**`) so only logged-in users with a valid token can interact with the app.

### [JwtTokenProvider.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/security/JwtTokenProvider.java)
- **What it does:** Implemented the core engine for generating JWTs and parsing user IDs from Bearer tokens.
- **Why:** Provides the cryptographic authority for the entire authentication lifecycle.

### [JwtAuthenticationFilter.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/security/JwtAuthenticationFilter.java)
- **What it does:** Intercepts every HTTP request, extracts the token, and populates the `SecurityContext`.
- **Why:** Allows the rest of the application (Services) to know "Who is performing this action?" without checking a database every time.

---

## 🏗️ Domain Layer & Database Fixes

### [UserAccount.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/domain/entity/UserAccount.java)
- **What it does:** Changed the constructor to `public` and renamed the `year` column to `academic_year`.
- **Why:** Fixes a critical H2 database boot error where "year" was a reserved SQL keyword and resolves visibility issues during repository instantiation.

### [ReservationRecord.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/domain/entity/ReservationRecord.java)
- **What it does:** Changed the constructor to `public`.
- **Why:** Ensures the JPA provider can instantiate the entity when fetching reservation history.

### [Repository Interfaces]
- **[ReservationRecordRepository.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/domain/repository/ReservationRecordRepository.java):** Added custom query methods for checking overlaps and daily quotas.
- **[LostItemRecordRepository.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/domain/repository/LostItemRecordRepository.java):** Fixed a naming typo in the derived query (changed `user` to `reportedBy`).
- **[WeeklyScheduleBlockRepository.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/domain/repository/WeeklyScheduleBlockRepository.java):** Fixed a naming typo to match `dayCode` and `timeSlot` entity properties.

---

## ⚡ Service Layer (Business Logic)

### [AuthService.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/domain/service/AuthService.java)
- **What it does:** Wired the registration/login flow to issue real JWTs and added strict `@std.yeditepe.edu.tr` domain validation.
- **Why:** Enforces university-only access and secures the user session.

### [CheckInService.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/domain/service/CheckInService.java)
- **What it does:** Implemented the full QR verification logic and the automated Responsibility Score reward system (+5 points).
- **Why:** Powers the "Check-in" feature of the mobile app.

### [DashboardService.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/domain/service/DashboardService.java)
- **What it does:** Replaced stub logic with dynamic `SecurityContext` queries to fetch the current user's data.
- **Why:** Ensures the Home screen shows *your* reservations and *your* score, not dummy data.

### [ReservationService.java](file:///c:/MrBardak/Code/Antigravity/CSE344/STUDYSYNC-IMPLEMENTATION/backend_java/src/main/java/com/studysync/domain/service/ReservationService.java)
- **What it does:** Linked the creation of reservations to the authenticated user and implemented the `myReservations()` list logic.
- **Why:** Bridges the gap between the mobile app's booking flow and the persistent database history.
