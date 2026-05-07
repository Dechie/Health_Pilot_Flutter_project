# Backend integration plan

This plan is derived from:
- `docs/FEATURE_BRANCH_PLAN.md` (UI refactor/feature roadmap, Branches A–Q — read-only reference)
- Backend API reference: `HealthPilot API Reference` + Postman collection (provided by backend team)
- Current session decisions tracked in `docs/BACKLOG.md`

The intent is to wire the backend to the Flutter app in **one-feature-domain-per-branch increments**, matching the same small-PR / clear-acceptance-criteria discipline established in the UI roadmap.

**Primary success metric:** each integration branch produces a self-contained, reviewable unit that adds the network and data layer for exactly one feature domain, keeps `flutter analyze` and `flutter test` clean, does not break UI that currently works with local/stub data, and allows all features to be toggled back to static data via a feature flag.

### Companion documents

| Document | Purpose |
|----------|---------|
| `docs/BACKEND_INTEGRATION_PLAN.md` | **This file** — roadmap, scope, and acceptance criteria |
| `docs/BACKEND_INTEGRATION_WORKTREE_PLAN.md` | Git workflow, branch stacking, worktrees, PR bases |
| `docs/FEATURE_BRANCH_PLAN.md` | Prior UI roadmap (Branches A–Q) — do not modify |
| `docs/BACKLOG.md` | All decisions and implementation notes |

---

## 0) Current baseline (as of 2026-05-05)

### Mobile app
- No HTTP client; no API layer of any kind.
- All feature data is local: `SharedPreferences`, in-memory `ChangeNotifier`, or hardcoded static seeds.
- Code comments throughout: "local seed until API exists", "no backend", "Client-side profile snapshot until backend auth provides a canonical user".
- `kEnableOnboardingFlow = false` (bypasses onboarding; see `BACKLOG.md` 2026-04-15).
- State management: Provider (`ChangeNotifier`); no repository layer exists yet.

### Backend (confirmed complete from API reference)
- Base URL: `http://<host>:9000`; all endpoints under `/api/v1/`.
- JWT auth: register → email activation → login → access + refresh tokens.
- Guest login available (`POST /api/v1/auth/guest/`).
- Full feature coverage: auth, profile, health tracking (symptoms, vitals, goals, dashboard), medications (reminders + doses), articles (likes, bookmarks, comments), AI assessment, chat (private + group, WebSocket), AI assistant, community/peers, nutrition, notifications, subscriptions.
- WebSocket real-time chat: `ws://<host>/ws/chat/private/<id>/?token=<jwt>` and `ws://<host>/ws/chat/group/<id>/?token=<jwt>`.
- Standard response envelope: `{ "success": true, "message": "...", "data": {...} }`.

---

## 1) Branch workflow (how to execute)

For each branch below:

- Create from the **correct parent** (see `docs/BACKEND_INTEGRATION_WORKTREE_PLAN.md §4`).
- Make **scoped changes only** — one feature domain per branch; no drive-by UI changes unless directly required by the API wiring.
- Keep public widget/provider interfaces stable: replace stub data **behind** the same provider surface; do not re-architect screens unless necessary.
- Run after every change:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
  - Smoke-test affected flows on device/emulator with both `kUseBackend = true` and `kUseBackend = false`
- Update `docs/BACKLOG.md` with implementation notes (files added/changed, DTO mapping choices).
- Merge back when green.

### Branch types

- **Type A — infrastructure/repository**: adds network client, repository interfaces, DTO models, or provider wiring with minimal or no UI change.
- **Type B — API wiring + UI update**: replaces stub/local data with real API; touches screen state management, loading/error states.
- **Type C — exploratory**: scope unclear or requires a product decision before coding.

### Naming convention

All integration branches use: `feat/api-<domain>`.

---

## 2) Architecture: data source flags + mock repositories

Every feature repository must support three modes — real backend, static/mock data, and test injection — without requiring code changes between modes. This isolates Flutter-side failures from backend failures.

### 2a) Feature flags (`lib/core/flags/feature_flags.dart`)

Each feature domain has its own flag. New domains default to `false` (static data) until the corresponding integration branch is merged and tested. Flags are driven by `--dart-define` so they can be set per build without touching source.

