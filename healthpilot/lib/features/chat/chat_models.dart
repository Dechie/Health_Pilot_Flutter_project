import 'package:flutter/foundation.dart';

@immutable
class DirectMessage {
  final String? id;
  final String senderId;

  /// Display name of the sender — server-provided (`sender_name`), used to
  /// label senders in group chats. Null for the current user's own messages.
  final String? senderName;
  final String content;
  final DateTime timestamp;

  /// True once the server has accepted the message (HTTP 2xx).
  final bool isDelivered;

  /// True when the API call failed (message could not be sent).
  final bool sendFailed;

  const DirectMessage({
    this.id,
    required this.senderId,
    this.senderName,
    required this.content,
    required this.timestamp,
    this.isDelivered = true,
    this.sendFailed = false,
  });

  DirectMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isDelivered,
    bool? sendFailed,
  }) =>
      DirectMessage(
        id: id ?? this.id,
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
        isDelivered: isDelivered ?? this.isDelivered,
        sendFailed: sendFailed ?? this.sendFailed,
      );

  factory DirectMessage.fromJson(Map<String, dynamic> json) {
    final rawSenderId = json['sender_id'];
    return DirectMessage(
      id: json['id'] as String?,
      senderId: rawSenderId is int ? rawSenderId.toString() : rawSenderId as String,
      senderName: json['sender_name'] as String?,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    // Live API `GET /chat/users/` returns connected peers as
    // {id: <int>, full_name, email, avatar}. Older shape used
    // {user_id, display_name, profile_picture_url, ...}; accept both.
    final rawId = json['user_id'] ?? json['id'];
    final rawName = json['display_name'] ?? json['full_name'];
    final rawPic = json['profile_picture_url'] ?? json['avatar'];
    return ChatUser(
      userId: rawId.toString(),
      displayName: rawName as String? ?? '',
      profilePictureUrl: rawPic is String ? rawPic : '',
      status: json['status'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? false,
      bio: json['bio'] as String? ?? '',
      isPro: json['is_pro'] as bool? ?? false,
      chatId: json['chat_id'] as String?,
      chatHistory: (json['chat_history'] as List<dynamic>? ?? [])
          .map((e) => DirectMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

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
  final String? description;
  final bool isMuted;
  final bool isPro;
  final bool isJoined;
  final List<String> membersId;

  /// Authoritative member count from the API (`participant_count`); the
  /// `participants` array may only contain a subset, so prefer this for display.
  final int participantCount;
  final List<DirectMessage> groupChatHistory;

  ChatGroup({
    required this.groupId,
    required this.groupName,
    this.description,
    this.isMuted = false,
    this.isPro = false,
    this.isJoined = false,
    this.membersId = const [],
    this.participantCount = 0,
    this.groupChatHistory = const [],
  });

  /// Best available member count: the API's `participant_count` when present,
  /// otherwise the size of the (possibly partial) participants list.
  int get memberCount =>
      participantCount > membersId.length ? participantCount : membersId.length;

  ChatGroup copyWith({
    List<DirectMessage>? groupChatHistory,
    String? description,
    List<String>? membersId,
    int? participantCount,
    bool? isMuted,
    bool? isPro,
    bool? isJoined,
  }) =>
      ChatGroup(
        groupId: groupId,
        groupName: groupName,
        description: description ?? this.description,
        isMuted: isMuted ?? this.isMuted,
        isPro: isPro ?? this.isPro,
        isJoined: isJoined ?? this.isJoined,
        membersId: membersId ?? this.membersId,
        participantCount: participantCount ?? this.participantCount,
        groupChatHistory: groupChatHistory ?? this.groupChatHistory,
      );

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    final rawId = json['group_id'] ?? json['id'];
    final rawName = json['group_name'] ?? json['name'];
    // Live API returns members as `participants: [{id, full_name, ...}]`;
    // older shape used a flat `members_id: [<id>]`. Accept both.
    final participants = json['participants'];
    final membersId = participants is List
        ? participants
            .map((e) => (e as Map<String, dynamic>)['id'].toString())
            .toList()
        : (json['members_id'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[];
    return ChatGroup(
      groupId: rawId.toString(),
      groupName: rawName as String,
      description: json['description'] as String?,
      isMuted: json['is_muted'] as bool? ?? false,
      isPro: json['is_pro'] as bool? ?? false,
      // `/groups/discover/` returns `is_member`; the joined `/groups/` list has
      // neither, so membership is also derived from `participants` against the
      // current user id (see ChatProvider.load).
      isJoined: (json['is_member'] ?? json['is_joined']) as bool? ?? false,
      membersId: membersId,
      participantCount: (json['participant_count'] as num?)?.toInt() ?? 0,
      groupChatHistory: (json['group_chat_history'] as List<dynamic>? ?? [])
          .map((e) => DirectMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

@immutable
class ChatThread {
  final String id;
  final String name;
  final String lastMessage;
  final bool isPro;
  final bool isGroupChat;
  final String? avatarUrl;

  const ChatThread({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.isPro,
    required this.isGroupChat,
    this.avatarUrl,
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
        lastMessage: json['last_message'] is Map
            ? (json['last_message'] as Map)['content'] as String?
            : json['last_message'] as String?,
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
    isJoined: true,
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
    groupName: 'Diabetes Support Group',
    description: 'A community for managing diabetes together.',
    isJoined: true,
    isMuted: true,
    isPro: false,
    membersId: ['4', '2', '5'],
    groupChatHistory: [
      DirectMessage(
          senderId: '4',
          content: 'Has anyone tried the new glucose monitor?',
          timestamp: DateTime.now().subtract(const Duration(days: 2))),
      DirectMessage(
          senderId: '5',
          content: 'Yes, it is much more accurate!',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 23))),
      DirectMessage(
          senderId: '1',
          content: "I've been thinking about switching.",
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 22))),
      DirectMessage(
          senderId: '2',
          content: 'You should, the readings are consistent.',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 21))),
      DirectMessage(
          senderId: '2',
          content: 'Plus the app integration is seamless.',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 20))),
    ],
  ),
  ChatGroup(
    groupId: 'g3',
    groupName: 'Mental Wellness Circle',
    description: 'Weekly check-ins and mindfulness exercises.',
    isJoined: false,
    isMuted: true,
    isPro: false,
    membersId: ['1', '3', '5'],
    groupChatHistory: [
      DirectMessage(
          senderId: '1',
          content: 'Welcome to the new members!',
          timestamp: DateTime.now().subtract(const Duration(days: 2))),
      DirectMessage(
          senderId: '3',
          content: 'Thank you, happy to be here.',
          timestamp:
              DateTime.now().subtract(const Duration(days: 2, hours: 23))),
    ],
  ),
  ChatGroup(
    groupId: 'g4',
    groupName: 'Fitness & Recovery',
    description: 'Share workout tips and recovery progress.',
    isJoined: false,
    isMuted: false,
    isPro: true,
    membersId: ['7', '8', '9'],
    groupChatHistory: [
      DirectMessage(
          senderId: '7',
          content: 'Morning workout done! Anyone else?',
          timestamp: DateTime.now().subtract(const Duration(days: 1))),
      DirectMessage(
          senderId: '8',
          content: 'Just finished my run. Feeling great!',
          timestamp:
              DateTime.now().subtract(const Duration(days: 1, hours: 1))),
    ],
  ),
];
