import 'package:flutter_test/flutter_test.dart';
import 'package:healthpilot/features/chatbot/chatbot_models.dart';

void main() {
  group('AI chat API parsing', () {
    test('fromApiHistoryJson maps role/content/timestamp', () {
      final message = ChatMessage.fromApiHistoryJson({
        'id': 42,
        'role': 'assistant',
        'content': 'Please seek medical care.',
        'timestamp': '2024-06-18T08:36:41.793139Z',
      });

      expect(message.id, '42');
      expect(message.fromUser, isFalse);
      expect(message.body, 'Please seek medical care.');
      expect(message.sentAt, DateTime.parse('2024-06-18T08:36:41.793139Z'));
    });

    test('fromApiHistoryJson maps user role as delivered', () {
      final message = ChatMessage.fromApiHistoryJson({
        'id': 1,
        'role': 'user',
        'content': 'I have chest pain.',
        'timestamp': '2024-06-18T08:36:40.793139Z',
      });

      expect(message.fromUser, isTrue);
      expect(message.showSentLabel, isTrue);
    });

    test('pending outgoing message hides Sent until marked sent', () {
      final pending = ChatMessage(
        id: 'u1',
        fromUser: true,
        body: 'Hello',
        sentAt: DateTime.parse('2024-06-18T08:36:40.793139Z'),
        deliveryStatus: OutgoingDeliveryStatus.pending,
      );

      expect(pending.showSentLabel, isFalse);
      expect(
        pending.copyWith(deliveryStatus: OutgoingDeliveryStatus.sent).showSentLabel,
        isTrue,
      );
    });

    test('fromApiReply maps reply field', () {
      final message = ChatMessage.fromApiReply({
        'reply': 'Please seek emergency medical care immediately.',
        'user_message': 'I have chest pain.',
      });

      expect(message.fromUser, isFalse);
      expect(
        message.body,
        'Please seek emergency medical care immediately.',
      );
    });
  });
}
