# Gap Fix Plan

Derived from comparing the live Swagger spec at
`https://pulsminds-healthpilot.chickenkiller.com/swagger.json` (103 endpoints)
against the Flutter app codebase (remote repos, providers, screens, navigation).

Branches are ordered by priority. Each branch must keep `flutter analyze` clean.

## Progress

| Branch | Status | Commits |
|---|---|---|
| 1 — Data-layer correctness | ✅ Done | `743ed87` |
| 2 — Provider surface gaps | ⬜ | |
| 3 — Live-wire missing UI | ⬜ | |
| 4 — WebSocket real-time chat | ⬜ | |
| 5 — Nutrition endpoint remapping | ✅ Done (in Branch 1) | `743ed87` |
| 6 — Guest assessment flow | ⬜ | |
| 7 — Health repo minor endpoints | ⬜ | |
| 8 — Community↔chat bridge | ⏳ Deferred (blocked on backend) | |
| 9 — UI dead controls sweep | ⬜ | |

---

## Branch 1 — Data-layer correctness fixes (P0) ✅

**Goal:** Fix remote-repo methods that call the wrong URL, wrong HTTP verb, or a
non-existent endpoint. These are live bugs that will crash or silently fail when
the corresponding feature flag is `true`.

| File | Fix | Status |
|---|---|---|
| `remote_subscription_repository.dart` `cancelSubscription()` | Changed `DELETE` → **`POST`** to match Swagger `POST /subscriptions/cancel/` | ✅ `743ed87` |
| `remote_nutrition_repository.dart` `fetchHistory()` | Rewired from `GET /history/` → **`GET /meals/`** | ✅ `743ed87` |
| `remote_nutrition_repository.dart` `addMeal()` | Rewired from `POST /history/` → **`POST /meals/`** | ✅ `743ed87` |
| `remote_nutrition_repository.dart` `fetchGoals()` / `saveGoals()` | Rewired from `/settings/` → **`/goals/`** | ✅ `743ed87` |
| `remote_health_repository.dart` `clearSymptoms()` | Made a no-op (backend has no bulk `DELETE /health/symptoms/`) | ✅ `743ed87` |
| `remote_health_repository.dart` `fetchConditions()` | Returns `[]` — conditions endpoint doesn't exist on backend | ⏳ Won't fix (no backend endpoint) |

**Acceptance:** `FF_* = true` for affected features does not throw 404/405.

---

## Branch 2 — Provider surface gaps (P1)

**Goal:** Expose already-implemented remote-repo methods through their
providers so screens can call them.

| Provider | Missing method | Remote repo has it? | Needed by |
|---|---|---|---|
| `ArticleProvider` | `fetchRecommended()` | ✅ `RemoteArticleRepository` | Article feed "For You" tab |
| `ArticleProvider` | `fetchBookmarks()` | ✅ | Bookmarks screen |
| `ArticleProvider` | `fetchArticle(id)` | ✅ | Article detail refresh |
| `ArticleProvider` | `toggleBookmark(id)` | ✅ | Bookmark toggle button |
| `ArticleProvider` | `fetchComments(id)` | ✅ | Article comment screen |
| `ArticleProvider` | `addComment(id, text)` | ✅ | "Post" comment button |
| `AssessmentProvider` | `submitGuestAssessment(summary)` | ✅ | Guest assessment flow |
| `HealthProvider` | `fetchSummaries()` (list all) | ✅ `RemoteHealthRepository.fetchSummaries` exists in the interface | Health summaries list |

**Method signatures to expose:**

```dart
// ArticleProvider additions
Future<List<ArticleFeedItem>> fetchRecommended();
Future<List<ArticleFeedItem>> fetchBookmarks();
Future<void> fetchArticle(String id);
Future<bool> toggleBookmark(String id);
Future<List<ArticleComment>> fetchComments(String id);
Future<ArticleComment> addComment(String id, String text);

// AssessmentProvider addition
Future<CompletedAssessmentEntry> submitGuestAssessment(AssessmentSummary summary);

// HealthProvider addition
Future<List<HealthSummary>> fetchSummaries();
```

---

## Branch 3 — Live-wire missing UI (P2 high)

