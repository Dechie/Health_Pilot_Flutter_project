import 'package:healthpilot/features/chat/chat_models.dart';

abstract class IChatRepository {
  Future<List<ChatUser>> fetchUsers();
  Future<List<ChatGroup>> fetchGroups();
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
