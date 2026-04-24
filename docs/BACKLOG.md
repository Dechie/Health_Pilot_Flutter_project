# Backlog (decisions + follow-ups)

This file tracks **temporary product/engineering decisions** and **follow-up work** we intend to revisit. Treat it as the single source of truth for “we did X for now, and we’ll undo/finish it later”.

---

## Decision log

### 2026-04-18 — Assessment history: in-memory today, API + in-memory cache tomorrow

- **Decision**: Treat **`InMemoryAssessmentHistory`** (`ChangeNotifier`) as the canonical place the Assessment tab reads/writes completed runs for now. **`recordCompleted(AssessmentSummary)`** is the single write path when the user taps **Finish** on the summary screen.
- **Future (API integration)**:
  - Introduce a **repository** (or evolve the notifier into one) that **loads assessment history from the backend** and persists new completions via **POST** (or equivalent).
  - **Keep an in-memory layer** as a **client-side cache** of server-backed data: same UX when offline or slow network; refresh on tab focus / pull-to-refresh / after mutations as product requires (exact strategy TBD).
  - Reuse **`AssessmentSummary`** / **`CompletedAssessmentEntry`** (or map DTOs ↔ these models) so UI changes stay minimal.
- **Why**: Ship history UI and flow without a backend; avoid throwing away this structure when wiring APIs later.
- **Primary files**: `healthpilot/lib/features/health_assessment/in_memory_assessment_history.dart`, `health_assessment_models.dart`, `main.dart` (provider), `assessment_history_screen.dart`, `summary_screen.dart`.

### 2026-04-15 — Temporarily skip onboarding and land on Home

- **Decision**: Bypass the full onboarding stack and navigate directly to **Home** on app start **by default**.
- **Why**: Until backend integration is in place, onboarding flows may be blocked or misleading; this keeps dev/test iterations fast.
- **Scope**: App startup only. This is a temporary UX change, not a removal of onboarding screens.
- **Implementation**: `healthpilot/lib/main.dart` `WelcomeScreen` uses compile-time flag **`kEnableOnboardingFlow`** (`healthpilot/lib/features/onboarding/onboarding_flow_screen.dart`). When `false`, splash → `HomePageScreen`; when `true`, splash → nested **`OnboardingFlowScreen`** (intro carousel → auth → existing post-auth screens).
- **Rollback plan (after backend integration)**:
  - Replace the boolean with real gating (auth / subscription / profile completion).
  - Keep **`OnboardingFlowScreen`** as the single nested navigator for onboarding-only routes; exits to the shell app continue to use **`rootNavigator: true`** where already applied.

### 2026-04-22 — Branch taxonomy + design-input gate for UI-heavy work

- **Decision**: Tag each plan slice as one of:
  - **Type A — refactor** (structure/ownership moves; minimal UX changes)
  - **Type B — UI feature** (new UI or significant UI changes)
  - **Type C — exploratory/decision** (scope unclear; decide first)
- **Workflow rule**:
  - For **Type B** branches, gather **Figma link/screenshots** before implementation.
  - For **Type C** branches, pause and decide scope/acceptance criteria before coding.
- **Plan doc**: `docs/FEATURE_BRANCH_PLAN.md` now includes **Type** fields and a **Design inputs** reminder where applicable.

### 2026-04-24 — Branch D (subscription) deferred; Branch E next from `main`

- **Decision**: **Pause plan Branch D** (`refactor/subscription-feature`) until **last** in the current sequence. **Subscription-focused refactors and new subscription UX are out of scope** until that branch is explicitly started.
- **Next work**: **Branch E** — `refactor/medication-feature`, branched from **`main`**, PR base **`main`** (stack adjustment documented in `docs/FEATURE_BRANCH_PLAN.md` §2 and `docs/FEATURE_BRANCH_WORKTREE_PLAN.md` §4).
- **Rationale**: Product wants to ignore subscription work for now while continuing the refactor roadmap.

### 2026-04-22 — What to do with completed branches after merges (A/B/C…)

- **Decision**: Once a branch is merged into `main`, we generally **do not keep “syncing” the completed branch**.
- **Default**: switch back to updated `main` and start the next slice from there (or from the correct stacked parent branch if the stack is still open).
- **Only sync a completed branch if** you must keep it open for review/follow-up changes; then rebase/merge it onto latest `main` to reduce drift.
- **Cleanup**: after merge + after verifying the final state is in `main`, it’s safe to delete the remote branch and your local branch.

