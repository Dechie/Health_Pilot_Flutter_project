# Project changes (contributor update)

This document summarizes the work merged on the contributor branch (roughly commits from `refactor: adopt feature-first lib layout…` through `feat: add food & nutrition…`). Use it for PM / reviewer handoff.

---

## 1. Tooling

| Item | Notes |
|------|--------|
| **Flutter** | Upgraded from the previous project baseline (~3.11) to **3.41** (current stable used for development). |
| **Dart SDK** | `pubspec.yaml` constraint: `>=3.3.0 <4.0.0`. |
| **Analyzer** | `flutter_lints` ^5.0.0 in dev_dependencies. |

Run from the `healthpilot/` package:

```bash
cd healthpilot && flutter pub get && flutter analyze && flutter test
```

---

## 2. Dependencies (`healthpilot/pubspec.yaml`)

- **Modernized** versions across the dependency set (see `pubspec.lock` for resolved versions).
- **Added [provider](https://pub.dev/packages/provider)** (^6.1.5+1) for lightweight app-wide state.
- **Replaced discontinued or outdated packages** with maintained alternatives where the old stack was no longer viable (details in commit `59c61bd` and lockfile diff).

---

## 3. Application architecture

### Before

- Primary UI lived under `lib/screens/…` with feature names as folder names.

### After (feature-first)

- **`lib/features/<feature_name>/`** — screens and feature-local widgets (e.g. `chat/`, `onboarding/`, `forgot_password/`, `food_nutrition/`).
- **`lib/core/`** — shared non-UI infrastructure (e.g. `providers/app_state.dart`, `widgets/safe_assets.dart`).
- **`lib/data/`** — constants, string tables, asset path registry (`constants.dart`, `app_strings.dart`, `asset_paths.dart`).
- **`lib/theme/`** — `app_theme.dart` (light/dark `ThemeData`, palette, context helpers).
- **`lib/widget/`** — remaining shared widgets (e.g. `custom_app_bar_title.dart`).

Imports across the app were updated to the new paths.

---

## 4. App entry & global state (`lib/main.dart`)

- Wraps the app in **`MultiProvider`** with **`ChangeNotifierProvider<AppState>`** and **`ChangeNotifierProvider<InMemoryAssessmentHistory>`** (completed health assessments, in-process memory only for now).
- **`MaterialApp`** uses:
  - `theme: AppTheme.light`
  - `darkTheme: AppTheme.dark`
  - **`themeMode: appState.themeMode`** (user-controllable; see profile settings).
- Splash / welcome uses **`SafeRasterAsset`** with **`AssetPaths.welcomeLogo`** for resilient image loading.

---

## 5. Theme & design tokens (`lib/theme/app_theme.dart`)

- Central **Figma-aligned palettes** (`AppPalette`: light strong / light / light soft; dark variants).
- **`ColorScheme`** and **`TextTheme`** built around **PlusJakartaSans** (and existing font registration).
- Helpers such as **`AppTheme.circleBackButtonStyle`**, **`bodyMuted`**, **`headlinePanel`**, gradients for home overview, etc., to reduce hard-coded colors in widgets.

---

## 6. Assets & copy (`lib/data/`, `lib/core/widgets/safe_assets.dart`)

- **`asset_paths.dart`** — single place for asset path constants (many legacy top-level `constants.dart` aliases re-export or delegate here).
- **`app_strings.dart`** — shared user-facing strings where centralized.
- **`constants.dart`** — trimmed/reorganized; still exports `app_strings` / `asset_paths` for backward compatibility.
- **`SafeRasterAsset` / `SafeSvgAsset`** — load images/SVGs with **themed placeholders** when a file is missing or fails to load (avoids red error boxes in production builds during asset drift).

---

## 7. New or substantially new features

### Health assessment — history data (in-memory; API-ready plan)

- **`InMemoryAssessmentHistory`** (`lib/features/health_assessment/in_memory_assessment_history.dart`) stores completed runs after **Finish** on the summary screen; the Assessment tab history UI consumes it via **Provider**.
- **`AssessmentSummary`** / **`BloodType`** live in **`health_assessment_models.dart`** for a single shared shape across flow, summary, stepper, and store.
- **Planned evolution** (not implemented yet): add an API-backed repository and use the same in-memory layer as a **cache** of backend data. Source of truth for intent: **`docs/BACKLOG.md`** (2026-04-18 decision + implementation notes) and **`docs/FEATURE_BRANCH_PLAN.md`** §3.

### Forgot password (`lib/features/forgot_password/`)

- **`forgot_password_flow.dart`** — multi-step UI (request / check email style flow).
- **`forgot_password_controller.dart`** — state for the flow.
- **`widgets/forgot_password_header.dart`**, **`forgot_password_primary_button.dart`** — shared chrome.
- Login/signup screen was **refactored** to route into this flow (large reduction of inline code in `signup_and_login_screen.dart`).

### Food & nutrition (`lib/features/food_nutrition/`)

- **`food_nutrition_tracking_screen.dart`** — report frequency, push notification toggle, diet filter chips, **Finish** (returns via `Navigator.pop`).
- **`food_nutrition_history_screen.dart`** — date header and **timeline** meal list with kcal.
- **Navigation wired from:**
  - `features/emergency_contact/personal_information.dart`
  - `features/personal_doctor/personal_information.dart`  
  (section header → history; preview rows → history; **Start Setup** → tracking screen.)
- **`features/onboarding/personal_information_screen.dart`** — nutrition card: **Start setup** opens tracking when subscribed; **Subscribe** opens payment; **no longer** calls `Navigator.push` inside `setState`.

### Home overview

- **`features/home/overview_card.dart`** added (overview content moved out of the old `screens/home_page_screen/overview_card.dart` location).
- **`home_page_screen.dart`** updated to use the new structure and theme-aware styling where touched.

---

## 8. Removed

| Removed | Notes |
|---------|--------|
| **`lib/screens/meet_the_devs_screen/`** | Entire **Meet the Developers** feature removed (`meet_the_devs.dart`, `devs_card.dart`). |
| **Profile entry** | Row / navigation to Meet the Developers removed from **`profile_and_setting_screen.dart`**. |
| **Old `lib/screens/...` tree** | Feature code **moved** under `lib/features/...` (not deleted conceptually—paths changed). |

*Note:* Shared placeholder assets used elsewhere (e.g. chat avatars) may still reference generic profile imagery from constants; only the Meet the Devs **screens and navigation** were removed.

---

## 9. Other touched areas (by file move / import fix)

The following areas were **relocated** under `features/` and adjusted for imports and, where needed, theme or safe assets:

- **Articles** — `article_screen`, `article_detail_screen`, `article_comment_screen`
- **Chat** — `chat_screen`, `general_chat_screen`, `group_chat_screen`, audio/video call screens, `public_profile_screen`, `similar_people_screen`, `user_detail_screen`, small widgets
- **Chatbot** — `chatbot_screen` and bubbles
- **Emergency contact** — `setup_emergency_contact`, `personal_information` (+ food section wiring)
- **Gadgets** — `gadgetscreen`, `addgadgetScreen`
- **Get started** — `get_started_screen`
- **Health** — `health_tracking_screen`, `symptom_tracking_screen`, `health_profile_screen`
- **Home** — `home_page_screen`, `discover_healthpilot`, `ad_widget`, `blog_reccomendation._card`
- **Onboarding** — `signup_and_login_screen`, `personal_information_screen`, `profile_and_setting_screen`, `physical_therapy_screen`, `subscription_and_payment_screen`, terms, language, medications
- **Personal doctor** — `setup_personal_doctor`, `personal_information` (+ food section wiring)
- **Personal info (initial flows)** — `initial_info_1` … `initial_info_4`

---

## 10. Documentation in-repo

- **`healthpilot/README.md`** and root **`ReadMe.md`** — contributor / clone instructions were updated in an earlier commit (`44167ae` message: readme instructions).

---

## 11. Git reference (this workstream)

Approximate commit sequence on the contributor branch:

1. `refactor: adopt feature-first lib layout and modernize dependencies`
2. `feat(auth): add forgot-password flow under features/forgot_password`
3. `feat(theme): centralize light/dark palettes, TextTheme, assets, and safe image fallbacks`
4. `removed 'meet the devs' feature`
5. `feat: add food & nutrition setup and history screens with navigation`

For an exact file list: `git diff --stat <upstream-main>...HEAD -- healthpilot/`

---

*Last updated to match repository state at documentation authoring time.*
