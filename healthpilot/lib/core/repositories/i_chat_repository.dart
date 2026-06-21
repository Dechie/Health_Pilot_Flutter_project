import 'package:healthpilot/features/chat/chat_models.dart';

abstract class IChatRepository {
  Future<List<ChatUser>> fetchUsers();

  /// Groups the current user has joined — `GET /chat/groups/`.
  Future<List<ChatGroup>> fetchGroups();

  /// All groups, joined or not, each flagged with `is_member`
  /// — `GET /chat/groups/discover/`.
  Future<List<ChatGroup>> discoverGroups();
  Future<DirectMessage> sendDirectMessage(String chatId, String content);
  Future<List<DirectMessage>> fetchPrivateMessages(String chatId);
  Future<DirectMessage> sendGroupMessage(String groupId, String content);
  Future<PrivateChat> startPrivateChat(int userId);
  Future<List<PrivateChat>> listPrivateChats();
  Future<ChatGroup> createGroup(String name, String description);
  Future<void> joinGroup(String groupId);
  Future<void> leaveGroup(String groupId);
  Future<List<DirectMessage>> fetchGroupMessages(String groupId);
}
