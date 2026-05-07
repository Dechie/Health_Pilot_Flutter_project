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