---

## Implementation log (detailed)

This section records **what we changed in code** (files + intent). It’s meant for future you (or another dev) to quickly understand “what moved” and “why”, and to spot temporary hacks that should be revisited.

### 2026-04-24 — Branch E: Health tab entry points for medication + stubs

- **Goal**: Make medication discoverable from the **Health** tab (not only Profile), and reserve routes for reminders/history per `docs/FEATURE_BRANCH_PLAN.md` Branch E.
- **Changes**:
  - **`HealthProfile`** (Health tab): new **Medication** card with list rows for **My medications** → existing **`MedicationScreen`**, plus **Reminders** and **History** → placeholder screens.
  - **Stubs**: `medication_reminders_screen.dart`, `medication_history_screen.dart` under `lib/features/medication/`.
- **Files**: `healthpilot/lib/features/health/health_profile_screen.dart`, `healthpilot/lib/features/medication/medication_reminders_screen.dart`, `healthpilot/lib/features/medication/medication_history_screen.dart`.
- **Note**: Profile → Medications entry unchanged. Subscription work remains deferred (Branch D).

### 2026-04-15 — Refactor plan created (feature-by-feature branches)

- **Decision**: Adopt a “one feature (or one refactor theme) per branch” workflow for upcoming restructuring work from the fromdld analysis.
- **Why**: Keeps merges small and reduces regressions while moving feature boundaries to match Figma.
- **Plan doc**: `docs/FEATURE_BRANCH_PLAN.md`
- **Source inputs reviewed**:
  - `healthpilot/fromdld/flutter_project_analysis.md`
  - `healthpilot/fromdld/flutter_refactor_checklist.md`
- **Key gaps captured for follow-up branches**:
  - Tutorials feature is missing (per analysis).
  - Subscription/payment exists but is not modular/reusable; needs extraction out of onboarding.
  - Profile “system” is architecturally missing (UI exists, but ownership/model is fragmented).
  - Medication and language settings are implemented but misplaced (currently live under onboarding).

### 2026-04-15 — Assessment tab: history-first, flow pushed as separate route

- **Goal**: Make the Assessment tab start with the “history + timeline” screen (like the provided screenshot), and have “Add New Assessment” launch the multi-step pageview flow as a separate route (outside the bottom-nav tab framework).
- **Changes**:
  - **Assessment tab root**: `HomePageScreen` now renders **`AssessmentHistoryScreen()`** (no constructor args; data comes from app state / provider) for the Assessment tab index.
    - File: `healthpilot/lib/features/home/home_page_screen.dart`
  - **Add New Assessment → flow**: tapping the plus icon now `Navigator.push(...)`es `HealthAssessmentFlowScreen`.
    - File: `healthpilot/lib/features/health_assessment/assessment_history_screen.dart`
  - **Flow completion stack**:
    - `HealthAssessmentFlowScreen` pushes `SummaryScreen`.
    - `SummaryScreen` uses `pushReplacement` to go to `ResultBackToHomeScreen` on Finish (prevents returning to Summary on back).
    - File: `healthpilot/lib/features/health_assessment/health_assessment_flow_screen.dart`
    - File: `healthpilot/lib/features/health_assessment/summary_screen.dart`

### 2026-04-15 — Assessment flow UX fixes and branching logic

- **Centered option groups**: On multiple steps, the option buttons are vertically centered (consistent with “Who is the assessment for?” + “What is their blood type?”).
  - Steps affected include:
    - Who-for, blood type (existing)
    - Duration (“How long have you had this symptom?”)
    - Other symptoms (“Do you have any other symptoms?”)
    - Trend (“How are your symptoms changing over time?”)
  - File: `healthpilot/lib/features/health_assessment/health_assessment_flow_screen.dart`
- **Other symptoms branching**:
  - **Decision**: Add a simple “Add other symptoms” step after “Other symptoms” that only appears when the user answers **Yes**.
  - **Why**: Keeps the state machine simple; preserves existing selections; avoids jumping back to earlier pages in a confusing way.
  - **Implementation**:
    - Inserts an additional `_SymptomsPage` labeled “Add other symptoms”.
    - If user selects **No**, navigation skips directly to the Trend step.
    - Back navigation also skips correctly (Trend → OtherSymptoms when “No”).
  - File: `healthpilot/lib/features/health_assessment/health_assessment_flow_screen.dart`