```dart
// lib/core/flags/feature_flags.dart
class FeatureFlags {
  static const bool auth         = bool.fromEnvironment('FF_AUTH',         defaultValue: false);
  static const bool userProfile  = bool.fromEnvironment('FF_PROFILE',      defaultValue: false);
  static const bool articles     = bool.fromEnvironment('FF_ARTICLES',     defaultValue: false);
  static const bool medications  = bool.fromEnvironment('FF_MEDICATIONS',  defaultValue: false);
  static const bool assessment   = bool.fromEnvironment('FF_ASSESSMENT',   defaultValue: false);
  static const bool contacts     = bool.fromEnvironment('FF_CONTACTS',     defaultValue: false);
  static const bool healthData   = bool.fromEnvironment('FF_HEALTH_DATA',  defaultValue: false);
  static const bool chat         = bool.fromEnvironment('FF_CHAT',         defaultValue: false);
  static const bool aiAssistant  = bool.fromEnvironment('FF_AI_ASSISTANT', defaultValue: false);
  static const bool community    = bool.fromEnvironment('FF_COMMUNITY',    defaultValue: false);
  static const bool nutrition    = bool.fromEnvironment('FF_NUTRITION',    defaultValue: false);
  static const bool notifications = bool.fromEnvironment('FF_NOTIFICATIONS', defaultValue: false);
  static const bool subscriptions = bool.fromEnvironment('FF_SUBSCRIPTIONS', defaultValue: false);
}
```

Run with backend enabled per domain:
```bash
flutter run --dart-define=FF_AUTH=true --dart-define=FF_ARTICLES=true
```

Run fully static (default, no flags needed):
```bash
flutter run
```

### 2b) Repository pattern (`lib/core/repositories/`)

Each feature defines an **abstract repository interface**. The `main.dart` `MultiProvider` injects the real or mock implementation based on the feature flag. Tests always inject a mock.

```text
lib/core/repositories/
  i_article_repository.dart         ← abstract interface
  i_medication_repository.dart
  ...

lib/features/articles/repositories/
  remote_article_repository.dart    ← implements IArticleRepository, calls ApiClient
  mock_article_repository.dart      ← implements IArticleRepository, returns static seeds

lib/features/articles/providers/
  article_provider.dart             ← ChangeNotifier; depends only on IArticleRepository
```

Injection in `main.dart`:
```dart
Provider<IArticleRepository>(
  create: (_) => FeatureFlags.articles
      ? RemoteArticleRepository(apiClient)
      : MockArticleRepository(),
),
```

In tests:
```dart
Provider<IArticleRepository>(create: (_) => MockArticleRepository()),
```

### 2c) Mock repositories

Mock implementations return the **existing hardcoded static data** that currently lives in screens and models. This means:
- All existing UI behaviour is preserved when flags are `false`.
- Each mock is also the test double used in `flutter test`.
- When a real backend response differs from static data, update the mock to match the real shape so tests stay green.

### 2d) Static data preservation rule

**Do not delete or move any hardcoded seed list, `_kSampleX` constant, or `InMemoryXProvider` when adding backend integration.** Move them into the corresponding `MockXRepository` instead. The mock then owns the static data, and the UI never sees the difference.

---

## 3) Planned branches (in recommended order)

### Integration Branch 1 — Network layer + repository infrastructure (foundational)
- **Branch**: `feat/api-network-layer`
- **Type**: A (infrastructure)
- **Goal**: Introduce the HTTP client, base API configuration, auth interceptors, shared error types, feature flags, and the abstract repository pattern that all subsequent branches build on. Zero UI changes.
- **Scope**:
  - Add to `pubspec.yaml`:
    - `dio: ^5.x`
    - `flutter_secure_storage: ^9.x`
  - Create `lib/core/network/`:
    - `api_client.dart` — singleton `Dio`; base URL `http://<host>:9000`; from `AppEnv`; connect/receive timeouts; unwraps the standard `{ success, data, error }` envelope.
    - `api_interceptors.dart` — injects `Authorization: Bearer <token>` header; on 401: calls `POST /api/v1/auth/token/refresh/` once, retries original request; on second 401: clears tokens, emits auth-expired event.
    - `api_error.dart` — `ApiException` sealed class: `NetworkError`, `ServerError(statusCode, code, message)`, `AuthExpired`, `UnknownError`.
    - `api_constants.dart` — path constants (`kAuthBase = '/api/v1/auth'`, `kProfileBase = '/api/v1/profile'`, etc.).
  - Create `lib/core/env/`:
    - `app_env.dart` — `AppEnvironment` enum (dev/prod) + `static String baseUrl` from `--dart-define=APP_ENV`; dev default `http://10.0.2.2:9000`.
  - Create `lib/core/flags/feature_flags.dart` — all per-domain flags as described in §2a.
  - Create `lib/core/repositories/` — one abstract interface file per feature domain (empty `abstract class IXRepository {}` stubs, to be filled per branch).
  - Create `lib/core/di/` (or extend `main.dart`):
    - `repository_locator.dart` — builds the `MultiProvider` list of `Provider<IXRepository>` based on flags; injected at app root.
- **Acceptance criteria**:
  - `flutter analyze` clean; `flutter test` passes.
  - `ApiClient` smoke-test: GET `http://10.0.2.2:9000/health/` returns 200 (manual check).
  - `flutter run` with no `--dart-define` flags: app behaves identically to current (all flags `false`).
  - `flutter run --dart-define=FF_AUTH=true`: app still launches (no crash even though auth branch not yet done).
