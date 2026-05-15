# Project Handoff & Issue Tracker

The following list contains bugs to be fixed, new features to be added, and open questions regarding the project.

## 🐛 Bug Fixes & Current Issues

- [ ] **Password Change:** Password change process works, but the error screen continues to show in the background.
- [ ] **Course Edit:** The course edit function is not working.
- [ ] **Check-in System:** Check-in can be done at any time. **Rule:** If check-in is not completed within the first 15 minutes, the reservation must be automatically canceled.
- [ ] **Reservation Map:** The reservation map is currently not working.
- [ ] **Lost Item UI & Logic:** Seats/Areas with a lost item notification cannot be reserved. **Solution:** Instead of the entire area turning yellow, it should just display a notification/icon on the side and should not block reservations.
- [ ] **Email Verification/Delivery:** Emails containing verification/password codes are not being delivered.
- [ ] **Duplicate Email Registration:** The check for accounts with the same email is done too late. (Should be validated earlier / on the frontend).
- [ ] **Conflicting Reservations:** Attempting to book a reservation for the same timeslot is blocked by the backend (returns an error), but this is not properly displayed as a warning to the user on the frontend.

## 🚀 New Features & Enhancements

- [ ] **Lost Item Found:** Add a reporting/marking feature for when a "Lost item" is found.
- [ ] **KVKK (GDPR/Privacy Policy) Approval:** Add a KVKK approval step to the registration or reservation process.
- [x] **Course Rating:** Ensure that users can only rate courses they are actually taking. (Planned for after Finals).
- [ ] **Forgot Password:** The "Forgot password" flow is currently missing and needs to be added.
- [ ] **Buddy / "Previous" Tab:** Add a reporting feature via the "Previous" tab in the Buddy system (Users should be able to write comments).

## ❓ Questions & Open Topics

- [ ] **Notification System:** Is there an existing notification system? This needs to be checked and added/configured if necessary.