- **CTA behavior (state-aware)**:
  - **Change**: The primary CTA is now **disabled until required input is provided** on each step.
  - **Why**: Prevents users from advancing without selecting an option, which produced inconsistent state and confusing UX.
  - **Rules**:
    - Who-for: requires selection
    - Blood type: requires selection
    - Allergies: can be skipped
    - Symptoms: requires at least one selected symptom
    - Duration: requires selection
    - Other symptoms: requires Yes/No selection
    - “Add other symptoms” (conditional step): requires at least one selected symptom (prevents proceeding if user clears everything)
    - Trend: requires selection
  - **Allergies label rule**:
    - Shows **Skip** only when the allergies field is empty.
    - Switches to **Next** as soon as the user types anything.
  - File: `healthpilot/lib/features/health_assessment/health_assessment_flow_screen.dart`
- **Bottom sheet info links**:
  - **Fixes**:
    - Ensure full width + safe area.
    - Increase height (sheet opens at ~58% of screen height).
    - Make content scrollable.
  - File: `healthpilot/lib/features/health_assessment/health_assessment_flow_screen.dart`

### 2026-04-15 — Assessment history UI: timeline rows + “show more/less”

- **Note (2026-04-18)**: Inline **Show more / Show less** was **removed** in favor of **two fixed panes**, each with its own **`ListView`** + **`Scrollbar`** + light border and a short “Scroll this list” hint; **Add New Assessment** stays in a **non-scrolling footer**. Timeline row styling is unchanged.
- **Timeline/stepper-style rows**:
  - **Change**: Use timeline-style list rows (dot + vertical line) rather than embedding Material `Stepper` widgets in the list.
  - **Why**: Matches the desired UI (provided screenshot) and keeps the history page visually clean.
  - File: `healthpilot/lib/features/health_assessment/assessment_history_screen.dart`
- **Show more / show less**:
  - **Decision**: Collapse each section to 4 items by default and allow expanding inline.
  - **Why**: Avoid nested scroll areas and keep the page tidy when histories grow.
  - **Implementation**:
    - `AssessmentHistoryScreen` became `StatefulWidget`.
    - Each section (Assessment History / Symptom History) has its own toggle state.
    - Connector line is suppressed on the last visible item for nicer visuals.
  - File: `healthpilot/lib/features/health_assessment/assessment_history_screen.dart`

### 2026-04-15 — Safe-area fixes (content should not slide under OS navigation bars)

- **Problem**: Multiple screens were rendering content under the system navigation/home indicator (Android 3-button bar / gesture bar, iOS home indicator).
- **Fix approach**: Wrap screen bodies in `SafeArea(bottom: true)` (or use `useSafeArea: true` for bottom sheets).
- **Files updated**:
  - `healthpilot/lib/features/health_assessment/assessment_detail_screen.dart`
  - `healthpilot/lib/features/health_assessment/summary_screen.dart`
  - `healthpilot/lib/features/health_assessment/result_back_to_home_screen.dart`
  - `healthpilot/lib/features/chat/chat_screen.dart`
  - `healthpilot/lib/features/chat/group_chat_screen.dart`
  - `healthpilot/lib/features/chat/user_detail_screen.dart`

### 2026-04-15 — Fix: assessment tab white screen / layout exceptions

- **Root cause**: `HomePageScreen` wrapped all tab pages in a `SingleChildScrollView`, which gave `HealthAssessmentFlowScreen`’s `Scaffold` an unbounded height → “infinite size during layout”.
- **Fix**:
  - Only the Home tab is scrollable; other tabs render as full-height pages.
  - File: `healthpilot/lib/features/home/home_page_screen.dart`
- **Additional fix**:
  - Removed `setState(() async { ... })` pattern in the home tutorial dialog (caused runtime assertion).
  - File: `healthpilot/lib/features/home/home_page_screen.dart`

### 2026-04-15 — New assessment screens + assets

- **New assessment feature screens added**:
  - `healthpilot/lib/features/health_assessment/assessment_history_screen.dart`
  - `healthpilot/lib/features/health_assessment/assessment_history_stepper_screen.dart`
  - `healthpilot/lib/features/health_assessment/health_assessment_flow_screen.dart`
  - `healthpilot/lib/features/health_assessment/summary_screen.dart`
  - `healthpilot/lib/features/health_assessment/result_back_to_home_screen.dart`
  - `healthpilot/lib/features/health_assessment/assessment_detail_screen.dart`
  - plus supporting widgets/files under `healthpilot/lib/features/health_assessment/`