- **Backlog update**:
  - Record: `dio` version, `flutter_secure_storage` version, `APP_ENV` default, token storage key names, envelope unwrap strategy.

---

### Integration Branch 2 — Authentication
- **Branch**: `feat/api-auth`
- **Type**: A+B
- **Goal**: Wire signup, email activation, login, token refresh, and logout to the backend auth endpoints. Gate app entry on real auth state. `FeatureFlags.auth = true` by default after this branch merges.
- **Scope**:
  - Fill `IAuthRepository` interface: `register`, `activate`, `login`, `refreshToken`, `logout`, `guestLogin`, `getMe`, `updateMe`, `currentUserId`.
  - Create `lib/core/auth/`:
    - `remote_auth_repository.dart` — calls:
      - `POST /api/v1/auth/register/` `{email, first_name, last_name, password, password2}`
      - `POST /api/v1/auth/activate/` `{token}` → returns JWT tokens
      - `POST /api/v1/auth/login/` `{email, password}` → returns JWT tokens + user
      - `POST /api/v1/auth/token/refresh/` `{refresh}` (also used by interceptor)
      - `POST /api/v1/auth/logout/` `{refresh}`
      - `POST /api/v1/auth/guest/` → limited-access session
      - `GET /api/v1/auth/me/` → current user object
      - `PATCH /api/v1/auth/me/` → update user fields
    - `mock_auth_repository.dart` — returns a hardcoded demo user; always "authenticated".
    - `auth_state.dart` (`ChangeNotifier`) — `AuthStatus` (`unknown`, `authenticated`, `unauthenticated`); `initialize()` on app start reads stored token and validates.
    - `secure_token_store.dart` — wraps `flutter_secure_storage`; get/set/clear access + refresh tokens + userId.
  - Add email activation screen (`lib/features/auth/activation_screen.dart`): input field for the token from the email link; calls `activate(token)`.
  - Update `main.dart`: add `AuthState` to `MultiProvider`; `AuthState.initialize()` runs at startup; result routes to `HomePageScreen` (authenticated) or login (unauthenticated). Retire `kEnableOnboardingFlow` when `FeatureFlags.auth = true`; document in `BACKLOG.md`.
  - Update `SignupAndLoginScreen`: wire login form to `IAuthRepository.login`; register form to `IAuthRepository.register` → navigate to activation screen.
  - Update `SettingsScreen` logout: call `IAuthRepository.logout()`, clear tokens, navigate to login.
- **Acceptance criteria**:
  - `FF_AUTH=false` → app behaves as today (mock always authenticated; skips login).
  - `FF_AUTH=true`:
    - Register → activation email sent; activation screen accepts token → navigates to Home.
    - Login with real credentials → JWT stored → Home.
    - Invalid credentials → error snackbar, no crash.
    - App restart with valid stored token → goes directly to Home.
    - Expired token → interceptor refreshes silently; if refresh fails → Login screen.
    - Logout → tokens cleared → Login screen.
  - `flutter analyze` clean; `flutter test` passes.
- **Backlog update**:
  - Record: token key names, `currentUserId` storage key, `kEnableOnboardingFlow` retirement decision.

---

### Integration Branch 3 — User profile sync
- **Branch**: `feat/api-user-profile`
- **Type**: A+B
- **Goal**: Replace `kDemoUserProfile` with real data from the backend. Profile screen shows real user info after login.
- **Scope**:
  - Fill `IProfileRepository` interface: `fetchMe`, `updateMe`, `fetchPublicProfile`, `updatePublicProfile`.
  - `RemoteProfileRepository`:
    - `GET /api/v1/auth/me/` → user fields (`first_name`, `last_name`, `email`, `weight_kg`, `height_cm`, etc.)
    - `PATCH /api/v1/auth/me/` → update user fields
    - `GET /api/v1/profile/me/` → `about_me`, `is_visible_in_community`
    - `PATCH /api/v1/profile/me/` → update public profile
  - `MockProfileRepository` → wraps existing `kDemoUserProfile` static data.
  - Create/extend `ProfileProvider` (`ChangeNotifier`): loads profile on auth; exposes `UserProfile`; `save()` calls `updateMe`; handles loading/error.
  - Update `ProfileScreen` and `PersonalInformationScreen` to read from/write to `ProfileProvider`.
  - Add `ProfileProvider` to `MultiProvider`; initialized after `AuthState` is authenticated.
- **Feature flag**: `FF_PROFILE`
- **Acceptance criteria**:
  - `FF_PROFILE=false` → `kDemoUserProfile` shown (current behaviour).
  - `FF_PROFILE=true` → real name and email from backend shown; edit and save persists.
  - `flutter analyze` clean; `flutter test` passes.
