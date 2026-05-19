import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/di/repository_locator.dart';
import 'package:healthpilot/core/network/api_interceptors.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/core/localization/app_locales.dart';
import 'package:healthpilot/core/providers/app_state.dart';
import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/asset_paths.dart';
import 'package:healthpilot/features/home/home_page_screen.dart';
import 'package:healthpilot/features/onboarding/onboarding_flow_screen.dart';
import 'package:healthpilot/features/onboarding/signup_and_login_screen.dart';
import 'package:healthpilot/theme/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LoggingInterceptor.init();
  RepositoryLocator.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ...RepositoryLocator.providers,
      ],
      child: const HealthPilotApp(),
    ),
  );
}

class HealthPilotApp extends StatelessWidget {
  const HealthPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(411, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<AppState>(
            builder: (context, appState, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Health Pilot',
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: appState.themeMode,
                locale: appState.locale,
                supportedLocales: AppLocales.supportedLocales,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const WelcomeScreen(),
              );
            },
          );
        });
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future<void> _goToNextScreen() async {
    final auth = context.read<AuthState>();
    // Wait for auth init and a minimum splash display time in parallel.
    await Future.wait([
      auth.initialize(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted) return;

    final Widget next;
    if (!FeatureFlags.auth || auth.status == AuthStatus.authenticated) {
      next = kEnableOnboardingFlow
          ? const OnboardingFlowScreen()
          : const HomePageScreen(isHelpPressed: false);
    } else {
      next = const SignupAndLoginScreen();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => next),
    );
  }

  @override
  void initState() {
    super.initState();
    _goToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SafeRasterAsset(
            AssetPaths.welcomeLogo,
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
