import 'package:flutter/material.dart';
import 'package:healthpilot/features/onboarding/signup_and_login_screen.dart';

/// When `true`, [WelcomeScreen] routes into [OnboardingFlowScreen] instead of home.
/// Default stays `false` until backend-driven gating replaces this switch.
const bool kEnableOnboardingFlow = false;

/// Owns a nested [Navigator] for onboarding-only screens (auth → initial info → done).
/// Child routes that leave onboarding for the main app must use
/// `Navigator.of(context, rootNavigator: true)` when pushing [HomePageScreen].
class OnboardingFlowScreen extends StatelessWidget {
  const OnboardingFlowScreen({super.key});

  static const String authRoute = '/onboarding/auth';

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: authRoute,
      onGenerateRoute: (RouteSettings settings) {
        final Widget page = switch (settings.name) {
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
