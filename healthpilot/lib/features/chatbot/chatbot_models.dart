class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.fromUser,
    required this.body,
    required this.sentAt,
  });

  final String id;
  final bool fromUser;
  final String body;
  final DateTime sentAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        fromUser: json['from_user'] as bool,
        body: json['body'] as String,
        sentAt: DateTime.parse(json['sent_at'] as String),
      );

  /// GET /api/v1/chat/ai/history/ item: {id, role, content, timestamp}.
  factory ChatMessage.fromApiHistoryJson(Map<String, dynamic> json) =>
      ChatMessage(
        id: json['id'].toString(),
        fromUser: json['role'] == 'user',
        body: json['content'] as String,
        sentAt: DateTime.parse(json['timestamp'] as String),
      );

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
