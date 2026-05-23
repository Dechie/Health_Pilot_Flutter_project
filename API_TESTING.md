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
- ✅ Happy path — returns correct user identity fields (id, email, first_name, last_name, full_name, etc.)

### PATCH `/api/v1/auth/me/`
- ✅ Happy path — first name and last name updates saved and reflected immediately in profile screen
- ⬜ Email update — skipped for now (likely requires re-verification flow)
- ⬜ Invalid payload — user-friendly validation error

### POST `/api/v1/auth/token/refresh/`
- ⬜ Happy path — interceptor silently refreshes on 401 (hard to test manually, 60 min expiry)
- ⬜ Expired refresh token — app should redirect to login screen gracefully

### POST `/api/v1/auth/guest/`
- ✅ Happy path — returns guest tokens, app proceeds without account
- ✅ No internet fallback — offline local guest mode: `isGuest=true` set without a token, UI shows "Guest" correctly with all edit/health-info restricted

---

## 2 · Profile — `FF_PROFILE`

### GET `/api/v1/auth/me/` + GET `/api/v1/profile/me/`
- ✅ Happy path — both endpoints hit on profile screen open; data merged and displayed correctly
- ✅ Loading state — spinner shown while fetching, real name replaces it on response

### PATCH `/api/v1/auth/me/`
- ✅ Happy path — name/last name edits saved and reflected immediately in profile screen
- ⬜ Email update — skipped (likely requires re-verification flow)
- ⬜ Invalid fields — user-friendly validation error shown

### PATCH `/api/v1/profile/me/`
- ⬜ Happy path — about_me and visibility fields saved correctly

---

## 3 · Health Data — `FF_HEALTH_DATA`

> **Backend note:** `/api/v1/health/conditions/` does not exist. Remote stubs return empty list.
> Actual backend health routes (from Postman collection): `symptoms/`, `vitals/`, `summaries/`, `goals/`, `dashboard/`.
> Symptoms response is **paginated** — `{count, next, previous, results: [...]}`.

### ~~conditions/~~ — not implemented on backend

### GET `/api/v1/health/symptoms/`
- ✅ Returns paginated response — app correctly unwraps `results` field
- ⬜ Happy path with data — symptoms render correctly in list

### POST `/api/v1/health/symptoms/`
- ⬜ Happy path — payload: `{symptom_name, severity (0–10), body_location, description}`; new entry appears in list
- ⬜ Duplicate symptom — backend response

### DELETE `/api/v1/health/symptoms/{id}/`
- ⬜ Happy path — symptom removed from list

### GET `/api/v1/health/vitals/`
- ⬜ Not yet wired in app — backend exists

### POST `/api/v1/health/vitals/`
- ⬜ Not yet wired in app — payload: `{systolic_bp, diastolic_bp, heart_rate, weight_kg, steps}`

### GET `/api/v1/health/dashboard/`
- ⬜ Not yet wired in app

### GET `/api/v1/health/summaries/`
- ⬜ Not yet wired in app

### GET `/api/v1/health/goals/`
- ⬜ Not yet wired in app

### POST `/api/v1/health/goals/`
- ⬜ Not yet wired in app — payload: `{goal_type, target_value, unit}`

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

> **Endpoint correction (Postman):** AI routes are under `chat/ai/`, not `chat/messages/`.

### GET `/api/v1/chat/ai/history/`
- ⬜ Happy path — existing conversation history loads
- ⬜ Empty state — greeting shown when no history

### POST `/api/v1/chat/ai/`
- ⬜ Happy path — payload: `{message}`; AI reply received and rendered
- ⬜ Empty message — should not send
- ⬜ Long message — no layout overflow

### DELETE `/api/v1/chat/ai/history/`
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

> **Endpoint correction (Postman):** `history/` → `meals/`; `settings/` → `goals/`; also has `search/` and `summary/`.

### GET `/api/v1/nutrition/search/?q=<query>`
- ⬜ Happy path — food search results load

### GET `/api/v1/nutrition/meals/`
- ⬜ Happy path — meal log history loads
- ⬜ Empty state

### POST `/api/v1/nutrition/meals/`
- ⬜ Happy path — payload: `{meal_type, entries: [{food_name, quantity_g, calories, ...}]}`

### GET `/api/v1/nutrition/goals/`
- ⬜ Happy path — daily calorie/macro goals load

### PATCH `/api/v1/nutrition/goals/`
- ⬜ Happy path — updated goals persisted correctly

### GET `/api/v1/nutrition/summary/`
- ⬜ Happy path — daily summary loads

---

## 8 · Contacts — `FF_CONTACTS`

> **Endpoint correction (Postman):** contacts live under `profile/`, not a separate `contacts/` prefix.

### GET `/api/v1/profile/emergency-contacts/`
- ⬜ Happy path — emergency contacts load
- ⬜ Empty state

### POST `/api/v1/profile/emergency-contacts/`
- ⬜ Happy path — payload: `{first_name, last_name, relationship, phone, email}`; contact appears in list

### PATCH `/api/v1/profile/emergency-contacts/{id}/`
- ⬜ Happy path — updated contact details reflected

### DELETE `/api/v1/profile/emergency-contacts/{id}/`
- ⬜ Happy path — contact removed

### GET `/api/v1/profile/doctors/`
- ⬜ Happy path — doctor contacts load

### POST `/api/v1/profile/doctors/`
- ⬜ Happy path — payload: `{first_name, last_name, specialization, email, report_frequency}`

### DELETE `/api/v1/profile/doctors/{id}/`
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

> **Endpoint correction (Postman):** no `plans/`, `subscribe/`, or `cancel/` — payment flow instead.

### GET `/api/v1/subscriptions/status/`
- ⬜ Happy path — current subscription status reflects correctly

### POST `/api/v1/subscriptions/payment/`
- ⬜ Happy path — payload: `{amount, payment_method, currency, months}`; returns payment_id

### POST `/api/v1/subscriptions/payment/confirm/`
- ⬜ Happy path — payload: `{payment_id}`; subscription activated

### GET `/api/v1/subscriptions/payment/history/`
- ⬜ Happy path — payment history loads

---

## 12 · Community — `FF_COMMUNITY`

- ⬜ No endpoints mapped yet — explore once flag is enabled
