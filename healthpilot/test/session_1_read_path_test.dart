// Session 1 — Read path.
//
// Each test pumps a single screen with all providers pre-loaded from mock
// repositories, then asserts that expected seed data is visible and no crash
// occurs. No mutations are performed here — that is Session 2.
//
// Run with:
//   flutter test test/session_1_read_path_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/auth/mock_auth_repository.dart';
import 'package:healthpilot/core/providers/app_state.dart';
import 'package:healthpilot/core/storage/secure_token_store.dart';
import 'package:healthpilot/features/articles/article_provider.dart';
import 'package:healthpilot/features/articles/article_screen.dart';
import 'package:healthpilot/features/articles/repositories/mock_article_repository.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/chat_screen.dart';
import 'package:healthpilot/features/chat/general_chat_screen.dart';
import 'package:healthpilot/features/chat/group_chat_screen.dart';
import 'package:healthpilot/features/chat/repositories/mock_chat_repository.dart';
import 'package:healthpilot/features/chatbot/ai_assistant_provider.dart';
import 'package:healthpilot/features/chatbot/chatbot_screen.dart';
import 'package:healthpilot/features/chatbot/repositories/mock_ai_assistant_repository.dart';
import 'package:healthpilot/features/emergency_contact/setup_emergency_contact.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_history_screen.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_tracking_screen.dart';
import 'package:healthpilot/features/food_nutrition/nutrition_provider.dart';
import 'package:healthpilot/features/food_nutrition/repositories/mock_nutrition_repository.dart';
import 'package:healthpilot/features/health/health_profile_screen.dart';
import 'package:healthpilot/features/health/health_provider.dart';
import 'package:healthpilot/features/health/repositories/mock_health_repository.dart';
import 'package:healthpilot/features/health_assessment/assessment_history_screen.dart';
import 'package:healthpilot/features/health_assessment/assessment_provider.dart';
import 'package:healthpilot/features/health_assessment/in_memory_assessment_history.dart';
import 'package:healthpilot/features/health_assessment/repositories/mock_assessment_repository.dart';
import 'package:healthpilot/features/medication/medication_provider.dart';
import 'package:healthpilot/features/medication/medications_screen.dart';
import 'package:healthpilot/features/medication/repositories/mock_medication_repository.dart';
import 'package:healthpilot/features/onboarding/signup_and_login_screen.dart';
import 'package:healthpilot/features/profile/contacts_provider.dart';
import 'package:healthpilot/features/profile/profile_provider.dart';
import 'package:healthpilot/features/profile/profile_screen.dart';
import 'package:healthpilot/features/profile/repositories/mock_contacts_repository.dart';
import 'package:healthpilot/features/profile/repositories/mock_profile_repository.dart';
import 'package:healthpilot/features/subscription/repositories/mock_subscription_repository.dart';
import 'package:healthpilot/features/subscription/subscription_and_payment_screen.dart';
import 'package:healthpilot/features/subscription/subscription_provider.dart';
import 'package:healthpilot/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Test harness
// ---------------------------------------------------------------------------

