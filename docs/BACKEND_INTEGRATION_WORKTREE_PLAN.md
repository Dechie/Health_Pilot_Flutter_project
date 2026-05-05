# Backend integration: stacked PRs + git worktrees

This document is the **operational companion** to `docs/BACKEND_INTEGRATION_PLAN.md`: it maps branches to PR bases, provides worktree commands, and lists common mistakes.

**For the full roadmap, scope, acceptance criteria, and the data-source flag / mock-repository architecture, see `docs/BACKEND_INTEGRATION_PLAN.md`.**

**App code root:** `healthpilot/` (Flutter package). **Docs / git root:** repo root.

---

## 1) Mental model: infrastructure first, features upward

```text
main
 └── feat/api-network-layer           (Branch 1 — Dio, interceptors, FeatureFlags, IRepository interfaces, MockRepositories)
      └── feat/api-auth                (Branch 2 — JWT auth, AuthState, email activation, mock-always-authenticated)
           ├── feat/api-user-profile    (Branch 3)
           ├── feat/api-articles        (Branch 4)
           ├── feat/api-medications     (Branch 5)
           ├── feat/api-assessment      (Branch 6)
           ├── feat/api-contacts        (Branch 7)
           ├── feat/api-health-data     (Branch 8)
           ├── feat/api-chat            (Branch 9)
           ├── feat/api-chatbot         (Branch 10)
           ├── feat/api-community       (Branch 11)
           ├── feat/api-nutrition       (Branch 12)
           └── feat/api-notifications   (Branch 13)
                (after refactor/subscription-feature / Branch D merges)
                └── feat/api-payment    (Branch 14)
```

- **Branches 1 and 2** are strictly sequential — prerequisites for everything else.
- **Branches 3–13** can be worked in **parallel** once Branch 2 is merged: each owns a distinct feature domain with no shared files.
- **Branch 14** must wait for `refactor/subscription-feature` (Branch D, `FEATURE_BRANCH_PLAN.md`) to merge first.

---

## 2) Optional: folder layout with worktrees

```text
Health_Pilot_Flutter_project/     ← primary repo (e.g. working on feat/api-auth)
../wt-api-profile/                ← worktree: feat/api-user-profile
../wt-api-articles/               ← worktree: feat/api-articles
../wt-api-medications/            ← worktree: feat/api-medications
../wt-api-assessment/             ← worktree: feat/api-assessment
../wt-api-health/                 ← worktree: feat/api-health-data
../wt-api-chat/                   ← worktree: feat/api-chat
```

Only spin up as many worktrees as actively needed. Each requires its own `flutter pub get`.

---

## 3) Commands cheat sheet

### Start Branch 1 from `main`

```bash
git fetch origin
git checkout main
git pull origin main
git checkout -b feat/api-network-layer
cd healthpilot && flutter pub get
```

### Stack Branch 2 on Branch 1 (before Branch 1 merges)

```bash
# from repo root, checked out on feat/api-network-layer
git worktree add -b feat/api-auth ../wt-api-auth
cd ../wt-api-auth/healthpilot && flutter pub get
```

### After Branch 1 merges: rebase Branch 2 onto `main`

```bash
git fetch origin
git checkout feat/api-auth
git rebase origin/main
git push --force-with-lease origin feat/api-auth
```

### Spin up parallel feature branches (after Branch 2 merges)

```bash
git fetch origin && git checkout main && git pull origin main

# primary repo: one branch
git checkout -b feat/api-user-profile

# parallel worktrees
git worktree add -b feat/api-articles     ../wt-api-articles
git worktree add -b feat/api-medications  ../wt-api-medications
git worktree add -b feat/api-assessment   ../wt-api-assessment
git worktree add -b feat/api-health-data  ../wt-api-health
```

Run `flutter pub get` inside `<worktree>/healthpilot/` before editing.

### Run with a feature flag enabled

