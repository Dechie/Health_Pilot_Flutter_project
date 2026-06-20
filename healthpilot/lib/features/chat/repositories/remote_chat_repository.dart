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

  /// Fetches every page of a DRF-paginated endpoint, following the `next`
  /// link until it is null, and returns the concatenated `results`. Falls
  /// back gracefully to a single page for non-paginated (plain list) bodies.
  Future<List<dynamic>> _fetchAllPages(String path) async {
    final all = <dynamic>[];
    Map<String, dynamic>? query;
    final seenPages = <String>{};
    while (true) {
      final data = await _api.get(path, queryParameters: query);
      if (data is! Map) {
        if (data is List) all.addAll(data);
        break;
      }
      final results = data['results'];
      if (results is List) all.addAll(results);
      final next = data['next'];
      if (next is! String || next.isEmpty) break;
      final nextQuery = Uri.parse(next).queryParameters;
      // Guard against a server that returns a self-referential `next`.
      final key = nextQuery.toString();
      if (nextQuery.isEmpty || !seenPages.add(key)) break;
      query = Map<String, dynamic>.from(nextQuery);
    }
    return all;
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
    final items = await _fetchAllPages(
      '${ApiConstants.chatBase}/private/$chatId/messages/',
    );
    return items
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
    final items = await _fetchAllPages(
      '${ApiConstants.chatBase}/groups/$groupId/messages/',
    );
    return items
        .map((e) => DirectMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