- **Backlog update**:
  - Record: DTO field mapping (`weight_kg` vs `weight`, etc.), any field name mismatches.

---

### Integration Branch 13 — Articles feed
- **Branch**: `feat/api-articles`
- **Type**: A+B
- **Goal**: Replace hardcoded article seeds with live articles. Wire likes, bookmarks, and comments to the backend.
- **Scope**:
  - Fill `IArticleRepository`.
  - `RemoteArticleRepository`:
    - `GET /api/v1/articles/` → paginated public feed (`?search=`, `?categories__slug=`)
    - `GET /api/v1/articles/<id>/` → full article detail
    - `GET /api/v1/articles/recommended/` → personalised feed (auth required)
    - `GET /api/v1/articles/bookmarks/` → saved articles
    - `POST /api/v1/articles/<id>/like/` → toggles like
    - `POST /api/v1/articles/<id>/bookmark/` → toggles bookmark
    - `GET /api/v1/articles/<id>/comments/` → comment list
    - `POST /api/v1/articles/<id>/comments/` `{text, parent?}` → post comment
  - `MockArticleRepository` → wraps existing seed `ArticleFeedItem` list.
  - Update `ArticleScreen`, `ArticleDetailScreen`, `ArticleCommentScreen` to use `IArticleRepository` via provider.
  - Show loading, empty, and error states on all three screens.
  - Add pagination ("load more") to the article list.
- **Feature flag**: `FF_ARTICLES`
- **Acceptance criteria**:
  - `FF_ARTICLES=false` → static seeds (current behaviour); all article screens still work.
  - `FF_ARTICLES=true` → real articles from backend; like/bookmark/comment persist (verify in backend admin).
  - `flutter analyze` clean; `flutter test` passes (mock test for all repository methods).
- **Backlog update**:
  - Record: pagination strategy, image URL format (absolute vs relative), article `source` field usage.

---

### Integration Branch 4 — Medications
- **Branch**: `feat/api-medications`
- **Type**: A+B
- **Goal**: Replace local medication list with backend-persisted data. Add reminder scheduling and dose logging.
- **Scope**:
  - Fill `IMedicationRepository`.
  - `RemoteMedicationRepository`:
    - `GET /api/v1/medications/` → list (`?active=true`)
    - `POST /api/v1/medications/` `{medication_name, dosage_amount, dosage_unit, doses_per_day, ...}`
    - `PATCH /api/v1/medications/<id>/` → update
    - `DELETE /api/v1/medications/<id>/` → deactivate
    - `GET /api/v1/medications/<id>/reminders/` → list reminders
    - `POST /api/v1/medications/<id>/reminders/` `{reminder_time, days_of_week}` → add reminder
    - `PATCH /api/v1/medications/<id>/reminders/<rid>/` → update reminder
    - `DELETE /api/v1/medications/<id>/reminders/<rid>/` → remove
    - `GET /api/v1/medications/<id>/doses/` → dose history
    - `POST /api/v1/medications/<id>/doses/` `{status, scheduled_at, taken_at?}` → log dose
  - `MockMedicationRepository` → wraps existing medication seed data.
  - Update `MedicationScreen` and add/edit form to use `IMedicationRepository`.
  - Wire `MedicationRemindersScreen` to reminder endpoints (currently a stub).
  - Wire `MedicationHistoryScreen` to dose log endpoint (currently a stub).
  - `dosage_unit` values from backend: `mg|mcg|ml|g|iu|tabs|caps|drops` — update the Flutter unit dropdown to match exactly.
- **Feature flag**: `FF_MEDICATIONS`
- **Acceptance criteria**:
  - `FF_MEDICATIONS=false` → stub/seed data (current behaviour).
  - `FF_MEDICATIONS=true` → CRUD persists; reminders and dose history load from backend.
  - `flutter analyze` clean; `flutter test` passes.
- **Backlog update**:
  - Record: dosage unit string mapping, `days_of_week` array convention (0=Monday).

---

