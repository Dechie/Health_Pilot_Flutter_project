import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/core/repositories/i_ai_assistant_repository.dart';
import 'package:healthpilot/features/chat/data/chat_local_store.dart';
import 'package:healthpilot/features/chatbot/chatbot_models.dart';

class AiAssistantProvider extends ChangeNotifier {
  final IAiAssistantRepository _repo;
  final ChatLocalStore _localStore;

  List<ChatMessage> _messages = [_greeting()];
  bool _loadStarted = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  AiAssistantProvider(
    this._repo, {
    ChatLocalStore? localStore,
  }) : _localStore = localStore ?? ChatLocalStore.instance;

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
      print('[HealthPilot] AI load → SQLite (local chat history)');
    }
    try {
      final history = await _localStore.fetchAiMessages();
      _messages = history.isEmpty ? [_greeting()] : history;
      notifyListeners();
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
    final userId = '${DateTime.now().microsecondsSinceEpoch}_user';
    final userMessage = ChatMessage(
      id: userId,
      fromUser: true,
      body: trimmed,
      sentAt: DateTime.now(),
      deliveryStatus: OutgoingDeliveryStatus.pending,
    );
    _messages = [..._messages, userMessage];
    notifyListeners();
    await _localStore.insertAiMessage(userMessage);
    await _deliver(userId, trimmed);
  }

  /// Re-sends a previously failed outgoing message (by id), reusing its body.
  Future<void> retry(String messageId) async {
    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final body = _messages[idx].body;
    final pending = _messages[idx].copyWith(
      deliveryStatus: OutgoingDeliveryStatus.pending,
    );
    _messages = [
      for (final m in _messages)
        if (m.id == messageId) pending else m,
    ];
    notifyListeners();
    await _localStore.insertAiMessage(pending);
    await _deliver(messageId, body);
  }

  /// Sends [body], marking the outgoing message [userId] sent or failed.
  /// Never throws — failure is surfaced via the message's delivery status so
  /// the UI can show a retry affordance.
  Future<void> _deliver(String userId, String body) async {
    try {
      final reply = await _repo.sendMessage(body);
      final deliveredUser = _messages
          .firstWhere((m) => m.id == userId)
          .copyWith(deliveryStatus: OutgoingDeliveryStatus.sent);
      _messages = [
        for (final m in _messages)
          if (m.id == userId) deliveredUser else m,
        reply,
      ];
      notifyListeners();
      await _localStore.insertAiMessage(deliveredUser);
      await _localStore.insertAiMessage(reply);
    } catch (e) {
      final failed = _messages
          .firstWhere((m) => m.id == userId)
          .copyWith(deliveryStatus: OutgoingDeliveryStatus.failed);
      _messages = [
        for (final m in _messages)
          if (m.id == userId) failed else m,
      ];
      notifyListeners();
      await _localStore.insertAiMessage(failed);
      if (kDebugMode) {
        // ignore: avoid_print
        print('[HealthPilot] AI send failed: $e');
      }
    }
  }

  Future<void> clear() async {
    await _localStore.clearAiMessages();
    if (FeatureFlags.aiAssistant) {
      try {
        await _repo.clearHistory();
      } catch (_) {
        // Local clear is authoritative until backend sync is finalized.
      }
    }
    _messages = [_greeting()];
    notifyListeners();
  }
}