- **New SVG assets added** (used in Summary and Back to Home screens):
  - `healthpilot/assets/images/assessment_summary.svg`
  - `healthpilot/assets/images/back_to_home.svg`
  - Registered via existing `pubspec.yaml` assets folder include (`assets/images/`), no further change required.
  - Added constants:
    - `AssetPaths.assessmentSummaryIllustration`
    - `AssetPaths.backToHomeIllustration`
    - File: `healthpilot/lib/data/asset_paths.dart`

### 2026-04-15 — Navigation: “Check another symptom”

- **Desired behavior**: Keep Assessment History as the stable entry point, but let the user start the flow again from the result screen.
- **Implementation (original)**: Pop to first route, then push `HealthAssessmentFlowScreen`.
- **Update (2026-04-18)**: Use **`pushAndRemoveUntil(..., (route) => route.isFirst)`** then push **`HealthAssessmentFlowScreen(key: ValueKey(sessionKey))`** so the old flow under **`SummaryScreen`’s `pushReplacement`** is removed and each run starts with **fresh state**. Same **`ValueKey(Object())`** pattern when starting the flow from the history tab **+** FAB.
  - File: `healthpilot/lib/features/health_assessment/result_back_to_home_screen.dart`
  - File: `healthpilot/lib/features/health_assessment/assessment_history_screen.dart`

### 2026-04-18 — In-memory assessment history drives the Assessment tab lists

- **What**: On **Finish**, **`SummaryScreen`** calls **`context.read<InMemoryAssessmentHistory>().recordCompleted(AssessmentSummary)`** then **`pushReplacement`** to **`ResultBackToHomeScreen`**. **`AssessmentHistoryScreen`** uses **`Consumer<InMemoryAssessmentHistory>`** to show:
  - **Assessment History** — one row per completed run (tap → **`AssessmentHistoryStepperScreen`**).
  - **Symptom History** — one row per symptom per completed run, newest-first (tap → stepper for that run’s summary).
- **Layout (current)**: Two **`Expanded`** halves (no heavy divider); each has title, **“Scroll this list”** hint, **`Scrollbar` + `ListView`** inside a light rounded border; **Add New Assessment** row is **fixed below** the halves (not inside either scroll view). **`ScrollController`**s are **`final`** field initializers (avoids **`LateInitializationError`** after hot reload vs. `late` + `initState` only).
- **Models**: **`BloodType`** and **`AssessmentSummary`** in **`health_assessment_models.dart`** (shared by flow, summary, stepper, store).
- **Files**: `in_memory_assessment_history.dart`, `health_assessment_models.dart`, `allergy_suggestion_catalog.dart`, `main.dart`, `assessment_history_screen.dart`, `summary_screen.dart`, `health_assessment_flow_screen.dart`, `assessment_history_stepper_screen.dart`, `home_page_screen.dart` (`const AssessmentHistoryScreen()`).
- **Summary secondary CTA**: **Review this assessment** → **`AssessmentHistoryStepperScreen`** for the **current** run only (history list still updates only on **Finish**).
- **Follow-up**: Decision log **2026-04-18** (API + retain in-memory **cache**).

### 2026-04-18 — health-assessment branch roll-up (workflow + PR review + navigation)

Use this as the **single checklist** for what landed on **`health-assessment`** after merging **`origin/main`** and iterating on review + product feedback.

- **Documentation**
  - **`docs/PR_STACK_WORKFLOW.md`**: merging **`main`** on feature branches, merging **stacked parents**, small diffs under feature dirs, worktrees pointer, **`--force-with-lease`**, **§6 import cycle** (assessment result / summary chain must not import **`HomePageScreen`**), **§7** pointer to backlog for assessment → API.
  - **`docs/FEATURE_BRANCH_PLAN.md`** §3: assessment **in-memory → repository → API**, keep in-memory as **cache**.
  - **`docs/PROJECT_CHANGES.md`**: **`InMemoryAssessmentHistory`** in **`MultiProvider`**, assessment data subsection.
- **Health assessment flow** (`health_assessment_flow_screen.dart`, `allergy_suggestion_catalog.dart`)
  - **Who-for** change clears **blood type** when the subject value actually changes.
  - **Back** on first step: **`Navigator.maybePop`**, non-null top-bar back handler.
  - **Allergies**: suggestions filtered from shared catalog (onboarding-aligned); tap appends to field.
  - **Symptoms** suggestions list: **one** “Dry Cough” row (was three duplicates).
  - **`BloodType`** moved to **`health_assessment_models.dart`**.
