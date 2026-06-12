import 'package:flutter/material.dart';
import 'package:healthpilot/features/auth/activation_screen.dart';
import 'package:healthpilot/features/home/home_page_screen.dart';
import 'package:healthpilot/features/onboarding/signup_and_login_screen.dart';

/// Shared navigation helpers for major app surfaces.
///
/// **Feature entry points** (prefer opening these from cross-feature code rather
/// than duplicating route builders). Paths are under `lib/features/…` unless noted.
/// - **Home shell**: `HomePageScreen` — `home/home_page_screen.dart`
/// - **Onboarding stack**: `OnboardingFlowScreen` — `onboarding/onboarding_flow_screen.dart`
/// - **Medication**: `MedicationScreen` — `medication/medications_screen.dart`
/// - **Tutorials**: `TutorialsEntryScreen` — `tutorials/tutorials_entry_screen.dart`
/// - **Health tab**: `HealthProfile` — `health/health_profile_screen.dart`
abstract final class HomeTab {
  static const int home = 0;
  static const int health = 1;
  static const int assessment = 2;
  static const int chat = 3;
  static const int profile = 4;
}

abstract final class AppNavigation {
  AppNavigation._();

  /// Replaces the current route with the main home shell.
  ///
  /// Uses [Navigator.of] with [rootNavigator] so flows hosted under a nested
  /// navigator (for example onboarding’s nested [Navigator]) still land on the app root.
  static void replaceWithHome(
    BuildContext context, {
    bool isHelpPressed = false,
    int initialTabIndex = HomeTab.home,
    bool useRootNavigator = true,
  }) {
    Navigator.of(context, rootNavigator: useRootNavigator).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomePageScreen(
          isHelpPressed: isHelpPressed,
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
  }

  /// Pops assessment (and similar) flows back to the root shell, then replaces
  /// it with a fresh [HomePageScreen] on [initialTabIndex] so back cannot return
  /// to the previous flow.
  static void replaceRootHomeTab(
    BuildContext context, {
    required int initialTabIndex,
    bool isHelpPressed = false,
  }) {
    final nav = Navigator.of(context, rootNavigator: true);
    nav.popUntil((route) => route.isFirst);
    nav.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomePageScreen(
          isHelpPressed: isHelpPressed,
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
  }

  /// Replaces the current route with the login/signup screen.
  static void replaceWithLogin(BuildContext context, {bool useRootNavigator = true}) {
    Navigator.of(context, rootNavigator: useRootNavigator).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignupAndLoginScreen()),
      (_) => false,
    );
  }

  /// Replaces the current route with the email-activation screen.
  static void replaceWithActivation(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ActivationScreen()),
    );
  }

  /// Login screen for users who already registered but have not activated yet.
  static void replaceWithLoginAfterRegistration(
    BuildContext context, {
    String? email,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SignupAndLoginScreen(
          initialLogin: true,
          initialEmail: email,
        ),
      ),
    );
  }
}
