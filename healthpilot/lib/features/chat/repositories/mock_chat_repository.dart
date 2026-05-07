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
}
