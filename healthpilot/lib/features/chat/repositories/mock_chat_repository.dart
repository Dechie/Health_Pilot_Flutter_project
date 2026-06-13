import 'package:healthpilot/core/repositories/i_chat_repository.dart';
import 'package:healthpilot/features/chat/chat_models.dart';

class MockChatRepository implements IChatRepository {
  @override
  Future<List<ChatUser>> fetchUsers() async => List.of(kSeedUsers);

  @override
  Future<List<ChatGroup>> fetchGroups() async => List.of(kSeedGroups);

  @override
  Future<DirectMessage> sendDirectMessage(
      String targetUserId, DirectMessage message) async => message;

  @override
  Future<DirectMessage> sendGroupMessage(
      String groupId, DirectMessage message) async => message;

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
          email: '${user.displayName.toLowerCase().replaceAll(' ', '.')}@example.com',
        ),
      ],
      createdAt: DateTime.now(),
    );
  }
}