### Integration Branch 6 — AI Health Assessment
- **Branch**: `feat/api-assessment`
- **Type**: A+B
- **Goal**: Replace the in-memory assessment history with the AI-powered backend assessment. Assessment results now come from the backend's AI model (4–5 possible causes with urgency levels).
- **Scope**:
  - Fill `IAssessmentRepository`.
  - `RemoteAssessmentRepository`:
    - `POST /api/v1/assessments/` `{symptoms, severity, for_whom?, blood_type?, allergies?, ...}` → AI result with `possible_causes`, `general_advice`, `seek_emergency_care`
    - `GET /api/v1/assessments/` → past assessments list
    - `GET /api/v1/assessments/<uuid>/` → single assessment + result
    - `POST /api/v1/assessments/guest/` → no auth, result not saved
  - `MockAssessmentRepository` → wraps existing `InMemoryAssessmentHistory` static data; `runAssessment()` returns a hardcoded mock result shape.
  - Update `AssessmentHistoryScreen` to load from repository; add pull-to-refresh.
  - Update `SummaryScreen` to display the new `possible_causes` result shape (ranked causes, urgency, recommended next steps).
  - **`seek_emergency_care = true`** → show an urgent alert/modal and surface the emergency contact (coordinate with contacts branch).
  - Retain `InMemoryAssessmentHistory` as the cache layer for the authenticated flow; `RemoteAssessmentRepository` populates it on fetch and appends on new run.
  - Per 2026-04-18 `BACKLOG.md` decision: in-memory layer stays as client-side cache — do not delete.
- **Feature flag**: `FF_ASSESSMENT`
- **Acceptance criteria**:
  - `FF_ASSESSMENT=false` → in-memory flow unchanged.
  - `FF_ASSESSMENT=true` → assessment POSTs to backend; result shows AI causes; history loads from backend; pull-to-refresh works.
  - `seek_emergency_care = true` case shows alert (test with mock returning `seek_emergency_care: true`).
  - `flutter analyze` clean; `flutter test` passes.
- **Backlog update**:
  - Record: `possible_causes` result shape, how `seek_emergency_care` alert is surfaced, guest assessment flow.

---

### Integration Branch 9 — Emergency contacts & personal doctors
- **Branch**: `feat/api-contacts`
- **Type**: A+B
- **Goal**: Sync emergency contacts and personal doctor entries to the backend instead of keeping them in-memory per session.
- **Scope**:
  - Fill `IContactsRepository`.
  - `RemoteContactsRepository`:
    - `GET /api/v1/profile/emergency-contacts/` → list
    - `POST /api/v1/profile/emergency-contacts/` `{first_name, last_name, relationship, phone, email?}`
    - `PATCH /api/v1/profile/emergency-contacts/<id>/` → update
    - `DELETE /api/v1/profile/emergency-contacts/<id>/` → remove
    - `GET /api/v1/profile/doctors/` → list
    - `POST /api/v1/profile/doctors/` `{first_name, last_name, specialization, email?, report_frequency?}`
    - `PATCH /api/v1/profile/doctors/<id>/` → update
    - `DELETE /api/v1/profile/doctors/<id>/` → remove
  - `MockContactsRepository` → wraps existing in-memory `EmergencyContactEntry` / `PersonalDoctorEntry` lists.
  - Map backend relationship strings to Flutter display labels; map `specialization` / `report_frequency` enums.
  - `report_frequency` values from backend: `W` (Weekly) | `BW` (Bi-weekly) | `M` (Monthly) | `N` (Never) — update the Flutter dropdown to match.
  - Update `EmergencyContactPersonalInformation` and `PersonalDoctorPersonalInformation` screens to use `IContactsRepository`.
- **Feature flag**: `FF_CONTACTS`
- **Acceptance criteria**:
  - `FF_CONTACTS=false` → in-memory behaviour unchanged.
  - `FF_CONTACTS=true` → contacts and doctors persist across restarts; delete removes from backend.
  - `flutter analyze` clean; `flutter test` passes.
- **Backlog update**:
  - Record: `relationship` enum mapping, `specialization` codes (e.g. `CA`), max-3 contacts enforcement.

---

### Integration Branch 5 — Health tracking (symptoms, vitals, goals, dashboard)
- **Branch**: `feat/api-health-data`
- **Type**: A+B
- **Goal**: Wire symptom logging, vital signs, health goals, dashboard stats, and AI-generated health summaries to the backend. These are entirely new features on the Flutter side (currently stub/empty).
- **Scope**:
  - Fill `IHealthRepository`.
  - `RemoteHealthRepository`:
    - `GET /api/v1/health/symptoms/` `?date_from=&severity=&body_location=`
    - `POST /api/v1/health/symptoms/` `{symptom_name, severity(1-10), description?, body_location?, ...}`
    - `DELETE /api/v1/health/symptoms/<id>/`
    - `GET /api/v1/health/vitals/` `?date_from=&date_to=`
    - `POST /api/v1/health/vitals/` `{systolic_bp?, diastolic_bp?, heart_rate?, temperature_c?, oxygen_saturation?, blood_glucose?, weight_kg?, steps?, ...}`
    - `GET /api/v1/health/dashboard/` → 7-day stats, symptom averages, vital averages, top symptoms, goals
    - `GET /api/v1/health/summaries/` → AI-generated health summary list
    - `GET /api/v1/health/summaries/latest/` → latest summary
    - `GET /api/v1/health/goals/` → active goals
    - `POST /api/v1/health/goals/` `{goal_type, target_value, unit?}` → create goal
    - `PATCH /api/v1/health/goals/<id>/` → update
    - `DELETE /api/v1/health/goals/<id>/` → deactivate
  - `MockHealthRepository` → wraps static symptom/vital seed data (create any needed seeds).
  - Update health tracking screens (symptom list, add-symptom flow, severity slider) to use `IHealthRepository`.
  - Wire vitals entry form (currently stub) to `POST /api/v1/health/vitals/`.
  - Wire health goals list to `IHealthRepository.fetchGoals`.
  - Display dashboard data on the Health tab (or a dedicated dashboard widget).
  - `goal_type` values: `sleep|steps|water|weight|calories|blood_sugar|blood_pressure|custom`.
