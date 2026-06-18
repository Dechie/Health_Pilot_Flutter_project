import 'package:healthpilot/core/repositories/i_chat_repository.dart';
import 'package:healthpilot/features/chat/chat_models.dart';

class MockChatRepository implements IChatRepository {
  @override
  Future<List<ChatUser>> fetchUsers() async => List.of(kSeedUsers);

  @override
  Future<List<ChatGroup>> fetchGroups() async => List.of(kSeedGroups);

  @override
  Future<DirectMessage> sendDirectMessage(
      String chatId, String content) async {
    return DirectMessage(
      senderId: '123',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<List<DirectMessage>> fetchPrivateMessages(String chatId) async {
    return [];
  }

  @override
  Future<DirectMessage> sendGroupMessage(
      String groupId, String content) async {
    return DirectMessage(
      id: 'mock-msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: '123',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<PrivateChat> startPrivateChat(int userId) async {
    final user = kSeedUsers.firstWhere(
      (u) => u.userId == userId.toString(),
      orElse: () => kSeedUsers.first,
    );
    return PrivateChat(
      id: 'mock-private-${DateTime.now().millisecondsSinceEpoch}',
      participants: [
        const PrivateChatParticipant(
          id: 123,
          fullName: 'Current User',
          email: 'user@example.com',
        ),
        PrivateChatParticipant(
          id: userId,
          fullName: user.displayName,
          email:
              '${user.displayName.toLowerCase().replaceAll(' ', '.')}@example.com',
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<PrivateChat>> listPrivateChats() async {
    return [];
  }

  @override
  Future<ChatGroup> createGroup(String name, String description) async {
    return ChatGroup(
      groupId: 'mock-group-${DateTime.now().millisecondsSinceEpoch}',
      groupName: name,
      description: description,
      membersId: ['123'],
    );
  }

  @override
  Future<void> joinGroup(String groupId) async {}

  @override
  Future<void> leaveGroup(String groupId) async {}

  @override
  Future<List<DirectMessage>> fetchGroupMessages(String groupId) async {
    return [];
  }
}
