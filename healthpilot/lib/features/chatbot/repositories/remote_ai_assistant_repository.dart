import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_ai_assistant_repository.dart';
import 'package:healthpilot/features/chatbot/chatbot_models.dart';

class RemoteAiAssistantRepository implements IAiAssistantRepository {
  const RemoteAiAssistantRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<ChatMessage>> fetchHistory() async {
    final data = await _client.get('${ApiConstants.chatBase}/ai/history/');
    if (data is! List) return [];
    return data
        .map((e) => ChatMessage.fromApiHistoryJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChatMessage> sendMessage(String text) async {
    final data = await _client.post(
      '${ApiConstants.chatBase}/ai/',
      data: {'message': text},
    );
    return ChatMessage.fromApiReply(data as Map<String, dynamic>);
  }

  @override
  Future<void> clearHistory() async =>
      _client.delete('${ApiConstants.chatBase}/ai/history/');
}
