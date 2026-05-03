import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:healthpilot/core/providers/app_state.dart';
import 'package:healthpilot/features/articles/article_screen.dart';
import 'package:healthpilot/features/chat/chat_screen.dart';
import 'package:healthpilot/features/chat/group_chat_screen.dart';
import 'package:healthpilot/features/chat/general_chat_screen.dart';
import 'package:healthpilot/features/health/health_profile_screen.dart';
import 'package:healthpilot/features/home/home_page_screen.dart';
import 'package:healthpilot/features/profile/profile_screen.dart';
import 'package:healthpilot/features/profile/settings_screen.dart';
import 'package:healthpilot/features/health_assessment/in_memory_assessment_history.dart';
import 'package:healthpilot/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef WidgetBuilderFn = Widget Function();

class _Scenario {
  const _Scenario({
    required this.name,
    required this.size,
    required this.textScaleFactor,
    required this.themeMode,
  });

  final String name;
  final Size size;
  final double textScaleFactor;
  final ThemeMode themeMode;
}

Future<void> _pumpScenario(
  WidgetTester tester, {
  required _Scenario scenario,
  required Widget child,
}) async {
  await tester.binding.setSurfaceSize(scenario.size);

  final appState = AppState();
  // Ensure deterministic theme for the scenario (ignore persisted value).
  await appState.setThemeMode(scenario.themeMode);

  final errors = <FlutterErrorDetails>[];
  final oldOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    errors.add(details);
  };

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<InMemoryAssessmentHistory>(
          create: (_) => InMemoryAssessmentHistory(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(411, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: scenario.themeMode,
          home: MediaQuery(
            data: MediaQueryData(
              size: scenario.size,
              textScaler: TextScaler.linear(scenario.textScaleFactor),
            ),
            child: child,
          ),
        ),
      ),
    ),
  );

  // Let layout + async image decode/etc settle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));

  FlutterError.onError = oldOnError;
  await tester.binding.setSurfaceSize(null);

  // Treat ANY FlutterError as a failure (RenderFlex overflow, constraints, etc).
  if (errors.isNotEmpty) {
    final msg = errors
        .map((e) => e.toString())
        .take(3)
        .join('\n---\n');
    fail('Scenario ${scenario.name} produced FlutterError(s):\n$msg');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  final scenarios = <_Scenario>[
    const _Scenario(
      name: 'phone-small-light-1.0x',
      size: Size(360, 640),
      textScaleFactor: 1.0,
      themeMode: ThemeMode.light,
    ),
    const _Scenario(
      name: 'phone-small-dark-1.0x',
      size: Size(360, 640),
      textScaleFactor: 1.0,
      themeMode: ThemeMode.dark,
    ),
    const _Scenario(
      name: 'phone-small-dark-1.3x',
      size: Size(360, 640),
      textScaleFactor: 1.3,
      themeMode: ThemeMode.dark,
    ),
    const _Scenario(
      name: 'phone-compact-dark-1.4x',
      size: Size(375, 667),
      textScaleFactor: 1.4,
      themeMode: ThemeMode.dark,
    ),
  ];

  final screens = <String, WidgetBuilderFn>{
    'HomePageScreen': () => const HomePageScreen(isHelpPressed: false),
    'ProfileScreen': () => const ProfileScreen(),
    'SettingsScreen': () => const SettingsScreen(),
    'Articles': () => const ArticleScreen(),
    'Chat 1:1': () => const ChatScreen(senderId: '1', userId: '123'),
    'Chat group': () => const GroupChatScreen(groupId: 'g1', userId: '123'),
    'Chat inbox': () => const GeneralChatScreen(showBackButton: false),
    'Health tab': () => const HealthProfile(),
  };

  for (final scenario in scenarios) {
    for (final entry in screens.entries) {
      testWidgets('layout smoke: ${entry.key} @ ${scenario.name}',
          (WidgetTester tester) async {
        await _pumpScenario(
          tester,
          scenario: scenario,
          child: entry.value(),
        );
      });
    }
  }
}