```bash
# from healthpilot/
flutter run --dart-define=FF_ARTICLES=true --dart-define=APP_BASE_URL=http://10.0.2.2:9000
```

### Run fully static (all flags off — default)

```bash
flutter run
```

### List all active worktrees

```bash
git worktree list
```

### Remove a worktree after merge

```bash
git worktree remove ../wt-api-articles
git branch -d feat/api-articles
git worktree prune
```

### Sync a retained branch with `main` (Option A — merge, no force-push)

```bash
git checkout feat/api-articles
git fetch origin
git merge origin/main
git push origin feat/api-articles
```

---

## 4) Plan mapped to branches + suggested PR bases

Branches 3–13 may be opened **simultaneously** with `main` as the base once Branch 2 has merged.

| Step | Branch | Suggested PR base | One-line intent |
|------|--------|-------------------|-----------------|
| 1 | `feat/api-network-layer` | `main` | Dio, interceptors, FeatureFlags, abstract IRepository interfaces, MockRepositories, AppEnv |
| 2 | `feat/api-auth` | `feat/api-network-layer` (or `main` after 1 merges) | JWT login/register/email-activation, AuthState, guest login, mock-always-auth |
| 3 | `feat/api-user-profile` | `feat/api-auth` (or `main`) | Profile + public profile fetch/update via `/api/v1/auth/me/` + `/api/v1/profile/me/` |
| 4 | `feat/api-articles` | `feat/api-auth` (or `main`) | Article feed, likes, bookmarks, comments — `/api/v1/articles/` |
| 5 | `feat/api-medications` | `feat/api-auth` (or `main`) | Medication CRUD + reminders + dose log — `/api/v1/medications/` |
| 6 | `feat/api-assessment` | `feat/api-auth` (or `main`) | AI assessment POST + history — `/api/v1/assessments/` |
| 7 | `feat/api-contacts` | `feat/api-auth` (or `main`) | Emergency contacts + doctors — `/api/v1/profile/emergency-contacts/` + `/api/v1/profile/doctors/` |
| 8 | `feat/api-health-data` | `feat/api-auth` (or `main`) | Symptoms, vitals, goals, dashboard — `/api/v1/health/` |
| 9 | `feat/api-chat` | `feat/api-auth` (or `main`) | Private + group chat (REST + WebSocket) — `/api/v1/chat/private/` + WS |
| 10 | `feat/api-chatbot` | `feat/api-auth` (or `main`) | AI assistant send/history/clear — `/api/v1/chat/ai/` |
| 11 | `feat/api-community` | `feat/api-auth` (or `main`) | Peer discovery, connections, community groups — `/api/v1/community/` |
| 12 | `feat/api-nutrition` | `feat/api-auth` (or `main`) | Meal logging, food search, nutrition goals — `/api/v1/nutrition/` |
| 13 | `feat/api-notifications` | `feat/api-auth` (or `main`) | Device registration, notification list, mark-read — `/api/v1/notifications/` |
| 14 | `feat/api-payment` | `main` **after** `refactor/subscription-feature` (Branch D) | Two-step payment + subscription status — `/api/v1/subscriptions/` |

---

## 5) Feature flag quick reference

Each branch is controlled by a `--dart-define` flag. Default is `false` (mock/static mode).

| Branch | Flag | Default |
|--------|------|---------|
| 2 — Auth | `FF_AUTH` | `false` |
| 3 — Profile | `FF_PROFILE` | `false` |
| 4 — Articles | `FF_ARTICLES` | `false` |
| 5 — Medications | `FF_MEDICATIONS` | `false` |
| 6 — Assessment | `FF_ASSESSMENT` | `false` |
| 7 — Contacts | `FF_CONTACTS` | `false` |
| 8 — Health data | `FF_HEALTH_DATA` | `false` |
| 9 — Chat | `FF_CHAT` | `false` |
| 10 — AI assistant | `FF_AI_ASSISTANT` | `false` |
| 11 — Community | `FF_COMMUNITY` | `false` |
| 12 — Nutrition | `FF_NUTRITION` | `false` |
| 13 — Notifications | `FF_NOTIFICATIONS` | `false` |
| 14 — Subscriptions | `FF_SUBSCRIPTIONS` | `false` |

