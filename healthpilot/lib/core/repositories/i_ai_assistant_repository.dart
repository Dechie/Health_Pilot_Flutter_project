import 'package:healthpilot/features/chatbot/chatbot_models.dart';

abstract class IAiAssistantRepository {
  Future<List<ChatMessage>> fetchHistory();
  Future<ChatMessage> sendMessage(String text);
  Future<void> clearHistory();
}
