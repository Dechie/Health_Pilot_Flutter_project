// Session 2 — Write path.
//
// Each test performs a mutation and verifies that the provider state reflects
// the change immediately. Navigation tests verify the correct destination
// screen appears. No persistence to disk is assumed except for the nutrition
// mock which delegates to SharedPreferences.
//
// Run with:
//   flutter test test/session_2_write_path_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/auth/mock_auth_repository.dart';
import 'package:healthpilot/core/providers/app_state.dart';
import 'package:healthpilot/core/storage/secure_token_store.dart';

import 'package:healthpilot/features/articles/article_provider.dart';
import 'package:healthpilot/features/articles/article_detail_screen.dart';
import 'package:healthpilot/features/articles/article_screen.dart';
import 'package:healthpilot/features/articles/repositories/mock_article_repository.dart';

import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/general_chat_screen.dart';
import 'package:healthpilot/features/chat/repositories/mock_chat_repository.dart';

import 'package:healthpilot/features/chatbot/ai_assistant_provider.dart';
import 'package:healthpilot/features/chatbot/chatbot_screen.dart';
import 'package:healthpilot/features/chatbot/repositories/mock_ai_assistant_repository.dart';

import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';
import 'package:healthpilot/features/food_nutrition/nutrition_provider.dart';
import 'package:healthpilot/features/food_nutrition/repositories/mock_nutrition_repository.dart';

import 'package:healthpilot/features/health/health_models.dart';
import 'package:healthpilot/features/health/health_provider.dart';
import 'package:healthpilot/features/health/repositories/mock_health_repository.dart';

import 'package:healthpilot/features/health_assessment/assessment_provider.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_subject.dart';
import 'package:healthpilot/features/health_assessment/in_memory_assessment_history.dart';
import 'package:healthpilot/features/health_assessment/repositories/mock_assessment_repository.dart';

import 'package:healthpilot/features/medication/medication_models.dart';
import 'package:healthpilot/features/medication/medication_provider.dart';
import 'package:healthpilot/features/medication/repositories/mock_medication_repository.dart';

import 'package:healthpilot/features/profile/contacts_provider.dart';
import 'package:healthpilot/features/profile/personal_info_contact_models.dart';
import 'package:healthpilot/features/profile/personal_information_screen.dart';
import 'package:healthpilot/features/profile/profile_provider.dart';
import 'package:healthpilot/features/profile/repositories/mock_contacts_repository.dart';
import 'package:healthpilot/features/profile/repositories/mock_profile_repository.dart';

import 'package:healthpilot/features/subscription/repositories/mock_subscription_repository.dart';
import 'package:healthpilot/features/subscription/subscription_and_payment_screen.dart';
import 'package:healthpilot/features/subscription/subscription_provider.dart';

import 'package:healthpilot/theme/app_theme.dart';

