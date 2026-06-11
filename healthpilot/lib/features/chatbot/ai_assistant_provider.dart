import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/core/repositories/i_ai_assistant_repository.dart';
import 'package:healthpilot/features/chatbot/chatbot_models.dart';

class AiAssistantProvider extends ChangeNotifier {
  final IAiAssistantRepository _repo;

  List<ChatMessage> _messages = [_greeting()];
  bool _isTyping = false;
  bool _loadStarted = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  AiAssistantProvider(this._repo);

  static ChatMessage _greeting() => ChatMessage(
        id: 'greeting',
        fromUser: false,
        body: kBotGreeting,
        sentAt: DateTime.now(),
      );

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    if (kDebugMode) {
      // ignore: avoid_print
      print(
        '[HealthPilot] AI load → '
        '${FeatureFlags.aiAssistant ? "GET /api/v1/chat/ai/history/" : "MOCK (FF_AI_ASSISTANT=false)"}',
      );
    }
    try {
      final history = await _repo.fetchHistory();
      if (history.isNotEmpty) {
        _messages = history;
        notifyListeners();
      }
    } catch (e) {
      _loadStarted = false;
      if (kDebugMode) {
        // ignore: avoid_print
        print('[HealthPilot] AI load failed: $e');
      }
      rethrow;
    }
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (kDebugMode) {
      // ignore: avoid_print
      print(
        '[HealthPilot] AI send → '
        '${FeatureFlags.aiAssistant ? "POST /api/v1/chat/ai/" : "MOCK (FF_AI_ASSISTANT=false)"}',
      );
    }
    _messages = [
      ..._messages,
      ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}_user',
        fromUser: true,
        body: trimmed,
        sentAt: DateTime.now(),
      ),
    ];
    _isTyping = true;
    notifyListeners();
    try {
      final reply = await _repo.sendMessage(trimmed);
      _messages = [..._messages, reply];
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    await _repo.clearHistory();
    _messages = [_greeting()];
    _isTyping = false;
    notifyListeners();
  }
}
