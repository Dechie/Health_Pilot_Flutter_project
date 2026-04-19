# 🛠️ Flutter Refactor Roadmap (Branch-Based Checklist)

---

## 📌 How to Use This
Each **top-level section = one Git branch / milestone**.

Workflow:
1. Create branch
2. Complete all steps inside
3. Test
4. Merge

---

# 🌿 1. Extract Core Feature Boundaries

## Goal
Separate wrongly placed features into proper modules.

### Steps

#### 1.1 Create new feature folders
- `features/medication/`
- `features/subscription/`
- `features/profile/`
- `features/tutorials/`

#### 1.2 Move files
- Move:
  - `onboarding/medications._screen.dart` → `medication/`
  - `onboarding/subscription_and_payment_screen.dart` → `subscription/`

#### 1.3 Fix imports
- Update all imports across project
- Use IDE refactor tools (important)

#### 1.4 Smoke test
- Run app
- Verify navigation still works

---

# 🌿 2. Build Profile Feature Properly

## Goal
Centralize all user-related data & UI

### Steps

#### 2.1 Create profile screens
- `profile_screen.dart`
- `settings_screen.dart`

#### 2.2 Move logic
- Merge:
  - onboarding profile screen
  - emergency_contact personal info

#### 2.3 Create shared model (optional)
- UserProfile model

#### 2.4 Update navigation
- Replace old profile routes with new ones

---

# 🌿 3. Fix Onboarding Flow

## Goal
Turn onboarding into a real guided flow

### Steps

#### 3.1 Create flow controller
- `onboarding_flow.dart`

#### 3.2 Define steps
- Intro → Auth → Initial Info → Done

#### 3.3 Remove unrelated screens
- Remove:
  - medication
  - subscription
  - language

#### 3.4 Centralize navigation
- Replace scattered Navigator.push calls

---

# 🌿 4. Extract Subscription Feature

## Goal
Make subscription reusable & independent

### Steps

#### 4.1 Create module
- `features/subscription/`

#### 4.2 Move UI
- Move payment screen

#### 4.3 Add entry points
- From:
  - onboarding
  - food nutrition

#### 4.4 Prepare backend integration (future)
- Add placeholder service

---

# 🌿 5. Extract Medication Feature

## Goal
Make medication a proper health module

### Steps

#### 5.1 Move screen
- Into `features/medication/`

#### 5.2 Add navigation
- From:
  - home
  - health section

#### 5.3 Prepare structure
- Add:
  - reminders
  - history (future)

---

# 🌿 6. Move Language to Settings

## Goal
Make language part of profile/settings

### Steps

#### 6.1 Move file
- `language_translation.dart` → profile/settings

#### 6.2 Add entry point
- Settings screen

#### 6.3 Connect to AppState
- Update theme/locale logic if needed

---

# 🌿 7. Create Tutorials Feature

## Goal
Implement missing feature from Figma

### Steps

#### 7.1 Create module
- `features/tutorials/`

#### 7.2 Build basic UI
- Simple card/list tutorial screen

#### 7.3 Add navigation
- From:
  - home
  - onboarding completion

---

# 🌿 8. Navigation Cleanup

## Goal
Standardize navigation across app

### Steps

#### 8.1 Remove deep nested navigation
- Avoid chained Navigator.push

#### 8.2 Introduce entry points
- Each feature has:
  - main screen

#### 8.3 Optional (advanced)
- Add central router

---

# 🌿 9. Final Cleanup & Validation

## Goal
Stabilize system after refactor

### Steps

#### 9.1 Test flows
- Onboarding
- Auth
- Profile
- Health features

#### 9.2 Remove dead code
- Old screens
- Unused imports

#### 9.3 UI polish
- Fix broken layouts if any

---

# ✅ Final Result

After completing all branches:

- Clean feature boundaries
- Scalable architecture
- Figma-aligned structure
- Easier future development

---

