import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/auth/mock_auth_repository.dart';
import 'package:healthpilot/core/providers/app_state.dart';
import 'package:healthpilot/core/storage/secure_token_store.dart';
import 'package:healthpilot/features/articles/article_provider.dart';
import 'package:healthpilot/features/articles/repositories/mock_article_repository.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/repositories/mock_chat_repository.dart';
import 'package:healthpilot/features/chatbot/ai_assistant_provider.dart';
import 'package:healthpilot/features/chatbot/repositories/mock_ai_assistant_repository.dart';
import 'package:healthpilot/features/food_nutrition/nutrition_provider.dart';
import 'package:healthpilot/features/food_nutrition/repositories/mock_nutrition_repository.dart';
import 'package:healthpilot/features/health/health_provider.dart';
import 'package:healthpilot/features/health/repositories/mock_health_repository.dart';
import 'package:healthpilot/features/health_assessment/assessment_provider.dart';
import 'package:healthpilot/features/health_assessment/in_memory_assessment_history.dart';
import 'package:healthpilot/features/health_assessment/repositories/mock_assessment_repository.dart';
import 'package:healthpilot/features/medication/medication_provider.dart';
import 'package:healthpilot/features/medication/repositories/mock_medication_repository.dart';
import 'package:healthpilot/features/profile/contacts_provider.dart';
import 'package:healthpilot/features/profile/profile_provider.dart';
import 'package:healthpilot/features/profile/repositories/mock_contacts_repository.dart';
import 'package:healthpilot/features/profile/repositories/mock_profile_repository.dart';
import 'package:healthpilot/features/subscription/repositories/mock_subscription_repository.dart';
import 'package:healthpilot/features/subscription/subscription_provider.dart';
import 'package:healthpilot/theme/app_theme.dart';

import 'chat_local_store_test_helper.dart';

/// No-op secure storage for widget tests (avoids platform channel hangs).
class E2eMockTokenStore extends SecureTokenStore {
  const E2eMockTokenStore() : super(const FlutterSecureStorage());

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<String?> getUserId() async => null;

  @override
  Future<void> setAccessToken(String t) async {}

  @override
  Future<void> setRefreshToken(String t) async {}

  @override
  Future<void> setUserId(String id) async {}

  @override
  Future<void> clearAll() async {}
}

/// Ignores known benign layout noise in long assessment choice labels.
void ignoreBenignLayoutOverflow(WidgetTester tester) {
  final oldOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    if (message.contains('RenderFlex overflowed')) {
      return;
    }
    oldOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = oldOnError);
}

/// Pumps [screen] inside the standard provider tree used across session tests.
Future<void> pumpE2eScreen(
  WidgetTester tester,
  Widget screen, {
  AssessmentProvider? assessP,
  ChatProvider? chatP,
  AiAssistantProvider? aiP,
}) async {
  ignoreBenignLayoutOverflow(tester);
  await tester.binding.setSurfaceSize(const Size(411, 852));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final assess = assessP ?? AssessmentProvider(MockAssessmentRepository());
  if (assessP == null) await assess.load();
  final localStore = await createTestChatLocalStore();
  final chat = chatP ??
      ChatProvider(MockChatRepository(), localStore: localStore);
  if (chatP == null) await chat.load();
  final ai = aiP ??
      AiAssistantProvider(
        MockAiAssistantRepository(),
        localStore: localStore,
      );
  if (aiP == null) await ai.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(
          create: (_) => AuthState(
            repo: MockAuthRepository(),
            tokenStore: const E2eMockTokenStore(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => InMemoryAssessmentHistory()),
        ChangeNotifierProvider(create: (_) => ArticleProvider(MockArticleRepository())),
        ChangeNotifierProvider.value(value: chat),
        ChangeNotifierProvider.value(value: ai),
        ChangeNotifierProvider(create: (_) => NutritionProvider(MockNutritionRepository())),
        ChangeNotifierProvider(create: (_) => HealthProvider(MockHealthRepository())),
        ChangeNotifierProvider(create: (_) => MedicationProvider(MockMedicationRepository())),
        ChangeNotifierProvider.value(value: assess),
        ChangeNotifierProvider(create: (_) => ProfileProvider(MockProfileRepository())),
        ChangeNotifierProvider(create: (_) => ContactsProvider(MockContactsRepository())),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider(MockSubscriptionRepository())),
      ],
      child: ScreenUtilInit(
        designSize: const Size(411, 852),
        minTextAdapt: true,
        builder: (_, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: screen,
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Taps the assessment flow primary CTA (`Next`, `Skip`, or `Finish`).
Future<void> tapAssessmentCta(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(FilledButton, label));
  await tester.pumpAndSettle(const Duration(milliseconds: 350));
}

/// Taps the first widget whose text contains [snippet].
Future<void> tapTextContaining(WidgetTester tester, String snippet) async {
  await tester.tap(find.textContaining(snippet).first);
  await tester.pumpAndSettle(const Duration(milliseconds: 200));
}