- **Feature flag**: `FF_HEALTH_DATA`
- **Acceptance criteria**:
  - `FF_HEALTH_DATA=false` → static/stub behaviour unchanged.
  - `FF_HEALTH_DATA=true` → symptoms, vitals, and goals persist; dashboard shows real 7-day stats; AI summary displays.
  - `flutter analyze` clean; `flutter test` passes.
- **Backlog update**:
  - Record: severity 1–10 mapping to UI severity control, vital fields logged in the first pass, dashboard widget placement decision.

---

### Integration Branch 10 — Real-time chat
- **Branch**: `feat/api-chat`
- **Type**: A+B
- **Goal**: Replace stub/seed chat data with real private and group chats. Wire WebSocket for real-time delivery.
- **Scope**:
  - Add to `pubspec.yaml`: `web_socket_channel: ^3.x`
  - Fill `IChatRepository`.
  - `RemoteChatRepository`:
    - `GET /api/v1/chat/private/` → my private chats
    - `POST /api/v1/chat/private/` `{user_id}` → start or retrieve chat
    - `GET /api/v1/chat/private/<id>/messages/` → message history
    - `GET /api/v1/chat/groups/` → my group chats
    - `POST /api/v1/chat/groups/` `{name, description?}` → create group
    - `POST /api/v1/chat/groups/<id>/join/`
    - `POST /api/v1/chat/groups/<id>/leave/`
    - `GET /api/v1/chat/groups/<id>/messages/` → group message history
  - `RemoteChatWebSocketService`:
    - Private: `ws://<host>/ws/chat/private/<id>/?token=<jwt>` → send `{"content": "..."}`.
    - Group: `ws://<host>/ws/chat/group/<id>/?token=<jwt>`.
    - Expose incoming messages as `Stream<ChatMessage>`; reconnect with exponential backoff.
  - `MockChatRepository` → wraps existing `sampleChatUsers`, seed message lists, seed group data.
  - Update `GeneralChatScreen`: load real chat list; handle loading/empty states.
  - Update `ChatScreen`: load message history from REST on open; subscribe to WS stream; send via REST `POST` (document choice in `BACKLOG.md`).
  - Replace all hardcoded seed users/messages.
- **Feature flag**: `FF_CHAT`
- **Out of scope**: Voice/video call integration (separate external service).
- **Acceptance criteria**:
  - `FF_CHAT=false` → seed data behaviour unchanged.
  - `FF_CHAT=true` → chat list shows real conversations; messages sent in session A appear in session B via WS.
  - `flutter analyze` clean; `flutter test` passes (mock WS stream in tests).
- **Backlog update**:
  - Record: send-via-REST-vs-WS decision, WS message schema, reconnection strategy.

---

### Integration Branch 7 — AI Assistant (HealthBot)
- **Branch**: `feat/api-chatbot`
- **Type**: A+B
- **Goal**: Replace stub bot replies with the real AI assistant backend endpoint.
- **Scope**:
  - Fill `IAiAssistantRepository`.
  - `RemoteAiAssistantRepository`:
    - `POST /api/v1/chat/ai/` `{message}` (max 2000 chars) → AI reply
    - `GET /api/v1/chat/ai/history/` → conversation history
    - `DELETE /api/v1/chat/ai/history/` → clear conversation
  - `MockAiAssistantRepository` → existing stub "thinking…" → static reply pattern.
  - Update `ChatbotScreen`:
    - Each user message → `sendMessage`; append AI reply from response.
    - "Clear chat" → `clearHistory()` on repository; reset message list.
    - Typing indicator shows while awaiting response (already stubbed; wire to real async wait).
    - Load history on screen open (last N messages).
  - Persist nothing on Flutter side for conversation — backend owns the history.
- **Feature flag**: `FF_AI_ASSISTANT`
- **Acceptance criteria**:
  - `FF_AI_ASSISTANT=false` → stub reply behaviour unchanged.
  - `FF_AI_ASSISTANT=true` → real AI replies; clear works; history loads on reopen.
  - `flutter analyze` clean; `flutter test` passes.
