import 'package:flutter/foundation.dart';

@immutable
class DirectMessage {
  final String senderId;
  final String content;
  final DateTime timestamp;

  /// True once the server has accepted the message (HTTP 2xx).
  final bool isDelivered;

  const DirectMessage({
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isDelivered = true,
  });

  DirectMessage copyWith({
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? isDelivered,
  }) =>
      DirectMessage(
        senderId: senderId ?? this.senderId,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
        isDelivered: isDelivered ?? this.isDelivered,
      );

  factory DirectMessage.fromJson(Map<String, dynamic> json) => DirectMessage(
        senderId: json['sender_id'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'sender_id': senderId,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}

class ChatUser {
  final String userId;
  final String displayName;
  final String profilePictureUrl;
  final String status;
  final bool isOnline;
  final String bio;
  final bool isPro;
  final String? chatId;
  final List<DirectMessage> chatHistory;

  ChatUser({
    required this.userId,
    required this.displayName,
    required this.profilePictureUrl,
    required this.status,
    required this.isOnline,
    required this.bio,
    required this.isPro,
    this.chatId,
    required this.chatHistory,
  });

  ChatUser copyWith({
    List<DirectMessage>? chatHistory,
    String? chatId,
  }) =>
      ChatUser(
        userId: userId,
        displayName: displayName,
        profilePictureUrl: profilePictureUrl,
        status: status,
        isOnline: isOnline,
        bio: bio,
        isPro: isPro,
        chatId: chatId ?? this.chatId,
        chatHistory: chatHistory ?? this.chatHistory,
      );

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        userId: json['user_id'] as String,
        displayName: json['display_name'] as String,
        profilePictureUrl: json['profile_picture_url'] as String? ?? '',
        status: json['status'] as String? ?? '',
        isOnline: json['is_online'] as bool? ?? false,
        bio: json['bio'] as String? ?? '',
        isPro: json['is_pro'] as bool? ?? false,
        chatId: json['chat_id'] as String?,
        chatHistory: (json['chat_history'] as List<dynamic>? ?? [])
            .map((e) => DirectMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'display_name': displayName,
        'profile_picture_url': profilePictureUrl,
        'status': status,
        'is_online': isOnline,
        'bio': bio,
        'is_pro': isPro,
        if (chatId != null) 'chat_id': chatId,
        'chat_history': chatHistory.map((m) => m.toJson()).toList(),
      };
}

class ChatGroup {
  final String groupId;
  final String groupName;
  final bool isMuted;
  final bool isPro;
  final List<String> membersId;
  final List<DirectMessage> groupChatHistory;

  ChatGroup({
    required this.groupId,
    required this.groupName,
    required this.isMuted,
    required this.isPro,
    required this.membersId,
    required this.groupChatHistory,
  });

  ChatGroup copyWith({List<DirectMessage>? groupChatHistory}) => ChatGroup(
        groupId: groupId,
        groupName: groupName,
        isMuted: isMuted,
        isPro: isPro,
        membersId: membersId,
        groupChatHistory: groupChatHistory ?? this.groupChatHistory,
      );

  factory ChatGroup.fromJson(Map<String, dynamic> json) => ChatGroup(
        groupId: json['group_id'] as String,
        groupName: json['group_name'] as String,
        isMuted: json['is_muted'] as bool? ?? false,
        isPro: json['is_pro'] as bool? ?? false,
        membersId: (json['members_id'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        groupChatHistory: (json['group_chat_history'] as List<dynamic>? ?? [])
            .map((e) => DirectMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

@immutable
class ChatThread {
  final String id;
  final String name;
  final String lastMessage;
  final bool isPro;
  final bool isGroupChat;

  const ChatThread({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.isPro,
    required this.isGroupChat,
  });
}

class PrivateChatParticipant {
  final int id;
  final String fullName;
  final String email;
  final String? profilePicture;

  const PrivateChatParticipant({
    required this.id,
    required this.fullName,
    required this.email,
    this.profilePicture,
  });

  factory PrivateChatParticipant.fromJson(Map<String, dynamic> json) =>
      PrivateChatParticipant(
        id: json['id'] as int,
        fullName: json['full_name'] as String,
        email: json['email'] as String,
        profilePicture: json['profile_picture'] as String?,
      );
}

@immutable
class PrivateChat {
  final String id;
  final List<PrivateChatParticipant> participants;
  final String? lastMessage;
  final DateTime createdAt;

  const PrivateChat({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.createdAt,
  });

  factory PrivateChat.fromJson(Map<String, dynamic> json) => PrivateChat(
        id: json['id'] as String,
        participants: (json['participants'] as List<dynamic>)
            .map((e) =>
                PrivateChatParticipant.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastMessage: json['last_message'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

// Seed data used by MockChatRepository
final kSeedUsers = [
  ChatUser(
    userId: '1',
    displayName: 'John Doe',
    profilePictureUrl: '',
    status: 'Online',
    isOnline: true,
    bio: 'Hello, I am John Doe!',
    isPro: true,
    chatHistory: [
      DirectMessage(
          senderId: '123',
          content: 'Hello John Doe!',
          timestamp: DateTime.now().subtract(const Duration(days: 2))),
      DirectMessage(
          senderId: '123',
          content: 'How are you today?',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 23))),
      DirectMessage(
          senderId: '1',
          content: "Hi! I'm doing well, thanks!",
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 22))),
      DirectMessage(
          senderId: '123',
          content: "That's great to hear!",
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 21))),
      DirectMessage(
          senderId: '1',
          content: 'By the way, have you seen the latest movie?',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 20))),
    ],
  ),
  ChatUser(
    userId: '2',
    displayName: 'Emma Smith',
    profilePictureUrl: '',
    status: 'Offline',
    isOnline: false,
    bio: 'Greetings from Emma Smith!',
    isPro: false,
    chatHistory: [
      DirectMessage(
          senderId: '123',
          content: 'Hi Emma Smith!',
          timestamp:
              DateTime.now().subtract(const Duration(days: 1, hours: 20))),
      DirectMessage(
          senderId: '123',
          content: 'Are you free for a call later?',
          timestamp:
              DateTime.now().subtract(const Duration(days: 1, hours: 19))),
      DirectMessage(
          senderId: '2',
          content: 'I have a meeting scheduled, but how about tomorrow?',
          timestamp:
              DateTime.now().subtract(const Duration(days: 1, hours: 18))),
      DirectMessage(
          senderId: '123',
          content: "Sure, let's plan for tomorrow. What time works for you?",
          timestamp:
              DateTime.now().subtract(const Duration(days: 1, hours: 17))),
    ],
  ),
  ChatUser(
    userId: '3',
    displayName: 'Alice Johnson',
    profilePictureUrl: '',
    status: 'Online',
    isOnline: true,
    bio: 'Nice to meet you!',
    isPro: true,
    chatHistory: [
      DirectMessage(
          senderId: '123',
          content: 'Hello Alice Johnson!',
          timestamp: DateTime.now().subtract(const Duration(hours: 18))),
      DirectMessage(
          senderId: '3',
          content: "Hi John! How's it going?",
          timestamp: DateTime.now().subtract(const Duration(hours: 17))),
      DirectMessage(
          senderId: '123',
          content: 'Not bad, just working on some projects. How about you?',
          timestamp: DateTime.now().subtract(const Duration(hours: 16))),
      DirectMessage(
          senderId: '3',
          content:
              'I am preparing for a presentation. Its a bit stressful, but exciting!',
          timestamp: DateTime.now().subtract(const Duration(hours: 15))),
      DirectMessage(
          senderId: '123',
          content:
              'I can imagine. You will do great! If you need any help, let me know.',
          timestamp: DateTime.now().subtract(const Duration(hours: 14))),
    ],
  ),
  ChatUser(
    userId: '4',
    displayName: 'Bob Williams',
    profilePictureUrl: '',
    status: 'Offline',
    isOnline: false,
    bio: 'Bob here!',
    isPro: false,
    chatHistory: [
      DirectMessage(
          senderId: '4',
          content: "Hi John! How's it going?",
          timestamp: DateTime.now().subtract(const Duration(hours: 17))),
    ],
  ),
  ChatUser(
    userId: '5',
    displayName: 'Sophia Brown',
    profilePictureUrl: '',
    status: 'Online',
    isOnline: true,
    bio: 'Sophia, reporting for duty!',
    isPro: true,
    chatHistory: [
      DirectMessage(
          senderId: '123',
          content: 'Hi Sophia!',
          timestamp: DateTime.now().subtract(const Duration(hours: 12))),
      DirectMessage(
          senderId: '5',
          content: 'Hey Alice! Do you have any plans this weekend?',
          timestamp: DateTime.now().subtract(const Duration(hours: 11))),
      DirectMessage(
          senderId: '123',
          content: 'Not yet. Maybe we can plan something together!',
          timestamp: DateTime.now().subtract(const Duration(hours: 10))),
      DirectMessage(
          senderId: '5',
          content: "That sounds like a great idea! Let's catch up and decide.",
          timestamp: DateTime.now().subtract(const Duration(hours: 9))),
    ],
  ),
];

final kSeedGroups = [
  ChatGroup(
    groupId: 'g1',
    groupName: 'Schizophrenia Support',
    isMuted: false,
    isPro: true,
    membersId: ['1', '2', '3'],
    groupChatHistory: [
      DirectMessage(
          senderId: '1',
          content: 'Hello John Doe!',
          timestamp: DateTime.now().subtract(const Duration(days: 2))),
      DirectMessage(
          senderId: '2',
          content: 'How are you today?',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 23))),
      DirectMessage(
          senderId: '3',
          content: "Hi! I'm doing well, thanks!",
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 22))),
      DirectMessage(
          senderId: '1',
          content: "That's great to hear!",
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 21))),
      DirectMessage(
          senderId: '2',
          content: 'By the way, have you seen the latest movie?',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 20))),
    ],
  ),
  ChatGroup(
    groupId: 'g2',
    groupName: 'Schizophrenia Support',
    isMuted: true,
    isPro: false,
    membersId: ['4', '2', '5'],
    groupChatHistory: [
      DirectMessage(
          senderId: '4',
          content: 'Hello John Doe!',
          timestamp: DateTime.now().subtract(const Duration(days: 2))),
      DirectMessage(
          senderId: '5',
          content: 'How are you today?',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 23))),
      DirectMessage(
          senderId: '1',
          content: "Hi! I'm doing well, thanks!",
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 22))),
      DirectMessage(
          senderId: '2',
          content: "That's great to hear!",
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 21))),
      DirectMessage(
          senderId: '2',
          content: 'By the way, have you seen the latest movie?',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 20))),
    ],
  ),
  ChatGroup(
    groupId: 'g3',
    groupName: 'Schizophrenia Support',
    isMuted: true,
    isPro: false,
    membersId: ['1', '3', '5'],
    groupChatHistory: [
      DirectMessage(
          senderId: '1',
          content: 'Hello John Doe!',
          timestamp: DateTime.now().subtract(const Duration(days: 2))),
      DirectMessage(
          senderId: '3',
          content: 'How are you today?',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 23))),
      DirectMessage(
          senderId: '5',
          content: "Hi! I'm doing well, thanks!",
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 22))),
      DirectMessage(
          senderId: '1',
          content: "That's great to hear!",
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 21))),
      DirectMessage(
          senderId: '1',
          content: 'By the way, have you seen the latest movie?',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 20))),
    ],
  ),
];
