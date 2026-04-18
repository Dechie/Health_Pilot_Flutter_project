# Backlog (decisions + follow-ups)

This file tracks **temporary product/engineering decisions** and **follow-up work** we intend to revisit. Treat it as the single source of truth for “we did X for now, and we’ll undo/finish it later”.

---

## Decision log

### 2026-04-15 — Temporarily skip onboarding and land on Home

- **Decision**: Bypass the onboarding flow and navigate directly to **Home** on app start.
- **Why**: Until backend integration is in place, onboarding flows may be blocked or misleading; this keeps dev/test iterations fast.
- **Scope**: App startup only. This is a temporary UX change, not a removal of onboarding screens.
- **Implementation**: `healthpilot/lib/main.dart` welcome/splash now routes to `HomePageScreen` instead of onboarding.
- **Rollback plan (after backend integration)**:
  - Restore the initial navigation target to the intended onboarding entry screen/flow.
  - If backend-gated, route based on real auth/subscription/profile completion state rather than a hardcoded screen.

---

## Implementation log (detailed)

This section records **what we changed in code** (files + intent). It’s meant for future you (or another dev) to quickly understand “what moved” and “why”, and to spot temporary hacks that should be revisited.

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
  - **Assessment tab root**: `HomePageScreen` now renders `AssessmentHistoryScreen(...)` for the Assessment tab index.
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
- **Implementation**: “Check another symptom” pops to the first route, then pushes `HealthAssessmentFlowScreen`.
  - File: `healthpilot/lib/features/health_assessment/result_back_to_home_screen.dart`

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

### Next branch (C): use a git worktree

From repo root, after `refactor/profile-feature` is checked out and pushed (or from its tip):

```bash
git fetch origin
git checkout refactor/profile-feature   # or: stay on merged main + pull, then checkout parent tip
git worktree add -b refactor/onboarding-flow ../wt-onboarding
cd ../wt-onboarding
```

Open PR **Branch C** with base **`refactor/profile-feature`** (or `main` if the stack below is already merged). Details: `docs/FEATURE_BRANCH_WORKTREE_PLAN.md` §3–4.


