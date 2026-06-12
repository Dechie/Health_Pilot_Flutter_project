/// Delivery state for outgoing AI chat messages shown in the UI.
enum OutgoingDeliveryStatus {
  /// Incoming messages and greetings — no delivery label.
  notApplicable,
  pending,
  sent,
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.fromUser,
    required this.body,
    required this.sentAt,
    this.deliveryStatus = OutgoingDeliveryStatus.notApplicable,
  });

  final String id;
  final bool fromUser;
  final String body;
  final DateTime sentAt;
  final OutgoingDeliveryStatus deliveryStatus;

  bool get showSentLabel =>
      fromUser && deliveryStatus == OutgoingDeliveryStatus.sent;

  ChatMessage copyWith({
    String? id,
    bool? fromUser,
    String? body,
    DateTime? sentAt,
    OutgoingDeliveryStatus? deliveryStatus,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        fromUser: fromUser ?? this.fromUser,
        body: body ?? this.body,
        sentAt: sentAt ?? this.sentAt,
        deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      );

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        fromUser: json['from_user'] as bool,
        body: json['body'] as String,
        sentAt: DateTime.parse(json['sent_at'] as String),
        deliveryStatus: (json['from_user'] as bool)
            ? OutgoingDeliveryStatus.sent
            : OutgoingDeliveryStatus.notApplicable,
      );

  /// GET /api/v1/chat/ai/history/ item: {id, role, content, timestamp}.
  factory ChatMessage.fromApiHistoryJson(Map<String, dynamic> json) {
    final fromUser = json['role'] == 'user';
    return ChatMessage(
      id: json['id'].toString(),
      fromUser: fromUser,
      body: json['content'] as String,
      sentAt: DateTime.parse(json['timestamp'] as String),
      deliveryStatus: fromUser
          ? OutgoingDeliveryStatus.sent
          : OutgoingDeliveryStatus.notApplicable,
    );
  }

  /// POST /api/v1/chat/ai/ response: {reply, user_message}.
  factory ChatMessage.fromApiReply(Map<String, dynamic> json) => ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}_assistant',
        fromUser: false,
        body: json['reply'] as String,
        sentAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'from_user': fromUser,
        'body': body,
        'sent_at': sentAt.toIso8601String(),
      };
}

const String kBotGreeting =
    'Hey there 👋 I am here to answer general health questions. '
    'Ask in your own words or tap a suggestion below. '
    'This is not a substitute for professional care.';
