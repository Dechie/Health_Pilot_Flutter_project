# API Testing Checklist

**Base URL:** `https://healthpilot-v0jbkkgx.b4a.run`  
**Auth header:** `Authorization: Bearer <access_token>` (all protected endpoints)

Legend: ✅ passed · ❌ failed · ⬜ not yet tested

---

## Priority Guide

| Priority | Feature | Flag |
|---|---|---|
| 1 | Auth | `FF_AUTH` |
| 2 | Profile | `FF_PROFILE` |
| 3 | Health Data | `FF_HEALTH_DATA` |
| 4 | Health Assessment | `FF_ASSESSMENT` |
| 5 | AI Assistant | `FF_AI_ASSISTANT` |
| 6 | Medications | `FF_MEDICATIONS` |
| 7 | Nutrition | `FF_NUTRITION` |
| 8 | Contacts | `FF_CONTACTS` |
| 9 | Articles | `FF_ARTICLES` |
| 10 | Chat | `FF_CHAT` |
| 11 | Subscriptions | `FF_SUBSCRIPTIONS` |
| 12 | Community | `FF_COMMUNITY` |

---

## 1 · Auth — `FF_AUTH`

### POST `/api/v1/auth/register/`
- ✅ Happy path — valid payload returns 201, activation email received
- ✅ Duplicate email — snackbar: "a user with that email already exists"
- ✅ Weak/mismatched password — snackbar: "passwords do not match"

### POST `/api/v1/auth/activate/`
- ✅ Happy path — valid UUID token activates account, returns access + refresh tokens
- ❌ Invalid/expired token — backend accepted a wrong UUID and returned 200 (backend bug)

### POST `/api/v1/auth/login/`
- ✅ Happy path — correct credentials return tokens, app navigates to home
- ✅ Wrong password — snackbar shows "Invalid email or password."
- ⬜ Unactivated account — should return a clear message

### POST `/api/v1/auth/logout/`
- ✅ Happy path — clears tokens, navigates to login screen, spinner shown during logout

### GET `/api/v1/auth/me/`
- ⬜ Happy path — returns current user identity fields

### PATCH `/api/v1/auth/me/`
- ⬜ Happy path — updates user identity fields (name, email)
- ⬜ Invalid payload — user-friendly validation error

### POST `/api/v1/auth/token/refresh/`
- ⬜ Happy path — interceptor silently refreshes on 401 (hard to test manually, 60 min expiry)
- ⬜ Expired refresh token — app should redirect to login screen gracefully

### POST `/api/v1/auth/guest/`
- ⬜ Happy path — returns guest tokens, app proceeds without account

---

## 2 · Profile — `FF_PROFILE`

### GET `/api/v1/auth/me/` + GET `/api/v1/profile/me/`
- ⬜ Happy path — combined profile loads and all fields render correctly

### PATCH `/api/v1/auth/me/` + PATCH `/api/v1/profile/me/`
- ⬜ Happy path — edits saved and reflected immediately in UI
- ⬜ Invalid fields — user-friendly validation error shown

---

## 3 · Health Data — `FF_HEALTH_DATA`

### GET `/api/v1/health/conditions/`
- ⬜ Happy path — conditions list loads and renders correctly
- ⬜ Empty state — graceful empty UI when no conditions saved

### POST `/api/v1/health/conditions/`
- ⬜ Happy path — new condition appears in list immediately
- ⬜ Duplicate condition — should show a clear error

### DELETE `/api/v1/health/conditions/{id}/`
- ⬜ Happy path — condition removed from list
- ⬜ Non-existent ID — should not crash

### DELETE `/api/v1/health/conditions/` _(bulk clear)_
- ⬜ Happy path — all conditions removed

### GET `/api/v1/health/symptoms/`
- ⬜ Happy path — symptoms list loads and renders correctly
- ⬜ Empty state

### POST `/api/v1/health/symptoms/`
- ⬜ Happy path — new symptom appears in list
- ⬜ Duplicate symptom

### DELETE `/api/v1/health/symptoms/{id}/`
- ⬜ Happy path — symptom removed from list

### DELETE `/api/v1/health/symptoms/` _(bulk clear)_
- ⬜ Happy path — all symptoms removed

---

## 4 · Health Assessment — `FF_ASSESSMENT`

### GET `/api/v1/assessments/`
- ⬜ Happy path — assessment history loads and renders
- ⬜ Empty state — clear empty UI before first submission

### POST `/api/v1/assessments/`
- ⬜ Happy path — submission succeeds, new entry appears in history
- ⬜ Incomplete payload — validation error shown to user

