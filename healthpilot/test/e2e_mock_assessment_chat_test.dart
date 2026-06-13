// End-to-end mock UI tests for assessment, direct chat, and AI chat.
//
// Run with:
//   flutter test test/e2e_mock_assessment_chat_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthpilot/features/chat/chat_screen.dart';
import 'package:healthpilot/features/chat/general_chat_screen.dart';
import 'package:healthpilot/features/chatbot/chatbot_screen.dart';
import 'package:healthpilot/features/health_assessment/assessment_history_screen.dart';
import 'package:healthpilot/features/health_assessment/assessment_provider.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_flow_screen.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_subject.dart';
import 'package:healthpilot/features/health_assessment/repositories/mock_assessment_repository.dart';
import 'package:healthpilot/features/chatbot/chatbot_models.dart';
import 'package:healthpilot/features/chatbot/repositories/mock_ai_assistant_repository.dart';

import 'helpers/chat_local_store_test_helper.dart';
import 'helpers/e2e_test_harness.dart';

/// Same mock replies as production mock, without the 900ms delay (avoids
/// typing-indicator frames that need italic Google Fonts in widget tests).
class _InstantAiAssistantRepository extends MockAiAssistantRepository {
  @override
  Future<ChatMessage> sendMessage(String text) async {
    return ChatMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}_bot',
      fromUser: false,
      body: 'Thanks for your message. I cannot diagnose or prescribe. '
          'For "$text", a reliable next step is to review trusted sources '
          'such as your national health service or speak with a clinician '
          'for personal advice.',
      sentAt: DateTime.now(),
    );
  }
}

/// Records submissions and returns a completed AI result for summary UI checks.
class _E2eAssessmentRepository extends MockAssessmentRepository {
  final List<CompletedAssessmentEntry> submissions = [];

  @override
  Future<CompletedAssessmentEntry> submitAssessment(
    AssessmentSummary summary,
  ) async {
    final entry = CompletedAssessmentEntry(
      id: 'e2e-${DateTime.now().microsecondsSinceEpoch}',
      completedAt: DateTime.now(),
      summary: summary,
      status: 'completed',
      result: const AssessmentAiResult(
        possibleCauses: [
          PossibleCause(
            name: 'Common cold',
            description: 'Mild viral upper respiratory illness.',
            urgency: 'low',
          ),
        ],
        generalAdvice: 'Rest and stay hydrated.',
      ),
    );
    submissions.insert(0, entry);
    return entry;
  }

  @override
  Future<List<CompletedAssessmentEntry>> fetchHistory() async =>
      List.of(submissions);
}

