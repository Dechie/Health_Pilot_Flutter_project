# Mock Testing Plan

Run all tests with **no `--dart-define` flags** — all feature flags default to `false`, meaning every repository uses its mock implementation.

```bash
flutter run
```

Two sessions, done back to back or on the same run:
- **Session 1** — Read path: open every screen, verify data loads and navigation works.
- **Session 2** — Write path: perform every mutation and verify state flows correctly back to the UI.

Report failures with: session number, test number, what you did, what happened, and whether the app crashed.

---

## Known mock behaviour (not bugs)

| Behaviour | Reason |
|-----------|--------|
| Auth accepts any email and password | Mock skips validation |
| Chat messages disappear after app restart | Mock doesn't persist messages to disk |
| Contacts and Assessment start empty | No seed data — add entries first |
| Nutrition history survives restarts | Mock delegates to SharedPreferences |
| Profile edits revert after restart | Mock doesn't persist to disk |

---

## Session 1 — Read path

**Goal:** walk through every screen in a single continuous run. You are only navigating and reading — no creating, editing, or deleting yet. Check that data loads, the right seed data appears, loading states don't hang, and every navigation gesture works.

Do these in order — each one assumes you're logged in from the previous step.

| # | Where | Action | Expected |
|---|-------|--------|----------|
| 1 | App launch | Open app cold | Login / onboarding screen shown — no crash, no blank screen |
| 2 | Login | Enter any email + any password, tap login | Lands on home screen, "Demo User" shown |
| 3 | Home | Observe home screen | No loading spinner stuck indefinitely; widgets render |
| 4 | Profile | Navigate to profile | Demo profile fields populated — name, bio, etc. — not blank |
| 5 | Health | Navigate to health screen | Seeded conditions and symptoms listed — screen not empty |
| 6 | Medications | Navigate to medications | Seeded medication list shown |
| 7 | Medication detail | Tap any medication | Detail screen opens with correct name, dosage, schedule |
| 8 | Back | Back from medication detail | Returns to medication list cleanly |
| 9 | Assessment | Navigate to assessment history | Empty state shown without crash (no seed data) |
| 10 | AI Chatbot | Navigate to chatbot | Screen loads — empty history or greeting, no crash |
| 11 | Nutrition history | Navigate to nutrition history | Sample day log shown (auto-seeded on first launch) |
| 12 | Nutrition settings | Navigate to nutrition settings/tracking | Current frequency and diet tags displayed |
| 13 | Articles | Navigate to articles screen | All 3 seeded articles listed |
| 14 | Article detail | Tap any article card | Detail screen opens with full article body |
| 15 | Back | Back from article detail | Returns to articles list |
| 16 | Contacts | Navigate to contacts/emergency screen | Empty state shown without crash (no seed data) |
| 17 | Chat | Navigate to general chat | 5 users and 3 groups listed |
| 18 | Direct message | Tap any user in chat list | DM screen opens with that user's chat history (empty or seeded) |
| 19 | Back | Back from DM screen | Returns to chat list cleanly |
| 20 | Group chat | Tap any group | Group chat screen opens with group history |
| 21 | Back | Back from group chat | Returns to chat list cleanly |
| 22 | User detail | Tap a user's avatar or name | User detail screen opens with profile info |
| 23 | Back | Back from user detail | Returns without crash |
| 24 | Subscriptions | Navigate to subscription screen | Premium ($25.99/month) and free plan cards both shown |
| 25 | Kill app | Force-close and reopen | Lands directly on home — still logged in, token persisted |
| 26 | Nutrition history (after restart) | Open nutrition history | Sample log still there (SharedPrefs persisted) |
| 27 | Profile (after restart) | Open profile | Demo profile data back (edits from session not persisted — expected) |

---

## Session 2 — Write path

**Goal:** perform every mutation the app supports. For each one, verify the UI reflects the new state immediately (optimistic update via provider), and that navigation after the action works correctly.

Start fresh from home — still logged in.

### Auth

| # | Action | Expected |
|---|--------|----------|
| W1 | Logout | Returns to login screen, no residual state |
| W2 | Login again | Home screen loads cleanly with demo user |