**Goal:** Surface features whose data layer exists but have no screen or have
dead UI controls.

### 3a — Notification centre screen
- **Provider:** `NotificationProvider` fully wired in `repository_locator.dart`.
- **Remote repo:** All 4 endpoints implemented.
- **Current state:** Home bell icon at `home_page_screen.dart:369` has **no
  `onTap` handler** → no-op; no notification screen exists.
- **Work:**
  1. Create `lib/features/notifications/notifications_screen.dart`
     - List from `NotificationProvider.items`
     - Unread badge per item
     - Tap → `markRead(id)` and show detail
     - "Mark all read" action in app bar
  2. Wire home bell icon `onTap` to push `NotificationsScreen`
  3. Show unread badge count on the bell icon using `NotificationProvider.unreadCount`

### 3b — Article comment screen (unstick)
- **Current state:** `article_comment_screen.dart:378` "Post" button is a no-op;
  `article_detail_screen.dart` opens with `comments: const []`.
- **Work:**
  1. Wire "Post" button → `context.read<ArticleProvider>().addComment(id, text)`
  2. On detail screen init → `provider.fetchComments(id)` → render list
  3. Wire like icon → `provider.likeArticle(id)`, bookmark → `provider.toggleBookmark(id)`

### 3c — Assessment delete affordance
- **Current state:** `AssessmentProvider.delete(id)` exists, but no UI calls it.
- **Work:** Add a swipe-to-delete or long-press menu on
  `assessment_history_screen.dart` rows → confirm dialog → `provider.delete(id)`.

### 3d — Symptom row tap
- **Current state:** `symptom_tracking_screen.dart` row `onTap: () {}` — no-op.
  `HealthProvider.deleteSymptom(id)` exists.
- **Work:** Add swipe-to-delete or a detail view on symptom rows.

### 3e — Payment flow in subscription screen
- **Current state:** `SubscriptionProvider` exposes `createPayment`,
  `confirmPayment`, `fetchPaymentHistory` but `subscription_and_payment_screen.dart`
  "Next" button doesn't call them (uses hardcoded amounts, no gateway flow).
- **Work:**
  1. Wire "Next" → call `provider.createPayment(amount, method)` → navigate to
     confirmation screen → call `provider.confirmPayment(id)` → show success.
  2. Add a payment history section from `provider.fetchPaymentHistory()`.

### 3f — Reset password deep link
- **Current state:** `ForgotPasswordController` calls
  `authState.requestPasswordReset(email)` successfully, but the email's token
  cannot deep-link into `ResetPasswordScreen` — user must manually paste.
- **Work:** Handle the incoming deep-link URI in `main.dart` (or the relevant
  entry point) to extract the token and push `ResetPasswordScreen(token: token)`.

---

## Branch 4 — WebSocket real-time chat (P2 medium)

**Current state:** `ChatScreen` and `GroupChatScreen` poll every 15 seconds via
`Timer.periodic`. No `web_socket_channel` dependency.

**Work:**
1. Add `web_socket_channel: ^3.x` to `pubspec.yaml`
2. Create `lib/features/chat/services/chat_websocket_service.dart`:
   - Private: `ws://<host>/ws/chat/private/<chatId>/?token=<jwt>`
   - Group: `ws://<host>/ws/chat/group/<groupId>/?token=<jwt>`
   - Expose `Stream<DirectMessage>` for incoming messages
   - Reconnect with exponential backoff
3. Integrate into `ChatProvider`:
   - On entering `ChatScreen` → subscribe to WS stream → prepend to message list
   - On leaving → unsubscribe
   - Keep REST POST as the send mechanism (documented choice)
4. Remove the 15-second polling Timer from `ChatScreen` and `GroupChatScreen`
   (fall back to polling only if WS fails to connect)

---

## Branch 5 — Nutrition endpoint remapping (P2 low) ✅

**Now covered by Branch 1** (`commit 743ed87`). All three endpoint rewires done:
1. ✅ `fetchHistory()` → `GET /nutrition/meals/`
2. ✅ `fetchGoals()` → `GET /nutrition/goals/`
3. ✅ `saveGoals()` → `PATCH /nutrition/goals/`
4. ✅ `fetchSummary()` → stays at `GET /nutrition/summary/` (confirmed correct)
5. ⏳ Keep `/nutrition/settings/` for app-level preferences — wire when UI needs it

