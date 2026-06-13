import 'package:healthpilot/features/chat/chat_models.dart';

abstract class IChatRepository {
  Future<List<ChatUser>> fetchUsers();
  Future<List<ChatGroup>> fetchGroups();
  Future<DirectMessage> sendDirectMessage(
      String targetUserId, DirectMessage message);
  Future<DirectMessage> sendGroupMessage(
      String groupId, DirectMessage message);
  Future<PrivateChat> startPrivateChat(int userId);
}
