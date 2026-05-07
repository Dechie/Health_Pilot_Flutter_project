# Live API Testing Plan

Test features in tier order. Each tier depends on the one above being fully green.
Report failures with: HTTP status code, response body, and the exact action that triggered it.

---

## Setup

Enable flags via `--dart-define`. Start with only the flags for the current tier — do not enable everything at once.

```bash
# Example: Auth only
flutter run --dart-define=FF_AUTH=true

# Example: Auth + Profile
flutter run --dart-define=FF_AUTH=true --dart-define=FF_PROFILE=true
```

---

## Tier 1 — Auth

**Flag:** `FF_AUTH=true`

Everything depends on this. Do not proceed until all pass.

| # | Action | Expected result | Capture if failing |
|---|--------|-----------------|--------------------|
| 1 | Register a new account | Lands on home/onboarding, no crash | HTTP status, error body |
| 2 | Login with valid credentials | Token stored, screen transitions to home | Same |
| 3 | Login with wrong password | Error message shown, no crash | Same |
| 4 | Kill app, reopen | Still logged in (token was persisted) | Describe what happens |
| 5 | Wait for token expiry — or manually delete token from secure storage | Redirected to login automatically, not stuck/blank | Describe the behavior |
| 6 | Logout | Token cleared, back to login screen | — |

---

## Tier 2 — Profile

**Flags:** `FF_AUTH=true FF_PROFILE=true`

| # | Action | Expected result | Capture if failing |
|---|--------|-----------------|--------------------|
| 1 | Open profile screen | Real name/avatar loads from backend | HTTP status, response shape |
| 2 | Edit a field (e.g. display name), save | Change persists after screen pop and reopen | Same |
| 3 | Open profile on slow/no network | Loading spinner shown, no blank screen, no crash | Describe behavior |

---

## Tier 3 — Health Data & Medications

**Flags:** `...FF_HEALTH_DATA=true FF_MEDICATIONS=true`

These two have no dependency on each other — test them in parallel.

### Health Data

| # | Action | Expected result | Capture if failing |
|---|--------|-----------------|--------------------|
| 1 | Open health screen | Real records load (or empty state — no crash) | HTTP status, response shape |
| 2 | Add a health entry | Entry appears in list immediately | Same |
| 3 | Kill app, reopen health screen | Entry still present | — |

### Medications

| # | Action | Expected result | Capture if failing |
|---|--------|-----------------|--------------------|
| 1 | Open medications screen | Medication list loads | HTTP status, response shape |
| 2 | Add a medication | Appears in list | Same |
| 3 | Mark as taken | Status updates in UI | Same |
| 4 | Delete a medication | Removed from list, does not reappear on reload | Same |

---

## Tier 4 — Assessment, AI Assistant, Nutrition

**Flags:** `...FF_ASSESSMENT=true FF_AI_ASSISTANT=true FF_NUTRITION=true`

These three have no dependency on each other — test in parallel.

### Assessment

| # | Action | Expected result | Capture if failing |
|---|--------|-----------------|--------------------|
| 1 | Complete a full assessment | Submits without error | HTTP status, error body |
| 2 | Open assessment history screen | Previous submissions listed | HTTP status, response shape |

### AI Assistant (Chatbot)

| # | Action | Expected result | Capture if failing |
|---|--------|-----------------|--------------------|
| 1 | Send a message | Response appears (streamed or full) | HTTP status, latency if very slow |
| 2 | Kill app, reopen chatbot | Chat history loaded from backend | HTTP status, response shape |
| 3 | Send an empty message | Graceful error or blocked — no crash | Describe behavior |
| 4 | Send a very long message | No crash, backend either accepts or returns clear error | HTTP status |

### Nutrition

| # | Action | Expected result | Capture if failing |
|---|--------|-----------------|--------------------|
| 1 | Open nutrition history | Logs load (or empty state — no crash) | HTTP status, response shape |
| 2 | Add a food day log | Appears in history | Same |
| 3 | Change nutrition settings (diet, frequency) | Persists after killing and reopening app | Same |

---

## Tier 5 — Articles & Contacts

**Flags:** `...FF_ARTICLES=true FF_CONTACTS=true`

### Articles

| # | Action | Expected result | Capture if failing |
|---|--------|-----------------|--------------------|
| 1 | Open articles screen | Feed loads from API (real content, not mock data) | HTTP status, response shape |
| 2 | Like an article | Like count increments, persists after screen pop | Same |
| 3 | Search for an article | Filtered results shown correctly | — |
| 4 | Open article detail | Full body renders, no overflow or crash | Describe layout issue if any |

### Contacts

| # | Action | Expected result | Capture if failing |
|---|--------|-----------------|--------------------|
| 1 | Open contacts screen | Contact list loads | HTTP status, response shape |
| 2 | Add a contact | Appears in list | Same |
| 3 | Remove a contact | Removed, does not reappear on reload | Same |

---

## Tier 6 — Chat

**Flags:** `...FF_CHAT=true`

Depends on Contacts being stable — chat user lookups use the same user IDs.

| # | Action | Expected result | Capture if failing |
|---|--------|-----------------|--------------------|
| 1 | Open general chat screen | User list and group list load | HTTP status, response shape |
| 2 | Open a direct message thread | Message history loads | Same |
| 3 | Send a direct message | Message appears in thread | Same |
| 4 | Open a group chat | Group history loads | HTTP status, response shape |
| 5 | Send a group message | Message appears for all members | Same |
| 6 | Unknown sender ID in a message | Name falls back gracefully — no crash | Describe behavior |

---

## Tier 7 — Subscriptions

**Flags:** `...FF_SUBSCRIPTIONS=true`

Test last — depends on Auth and Profile being stable. Real money is not involved in testing; confirm with backend team that a sandbox/test plan ID exists before running subscribe tests.

| # | Action | Expected result | Capture if failing |
|---|--------|-----------------|--------------------|
| 1 | Open subscription screen | Premium plan loads with real price from API | HTTP status, response shape |
| 2 | Tap premium plan button | `selectPlan()` fires, navigates to payment method screen | — |
| 3 | Complete payment review, tap Next | `confirmSubscription()` fires, navigates to success screen | HTTP status, error body |
| 4 | Kill app, reopen subscription screen | Status shows active/subscribed | HTTP status, response shape |
| 5 | (If sandbox supports it) Cancel subscription | Status reverts to free | Same |

---

## Reporting Format

When something fails, report back with:

```
Feature: <name>
Test #: <number>
Action: <what you did>
Expected: <what should happen>
Actual: <what happened>
HTTP status: <if visible in logs>
Response body: <if visible in logs or devtools>
```

To see HTTP traffic, run with:
```bash
flutter run --dart-define=FF_AUTH=true ... 2>&1 | grep -i "api\|http\|error\|dio"
```
Or attach the Flutter DevTools network tab.
