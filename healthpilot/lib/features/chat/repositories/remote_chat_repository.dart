import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_chat_repository.dart';
import 'package:healthpilot/features/chat/chat_models.dart';

class RemoteChatRepository implements IChatRepository {
  final ApiClient _api;
  RemoteChatRepository(this._api);

  @override
  Future<List<ChatUser>> fetchUsers() async {
    final data = await _api.get('${ApiConstants.chatBase}/users/');
    return (data as List<dynamic>)
        .map((e) => ChatUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ChatGroup>> fetchGroups() async {
    final data = await _api.get('${ApiConstants.chatBase}/groups/');
    return (data as List<dynamic>)
        .map((e) => ChatGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DirectMessage> sendDirectMessage(
      String targetUserId, DirectMessage message) async {
    final data = await _api.post(
      '${ApiConstants.chatBase}/direct/$targetUserId/messages/',
      data: message.toJson(),
    );
    return DirectMessage.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<DirectMessage> sendGroupMessage(
      String groupId, DirectMessage message) async {
    final data = await _api.post(
      '${ApiConstants.chatBase}/groups/$groupId/messages/',
      data: message.toJson(),
    );
    return DirectMessage.fromJson(data as Map<String, dynamic>);
  }
}