- **Result & community** (`result_back_to_home_screen.dart`, `general_chat_screen.dart`)
  - **Go to Community**: root **`popUntil(isFirst)`**, then **`push`** **`GeneralChatScreen(showBackButton: true)`** — **no** **`HomePageScreen`** import (avoids **circular imports** with home → history → flow → summary → result).
  - **`GeneralChatScreen`**: optional **`showBackButton`** toggles **`automaticallyImplyLeading`** so pushed chat shows a back control; tab instance stays default **false**.
  - **Check another symptom**: **`pushAndRemoveUntil`** + **`HealthAssessmentFlowScreen(key: ValueKey(sessionKey))`** (see Navigation entry above).
- **Regression / tooling**: **`flutter analyze`** clean on touched paths; hot-reload-safe scroll controllers (field init).

### 2026-04-15 — Branch A: extract feature boundaries (medication/subscription)

- **Goal**: Move misplaced features out of onboarding into dedicated feature modules.
- **Moved files**:
  - `healthpilot/lib/features/onboarding/medications._screen.dart` → `healthpilot/lib/features/medication/medications_screen.dart`
  - `healthpilot/lib/features/onboarding/subscription_and_payment_screen.dart` → `healthpilot/lib/features/subscription/subscription_and_payment_screen.dart`
- **New feature directories created**:
  - `healthpilot/lib/features/medication/`
  - `healthpilot/lib/features/subscription/`
  - `healthpilot/lib/features/profile/`
  - `healthpilot/lib/features/tutorials/`
- **Imports updated**:
  - `healthpilot/lib/features/onboarding/profile_and_setting_screen.dart`
  - `healthpilot/lib/features/onboarding/personal_information_screen.dart`

### 2026-04-18 — Branch B: profile feature entry (`refactor/profile-feature`)

- **Goal**: Own profile UI under `features/profile/`; Profile tab uses new entry; settings split out.
- **Added**:
  - `healthpilot/lib/features/profile/profile_screen.dart` — header + health information; AppBar opens `SettingsScreen`.
  - `healthpilot/lib/features/profile/settings_screen.dart` — gadgets, subscription, theme, language, legal, help, FAQ.
  - `healthpilot/lib/features/profile/widgets/profile_settings_shared.dart` — shared list/toggle widgets (moved from old monolith).
  - `healthpilot/lib/features/profile/widgets/premium_feature_dialog.dart` — shared premium upsell dialog.
- **Shim**:
  - `healthpilot/lib/features/onboarding/profile_and_setting_screen.dart` — barrel + `typedef ProfileAndSettingScreen = ProfileScreen` for legacy imports.
- **Integration**:
  - `healthpilot/lib/features/home/home_page_screen.dart` — Profile tab uses `ProfileScreen()` directly.

### 2026-04-20 — Branch B (`refactor/profile-feature`): own `PersonalInformationScreen` under profile

- **What**: Moved **`PersonalInformationScreen`** implementation from **`features/onboarding/`** to **`features/profile/personal_information_screen.dart`** (canonical location for profile edit / personal info).
- **Compatibility**: **`features/onboarding/personal_information_screen.dart`** is now a **deprecated re-export** so stale imports keep compiling until cleaned up.
- **Callers**: **`SubscriptionAndPaymentScreen`** now imports **`features/profile/personal_information_screen.dart`**.
- **Cleanup**: Removed a duplicate unused import in the moved screen after the move.

### 2026-04-18 — Mobile QA gate: Branch C / worktree (**PASS** — device screenshots)

- **Status**: Smoke testing on **physical device** completed using screenshots from the mobile build on **`refactor/profile-feature`**. Branch C (`refactor/onboarding-flow`) + **git worktree** are **unblocked** whenever you choose to start them (commands unchanged below).
- **Original gate** (kept for history): Do not start Branch C / worktree until device QA on profile branch — **done**.
- **Branch tested**: `refactor/profile-feature` (see also commit `ebb2d79` + backlog commit `7f20eff` for docs gate).
- **Smoke checklist** (executed on device):
  - **Profile tab**: layout OK (title, settings gear, name, Free badge, Edit, Health Information, active Profile tab).
  - **Settings**: full list visible; **Gadgets** → premium modal; **Subscription** → paywall / tiers screen; toggles and chevrons present.
  - **Medications** (from profile): list + search UI OK.
  - **Allergies** path: “One Last Step” / search / empty state / **Finish** — matches `InitialInfoThird` flow.
  - **Language**: picker screen OK (see follow-up typo below).