- **Backlog update**:
  - Record: error handling for `503 service_unavailable` (AI service down), max message length enforcement.

---

### Integration Branch 12 — Community / Peers
- **Branch**: `feat/api-community`
- **Type**: A+B
- **Goal**: Wire the "similar people" / peer discovery, connection requests, and community groups to the backend. Replace the stub `SimilarPeopleScreen` actions.
- **Scope**:
  - Fill `ICommunityRepository`.
  - `RemoteCommunityRepository`:
    - `GET /api/v1/community/peers/suggested/` → matched peers (scored by shared conditions)
    - `POST /api/v1/community/peers/connect/` `{receiver, match_reason?}` → send connection request
    - `PATCH /api/v1/community/peers/<id>/` `{status: accepted|declined|blocked}` → respond
    - `GET /api/v1/community/peers/connections/` → accepted connections
    - `GET /api/v1/community/groups/` → all community groups
    - `POST /api/v1/community/groups/` `{name, slug, description?, condition_tags?}`
    - `GET /api/v1/community/groups/<id>/`
    - `POST /api/v1/community/groups/<id>/join/`
    - `POST /api/v1/community/groups/<id>/leave/`
  - `MockCommunityRepository` → wraps existing `SimilarPeopleScreen` seed user cards.
  - Note: `PATCH /api/v1/community/peers/<id>/` with `status: accepted` **auto-creates a private chat** on the backend — wire `ChatScreen` open after accepted (coordinate with Branch 9).
  - Update `SimilarPeopleScreen`: "Vote to connect" → `sendConnectionRequest`; "Pass" → `decline`; snackbar on response.
  - Add connection list screen or integrate into chat inbox.
- **Feature flag**: `FF_COMMUNITY`
- **Acceptance criteria**:
  - `FF_COMMUNITY=false` → stub peer cards unchanged.
  - `FF_COMMUNITY=true` → suggested peers from backend; connect/decline persists; accepting a request opens the auto-created chat.
  - `flutter analyze` clean; `flutter test` passes.
- **Backlog update**:
  - Record: peer matching algorithm inputs (shared conditions), auto-chat-on-accept coordination with chat branch.

---

### Integration Branch 11 — Nutrition tracking
- **Branch**: `feat/api-nutrition`
- **Type**: A+B
- **Goal**: Replace `SharedPreferences`-backed food tracking with the backend nutrition API. Connect food search, meal logging, nutrition goals, and daily summary.
- **Scope**:
  - Fill `INutritionRepository`.
  - `RemoteNutritionRepository`:
    - `GET /api/v1/nutrition/search/` `?q=banana` → food search results
    - `GET /api/v1/nutrition/meals/` `?date=YYYY-MM-DD` → meal logs for a day
    - `POST /api/v1/nutrition/meals/` `{meal_type, entries: [{food_name, quantity_g, calories, protein_g, carbs_g, fat_g}], notes?, logged_at?}`
    - `GET /api/v1/nutrition/goals/` → daily macro goals
    - `PATCH /api/v1/nutrition/goals/` `{daily_calories, daily_protein_g, daily_carbs_g, daily_fat_g}`
    - `GET /api/v1/nutrition/summary/` `?date=YYYY-MM-DD` → daily totals vs goals
  - `MockNutritionRepository` → wraps existing `FoodDayLog` / `FoodMealEntry` `SharedPreferences` data (or in-memory seed).
  - Update `FoodNutritionTrackingScreen` (setup/settings) to use `INutritionRepository.updateGoals`.
  - Update `FoodNutritionHistoryScreen` to load from `fetchMeals` grouped by day.
  - Add food search UI (search bar → `searchFood` → select to add to meal entry).
  - Keep local `SharedPreferences` prefs (frequency, push toggle, diet chips) unchanged — those are app-level preferences, not backend data. Only the **meal history** and **nutrition goals** move to the backend.
  - `meal_type` values: `breakfast|lunch|dinner|snack`.
- **Feature flag**: `FF_NUTRITION`
- **Acceptance criteria**:
  - `FF_NUTRITION=false` → `SharedPreferences`-backed behaviour unchanged.
  - `FF_NUTRITION=true` → meal logs load from backend; nutrition goals persist; daily summary shows real totals.
  - `flutter analyze` clean; `flutter test` passes.
- **Backlog update**:
  - Record: which nutrition prefs stay in `SharedPreferences` vs backend, food search result shape, macro field names.

---

