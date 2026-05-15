# Project Handoff & Issue Tracker

## 🏗️ Architecture & Technical Notes

- **Project:** StudySync — Student workspace management. Consists of a **Flutter** mobile app (`mobile_flutter/`) and a **Spring Boot 3.3 / Java 21** API (`backend_java/`).
- **API Contract:** Single source of truth is `docs/api-contract-v1.md`. All paths are prefixed with `/api/v1` and use Bearer tokens (`Authorization`) for mobile.
- **Mobile API Configuration:** Configured in `mobile_flutter/lib/core/config/app_config.dart`.
  - Android emulator: `http://10.0.2.2:8080/api/v1`
  - iOS/desktop: `localhost:8080/api/v1`
  - Physical device: `--dart-define=API_BASE=http://<PC_LAN_IP>:8080/api/v1`
- **Backend Setup:**
  - Uses `application.yml` with H2 in-memory database (`ddl-auto: update`), running on port 8080.
  - Security (`config/SecurityConfig.java`) is mostly open for `/api/**` during development, but requires JWT and restricted endpoints for production.

## 🐛 Bug Fixes & Current Issues

- [ ] **Password Change:** Password change process works, but the error screen continues to show in the background.
- [ ] **Course Edit:** The course edit function is not working.
- [ ] **Check-in System:** Check-in can be done at any time. **Rule:** If check-in is not completed within the first 15 minutes, the reservation must be automatically canceled.
- [ ] **Email Verification/Delivery:** Emails containing verification/password codes are not being delivered.
- [ ] **Duplicate Email Registration:** The check for accounts with the same email is done too late. (Should be validated earlier / on the frontend).

## 🚀 New Features & Enhancements

- [ ] **Lost Item Found:** Add a reporting/marking feature for when a "Lost item" is found.
- [ ] **KVKK (GDPR/Privacy Policy) Approval:** Add a KVKK approval step to the registration or reservation process.
- [ ] **Forgot Password:** The "Forgot password" flow is currently missing and needs to be added.
- [ ] **Buddy / "Previous" Tab:** Add a reporting feature via the "Previous" tab in the Buddy system (Users should be able to write comments).
- [ ] **Admin Panel:** Implement an admin interface for managing reservations, users, and course data.

## ❓ Questions & Open Topics

- [ ] **Notification System:** Is there an existing notification system? This needs to be checked and added/configured if necessary.


