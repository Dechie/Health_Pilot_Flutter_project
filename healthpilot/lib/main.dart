import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:healthpilot/core/auth/activation_link_handler.dart';
import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/debug/dev_startup_log.dart';
import 'package:healthpilot/core/di/repository_locator.dart';
import 'package:healthpilot/core/network/api_interceptors.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/core/navigation/app_navigation.dart';
import 'package:healthpilot/core/localization/app_locales.dart';
import 'package:healthpilot/core/providers/app_state.dart';
import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/asset_paths.dart';
import 'package:healthpilot/features/auth/activation_screen.dart';
import 'package:healthpilot/features/home/home_page_screen.dart';
import 'package:healthpilot/features/onboarding/signup_and_login_screen.dart';
import 'package:healthpilot/features/personal_info/initial_info_1.dart';
import 'package:healthpilot/features/personal_info/initial_info_2.dart';
import 'package:healthpilot/features/personal_info/initial_info_3.dart';
import 'package:healthpilot/features/personal_info/initial_info_4.dart';
import 'package:healthpilot/theme/app_theme.dart';
import 'package:provider/provider.dart';

final ActivationLinkHandler activationLinkHandler = ActivationLinkHandler();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LoggingInterceptor.init();
  RepositoryLocator.initialize();
  await activationLinkHandler.init();
  logDevStartupConfig();
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

class HealthPilotApp extends StatefulWidget {
  const HealthPilotApp({super.key});

  @override
  State<HealthPilotApp> createState() => _HealthPilotAppState();
}

class _HealthPilotAppState extends State<HealthPilotApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  AuthStatus _prevAuthStatus = AuthStatus.unknown;
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
    activationLinkHandler.onLinkToken = _activateFromEmailLink;
  }

  Future<void> _activateFromEmailLink(String token) async {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    final auth = ctx.read<AuthState>();
    if (!auth.isActivationPending && auth.status == AuthStatus.authenticated) {
      return;
    }
    try {
      await auth.activate(token);
      if (!ctx.mounted) return;
      Navigator.of(ctx).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const InitialInfoFirst()),
        (_) => false,
      );
    } on Object {
      if (!ctx.mounted) return;
      Navigator.of(ctx).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => ActivationScreen(initialToken: token),
        ),
        (_) => false,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerAdded) {
      context.read<AuthState>().addListener(_onAuthChanged);
      _listenerAdded = true;
    }
  }

  void _onAuthChanged() {
    final auth = context.read<AuthState>();
    if (_prevAuthStatus == AuthStatus.authenticated &&
        auth.status == AuthStatus.unauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppNavigation.replaceWithLogin(
          _navigatorKey.currentContext!,
          useRootNavigator: false,
        );
      });
    }
    _prevAuthStatus = auth.status;
  }

  @override
  void dispose() {
    activationLinkHandler.onLinkToken = null;
    context.read<AuthState>().removeListener(_onAuthChanged);
    super.dispose();
  }

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
                navigatorKey: _navigatorKey,
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
  Widget _onboardingStepScreen(int step) => switch (step) {
        2 => const InitialInfoSecond(),
        3 => const InitialInfoThird(),
        4 => const InitialInfoFinal(),
        _ => const InitialInfoFirst(),
      };

  Future<void> _goToNextScreen() async {
    final auth = context.read<AuthState>();
    // Wait for auth init and a minimum splash display time in parallel.
    await Future.wait([
      auth.initialize(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted) return;

    final Widget next;
    if (!FeatureFlags.auth) {
      next = const HomePageScreen(isHelpPressed: false);
    } else if (auth.status == AuthStatus.authenticated) {
      next = auth.isOnboardingCompleted
          ? const HomePageScreen(isHelpPressed: false)
          : _onboardingStepScreen(auth.onboardingStep);
    } else {
      next = auth.isActivationPending
          ? ActivationScreen(
              initialToken: activationLinkHandler.initialToken,
            )
          : const SignupAndLoginScreen();
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
