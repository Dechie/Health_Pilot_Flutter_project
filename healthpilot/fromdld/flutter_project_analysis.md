# 📱 Project Gap Analysis & Architecture Restructuring

---

# 🧩 Part 1: Missing Features (Based on Figma Design Analysis)

## 📌 Introduction
This section is based on a high-level analysis of the provided Figma design screens compared against the current Flutter codebase.

Each Figma screen group was treated as a feature and mapped to the existing implementation. The goal is to identify which features are **not implemented or incomplete**, ignoring UI-level details and focusing only on feature-level coverage.

---

## ❌ Missing or Incomplete Features

### 1. Tutorials Feature
- No corresponding module exists in the codebase.
- Figma includes tutorial/onboarding help-style screens beyond initial onboarding.

👉 Status: **Completely missing**

---

### 2. Subscription & Payment (Incomplete)
- Exists as:
  - `subscription_and_payment_screen.dart`
- Issues:
  - Not structured as its own feature module
  - No clear backend/payment integration
  - Lives inside onboarding instead of being reusable

👉 Status: **Partially implemented**

---

### 3. Profile System (Not Properly Defined)
- Scattered across:
  - onboarding
  - emergency_contact
- No centralized profile feature or data model

👉 Status: **Architecturally missing (UI exists, system does not)**

---

### 4. Medication Feature (Misplaced)
- Exists inside onboarding:
  - `medications._screen.dart`
- Should be a standalone health feature

👉 Status: **Implemented but incorrectly structured**

---

### 5. Language Settings (Misplaced)
- Exists:
  - `language_translation.dart`
- Should belong to settings/profile

👉 Status: **Implemented but incorrectly structured**

---

## 🧠 Key Insight

The main gap is **not missing UI**, but:

> ❗ Misalignment between Figma feature boundaries and code architecture

---

# 🧱 Part 2: Feature Architecture Restructuring (Based on Codebase Metadata)

## 📌 Introduction

This section is based on the provided **system architecture metadata**, including:

- Feature-first folder structure
- Provider-based state management
- Centralized theming system
- Navigation patterns across features

The goal is to **realign the codebase with Figma feature boundaries**, improve scalability, and eliminate cross-feature coupling.

---

## 🚨 Core Problems Identified

### 1. Feature Leakage
- Features exist in wrong modules (e.g., medication in onboarding)

### 2. Fragmented Flows
- Onboarding split across multiple unrelated directories

### 3. No Clear Ownership
- Profile logic duplicated across multiple features

---

## ✅ Recommended Feature Structure

```bash
lib/features/
├── auth/
│   ├── login/
│   ├── forgot_password/
│   └── widgets/

├── onboarding/
│   ├── onboarding_flow.dart
│   ├── initial_info/
│   └── widgets/

├── home/

├── profile/
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   └── widgets/

├── articles/

├── chat/

├── chatbot/

├── health/
│   ├── tracking/
│   ├── symptoms/
│   └── profile/

├── health_assessment/

├── food_nutrition/

├── emergency_contact/

├── personal_doctor/

├── medication/
│   └── medication_screen.dart

├── subscription/
│   └── subscription_screen.dart

├── tutorials/
│   └── tutorial_screen.dart
```

---

## 🔧 Required Refactors

### 1. Move Medication
- From:
  - `onboarding/medications._screen.dart`
- To:
  - `features/medication/`

---

### 2. Extract Profile Feature
- Consolidate:
  - onboarding profile
  - emergency contact personal info
- Into:
  - `features/profile/`

---

### 3. Move Language Settings
- From onboarding
- To profile/settings

---

### 4. Extract Subscription Feature
- Move out of onboarding
- Create reusable subscription module

---

### 5. Create Tutorials Feature
- New module based on Figma

---

## 🧭 Navigation Architecture Recommendation

### Introduce Flow-Based Navigation

Instead of scattered navigation:

- Create:
  - `OnboardingFlowController`
  - `AuthFlowController`

Example:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => OnboardingFlow()),
);
```

---

## 🧠 Final Insight

Your codebase is already **strong technically** (theme system, providers, structure).

The real upgrade needed is:

> 🔥 Aligning feature boundaries with product design (Figma)

This will:
- Simplify navigation
- Reduce duplication
- Improve scalability
- Make adding features easier

---

# ✅ Summary

| Area | Status |
|------|------|
| UI Coverage | Mostly complete |
| Architecture | Needs restructuring |
| Missing Features | Tutorials |
| Misplaced Features | Medication, Language, Subscription |
| Main Issue | Feature misalignment |

---