---

## Branch 6 — Guest assessment flow (P3)

**Current state:** `POST /assessments/guest/` exists on the backend and is
implemented in `RemoteAssessmentRepository`, but `AssessmentProvider` never
exposes it and no screen calls it. Guest users land on the home screen with no
way to run an assessment.

**Work:**
1. Add `submitGuestAssessment` to `AssessmentProvider` (from Branch 2)
2. On `HomePageScreen`, when `authState.isGuest == true`, show a "Try our
   symptom checker" CTA card that routes to the assessment flow without
   requiring authentication
3. Ensure the guest flow does not attempt to save results to history (the
   backend returns the result but does not persist it)

---

## Branch 7 — Health repo minor endpoints (P3)

**Current state:** The following Swagger-listed endpoints are unimplemented in
`RemoteHealthRepository` but have no UI demand yet:

| Missing endpoint | Implement when |
|---|---|
| `GET /health/vitals/{id}/` | Detail view for a vital log entry |
| `GET /health/goals/{id}/` | Detail view for a goal |
| `PUT /health/goals/{id}/` | Full-replacement update pattern (PATCH suffices today) |
| `GET /health/summaries/` (list) | Health summaries list screen |

**Work:** Stub these as `throw UnimplementedError` with a descriptive message,
or implement them if the corresponding screen is being built.

---

## Branch 8 — Chat community→group bridge (P3 deferred)

**Current state:** `community_groups_screen.dart` `_openChat` can dead-end with
"Group Not Found" because `chatGroupId` is always `null` — the backend hasn't
shipped the link field yet. The `CommunityGroup.fromJson` parser already reads
`chat_group_id` / `group_chat_id` and stores it as `chatGroupId`. Nothing to
do on the Flutter side until the backend ships the field.

**Hold:** Await backend delivery of the `chat_group_id` field on the community
group response. Once available, wire `_openChat` to join the linked group chat
and navigate to `GroupChatScreen`.

---

## Branch 9 — UI dead controls sweep (P4)

Single pass to wire or remove all remaining no-op interactive elements:

| Screen | Control | Fix |
|---|---|---|
| `chat_screen.dart:92,113` | Attach button, `more: () {}` | Wire attach to file picker + upload; wire more to user details or remove |
| `group_chat_screen.dart:87,107` | Attach button, `more: () {}` | Same |
| `assessment_detail_screen.dart:81` | "Show nearest hospitals" | Wire to maps URL or remove |
| `health_profile_screen.dart` | "Health Profiles" add/edit/row taps | Wire to a profile editor or remove |
| `blog_reccomendation._card.dart:33` | "Consult our doctors" card | Wire to a doctor listing or remove |
| `user_detail_screen.dart` | `more` + notification toggle | Wire toggle to backend or remove |
| `home_page_screen.dart` | "Tell us your symptoms" text | Make tappable → navigate to symptom logger |
| `symptom_tracking_screen.dart` | Row `onTap: () {}` | Wire to delete confirmation or symptom detail |

---

## Appendix — Full endpoint coverage matrix

| Endpoint group | Total | Implemented | Missing | Branch |
|---|---|---|---|---|
| Auth | 14 | 14 | 0 (POST activate is optional; GET variant works) | — |
| Profile | 8 | 8 | 0 | — |
| Health | 20 | 14 | 6 (individual get, PUT goal, summaries list) | 7 |
| Medications | 12 | 12 | 0 | — |
| Articles | 10 | 10 | 0 (all in remote repo; provider missing 6) | 2 |
| Assessment | 4 | 4 | 0 (all in remote repo; provider missing guest) | 2, 6 |
| Chat | 20 | 18 | 2 skipped intentionally (alias routes); WebSocket missing | 4 |
| Community | 9 | 9 | 0 | — |
| Notifications | 4 | 4 | 0 (no UI screen) | 3a |
| Subscriptions | 8 | 8 | 0 | — |
| Nutrition | 10 | 10 | 0 | — |
| Ads | 2 | 2 | 0 | — |
| **Total** | **121** | **114** | **7** | |
