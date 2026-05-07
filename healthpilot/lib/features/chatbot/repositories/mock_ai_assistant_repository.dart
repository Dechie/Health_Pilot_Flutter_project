import 'package:healthpilot/core/repositories/i_ai_assistant_repository.dart';
import 'package:healthpilot/features/chatbot/chatbot_models.dart';

class MockAiAssistantRepository implements IAiAssistantRepository {
  @override
  Future<List<ChatMessage>> fetchHistory() async => [];

  @override
  Future<ChatMessage> sendMessage(String text) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
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

  @override
  Future<void> clearHistory() async {}
}