Environment: `APP_BASE_URL` (default: `http://10.0.2.2:9000` for Android emulator).

Once a branch is **merged and stable**, flip its flag default to `true` in `feature_flags.dart` and document the change in `BACKLOG.md`.

---

## 6) Common mistakes

| Mistake | Why it hurts |
|---------|--------------|
| Starting Branches 3–13 before Branch 2 lands | No valid auth token; all user-scoped endpoints return 401 |
| Deleting hardcoded seed data during API wiring | Breaks `FF_X=false` mode; breaks `flutter test` (mock mode) |
| Calling `ApiClient` directly from a screen | Bypasses feature flag; makes UI impossible to test in isolation |
| Monolithic "api_service.dart" across feature domains | Merge conflicts across all parallel Branches 3–13 |
| Hardcoding base URL in source | Breaks physical device; breaks CI |
| Skipping loading / error states | Crashes on null data; confusing UX on slow network |
| Opening Branch 14 before Branch D merges | Subscription screen ownership conflict |
| Forgetting to run with `FF_X=false` before PR | Regressions in mock mode go undetected |

---

## 7) PR description template (stacked)

```text
Backend integration — stacked PR (see docs/BACKEND_INTEGRATION_WORKTREE_PLAN.md).

Depends on: <parent-branch-name> (PR #___)
Domain: <auth | profile | articles | medications | assessment | contacts | health-data | chat | chatbot | community | nutrition | notifications | payment>
Feature flag: FF_<DOMAIN> (default false → true after this merges)
Scope: <one sentence>

Backend endpoints touched:
- <METHOD> /api/v1/<path>/
- <METHOD> /api/v1/<path>/

Tested:
- [ ] FF_<DOMAIN>=false: existing behaviour unchanged
- [ ] FF_<DOMAIN>=true: backend flow works end-to-end
- [ ] flutter analyze clean
- [ ] flutter test passes
```

---

## 8) Relation to existing plan docs

| Doc | Purpose |
|-----|---------|
| `docs/BACKEND_INTEGRATION_PLAN.md` | Roadmap — branch scopes, acceptance criteria, flag + mock architecture |
| `docs/BACKEND_INTEGRATION_WORKTREE_PLAN.md` | **This file** — git workflow, stacking, worktrees, PR bases, flag reference |
| `docs/FEATURE_BRANCH_PLAN.md` | UI roadmap (Branches A–Q) — read-only reference |
| `docs/BACKLOG.md` | All decisions + implementation notes |

---

## 9) Starting Branch 1: step-by-step

From the **repo root** (`Health_Pilot_Flutter_project/`), on a clean `main`:

```bash
git fetch origin
git checkout main
git pull origin main
git checkout -b feat/api-network-layer
cd healthpilot
flutter pub get
```

Deliverables per Branch 1 scope (`docs/BACKEND_INTEGRATION_PLAN.md` §3, Branch 1):

1. `pubspec.yaml` — add `dio`, `flutter_secure_storage`
2. `lib/core/network/` — `api_client.dart`, `api_interceptors.dart`, `api_error.dart`, `api_constants.dart`
3. `lib/core/env/app_env.dart` — `APP_BASE_URL` from `--dart-define`
4. `lib/core/flags/feature_flags.dart` — all 13 per-domain flags
5. `lib/core/repositories/` — one `i_<domain>_repository.dart` per domain (abstract stubs)
6. Each `lib/features/<domain>/repositories/mock_<domain>_repository.dart` — wrapping existing static data
7. `lib/core/di/repository_locator.dart` — `MultiProvider` list keyed on feature flags

Push and open PR with base `main`:

```bash
git push -u origin feat/api-network-layer
```