Future<void> _runAssessmentWizard(WidgetTester tester) async {
  await tapTextContaining(tester, 'Myself');
  await tapAssessmentCta(tester, 'Next');

  await tapTextContaining(tester, 'Type A');
  await tapAssessmentCta(tester, 'Next');

  await tapAssessmentCta(tester, 'Skip');

  await tapAssessmentCta(tester, 'Next');

  await tapTextContaining(tester, 'Less than a week');
  await tapAssessmentCta(tester, 'Next');

  await tapTextContaining(tester, 'No, I don');
  await tapAssessmentCta(tester, 'Next');

  await tapTextContaining(tester, 'getting worse');
  await tapAssessmentCta(tester, 'Finish');
}

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

  group('E2E Assessment (mock)', () {
    testWidgets('full wizard reaches summary and submits to mock repository',
        (tester) async {
      final repo = _E2eAssessmentRepository();
      final assessP = AssessmentProvider(repo);
      await assessP.load();

      await pumpE2eScreen(
        tester,
        const HealthAssessmentFlowScreen(),
        assessP: assessP,
      );

      await _runAssessmentWizard(tester);

      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Ready to analyze'), findsOneWidget);

      await tapAssessmentCta(tester, 'Finish');
      await tester.pumpAndSettle();

      expect(repo.submissions, hasLength(1));
      expect(assessP.entries, hasLength(1));
      expect(assessP.entries.first.summary.symptoms, contains('Cough'));
      expect(find.text('Assessment results'), findsOneWidget);
      expect(find.text('Possible causes'), findsOneWidget);
      expect(find.text('Common cold'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
    });

    testWidgets('history screen shows symptoms from completed assessments',
        (tester) async {
      final repo = _E2eAssessmentRepository();
      final assessP = AssessmentProvider(repo);
      await assessP.load();
      await assessP.submit(
        const AssessmentSummary(
          subject: HealthAssessmentSubject.myself,
          bloodType: BloodType.a,
          allergies: '',
          symptoms: ['Cough', 'Fever'],
          symptomDuration: 'Less than a week',
          hasOtherSymptoms: false,
          symptomsTrend: 'worse',
        ),
      );

      await pumpE2eScreen(
        tester,
        const AssessmentHistoryScreen(),
        assessP: assessP,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Cough'), findsWidgets);
      expect(find.textContaining('Fever'), findsWidgets);
      expect(find.text('Symptom History'), findsOneWidget);
      expect(find.textContaining('Myself'), findsWidgets);
    });
  });

  group('E2E AI chat (mock)', () {
    testWidgets('user can type, tap send, and see mock bot reply in thread',
        (tester) async {
      final aiP = await createTestAiProvider(
        repository: _InstantAiAssistantRepository(),
      );

      await pumpE2eScreen(tester, const ChatbotScreen(), aiP: aiP);

      expect(find.textContaining('Hey there'), findsWidgets);

      final input = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            (w.decoration?.hintText?.contains('Ask a health question') ?? false),
      );
      await tester.enterText(input, 'What helps with fever?');
      await tester.pump();
      expect(
        tester.widget<TextField>(input).controller?.text,
        'What helps with fever?',
      );

      await tester.tap(find.byTooltip('Send'));
      await tester.pumpAndSettle();

      expect(
        aiP.messages.any((m) => m.body == 'What helps with fever?'),
        isTrue,
      );
      expect(
        aiP.messages.any((m) => m.body.contains('Thanks for your message')),
        isTrue,
      );
      expect(find.textContaining('What helps with fever?'), findsWidgets);
      expect(find.textContaining('Thanks for your message'), findsOneWidget);
    });

    testWidgets('suggestion chip sends a question through the UI',
        (tester) async {
      final aiP = await createTestAiProvider(
        repository: _InstantAiAssistantRepository(),
      );

      await pumpE2eScreen(tester, const ChatbotScreen(), aiP: aiP);

      await tester.tap(find.text('Healthy sleep habits'));
      await tester.pumpAndSettle();

      expect(
        aiP.messages.any((m) => m.body == 'Healthy sleep habits'),
        isTrue,
      );
      expect(
        aiP.messages.any((m) => m.body.contains('Thanks for your message')),
        isTrue,
      );
      expect(find.text('Healthy sleep habits'), findsWidgets);
      expect(find.textContaining('Thanks for your message'), findsOneWidget);
    });
  });

  group('E2E direct chat (mock)', () {
    testWidgets('inbox opens DM and sent message appears in the thread',
        (tester) async {
      final chatP = await createTestChatProvider();

      await pumpE2eScreen(
        tester,
        const GeneralChatScreen(showBackButton: false),
        chatP: chatP,
      );

      await tester.tap(find.textContaining('John Doe').first);
      await tester.pumpAndSettle();

      expect(find.byType(ChatScreen), findsOneWidget);

      await tester.enterText(find.byWidgetPredicate(
        (w) => w is TextField && (w.decoration?.hintText == 'Message'),
      ), 'E2E hello from DM');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send_outlined));
      await tester.pumpAndSettle();

      expect(find.textContaining('E2E hello from DM'), findsWidgets);

      final user = chatP.findUser('1');
      expect(
        user.chatHistory.any((m) => m.content == 'E2E hello from DM'),
        isTrue,
      );
    });

    testWidgets('search narrows inbox then DM send still works', (tester) async {
      final chatP = await createTestChatProvider();

      await pumpE2eScreen(
        tester,
        const GeneralChatScreen(showBackButton: false),
        chatP: chatP,
      );

      final search = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            (w.decoration?.hintText?.contains('Search people') ?? false),
      );
      await tester.enterText(search, 'Emma');
      await tester.pump();

      expect(find.textContaining('Emma Smith'), findsWidgets);
      expect(find.textContaining('John Doe'), findsNothing);

      await tester.tap(find.textContaining('Emma Smith').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextField && (w.decoration?.hintText == 'Message'),
        ),
        'Hi Emma',
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_outlined));
      await tester.pumpAndSettle();

      expect(find.textContaining('Hi Emma'), findsWidgets);
      expect(
        chatP.findUser('2').chatHistory.any((m) => m.content == 'Hi Emma'),
        isTrue,
      );
    });
  });
}
