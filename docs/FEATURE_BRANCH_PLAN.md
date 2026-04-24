# Comprehensive plan: feature-by-feature branches

This plan is derived from:
- `healthpilot/fromdld/flutter_project_analysis.md` (gap analysis + target architecture)
- `healthpilot/fromdld/flutter_refactor_checklist.md` (branch-based roadmap)
- Current session decisions/changes tracked in `docs/BACKLOG.md`

The intent is to keep work **mergeable in small increments** by doing **one feature (or one refactor theme) per branch**, with clear acceptance criteria and rollback notes.

**Primary success metric:** as these branches merge, they should produce **minimal-to-zero merge conflicts** and **no feature overlap**. Every branch should have a clearly owned slice of the tree (files, routes, and responsibilities) so that parallel work can merge cleanly.

### Stacked PRs & git worktrees (recommended workflow)

For **how** to run branches in parallel (optional `git worktree`), **which GitHub PR base** to use when stacking PRs A→I, and **rebase rules** after parents merge, see:

- **`docs/FEATURE_BRANCH_WORKTREE_PLAN.md`**

Use that doc together with this file: **roadmap + acceptance criteria here**; **operational git workflow there**.

---

## 0) Current baseline (already done)

These changes are already implemented and tracked in `docs/BACKLOG.md` (do not redo—just keep stable while refactoring):

- Temporary startup bypass: onboarding → Home
- Assessment feature: history-first tab root + wizard flow route + summary/back-to-home screens
- Layout + safe-area fixes on several screens
- Added/updated docs: backlog + session overview

---

## 1) Branch workflow (how to execute)

For each branch below:

- Create branch from the **correct parent in your stack** (see `docs/FEATURE_BRANCH_WORKTREE_PLAN.md`): e.g. Branch B from Branch A’s branch tip, or from `main` once earlier PRs are merged. The historical note “from latest `health-assessment`” applies when that branch is still the integration tip; **prefer stacked bases** when multiple PRs are open.
- Make the scoped changes only (avoid drive-by refactors)
- Actively design for **conflict-free merges**:
  - Prefer **moving/owning** code under a single feature directory in the current branch instead of editing shared files across multiple branches.
  - If a shared file must change (e.g. `HomePageScreen` tab wiring, `AssetPaths`, `AppState`), keep the change **tiny**, and treat it as a deliberate “integration seam”.
  - Don’t let two branches “own” the same screen/flow. If ownership is unclear, resolve it by updating `docs/BACKLOG.md` before continuing.
  - Keep public APIs stable: if you must rename/move, do it once in the branch that owns the migration, and avoid follow-up renames in later branches.
