import 'package:flutter/material.dart';
import 'package:healthpilot/features/onboarding/physical_therapy_screen.dart';
import 'package:healthpilot/features/onboarding/signup_and_login_screen.dart';

/// When `true`, [WelcomeScreen] routes into [OnboardingFlowScreen] instead of home.
/// Default stays `false` until backend-driven gating replaces this switch.
const bool kEnableOnboardingFlow = false;

/// Owns a nested [Navigator] for onboarding-only screens (intro carousel → auth → initial info → done).
/// Child routes that leave onboarding for the main app must replace the stack with
/// the home shell via `AppNavigation.replaceWithHome` (see `core/navigation/app_navigation.dart`;
/// uses the root navigator).
class OnboardingFlowScreen extends StatelessWidget {
  const OnboardingFlowScreen({super.key});

  static const String introRoute = '/onboarding/intro';
  static const String authRoute = '/onboarding/auth';

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: introRoute,
      onGenerateRoute: (RouteSettings settings) {
        final Widget page = switch (settings.name) {
          introRoute => const PhysicalTherapyScreen(),
          authRoute => const SignupAndLoginScreen(),
          _ => const SignupAndLoginScreen(),
        };
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => page,
        );
      },
    );
  }
}
