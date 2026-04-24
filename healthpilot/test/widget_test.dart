import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthpilot/core/providers/app_state.dart';
import 'package:healthpilot/features/health_assessment/in_memory_assessment_history.dart';
import 'package:healthpilot/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HealthPilotApp builds and leaves splash', (WidgetTester tester) async {
    await tester.pumpWidget(
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
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);

    // WelcomeScreen delays ~2s before replacing with home/onboarding.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.byType(Scaffold), findsWidgets);
  });
}
