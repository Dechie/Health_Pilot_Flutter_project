# Mock Testing Plan

Run all tests with **no `--dart-define` flags** — all feature flags default to `false`, which means every repository uses its mock implementation. The goal is to confirm the UI, state management, navigation, and provider wiring are all correct before touching the live backend.

```bash
flutter run
```

Report failures with: which test number, what you did, what happened, and whether the app crashed or just looked wrong.

---

## Known mock behaviour (not bugs — do not report these)

- **Chat messages do not survive a full app restart.** The mock doesn't persist to disk. Within a session they appear correctly; after a kill/reopen they're gone. This is expected.
- **Contacts and Assessment start empty.** No seed data. Add entries first, then test editing/deleting them.
- **Nutrition history persists across restarts.** The mock delegates to SharedPreferences, so it survives kills.
- **Auth accepts any email and password.** No credentials are validated in mock mode.

---

## Tier 1 — Auth

No flags needed. The mock auto-accepts any input.

| # | Action | Expected | Notes |
|---|--------|----------|-------|
| 1 | Open app fresh | Login/onboarding screen shown | No crash, no blank screen |
| 2 | Register with any email + password | Proceeds without error | Mock ignores actual values |
| 3 | Login with any email + password | Lands on home screen, "Demo User" identity loaded | |
| 4 | Kill app, reopen | Still logged in — home screen shown directly | Token was stored in secure storage |
| 5 | Navigate to logout | Returns to login screen | No residual state from previous session |
| 6 | Login again after logout | Home screen loads cleanly | No stale data visible |

---

## Tier 2 — Profile

Seed data: `kDemoUserProfile` (a pre-built demo profile object).

| # | Action | Expected | Notes |
|---|--------|----------|-------|
| 1 | Open profile screen | Demo profile data displayed — name, fields populated | Not blank |
| 2 | Edit any field (e.g. name), save | Updated value shown on profile screen | Mock returns whatever you saved |
| 3 | Navigate away, come back to profile | Edited value still shown | Provider holds state in memory |
| 4 | Kill app, reopen, check profile | Reverts to original demo data | Mock doesn't persist edits — expected |

---

## Tier 3 — Health Data & Medications

Run both in the same session — they don't interfere.

### Health Data

Seed data: pre-built list of conditions and symptoms (`kSeedConditions`, `kSeedSymptoms`).

| # | Action | Expected |
|---|--------|----------|
| 1 | Open health screen | Seeded conditions and symptoms listed — not empty |
| 2 | Add a new condition | Appears at top of list immediately |
| 3 | Add a new symptom | Appears in symptoms list immediately |
| 4 | Delete a condition | Removed from list, no crash |
| 5 | Navigate away and back to health screen | Added items still present (in-memory) |

### Medications

Seed data: `kSeedMedications` (pre-built medication list).

| # | Action | Expected |
|---|--------|----------|
| 1 | Open medications screen | Seeded medications listed |
| 2 | Add a new medication | Appears in list with the details you entered |
| 3 | Edit an existing medication | Changes reflected in list |
| 4 | Add a reminder to a medication | Reminder saved, visible on medication detail |
| 5 | Log a dose (mark as taken) | Dose appears in dose log for that medication |
| 6 | Delete a medication | Removed from list |
| 7 | Navigate away and back | All in-session changes still present |

---

## Tier 4 — Assessment, AI Assistant, Nutrition

Test all three in the same session.

### Assessment

Seed data: **none** — starts empty.

| # | Action | Expected |
|---|--------|----------|
| 1 | Open assessment history screen before submitting | Empty state shown — no crash |
| 2 | Complete a full assessment (answer all questions) | Submits without error, confirmation shown |
| 3 | Open assessment history screen | Just-submitted entry visible |
| 4 | Submit a second assessment | Both entries visible in history, newest first |
| 5 | Delete one entry | Entry removed, other remains |

### AI Assistant (Chatbot)

Seed data: varies by mock implementation — history may start empty or with a greeting.

| # | Action | Expected |
|---|--------|----------|
| 1 | Open chatbot screen | Loads without crash; history shown (or empty state) |
| 2 | Type and send a message | Response appears in the chat thread |
| 3 | Send several messages in a row | All messages and responses appear in order, no overlap |
| 4 | Scroll up through history | No layout overflow or rendering errors |
| 5 | Send an empty message (if the UI allows it) | Either blocked by the input field, or graceful error — no crash |

