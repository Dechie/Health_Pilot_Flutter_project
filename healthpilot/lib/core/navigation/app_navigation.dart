import 'package:flutter/material.dart';
import 'package:healthpilot/features/home/home_page_screen.dart';

/// Shared navigation helpers for major app surfaces.
///
/// **Feature entry points** (prefer opening these from cross-feature code rather
/// than duplicating route builders). Paths are under `lib/features/…` unless noted.
/// - **Home shell**: `HomePageScreen` — `home/home_page_screen.dart`
/// - **Onboarding stack**: `OnboardingFlowScreen` — `onboarding/onboarding_flow_screen.dart`
/// - **Medication**: `MedicationScreen` — `medication/medications_screen.dart`
/// - **Tutorials**: `TutorialsEntryScreen` — `tutorials/tutorials_entry_screen.dart`
/// - **Health tab**: `HealthProfile` — `health/health_profile_screen.dart`
abstract final class AppNavigation {
  AppNavigation._();

  /// Replaces the current route with the main home shell.
  ///
  /// Uses [Navigator.of] with [rootNavigator] so flows hosted under a nested
  /// navigator (for example onboarding’s nested [Navigator]) still land on the app root.
  static void replaceWithHome(
    BuildContext context, {
    bool isHelpPressed = false,
    bool useRootNavigator = true,
  }) {
    Navigator.of(context, rootNavigator: useRootNavigator).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomePageScreen(isHelpPressed: isHelpPressed),
      ),
    );
  }
}