### DELETE `/api/v1/assessments/{id}/`
- ⬜ Happy path — assessment removed from history

---

## 5 · AI Assistant — `FF_AI_ASSISTANT`

### GET `/api/v1/chat/messages/`
- ⬜ Happy path — existing conversation history loads
- ⬜ Empty state — greeting shown when no history

### POST `/api/v1/chat/messages/`
- ⬜ Happy path — user message sent, AI reply received and rendered
- ⬜ Empty message — should not send
- ⬜ Long message — no layout overflow

### DELETE `/api/v1/chat/messages/`
- ⬜ Happy path — conversation history cleared

---

## 6 · Medications — `FF_MEDICATIONS`

### GET `/api/v1/medications/`
- ⬜ Happy path — medication list loads
- ⬜ Empty state

### POST `/api/v1/medications/`
- ⬜ Happy path — new medication appears in list

### PATCH `/api/v1/medications/{id}/`
- ⬜ Happy path — updated values reflected in list

### DELETE `/api/v1/medications/{id}/`
- ⬜ Happy path — medication removed

### GET `/api/v1/medications/{id}/reminders/`
- ⬜ Happy path — reminders load for a medication

### POST `/api/v1/medications/{id}/reminders/`
- ⬜ Happy path — reminder added

### PATCH `/api/v1/medications/{id}/reminders/{reminderId}/`
- ⬜ Happy path — reminder time/details updated

### DELETE `/api/v1/medications/{id}/reminders/{reminderId}/`
- ⬜ Happy path — reminder removed

### GET `/api/v1/medications/{id}/doses/`
- ⬜ Happy path — dose log loads

### POST `/api/v1/medications/{id}/doses/`
- ⬜ Happy path — dose logged, status set to taken

---

## 7 · Nutrition — `FF_NUTRITION`

### GET `/api/v1/nutrition/history/`
- ⬜ Happy path — nutrition log history loads
- ⬜ Empty state

### POST `/api/v1/nutrition/history/`
- ⬜ Happy path — new log entry appears in history

### GET `/api/v1/nutrition/settings/`
- ⬜ Happy path — diet tags and report frequency load correctly

### PATCH `/api/v1/nutrition/settings/`
- ⬜ Happy path — updated settings persisted and reloaded correctly

---

## 8 · Contacts — `FF_CONTACTS`

### GET `/api/v1/contacts/emergency/`
- ⬜ Happy path — emergency contacts load
- ⬜ Empty state

### POST `/api/v1/contacts/emergency/`
- ⬜ Happy path — new contact appears in list

### PATCH `/api/v1/contacts/emergency/{id}/`
- ⬜ Happy path — updated contact details reflected

### DELETE `/api/v1/contacts/emergency/{id}/`
- ⬜ Happy path — contact removed

### GET `/api/v1/contacts/doctors/`
- ⬜ Happy path — doctor contacts load

### POST `/api/v1/contacts/doctors/`
- ⬜ Happy path — new doctor added

### PATCH `/api/v1/contacts/doctors/{id}/`
- ⬜ Happy path — doctor details updated

### DELETE `/api/v1/contacts/doctors/{id}/`
- ⬜ Happy path — doctor removed

---

## 9 · Articles — `FF_ARTICLES`

### GET `/api/v1/articles/`
- ⬜ Happy path — articles load and render correctly
- ⬜ Empty state

### POST `/api/v1/articles/{id}/like/`
- ⬜ Happy path — like count increments immediately

---

## 10 · Chat — `FF_CHAT`

### GET `/api/v1/chat/users/`
- ⬜ Happy path — user list loads for DM search

### GET `/api/v1/chat/groups/`
- ⬜ Happy path — groups load and render

### POST `/api/v1/chat/direct/{userId}/messages/`
- ⬜ Happy path — DM sent and appears in thread

### POST `/api/v1/chat/groups/{groupId}/messages/`
- ⬜ Happy path — group message sent and appears in thread

---

## 11 · Subscriptions — `FF_SUBSCRIPTIONS`

### GET `/api/v1/subscriptions/plans/`
- ⬜ Happy path — plan list and pricing loads

### GET `/api/v1/subscriptions/status/`
- ⬜ Happy path — current subscription status reflects correctly

### POST `/api/v1/subscriptions/subscribe/`
- ⬜ Happy path — subscription confirmed, premium flag set

### DELETE `/api/v1/subscriptions/cancel/`
- ⬜ Happy path — subscription cancelled, status reverts

---

## 12 · Community — `FF_COMMUNITY`

- ⬜ No endpoints mapped yet — explore once flag is enabled