import 'helpers/chat_local_store_test_helper.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Token store that no-ops all storage calls so tests never hit the platform
/// channel for FlutterSecureStorage (which hangs on Linux without a daemon).
class _MockTokenStore extends SecureTokenStore {
  const _MockTokenStore() : super(const FlutterSecureStorage());

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

// ---------------------------------------------------------------------------
// Test harness
// ---------------------------------------------------------------------------

/// Pre-loads all providers and pumps [screen] inside a fully-wired app.
/// Pass a pre-built provider to observe its state after UI interactions.
Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  ArticleProvider? articleP,
  ChatProvider? chatP,
  AiAssistantProvider? aiP,
  NutritionProvider? nutritionP,
  HealthProvider? healthP,
  MedicationProvider? medP,
  AssessmentProvider? assessP,
  ProfileProvider? profileP,
  ContactsProvider? contactsP,
  SubscriptionProvider? subsP,
}) async {
  await tester.binding.setSurfaceSize(const Size(411, 852));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final article = articleP ?? ArticleProvider(MockArticleRepository());
  await article.load();
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
  final nutrition = nutritionP ?? NutritionProvider(MockNutritionRepository());
  await nutrition.load();
  final health = healthP ?? HealthProvider(MockHealthRepository());
  await health.load();
  final med = medP ?? MedicationProvider(MockMedicationRepository());
  await med.load();
  final assess = assessP ?? AssessmentProvider(MockAssessmentRepository());
  await assess.load();
  final profile = profileP ?? ProfileProvider(MockProfileRepository());
  await profile.load();
  final contacts = contactsP ?? ContactsProvider(MockContactsRepository());
  await contacts.load();
  final subs = subsP ?? SubscriptionProvider(MockSubscriptionRepository());
  await subs.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(
          create: (_) => AuthState(
            repo: MockAuthRepository(),
            tokenStore: const _MockTokenStore(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => InMemoryAssessmentHistory()),
        ChangeNotifierProvider.value(value: article),
        ChangeNotifierProvider.value(value: chat),
        ChangeNotifierProvider.value(value: ai),
        ChangeNotifierProvider.value(value: nutrition),
        ChangeNotifierProvider.value(value: health),
        ChangeNotifierProvider.value(value: med),
        ChangeNotifierProvider.value(value: assess),
        ChangeNotifierProvider.value(value: profile),
        ChangeNotifierProvider.value(value: contacts),
        ChangeNotifierProvider.value(value: subs),
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

AssessmentSummary _stubSummary() => const AssessmentSummary(
      subject: HealthAssessmentSubject.myself,
      bloodType: BloodType.a,
      allergies: 'none',
      symptoms: ['Headache'],
      symptomDuration: '2 days',
      hasOtherSymptoms: false,
      symptomsTrend: 'stable',
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_abs.com/flutter_secure_storage'),
      (_) async => null,
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  // ── W1–W2: Auth ──────────────────────────────────────────────────────────

  group('W1–W2 Auth', () {
    testWidgets('W1 logout sets status to unauthenticated', (tester) async {
      final auth = AuthState(
        repo: MockAuthRepository(),
        tokenStore: const _MockTokenStore(),
      );
      // Simulate an authenticated session by logging in first.
      await auth.login('user@example.com', 'pass');
      expect(auth.status, AuthStatus.authenticated);

      await auth.logout();
      expect(auth.status, AuthStatus.unauthenticated);
    });

    testWidgets('W2 login after logout restores authenticated status',
        (tester) async {
      final auth = AuthState(
        repo: MockAuthRepository(),
        tokenStore: const _MockTokenStore(),
      );
      await auth.login('user@example.com', 'pass');
      await auth.logout();
      await auth.login('user@example.com', 'pass');
      expect(auth.status, AuthStatus.authenticated);
    });
  });

  // ── W3–W4: Profile ───────────────────────────────────────────────────────

  group('W3–W4 Profile', () {
    testWidgets('W3 save updates profile in provider immediately',
        (tester) async {
      final profileP = ProfileProvider(MockProfileRepository());
      await profileP.load();
      await profileP.save(profileP.profile.copyWith(firstName: 'Aisha'));
      expect(profileP.profile.firstName, 'Aisha');
    });

    testWidgets('W4 provider holds edited state across reads', (tester) async {
      final profileP = ProfileProvider(MockProfileRepository());
      await profileP.load();
      await profileP.save(profileP.profile.copyWith(firstName: 'Aisha'));
      // Reading the same provider instance again reflects the edit.
      expect(profileP.profile.firstName, 'Aisha');
    });
  });

  // ── W5–W7: Health ────────────────────────────────────────────────────────

  group('W5–W7 Health', () {
    testWidgets('W5 add condition appears at top of list', (tester) async {
      final healthP = HealthProvider(MockHealthRepository());
      await healthP.load();
      final initial = healthP.conditions.length;
      await healthP.addCondition(
        const HealthCondition(name: 'Diabetes', loggedAt: '2026-05-12'),
      );
      expect(healthP.conditions.length, initial + 1);
      expect(healthP.conditions.first.name, 'Diabetes');
    });

    testWidgets('W6 add symptom appears in list', (tester) async {
      final healthP = HealthProvider(MockHealthRepository());
      await healthP.load();
      final initial = healthP.symptoms.length;
      await healthP.addSymptom(
        const HealthSymptom(
          name: 'Nausea',
          severity: 3,
          loggedAt: '2026-05-12',
        ),
      );
      expect(healthP.symptoms.length, initial + 1);
      expect(healthP.symptoms.any((s) => s.name == 'Nausea'), isTrue);
    });

    testWidgets('W7 delete condition removes it from list', (tester) async {
      final healthP = HealthProvider(MockHealthRepository());
      await healthP.load();
      await healthP.addCondition(
        const HealthCondition(name: 'Diabetes', loggedAt: '2026-05-12'),
      );
      final added = healthP.conditions.first;
      final before = healthP.conditions.length;
      await healthP.deleteCondition(added.id!);
      expect(healthP.conditions.length, before - 1);
      expect(healthP.conditions.any((c) => c.name == 'Diabetes'), isFalse);
    });
  });

  // ── W8–W12: Medications ──────────────────────────────────────────────────

  group('W8–W12 Medications', () {
    testWidgets('W8 add medication appears in list', (tester) async {
      final medP = MedicationProvider(MockMedicationRepository());
      await medP.load();
      final initial = medP.medications.length;
      await medP.add(const Medication('Metformin', 2, 500));
      expect(medP.medications.length, initial + 1);
      expect(
        medP.medications.any((m) => m.medicationName == 'Metformin'),
        isTrue,
      );
    });

    testWidgets('W9 update medication reflects new values', (tester) async {
      final medP = MedicationProvider(MockMedicationRepository());
      await medP.load();
      await medP.add(const Medication('Metformin', 2, 500));
      final added = medP.medications
          .firstWhere((m) => m.medicationName == 'Metformin');
      await medP.update(added.copyWith(miligrams: 1000));
      final updated = medP.medications
          .firstWhere((m) => m.medicationName == 'Metformin');
      expect(updated.miligrams, 1000);
    });

    testWidgets('W10 add reminder returns reminder with assigned id',
        (tester) async {
      final medP = MedicationProvider(MockMedicationRepository());
      await medP.load();
      final med = medP.medications.first; // Aspirin, id: 1
      final reminder = await medP.addReminder(
        med.id!,
        const MedicationReminder(reminderTime: '08:00'),
      );
      expect(reminder.id, isNotNull);
      expect(reminder.reminderTime, '08:00');
    });

    testWidgets('W11 log dose returns dose with status taken', (tester) async {
      final medP = MedicationProvider(MockMedicationRepository());
      await medP.load();
      final med = medP.medications.first; // Aspirin, id: 1
      final dose = await medP.logDose(
        med.id!,
        DoseLog(
          status: 'taken',
          scheduledAt: DateTime(2026, 5, 12, 8),
          takenAt: DateTime(2026, 5, 12, 8, 5),
        ),
      );
      expect(dose.status, 'taken');
      expect(dose.id, isNotNull);
    });

    testWidgets('W12 delete medication removes it from list', (tester) async {
      final medP = MedicationProvider(MockMedicationRepository());
      await medP.load();
      await medP.add(const Medication('Metformin', 2, 500));
      final added = medP.medications
          .firstWhere((m) => m.medicationName == 'Metformin');
      final before = medP.medications.length;
      await medP.delete(added.id!);
      expect(medP.medications.length, before - 1);
      expect(
        medP.medications.any((m) => m.medicationName == 'Metformin'),
        isFalse,
      );
    });
  });

  // ── W13–W16: Assessment ──────────────────────────────────────────────────

  group('W13–W16 Assessment', () {
    testWidgets('W13 submit assessment adds entry to history', (tester) async {
      final assessP = AssessmentProvider(MockAssessmentRepository());
      await assessP.load();
      expect(assessP.entries, isEmpty);
      await assessP.submit(_stubSummary());
      expect(assessP.entries.length, 1);
    });

    testWidgets('W14 history shows submitted entry', (tester) async {
      final assessP = AssessmentProvider(MockAssessmentRepository());
      await assessP.load();
      await assessP.submit(_stubSummary());
      expect(assessP.entries, isNotEmpty);
      expect(assessP.entries.first.summary.symptoms, contains('Headache'));
    });

    testWidgets('W15 second submit — both entries present newest-first',
        (tester) async {
      final assessP = AssessmentProvider(MockAssessmentRepository());
      await assessP.load();
      await assessP.submit(_stubSummary());
      await assessP.submit(
        const AssessmentSummary(
          subject: HealthAssessmentSubject.someoneElse,
          bloodType: BloodType.b,
          allergies: 'pollen',
          symptoms: ['Fatigue'],
          symptomDuration: '1 week',
          hasOtherSymptoms: true,
          symptomsTrend: 'worsening',
        ),
      );
      expect(assessP.entries.length, 2);
      expect(assessP.entries.first.summary.symptoms, contains('Fatigue'));
    });

    testWidgets('W16 delete one entry — other entry remains', (tester) async {
      final assessP = AssessmentProvider(MockAssessmentRepository());
      await assessP.load();
      await assessP.submit(_stubSummary());
      await assessP.submit(
        const AssessmentSummary(
          subject: null,
          bloodType: null,
          allergies: '',
          symptoms: ['Fatigue'],
          symptomDuration: null,
          hasOtherSymptoms: null,
          symptomsTrend: null,
        ),
      );
      final idToDelete = assessP.entries.first.id;
      await assessP.delete(idToDelete);
      expect(assessP.entries.length, 1);
      expect(assessP.entries.first.id, isNot(idToDelete));
    });
  });

  // ── W17–W20: AI Chatbot ──────────────────────────────────────────────────

  group('W17–W20 AI Chatbot', () {
    // sendMessage() has a 900ms Future.delayed in the mock. Use tester.runAsync()
    // to step outside the fake-async zone so real time elapses correctly.

    testWidgets('W17 send message — user message and bot reply appear',
        (tester) async {
      final aiP = await createTestAiProvider();
      final initial = aiP.messages.length;
      await tester.runAsync(() => aiP.send('Hello'));
      expect(aiP.messages.length, initial + 2);
      expect(aiP.messages.any((m) => m.body == 'Hello' && m.fromUser), isTrue);
      expect(aiP.messages.any((m) => !m.fromUser && m.id != 'greeting'), isTrue);
    });

    testWidgets('W18 send 3 more messages — all present in order',
        (tester) async {
      final aiP = await createTestAiProvider();
      final initial = aiP.messages.length;
      await tester.runAsync(() async {
        await aiP.send('Msg 1');
        await aiP.send('Msg 2');
        await aiP.send('Msg 3');
      });
      // Each send adds 1 user + 1 bot = 2 messages
      expect(aiP.messages.length, initial + 6);
      final userMessages =
          aiP.messages.where((m) => m.fromUser).map((m) => m.body).toList();
      expect(userMessages, containsAllInOrder(['Msg 1', 'Msg 2', 'Msg 3']));
    });

    testWidgets('W19 thread is scrollable without crash', (tester) async {
      final aiP = await createTestAiProvider();
      await tester.runAsync(() async {
        for (int i = 0; i < 5; i++) {
          await aiP.send('Message $i');
        }
      });
      await _pump(tester, const ChatbotScreen(), aiP: aiP);
      final list = find.byType(ListView);
      if (list.evaluate().isNotEmpty) {
        await tester.drag(list.first, const Offset(0, 300));
        await tester.pump();
      }
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('W20 empty message does not add to thread', (tester) async {
      final aiP = await createTestAiProvider();
      final before = aiP.messages.length;
      // Empty/blank strings return early — no repo call, no delay.
      await aiP.send('');
      await aiP.send('   ');
      expect(aiP.messages.length, before);
    });
  });

  // ── W21–W24: Nutrition ───────────────────────────────────────────────────

  group('W21–W24 Nutrition', () {
    testWidgets('W21 add day log appears in history', (tester) async {
      final nutritionP = NutritionProvider(MockNutritionRepository());
      await nutritionP.load();
      final initial = nutritionP.history.length;
      await nutritionP.addLog(
        const FoodDayLog(
          dayStamp: '2026-05-12',
          meals: [FoodMealEntry(name: 'Oats', calories: '350')],
        ),
      );
      expect(nutritionP.history.length, initial + 1);
      expect(
        nutritionP.history.any((l) => l.dayStamp == '2026-05-12'),
        isTrue,
      );
    });

    testWidgets('W22 change diet tags updates settings', (tester) async {
      final nutritionP = NutritionProvider(MockNutritionRepository());
      await nutritionP.load();
      await nutritionP.updateSettings(
        nutritionP.settings.copyWith(diets: {'Keto'}),
      );
      expect(nutritionP.settings.diets, {'Keto'});
    });

    testWidgets('W23 change report frequency updates settings', (tester) async {
      final nutritionP = NutritionProvider(MockNutritionRepository());
      await nutritionP.load();
      await nutritionP.updateSettings(
        nutritionP.settings.copyWith(
          frequency: FoodReportFrequency.monthly,
        ),
      );
      expect(nutritionP.settings.frequency, FoodReportFrequency.monthly);
    });

    testWidgets('W24 added log persists to SharedPrefs and reloads',
        (tester) async {
      final nutritionP = NutritionProvider(MockNutritionRepository());
      await nutritionP.load();
      await nutritionP.addLog(
        const FoodDayLog(
          dayStamp: '2026-05-12',
          meals: [FoodMealEntry(name: 'Oats', calories: '350')],
        ),
      );
      final savedCount = nutritionP.history.length;

      // A fresh provider backed by the same SharedPrefs mock should load the
      // data that was written by the first instance.
      final nutritionP2 = NutritionProvider(MockNutritionRepository());
      await nutritionP2.load();
      expect(nutritionP2.history.length, savedCount);
      expect(
        nutritionP2.history.any((l) => l.dayStamp == '2026-05-12'),
        isTrue,
      );
    });
  });

  // ── W25–W30: Articles ────────────────────────────────────────────────────

  group('W25–W30 Articles', () {
    testWidgets('W25 like first article increments like count by 1',
        (tester) async {
      final articleP = ArticleProvider(MockArticleRepository());
      await articleP.load();
      final before = articleP.articles.first.likes;
      await articleP.likeArticle(articleP.articles.first.id);
      expect(articleP.articles.first.likes, before + 1);
    });

    testWidgets('W26 liking same article again increments count again',
        (tester) async {
      final articleP = ArticleProvider(MockArticleRepository());
      await articleP.load();
      final before = articleP.articles.first.likes;
      await articleP.likeArticle(articleP.articles.first.id);
      await articleP.likeArticle(articleP.articles.first.id);
      expect(articleP.articles.first.likes, before + 2);
    });

    testWidgets('W27 search "growing" filters to matching article only',
        (tester) async {
      final articleP = ArticleProvider(MockArticleRepository());
      await articleP.load();
      await _pump(tester, const ArticleScreen(), articleP: articleP);

      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              (w.decoration?.hintText?.contains('Search') ?? false),
        ),
        'growing',
      );
      await tester.pump();

      // Matching article visible
      expect(find.textContaining('growing'), findsWidgets);
      // Non-matching titles not visible
      expect(find.text('Why old'), findsNothing);
      expect(find.text('Why get old'), findsNothing);
    });

    testWidgets('W28 search "xyz" shows no article titles', (tester) async {
      final articleP = ArticleProvider(MockArticleRepository());
      await articleP.load();
      await _pump(tester, const ArticleScreen(), articleP: articleP);

      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              (w.decoration?.hintText?.contains('Search') ?? false),
        ),
        'xyz',
      );
      await tester.pump();

      expect(find.textContaining('Why are we growing old?'), findsNothing);
      expect(find.text('Why old'), findsNothing);
      expect(find.text('Why get old'), findsNothing);
    });

    testWidgets('W29 clearing search restores all 3 article titles',
        (tester) async {
      final articleP = ArticleProvider(MockArticleRepository());
      await articleP.load();
      await _pump(tester, const ArticleScreen(), articleP: articleP);

      final searchField = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            (w.decoration?.hintText?.contains('Search') ?? false),
      );
      await tester.enterText(searchField, 'xyz');
      await tester.pump();
      await tester.enterText(searchField, '');
      await tester.pump();

      expect(find.textContaining('Why are we growing old?'), findsWidgets);
      expect(find.text('Why old'), findsWidgets);
    });

    testWidgets('W30 article detail screen has a share button',
        (tester) async {
      // ArticleDetail falls back to a placeholder when no route args provided.
      await _pump(tester, const ArticleDetail());
      expect(find.byIcon(Icons.share_outlined), findsWidgets);
    });
  });

  // ── W31–W34: Contacts ────────────────────────────────────────────────────

  group('W31–W34 Contacts', () {
    EmergencyContactEntry stubContact(String id) => EmergencyContactEntry(
          id: id,
          firstName: 'Alice',
          lastName: 'Smith',
          email: 'alice@example.com',
          phoneComplete: '+12025550000',
          relationship: 'Sister',
        );

    PersonalDoctorEntry stubDoctor(String id) => PersonalDoctorEntry(
          id: id,
          firstName: 'Dr',
          lastName: 'Jones',
          profession: 'Cardiologist',
          email: 'jones@clinic.com',
          phoneComplete: '+12025551111',
          reportFrequency: 2,
        );

    testWidgets('W31 add emergency contact appears in list', (tester) async {
      final contactsP = ContactsProvider(MockContactsRepository());
      await contactsP.load();
      expect(contactsP.contacts, isEmpty);
      await contactsP.addContact(stubContact('c1'));
      expect(contactsP.contacts.length, 1);
      expect(contactsP.contacts.first.firstName, 'Alice');
    });

    testWidgets('W32 add doctor appears in doctors list', (tester) async {
      final contactsP = ContactsProvider(MockContactsRepository());
      await contactsP.load();
      expect(contactsP.doctors, isEmpty);
      await contactsP.addDoctor(stubDoctor('d1'));
      expect(contactsP.doctors.length, 1);
      expect(contactsP.doctors.first.profession, 'Cardiologist');
    });

    testWidgets('W33 update contact reflects new values', (tester) async {
      final contactsP = ContactsProvider(MockContactsRepository());
      await contactsP.load();
      await contactsP.addContact(stubContact('c1'));
      await contactsP.updateContact(
        stubContact('c1').copyWith(firstName: 'Alicia'),
      );
      expect(contactsP.contacts.first.firstName, 'Alicia');
    });

    testWidgets('W34 delete emergency contact — doctor entry unaffected',
        (tester) async {
      final contactsP = ContactsProvider(MockContactsRepository());
      await contactsP.load();
      await contactsP.addContact(stubContact('c1'));
      await contactsP.addDoctor(stubDoctor('d1'));
      await contactsP.deleteContact('c1');
      expect(contactsP.contacts, isEmpty);
      expect(contactsP.doctors.length, 1);
    });
  });

  // ── W35–W40: Chat ────────────────────────────────────────────────────────

  group('W35–W40 Chat', () {
    testWidgets('W35 search filters to matching user', (tester) async {
      final chatP = await createTestChatProvider();
      await _pump(
        tester,
        const GeneralChatScreen(showBackButton: false),
        chatP: chatP,
      );

      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              (w.decoration?.hintText?.toLowerCase().contains('search') ??
                  false),
        ),
        'John',
      );
      await tester.pump();

      expect(find.textContaining('John Doe'), findsWidgets);
      expect(find.textContaining('Emma Smith'), findsNothing);
    });

    testWidgets('W36 clearing chat search restores full user list',
        (tester) async {
      final chatP = await createTestChatProvider();
      await _pump(
        tester,
        const GeneralChatScreen(showBackButton: false),
        chatP: chatP,
      );

      final searchField = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            (w.decoration?.hintText?.toLowerCase().contains('search') ?? false),
      );
      await tester.enterText(searchField, 'John');
      await tester.pump();
      await tester.enterText(searchField, '');
      await tester.pump();

      expect(find.textContaining('John Doe'), findsWidgets);
      expect(find.textContaining('Emma Smith'), findsWidgets);
    });

    testWidgets('W37 send direct message — appears in user chat history',
        (tester) async {
      final chatP = await createTestChatProvider();
      await chatP.sendDirect('1', '999', 'Hi from test');
      final user = chatP.findUser('1')!;
      expect(
        user.chatHistory.any((m) => m.content == 'Hi from test'),
        isTrue,
      );
    });

    testWidgets(
        'W38 reopening DM — message still present in same-session provider',
        (tester) async {
      final chatP = await createTestChatProvider();
      await chatP.sendDirect('1', '999', 'Persistent message');
      // Same provider instance — in-memory state is unchanged.
      final user = chatP.findUser('1')!;
      expect(
        user.chatHistory.any((m) => m.content == 'Persistent message'),
        isTrue,
      );
    });

    testWidgets('W39 send group message — appears in group chat history',
        (tester) async {
      final chatP = await createTestChatProvider();
      await chatP.sendGroup('g1', '999', 'Hello group');
      final group = chatP.findGroup('g1')!;
      expect(
        group.groupChatHistory.any((m) => m.content == 'Hello group'),
        isTrue,
      );
    });

    testWidgets('W40 reopening group — message still present same session',
        (tester) async {
      final chatP = await createTestChatProvider();
      await chatP.sendGroup('g1', '999', 'Group message');
      final group = chatP.findGroup('g1')!;
      expect(
        group.groupChatHistory.any((m) => m.content == 'Group message'),
        isTrue,
      );
    });
  });

  // ── W41–W45: Subscriptions ───────────────────────────────────────────────

  group('W41–W45 Subscriptions', () {
    testWidgets(
        'W41 tapping premium plan button navigates to payment screen',
        (tester) async {
      final subsP = SubscriptionProvider(MockSubscriptionRepository());
      await subsP.load();
      await _pump(
        tester,
        const SubscriptionAndPaymentScreen(),
        subsP: subsP,
      );

      await tester.tap(find.textContaining('25.99').first);
      await tester.pumpAndSettle();

      // PaymentMethodScreen shows "Checkout" header
      expect(find.textContaining('Checkout'), findsWidgets);
    });

    testWidgets(
        'W42 PaymentMethod "Next" navigates to payment review screen',
        (tester) async {
      await _pump(tester, const PaymentMethodScreen());

      await tester.tap(find.text('Next').first);
      await tester.pumpAndSettle();

      // PaymentReviewScreen contains the hard-coded review price
      expect(find.textContaining('25.99'), findsWidgets);
    });

    testWidgets('W43 confirmSubscription sets isPremium to true',
        (tester) async {
      final subsP = SubscriptionProvider(MockSubscriptionRepository());
      await subsP.load();
      subsP.selectPlan('premium');
      await subsP.confirmSubscription();
      expect(subsP.isPremium, isTrue);
    });

    testWidgets('W44 SubscriptionFinishScreen shows success and Finish button',
        (tester) async {
      await _pump(tester, const SubscriptionFinishScreen());
      expect(find.textContaining('Purchase Successful'), findsWidgets);
      expect(find.text('Finish'), findsWidgets);
    });

    testWidgets('W45 status reflects active subscription after confirm',
        (tester) async {
      final subsP = SubscriptionProvider(MockSubscriptionRepository());
      await subsP.load();
      expect(subsP.isPremium, isFalse);
      subsP.selectPlan('premium');
      await subsP.confirmSubscription();
      expect(subsP.isPremium, isTrue);
      expect(subsP.status?.isActive, isTrue);
    });
  });
}
