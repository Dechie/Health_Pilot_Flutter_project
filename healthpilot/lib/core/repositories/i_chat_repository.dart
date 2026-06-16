import 'package:healthpilot/features/chat/chat_models.dart';

abstract class IChatRepository {
  Future<List<ChatUser>> fetchUsers();
  Future<List<ChatGroup>> fetchGroups();
  Future<DirectMessage> sendDirectMessage(String chatId, String content);
  Future<List<DirectMessage>> fetchPrivateMessages(String chatId);
  Future<DirectMessage> sendGroupMessage(String groupId, DirectMessage message);
  Future<PrivateChat> startPrivateChat(int userId);
}