### 2026-04-18 — Mobile QA notes & follow-ups (from screenshots)

- **Screenshot assets** (workspace, for design/reference):  
  `assets/image-aabd84ee-7f24-4432-ac2d-de0f8866cc49.png` (Profile),  
  `assets/image-e6c6fb4a-4d84-4e28-a97f-068742110bc2.png` (Medications),  
  `assets/image-2506665f-ff6d-401b-bd75-0947f091fae2.png` (Allergies / one last step),  
  `assets/image-6ee7969d-b294-491b-bdca-d0c2bbde9cb3.png` (Premium dialog),  
  `assets/image-bc515e8e-5ec7-42bc-bc6e-f6c26e9e53d9.png` (Settings),  
  `assets/image-050d680a-3a6c-44cf-8f82-d44e50b4d011.png` (Subscription),  
  `assets/image-242aa25d-b863-4047-aaf4-10c7b328e0b7.png` (Language).  
  Paths are under the Cursor project `assets/` folder (not committed to the Flutter app unless copied into `healthpilot/assets/`).
- **Follow-up — medications placeholder (non-blocking for Branch C)**  
  - List shows seed row text **`medicationName`** (from `MedicationListProvider` default entry in `medications_screen.dart`).  
  - **Plan**: address under **Branch E** (`refactor/medication-feature`) — empty state vs realistic seed / backend.
- **Follow-up — language copy (non-blocking)**  
  - UI lists **“Urudu”**; correct spelling **“Urdu”**.  
  - **File**: `healthpilot/lib/features/onboarding/language_translation.dart` (line ~16).  
  - **Plan**: fix anytime; formally owned by **Branch F** (`refactor/language-settings`) when language moves under profile/settings.

### 2026-04-21 — Branch C follow-through: nested onboarding shell + intro carousel

- **Goal**: One nested navigator for onboarding; marketing carousel before auth; no duplicate pushes into auth/get-started.
- **Changes**:
  - **`OnboardingFlowScreen`**: `initialRoute` intro (`PhysicalTherapyScreen`) then `pushReplacement` into **`SignupAndLoginScreen`**; auth remains on the same nested stack.
  - **`PhysicalTherapyScreen`**: last-page CTA uses a single **`pushReplacement`** to auth (removed erroneous double `push` that included **`GetStartedScreen`**); fixed “Next” on non-final pages so the carousel does not advance and navigate in one tap.
- **Files**: `healthpilot/lib/features/onboarding/onboarding_flow_screen.dart`, `healthpilot/lib/features/onboarding/physical_therapy_screen.dart`.
- **Note**: Medication / subscription / language entry points belong to **profile** and later branches (D–F); they are not part of this nested onboarding route table.

### 2026-04-21 — Branch B follow-up: profile owns emergency + doctor setup UIs

- **Moved** setup flows into **`healthpilot/lib/features/profile/`**:
  - `emergency_contact/personal_information.dart` → `profile/emergency_contact_personal_information.dart`
  - `personal_doctor/personal_information.dart` → `profile/personal_doctor_personal_information.dart`
- **Deprecated shims** at old paths re-export the profile modules so legacy imports keep compiling.
- **Imports**: `profile/personal_information_screen.dart`, `subscription/subscription_and_payment_screen.dart` point at profile paths; emergency screen uses `package:healthpilot/theme/app_theme.dart`; doctor screen imports `personal_doctor/setup_personal_doctor.dart` by package URI.
- **`UserProfile`**: `profile/user_profile.dart` plus `kDemoUserProfile`; **`ProfileScreen`** display name reads from the model until persistence lands.
- **Optional later**: co-locate `setup_emergency_contact.dart` / `setup_personal_doctor.dart` under profile if we want zero cross-feature imports from profile into `emergency_contact/` / `personal_doctor/`.

### Follow-up: Branch C — git worktree (optional)

From repo root, with the parent branch at the commit you want to extend:

```bash
git fetch origin
git checkout refactor/profile-feature
git pull
git worktree add -b refactor/onboarding-flow ../wt-onboarding
cd ../wt-onboarding
```

Open PR **Branch C** with the correct **stacked base** (see `docs/FEATURE_BRANCH_WORKTREE_PLAN.md` §3–4 and §8). When starting a **new slice after merges**, refresh **`main`** first (`docs/FEATURE_BRANCH_PLAN.md` §1).


