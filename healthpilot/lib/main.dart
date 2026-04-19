import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:healthpilot/core/providers/app_state.dart';
import 'package:healthpilot/features/health_assessment/in_memory_assessment_history.dart';
import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/asset_paths.dart';
import 'package:healthpilot/features/home/home_page_screen.dart';
import 'package:healthpilot/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<InMemoryAssessmentHistory>(
          create: (_) => InMemoryAssessmentHistory(),
        ),
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
  void goToNextScreen() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePageScreen(isHelpPressed: false),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    goToNextScreen();
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