- Run:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test` (if/when tests exist)
  - smoke-test affected flows on device/emulator
- Update `docs/BACKLOG.md` with:
  - decision (if any)
  - implementation notes (files changed, rationale)
- Merge back when green

### Branch types (how we’ll run each slice)

Each planned branch is tagged as one of:

- **Type A — refactor**: restructure/moves/ownership boundaries with minimal UI changes.
- **Type B — UI feature**: new UI or significant UI changes. **Before starting**, capture design inputs (Figma link or screenshots) and confirm intended UX.
- **Type C — exploratory/decision**: unclear scope or requires a product decision. We’ll pause to decide scope before coding.

For **Type B** branches, the workflow is: **ask for Figma screenshots (or link)** → confirm acceptance criteria → implement.

### Starting the next slice from updated `main`

Whenever you pick up the next slice from this plan (for example Branch C follow-through, or D/E/F onward), **refresh local `main` from the canonical remote**, then **branch from that tip**, so the stack matches what is already merged and stays easy to rebase.

```bash
git fetch upstream
git checkout main
git pull upstream main
```

If your day-to-day `main` tracks your fork instead of the org remote, use `origin` (or whichever remote owns integrated `main`) in place of `upstream` for fetch/pull. Then create the feature branch from current `main`:

```bash
git checkout -b refactor/<slice-name>
```

If a **parent PR in the stack is still open** and you are not switching to a clean `main` tip yet, keep branching from the **correct parent branch** as described in `docs/FEATURE_BRANCH_WORKTREE_PLAN.md`; use the commands above when the parent has landed and you are starting a new slice from `main`.

Branch naming convention (recommended):

- `refactor/<area>-<short-scope>`
- `feat/<feature>-<short-scope>`

---

## 2) Planned branches (in recommended order)

### Execution order (stack adjustment — 2026-04-24)

- **Branch D** (`refactor/subscription-feature`) is **deferred to last** in the current sequence. Until it is explicitly started, treat **subscription-specific refactors and new subscribe/paywall flows as out of scope** (leave existing entry points such as profile/settings as they are unless fixing breakage).
- **Next slice from `main`:** **Branch E** (`refactor/medication-feature`). Open the PR with **base = `main`** while D is deferred (see `docs/FEATURE_BRANCH_WORKTREE_PLAN.md` §4).
- When **Branch D** is eventually picked up, do it **after** the branches you chose to run ahead of it (at minimum after **E**, and typically after **F** as well if you keep the original F→G dependency), then reconcile any subscription entry-point duplication called for by the plan.

### Branch A — Extract misplaced feature boundaries (foundational)
- **Branch**: `refactor/features-boundaries`
- **Type**: A (refactor)
- **Goal**: Move misplaced features into correct feature modules to align with Figma boundaries.
- **Scope (from fromdld)**:
  - Create folders:
    - `lib/features/medication/`
    - `lib/features/subscription/`
    - `lib/features/profile/`
    - `lib/features/tutorials/`
  - Move files:
    - `lib/features/onboarding/medications._screen.dart` → `lib/features/medication/`
    - `lib/features/onboarding/subscription_and_payment_screen.dart` → `lib/features/subscription/`
  - Fix imports across the app.
- **Acceptance criteria**:
  - App builds/runs, navigation still works.
  - No broken imports/analyzer errors.
- **Backlog update**:
  - Record exact moved paths and any newly introduced entry points.

### Branch B — Profile feature: consolidate “profile system”
- **Branch**: `refactor/profile-feature`
- **Type**: A (refactor)
- **Status (2026-04-18)**: Profile tab uses `features/profile/profile_screen.dart` + `settings_screen.dart`; legacy onboarding path is a thin export shim (see `docs/BACKLOG.md`).
- **Goal**: Centralize user/profile UI and prepare for a real profile model.
- **Scope**:
  - Create:
    - `lib/features/profile/profile_screen.dart`
    - `lib/features/profile/settings_screen.dart`
  - Move/merge logic scattered across onboarding + emergency_contact personal info into profile.
  - (Optional) Introduce a `UserProfile` model in `lib/features/profile/` or `lib/core/`.
- **Acceptance criteria**:
  - Profile tab points to the new feature entry screen(s).
  - No duplicated “profile” implementations across modules (or at least a clear deprecation path is documented).
- **Backlog update**:
  - Document what was consolidated, what remains, and migration notes.

### Branch C — Onboarding as a real flow controller
- **Branch**: `refactor/onboarding-flow`
- **Type**: A (refactor)
- **Goal**: Replace scattered onboarding navigation with a guided flow (auth → initial info → done).
- **Scope**:
  - Create an onboarding flow controller/screen (`onboarding_flow.dart`).
  - Ensure onboarding contains only onboarding steps.
  - Remove unrelated entry points from onboarding (medication/subscription/language).
- **Acceptance criteria**:
  - The onboarding flow can be re-enabled easily once backend integration is ready.
  - Flow runs end-to-end without cross-feature navigation leaks.
- **Backlog update**:
  - Track the intended post-backend gate logic (auth/subscription/profile completion).

### Branch D — Subscription feature: make reusable + independent
- **Branch**: `refactor/subscription-feature`
- **Type**: A (refactor)
- **Status (2026-04-24)**: **Deferred — run last.** No subscription-focused refactors or new subscription UX until this branch is started; see **Execution order** above.
- **Goal**: Subscription/payment UI becomes reusable and not tied to onboarding.
- **Scope**:
  - Ensure the subscription module owns the payment screen and routing.
  - Add entry points from:
    - onboarding (later re-enabled)
    - food & nutrition (already has subscribe/start-setup logic)
  - Add placeholder service interfaces for future backend integration.
- **Acceptance criteria**:
  - All subscription entry points route to the same subscription feature entry screen.

### Branch E — Medication feature: standalone health feature
- **Branch**: `refactor/medication-feature`
- **Type**: A (refactor)
- **Status (2026-04-24)**: Health tab lists medication entry points; reminders/history are stub routes pending backend/notifications.
- **While Branch D is deferred**: Branch **from `main`**, PR base **`main`** (not stacked on `refactor/subscription-feature`).
- **Goal**: Medication is accessible from appropriate places (health/home) and ready for reminders/history.
- **Scope**:
  - Move/rename medication screen(s) into `features/medication/`.
  - Add navigation entry points from home/health sections.
  - Create stubs for future: reminders, history.
- **Acceptance criteria**:
  - Medication screens are discoverable and no longer live under onboarding.

### Branch F — Language settings: move into profile/settings
- **Branch**: `refactor/language-settings`
- **Type**: A (refactor)
- **Status (2026-04-24)**: Implementation lives in `features/profile/language_translation.dart`; onboarding path is a **deprecated re-export**; `AppState` exposes `locale` and `MaterialApp` sets `supportedLocales` + `locale`.
- **Goal**: Language becomes a profile/settings concern and can later integrate with `AppState`.
- **Scope**:
  - Move `language_translation.dart` into profile/settings area.
  - Wire it from Settings screen.
  - (Optional) connect locale persistence to `AppState` (similar to theme mode).
- **Acceptance criteria**:
  - Language screen reachable from Settings.
  - No onboarding dependency.

### Branch G — Tutorials feature (missing feature)
- **Branch**: `feat/tutorials`
- **Type**: B (UI feature)
- **Design inputs**: Before starting, capture Figma screenshots (or link) for tutorials list/cards and tutorial detail (if any).
- **Goal**: Implement the missing tutorials feature noted in the analysis.
- **Scope**:
  - Create `features/tutorials/` with a simple tutorial list/card UI.
  - Add navigation entry points:
    - home
    - onboarding completion (after onboarding is restored)
- **Acceptance criteria**:
  - Tutorials screen exists and is reachable from at least one stable entry point (Home).

### Branch H — Navigation cleanup (standardization)
- **Branch**: `refactor/navigation-cleanup`
- **Type**: A (refactor)
- **Goal**: Standardize navigation patterns; reduce nested push chains; define feature entry screens.
- **Scope**:
  - Ensure each feature has a clear “entry screen”.
  - Reduce ad-hoc navigation from deep widgets where possible.
  - Optional: introduce a central router later (only if needed).
- **Acceptance criteria**:
  - No regressions; navigation remains predictable; fewer cross-feature imports.

### Branch I — Final cleanup & validation
- **Branch**: `chore/final-cleanup`
- **Type**: A (refactor)
- **Goal**: Stabilize after refactors.
- **Scope**:
  - Smoke-test major flows: auth/onboarding/profile/health/assessment/chat.
  - Remove dead code and unused imports.
  - Fix any layout regressions introduced by refactors.
- **Acceptance criteria**:
  - `flutter analyze` clean, app runs without runtime exceptions during standard navigation.

---

## 3) Notes / constraints

- While **Branch D** is deferred, **do not** expand subscription/paywall scope; keep existing paths stable unless fixing correctness or merge fallout.
- Keep `docs/BACKLOG.md` as the primary decision + implementation record.
- Prefer moving code with minimal functional changes per branch; do “behavior improvements” on follow-up feature branches.
- Backend integration is a known future dependency; avoid baking fake state into UI that will fight real auth/subscription state later.
- **Assessment history data layer**: Completed assessments are stored in **`InMemoryAssessmentHistory`** (see `docs/BACKLOG.md`, **Decision log 2026-04-18**). When APIs exist, introduce a **repository** (or evolve that type) to **fetch and persist via backend**, and treat the current in-memory notifier as a **client-side cache** of server data rather than deleting it outright. UI should keep depending on a small surface (e.g. “list entries + record completion”) so the swap is localized.
- **Conflict avoidance rule of thumb**: if a planned branch requires touching the same “shared seams” as another planned branch (navigation entry points, `AssetPaths`, global providers), either:
  - merge one branch first before starting the other, or
  - extract the shared change into a tiny prerequisite branch so the remaining feature branches can proceed independently.