### Integration Branch 8 — Notifications
- **Branch**: `feat/api-notifications`
- **Type**: A+B
- **Goal**: Register the device for push notifications and wire the in-app notification list to the backend.
- **Scope**:
  - Fill `INotificationRepository`.
  - `RemoteNotificationRepository`:
    - `POST /api/v1/notifications/device/register/` `{token, platform: android|ios}` → register FCM token
    - `GET /api/v1/notifications/` → all notifications
    - `GET /api/v1/notifications/unread-count/` → badge count
    - `POST /api/v1/notifications/read/` `{ids?}` → mark as read (omit `ids` = mark all)
  - `MockNotificationRepository` → returns empty notification list (no static seeds needed).
  - Add `firebase_messaging` (or `flutter_local_notifications`) to `pubspec.yaml` for device token retrieval.
  - On app start (after auth): call `registerDevice(fcmToken, platform)`.
  - Add notification list screen (or badge on home tab) using `fetchNotifications`.
  - Mark as read on open; show unread badge count from `fetchUnreadCount`.
- **Feature flag**: `FF_NOTIFICATIONS`
- **Out of scope**: Custom push notification payload rendering, deep-link routing from notifications (follow-up work).
- **Acceptance criteria**:
  - `FF_NOTIFICATIONS=false` → no notification UI shown (or empty); no crash.
  - `FF_NOTIFICATIONS=true` → device registered; in-app notification list loads; unread count visible; mark-read works.
  - `flutter analyze` clean; `flutter test` passes.
- **Backlog update**:
  - Record: FCM setup steps (google-services.json, etc.), platform token retrieval approach.

---

### Integration Branch 14 — Subscriptions / Payment
- **Branch**: `feat/api-payment`
- **Type**: A+B
- **Coordinate with**: `refactor/subscription-feature` (Branch D in `FEATURE_BRANCH_PLAN.md`) — run after Branch D merges, or ensure no conflicts on `SubscriptionAndPaymentScreen`.
- **Goal**: Wire the payment flow to the backend two-step payment (create → confirm). Update subscription status in the app after confirmation.
- **Scope**:
  - Fill `ISubscriptionRepository`.
  - `RemoteSubscriptionRepository`:
    - `GET /api/v1/subscriptions/status/` → `{plan, expiry, days_remaining}`
    - `POST /api/v1/subscriptions/payment/` `{amount, payment_method, currency, months?}` → creates pending payment
    - `POST /api/v1/subscriptions/payment/confirm/` `{payment_id}` → activates premium
    - `GET /api/v1/subscriptions/payment/history/` → payment records
  - `MockSubscriptionRepository` → returns free-tier status; `processPayment` always succeeds.
  - Two-step payment flow: create → show confirmation screen → confirm → premium active.
  - After confirmation: re-fetch subscription status → notify `ProfileProvider`; premium-gated surfaces react.
  - `payment_method` values: `bank|paypal|card|stripe` — update Flutter payment method selector to match.
  - Update premium-gated UI to check real subscription status from `ISubscriptionRepository.fetchStatus` instead of any hardcoded flag.
- **Feature flag**: `FF_SUBSCRIPTIONS`
- **Acceptance criteria**:
  - `FF_SUBSCRIPTIONS=false` → mock always-free or mock always-premium (document which in `BACKLOG.md`).
  - `FF_SUBSCRIPTIONS=true` → create + confirm flow activates premium; status shown correctly; history loads.
  - `flutter analyze` clean; `flutter test` passes.
- **Backlog update**:
  - Record: payment method string mapping, two-step create/confirm UX flow, premium gate check pattern.

---

## 4) Notes / constraints

- **Static data is never deleted**: every hardcoded seed list, `_kSample` constant, and in-memory provider is moved into the corresponding `MockXRepository`. The UI always talks to the interface; the flag decides the implementation.
- **Implement against the API reference docs**: treat the Postman collection and `HealthPilot API Reference` text as ground truth. If a real response differs, update the mock to match the real shape and document the delta in `BACKLOG.md`.
- **Auth is the keystone**: Branches 3–13 require a valid auth token. Do not toggle `FF_PROFILE` etc. to `true` until `FF_AUTH=true` is working end-to-end.
- **No new premium gating in Branches 1–13**: premium-locked UI is owned by Branch D + Branch 14.
- **Feature-owned repositories**: each domain owns its own `lib/features/<domain>/repositories/` sub-folder. No monolithic service file.
- **Error UX minimum**: every API-backed screen must handle loading, empty, and error states. Silent failure is not acceptable.
- **Test isolation**: `flutter test` must always pass with all flags `false` (mock mode). Backend availability is never a dependency for the test suite.
- **Parallelism window**: Branches 3–13 can run in parallel once Branch 2 is merged (each owns a distinct domain). Branch 14 must wait for Branch D.
- **Response envelope**: all backend responses wrap data in `{ "success": bool, "data": {...} }`. The `ApiClient` / interceptor layer should unwrap this before returning to repositories so repositories only deal with the inner `data` object.
- **Dev base URL**: Android emulator → `http://10.0.2.2:9000`; iOS simulator → `http://localhost:9000`. Set via `--dart-define=APP_BASE_URL=http://...`.