### Profile

| # | Action | Expected |
|---|--------|----------|
| W3 | Edit a profile field (e.g. name), save | Updated value immediately visible on profile screen |
| W4 | Navigate away from profile, navigate back | Edited value still shown — provider held state |

### Health Data

| # | Action | Expected |
|---|--------|----------|
| W5 | Add a new condition | Appears at top of conditions list immediately |
| W6 | Add a new symptom | Appears in symptoms list immediately |
| W7 | Delete the condition you just added | Removed from list, no crash, no reappearance |

### Medications

| # | Action | Expected |
|---|--------|----------|
| W8 | Add a new medication with all fields filled | Appears in medications list |
| W9 | Edit that medication (change dosage or name) | Updated details shown in list and detail screen |
| W10 | Add a reminder to that medication | Reminder visible in medication detail |
| W11 | Log a dose (mark as taken) | Dose log updated — status reflects taken |
| W12 | Delete the medication | Removed from list, reminders and logs gone with it |

### Assessment

| # | Action | Expected |
|---|--------|----------|
| W13 | Complete a full assessment | Submits without error, navigates to confirmation or history |
| W14 | Open assessment history | Submitted entry visible |
| W15 | Submit a second assessment | Both entries in history, newest first |
| W16 | Delete one entry | Removed, other entry remains untouched |

### AI Chatbot

| # | Action | Expected |
|---|--------|----------|
| W17 | Send a message | Message appears in thread, mock response follows |
| W18 | Send 3 more messages in a row | All appear in correct order, no overlap or missing messages |
| W19 | Scroll up through thread | Layout holds — no overflow, no blank gaps |
| W20 | Try sending an empty message | Input blocked or graceful error — no crash |

### Nutrition

| # | Action | Expected |
|---|--------|----------|
| W21 | Add a new food day log | Appears in history list immediately |
| W22 | Change diet tags in settings | Tags updated in settings screen |
| W23 | Change report frequency | Frequency updated — no crash |
| W24 | Kill app, reopen nutrition | Added log and settings changes still present (SharedPrefs) |

### Articles

| # | Action | Expected |
|---|--------|----------|
| W25 | Like the first article | Like count increments by 1 in the list |
| W26 | Like the same article again | Count increments again (mock allows re-liking) |
| W27 | Search "growing" | Only "Why are we growing old?" shown |
| W28 | Search "xyz" | Empty results — list clears cleanly, no crash |
| W29 | Clear search | All 3 articles return |
| W30 | Tap share on any article | System share sheet opens |

### Contacts

| # | Action | Expected |
|---|--------|----------|
| W31 | Add an emergency contact | Appears in emergency contacts list |
| W32 | Add a personal doctor | Appears in doctors list |
| W33 | Edit the emergency contact | Changes reflected immediately |
| W34 | Delete the emergency contact | Removed, doctor entry untouched |

### Chat

| # | Action | Expected |
|---|--------|----------|
| W35 | Search for a user by name | Filtered to matching users only |
| W36 | Clear search | Full list returns |
| W37 | Send a direct message to a user | Message appears in thread immediately |
| W38 | Go back, reopen that same user's DM | Message still visible (in-memory, same session) |
| W39 | Send a message in a group chat | Message appears with your sender name |
| W40 | Go back, reopen that group | Message still visible (same session) |

### Subscriptions

| # | Action | Expected |
|---|--------|----------|
| W41 | Tap "$25.99/month" button | `selectPlan()` fires — navigates to payment method screen |
| W42 | Fill payment method, proceed | Navigates to payment review (checkout) screen |
| W43 | Tap "Next" on review screen | `confirmSubscription()` fires — navigates to "Purchase Successful" |
| W44 | Tap "Finish" on success screen | Navigates forward without crash |
| W45 | Navigate back to subscription screen | Status reflects active subscription |

---

## Reporting format

```
Session:  1 or 2
Test #:   <number>
Action:   <exactly what you did>
Expected: <what should have happened>
Actual:   <what actually happened>
Crash:    yes / no
```

If the app crashed, paste the error from the terminal where `flutter run` is running.
