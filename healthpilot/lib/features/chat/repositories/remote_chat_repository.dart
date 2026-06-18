import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_chat_repository.dart';
import 'package:healthpilot/features/chat/chat_models.dart';

class RemoteChatRepository implements IChatRepository {
  final ApiClient _api;
  RemoteChatRepository(this._api);

  /// Extracts a list from either a direct JSON array or a paginated envelope
  /// `{count: …, results: […]}` returned by DRF.
  static List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final results = data['results'];
      if (results is List) return results;
    }
    return [];
  }

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
      String chatId, String content) async {
    final data = await _api.post(
      '${ApiConstants.chatBase}/private/$chatId/messages/',
      data: {'content': content},
    );
    return DirectMessage.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<DirectMessage>> fetchPrivateMessages(String chatId) async {
    final data = await _api.get(
      '${ApiConstants.chatBase}/private/$chatId/messages/',
    );
    return _extractList(data)
        .map((e) => DirectMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DirectMessage> sendGroupMessage(
      String groupId, String content) async {
    final data = await _api.post(
      '${ApiConstants.chatBase}/groups/$groupId/messages/',
      data: {'content': content},
    );
    return DirectMessage.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<PrivateChat> startPrivateChat(int userId) async {
    final data = await _api.post(
      '${ApiConstants.chatBase}/private/',
      data: {'user_id': userId},
    );
    return PrivateChat.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<PrivateChat>> listPrivateChats() async {
    final data = await _api.get('${ApiConstants.chatBase}/private/');
    return _extractList(data)
        .map((e) => PrivateChat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChatGroup> createGroup(String name, String description) async {
    final data = await _api.post(
      '${ApiConstants.chatBase}/groups/',
      data: {'name': name, 'description': description},
    );
    return ChatGroup.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> joinGroup(String groupId) async {
    await _api.post('${ApiConstants.chatBase}/groups/$groupId/join/');
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    await _api.post('${ApiConstants.chatBase}/groups/$groupId/leave/');
  }

  @override
  Future<List<DirectMessage>> fetchGroupMessages(String groupId) async {
    final data = await _api.get(
      '${ApiConstants.chatBase}/groups/$groupId/messages/',
    );
    return _extractList(data)
        .map((e) => DirectMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