### Nutrition

Seed data: if history is empty on first launch, `FoodDayLog.sampleFirstDay()` is seeded automatically. Persists via SharedPreferences.

| # | Action | Expected |
|---|--------|----------|
| 1 | Open nutrition history on first launch | Sample day log shown — not blank |
| 2 | Add a new food day log | Appears in history list |
| 3 | Kill app, reopen nutrition history | Both the seeded entry and added entry still present (SharedPrefs) |
| 4 | Open nutrition tracking/settings screen | Current settings loaded (frequency, diet tags) |
| 5 | Change diet tags and frequency, save | Settings screen reflects changes |
| 6 | Kill app, reopen settings | Changes still applied |

---

## Tier 5 — Articles & Contacts

### Articles

Seed data: 3 articles ("Why are we growing old?", "Why old", "Why get old").

| # | Action | Expected |
|---|--------|----------|
| 1 | Open articles screen | All 3 seeded articles visible |
| 2 | Search for "old" | All 3 results shown (all titles contain "old") |
| 3 | Search for "growing" | Only "Why are we growing old?" shown |
| 4 | Search for "xyz" | Empty results — no crash, no leftover items |
| 5 | Clear search | All 3 articles return |
| 6 | Tap like on an article | Like count increments by 1 in the list |
| 7 | Tap like again | Count increments again (mock allows re-liking) |
| 8 | Tap an article card | Opens article detail screen with full body |
| 9 | Tap "Read more" link in card snippet | Also opens article detail |
| 10 | Tap share icon | System share sheet appears |

### Contacts

Seed data: **none** — starts empty.

| # | Action | Expected |
|---|--------|----------|
| 1 | Open contacts screen before adding anything | Empty state — no crash |
| 2 | Add an emergency contact | Appears in emergency contacts list |
| 3 | Add a personal doctor | Appears in doctors list |
| 4 | Edit the emergency contact | Changes reflected |
| 5 | Delete the emergency contact | Removed from list |
| 6 | Navigate away and back | Doctor entry still present (in-memory) |

---

## Tier 6 — Chat

Seed data: `kSeedUsers` (5 users), `kSeedGroups` (3 groups). Messages do not survive app restarts.

| # | Action | Expected |
|---|--------|----------|
| 1 | Open general chat screen | 5 users and 3 groups listed |
| 2 | Search for a user by name | Filtered results shown |
| 3 | Search for a group | Filtered results shown |
| 4 | Clear search | Full list returns |
| 5 | Tap a user | Opens direct message screen, chat history shown |
| 6 | Send a message in direct chat | Message appears in the thread immediately |
| 7 | Go back, reopen the same user's chat | Message still visible (in-memory, same session) |
| 8 | Tap a group | Opens group chat screen |
| 9 | Send a message in group chat | Message appears with your name as sender |
| 10 | Tap a user's avatar or name | Opens user detail screen with profile info |
| 11 | Kill app, reopen chat | Messages gone — users and groups still listed (expected) |

---

## Tier 7 — Subscriptions

Seed data: premium plan ($25.99/month) and free plan ($0). Status starts as inactive (free).

| # | Action | Expected |
|---|--------|----------|
| 1 | Open subscription screen | Both premium and free plan cards shown with correct pricing |
| 2 | Verify premium price displayed | Shows "$25.99/month" — sourced from mock, not hardcoded |
| 3 | Tap the "$25.99/month" button | `selectPlan()` fires, navigates to payment method screen |
| 4 | Complete the payment method screen | Navigates to payment review (checkout) screen |
| 5 | Review screen shows correct card/payment info | Fields populated from `PersonalPaymentInformations` |
| 6 | Tap "Next" on review screen | `confirmSubscription()` fires, navigates to "Purchase Successful" screen |
| 7 | "Finish" on success screen | Navigates to next onboarding step without crash |
| 8 | Navigate back to subscription screen | Status now shows as active/subscribed |

---

## Reporting format

```
Feature:  <name>
Test #:   <number>
Action:   <exactly what you did>
Expected: <what should have happened>
Actual:   <what actually happened>
Crash:    yes / no
```

If the app crashes, include the error printed in the terminal where `flutter run` is active.