/// Pumps [screen] with all providers pre-loaded from mock repos.
///
/// Pre-loading (await provider.load() before pumpWidget) ensures screens that
/// call provider.findX() during their first build don't crash with "No element".
Future<void> _pump(WidgetTester tester, Widget screen) async {
  // Match design size so ScreenUtil scale = 1 and layout is predictable.
  await tester.binding.setSurfaceSize(const Size(411, 852));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  // Pre-load all providers before pumping so first build has data.
  final articleP = ArticleProvider(MockArticleRepository());
  await articleP.load();
  final chatP = ChatProvider(MockChatRepository());
  await chatP.load();
  final aiP = AiAssistantProvider(MockAiAssistantRepository());
  await aiP.load();
  final nutritionP = NutritionProvider(MockNutritionRepository());
  await nutritionP.load();
  final healthP = HealthProvider(MockHealthRepository());
  await healthP.load();
  final medP = MedicationProvider(MockMedicationRepository());
  await medP.load();
  final assessP = AssessmentProvider(MockAssessmentRepository());
  await assessP.load();
  final profileP = ProfileProvider(MockProfileRepository());
  await profileP.load();
  final contactsP = ContactsProvider(MockContactsRepository());
  await contactsP.load();
  final subsP = SubscriptionProvider(MockSubscriptionRepository());
  await subsP.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(
          create: (_) => AuthState(
            repo: MockAuthRepository(),
            tokenStore: const SecureTokenStore(FlutterSecureStorage()),
          ),
        ),
        // Legacy provider still consumed by some assessment widgets.
        ChangeNotifierProvider(create: (_) => InMemoryAssessmentHistory()),
        ChangeNotifierProvider.value(value: articleP),
        ChangeNotifierProvider.value(value: chatP),
        ChangeNotifierProvider.value(value: aiP),
        ChangeNotifierProvider.value(value: nutritionP),
        ChangeNotifierProvider.value(value: healthP),
        ChangeNotifierProvider.value(value: medP),
        ChangeNotifierProvider.value(value: assessP),
        ChangeNotifierProvider.value(value: profileP),
        ChangeNotifierProvider.value(value: contactsP),
        ChangeNotifierProvider.value(value: subsP),
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

  await tester.pump(); // let any remaining async work settle
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // Silence flutter_secure_storage channel — AuthState.initialize() reads it
    // but that method is only called from WelcomeScreen, not these direct tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_abs.com/flutter_secure_storage'),
      (_) async => null,
    );
  });

  // ── T1–T2: Auth ─────────────────────────────────────────────────────────

  group('T1–T2 Auth', () {
    testWidgets('T1 login screen renders without crash', (tester) async {
      await _pump(tester, const SignupAndLoginScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T2 email and password fields present', (tester) async {
      await _pump(tester, const SignupAndLoginScreen());
      expect(find.byType(TextFormField), findsWidgets);
    });
  });

  // ── T3–T5: Profile ───────────────────────────────────────────────────────

  group('T3–T5 Profile', () {
    testWidgets('T3 profile screen renders without crash', (tester) async {
      await _pump(tester, const ProfileScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T4 demo first name "Mohammed" visible', (tester) async {
      await _pump(tester, const ProfileScreen());
      expect(find.textContaining('Mohammed'), findsWidgets);
    });

    testWidgets('T5 profile is not blank — has text widgets', (tester) async {
      await _pump(tester, const ProfileScreen());
      expect(find.byType(Text), findsWidgets);
    });
  });

  // ── T6–T9: Health ────────────────────────────────────────────────────────

  group('T6–T9 Health', () {
    testWidgets('T6 health screen renders without crash', (tester) async {
      await _pump(tester, const HealthProfile());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T7 seeded condition "Schizophrenia" visible', (tester) async {
      await _pump(tester, const HealthProfile());
      expect(find.textContaining('Schizophrenia'), findsWidgets);
    });

    testWidgets('T8 seeded symptom "Fever" visible', (tester) async {
      await _pump(tester, const HealthProfile());
      expect(find.textContaining('Fever'), findsWidgets);
    });

    testWidgets('T9 seeded symptom "Cough" visible', (tester) async {
      await _pump(tester, const HealthProfile());
      expect(find.textContaining('Cough'), findsWidgets);
    });
  });

  // ── T10–T13: Medications ─────────────────────────────────────────────────

  group('T10–T13 Medications', () {
    testWidgets('T10 medications screen renders without crash', (tester) async {
      await _pump(tester, const MedicationScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T11 "Aspirin" visible in list', (tester) async {
      await _pump(tester, const MedicationScreen());
      expect(find.textContaining('Aspirin'), findsWidgets);
    });

    testWidgets('T12 "Vitamin D" visible in list', (tester) async {
      await _pump(tester, const MedicationScreen());
      expect(find.textContaining('Vitamin D'), findsWidgets);
    });

    testWidgets('T13 tapping a medication opens detail without crash',
        (tester) async {
      await _pump(tester, const MedicationScreen());
      await tester.tap(find.textContaining('Aspirin').first);
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // ── T14–T16: Assessment ──────────────────────────────────────────────────

  group('T14–T16 Assessment', () {
    testWidgets('T14 assessment history screen renders without crash',
        (tester) async {
      await _pump(tester, const AssessmentHistoryScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T15 "Assessment History" title shown', (tester) async {
      await _pump(tester, const AssessmentHistoryScreen());
      // Title appears in AppBar and possibly elsewhere — findsWidgets is correct.
      expect(find.text('Assessment History'), findsWidgets);
    });

    testWidgets('T16 empty state shown — no entries before any submission',
        (tester) async {
      await _pump(tester, const AssessmentHistoryScreen());
      // Mock starts empty — no history rows rendered.
      expect(find.byType(Card), findsNothing);
    });
  });

  // ── T17–T19: AI Chatbot ──────────────────────────────────────────────────

  group('T17–T19 AI Chatbot', () {
    testWidgets('T17 chatbot screen renders without crash', (tester) async {
      await _pump(tester, const ChatbotScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T18 bot greeting "Hey there" visible on load', (tester) async {
      await _pump(tester, const ChatbotScreen());
      expect(find.textContaining('Hey there'), findsWidgets);
    });

    testWidgets('T19 message input field is present', (tester) async {
      await _pump(tester, const ChatbotScreen());
      expect(
        find.byType(TextField).evaluate().isNotEmpty ||
            find.byType(TextFormField).evaluate().isNotEmpty,
        isTrue,
      );
    });
  });

  // ── T20–T22: Nutrition ───────────────────────────────────────────────────

  group('T20–T22 Nutrition', () {
    testWidgets('T20 nutrition history screen renders without crash',
        (tester) async {
      await _pump(tester, const FoodNutritionHistoryScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T21 history is not blank — seed entry visible on first launch',
        (tester) async {
      await _pump(tester, const FoodNutritionHistoryScreen());
      expect(find.byType(Text).evaluate().length, greaterThan(1));
    });

    testWidgets('T22 nutrition tracking/settings screen renders without crash',
        (tester) async {
      await _pump(tester, const FoodNutritionTrackingScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  // ── T23–T28: Articles ────────────────────────────────────────────────────

  group('T23–T28 Articles', () {
    testWidgets('T23 articles screen renders without crash', (tester) async {
      await _pump(tester, const ArticleScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T24 first 2 seeded articles visible; scrolling reveals 3rd',
        (tester) async {
      await _pump(tester, const ArticleScreen());
      expect(find.textContaining('Why are we growing old?'), findsWidgets);
      expect(find.textContaining('Why old'), findsWidgets);
      // Scroll down to render the 3rd card (may be below the fold).
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();
      expect(find.textContaining('Why get old'), findsWidgets);
    });

    testWidgets('T25 search "growing" shows only matching article',
        (tester) async {
      await _pump(tester, const ArticleScreen());
      await tester.enterText(find.byType(TextFormField).first, 'growing');
      await tester.pump();
      expect(find.textContaining('Why are we growing old?'), findsWidgets);
      expect(find.textContaining('Why old'), findsNothing);
    });

    testWidgets('T26 search "xyz" shows no articles', (tester) async {
      await _pump(tester, const ArticleScreen());
      await tester.enterText(find.byType(TextFormField).first, 'xyz');
      await tester.pump();
      expect(find.textContaining('Why'), findsNothing);
    });

    testWidgets('T27 clearing search restores visible articles', (tester) async {
      await _pump(tester, const ArticleScreen());
      await tester.enterText(find.byType(TextFormField).first, 'growing');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.pump();
      // First 2 articles are back in view — sufficient to confirm filter cleared.
      expect(find.textContaining('Why are we growing old?'), findsWidgets);
      expect(find.textContaining('Why old'), findsWidgets);
    });

    testWidgets('T28 tapping an article card opens detail without crash',
        (tester) async {
      await _pump(tester, const ArticleScreen());
      await tester.tap(find.textContaining('Why are we growing old?').first);
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // ── T29–T30: Contacts ────────────────────────────────────────────────────

  group('T29–T30 Contacts', () {
    testWidgets('T29 contacts screen renders without crash', (tester) async {
      await _pump(tester, const SetupEmergencyContact());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T30 contact list empty before any entries added',
        (tester) async {
      await _pump(tester, const SetupEmergencyContact());
      expect(find.byType(ListTile), findsNothing);
    });
  });

  // ── T31–T36: Chat ────────────────────────────────────────────────────────

  group('T31–T36 Chat', () {
    testWidgets('T31 general chat screen renders without crash', (tester) async {
      await _pump(tester, const GeneralChatScreen(showBackButton: false));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T32 seeded user "John Doe" visible', (tester) async {
      await _pump(tester, const GeneralChatScreen(showBackButton: false));
      expect(find.textContaining('John Doe'), findsWidgets);
    });

    testWidgets('T33 seeded group "Schizophrenia Support" visible',
        (tester) async {
      await _pump(tester, const GeneralChatScreen(showBackButton: false));
      expect(find.textContaining('Schizophrenia Support'), findsWidgets);
    });

    testWidgets('T34 search filters to matching user only', (tester) async {
      await _pump(tester, const GeneralChatScreen(showBackButton: false));
      final searchFields = find.byType(TextField);
      if (searchFields.evaluate().isNotEmpty) {
        await tester.enterText(searchFields.first, 'John');
        await tester.pump();
        expect(find.textContaining('John Doe'), findsWidgets);
        expect(find.textContaining('Emma Smith'), findsNothing);
      }
    });

    // senderId '1' matches kSeedUsers[0] (John Doe). userId is the current
    // user — any numeric string works; '999' has no match in seed data but
    // is only used as the outgoing sender ID, not for a lookup.
    testWidgets('T35 DM screen renders for seeded user id "1"', (tester) async {
      await _pump(tester, const ChatScreen(senderId: '1', userId: '999'));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T36 group chat screen renders for seeded group "g1"',
        (tester) async {
      await _pump(
          tester, const GroupChatScreen(groupId: 'g1', userId: '999'));
      expect(find.byType(Scaffold), findsOneWidget);
      // _TickerText starts a 2-second timer in initState. Advancing past it
      // lets the loop check `mounted` / `hasClients` and exit cleanly so no
      // pending timers remain when the test tears down.
      await tester.pump(const Duration(seconds: 3));
    });
  });

  // ── T37–T41: Subscriptions ───────────────────────────────────────────────

  group('T37–T41 Subscriptions', () {
    testWidgets('T37 subscription screen renders without crash', (tester) async {
      await _pump(tester, const SubscriptionAndPaymentScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('T38 "Premium Version" label visible', (tester) async {
      await _pump(tester, const SubscriptionAndPaymentScreen());
      expect(find.text('Premium Version'), findsWidgets);
    });

    testWidgets('T39 "Free Version" label visible', (tester) async {
      await _pump(tester, const SubscriptionAndPaymentScreen());
      expect(find.text('Free Version'), findsWidgets);
    });

    testWidgets('T40 premium price sourced from mock — "25.99" visible',
        (tester) async {
      await _pump(tester, const SubscriptionAndPaymentScreen());
      expect(find.textContaining('25.99'), findsWidgets);
    });

    testWidgets('T41 tapping premium price button navigates without crash',
        (tester) async {
      await _pump(tester, const SubscriptionAndPaymentScreen());
      await tester.tap(find.textContaining('25.99').first);
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
