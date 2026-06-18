import 'package:flutter_test/flutter_test.dart';
import 'package:healthpilot/features/chat/chat_models.dart';
import 'package:healthpilot/features/chat/data/chat_local_store.dart';
import 'package:healthpilot/features/chatbot/chatbot_models.dart';
import 'helpers/chat_local_store_test_helper.dart';

void main() {
  late ChatLocalStore store;

  setUp(() async {
    store = await createTestChatLocalStore();
  });

  group('ChatLocalStore AI messages', () {
    test('persists and reloads assistant conversation', () async {
      final user = ChatMessage(
        id: 'u1',
        fromUser: true,
        body: 'What is blood pressure?',
        sentAt: DateTime(2026, 6, 10, 12),
        deliveryStatus: OutgoingDeliveryStatus.sent,
      );
      final bot = ChatMessage(
        id: 'b1',
        fromUser: false,
        body: '**Blood pressure** is the force of blood on artery walls.',
        sentAt: DateTime(2026, 6, 10, 12, 1),
      );

      await store.insertAiMessage(user);
      await store.insertAiMessage(bot);

      final loaded = await store.fetchAiMessages();
      expect(loaded, hasLength(2));
      expect(loaded.first.body, user.body);
      expect(loaded.last.body, bot.body);
    });

    test('clear removes all AI messages', () async {
      await store.insertAiMessage(
        ChatMessage(
          id: 'u1',
          fromUser: true,
          body: 'Hi',
          sentAt: DateTime.now(),
          deliveryStatus: OutgoingDeliveryStatus.sent,
        ),
      );
      await store.clearAiMessages();
      expect(await store.fetchAiMessages(), isEmpty);
    });
  });

  group('ChatLocalStore direct messages', () {
    test('seeds fallback history once then reads from SQLite', () async {
      final fallback = [
        DirectMessage(
          senderId: '1',
          content: 'Hello',
          timestamp: DateTime(2026, 6, 9),
        ),
      ];

      final first = await store.loadDirectMessages('user-1', fallback);
      final second = await store.loadDirectMessages('user-1', [
        DirectMessage(
          senderId: '1',
          content: 'Different seed',
          timestamp: DateTime(2026, 6, 8),
        ),
      ]);

      expect(first, hasLength(1));
      expect(first.first.content, 'Hello');
      expect(second, hasLength(1));
      expect(second.first.content, 'Hello');
    });

    test('marks outgoing message as delivered', () async {
      final timestamp = DateTime(2026, 6, 10, 15);
      await store.insertDirectMessage(
        'user-2',
        DirectMessage(
          senderId: 'me',
          content: 'On my way',
          timestamp: timestamp,
          isDelivered: false,
        ),
      );

      await store.markDirectMessageDelivered('user-2', timestamp);
      final loaded = await store.fetchDirectMessages('user-2');
      expect(loaded.single.isDelivered, isTrue);
    });
  });
}
