import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_chat_repository.dart';
import 'package:healthpilot/features/chat/chat_models.dart';

enum ChatLoadStatus { idle, loading, loaded, error }

class ChatProvider extends ChangeNotifier {
  final IChatRepository _repo;

  List<ChatUser> _users = [];
  List<ChatGroup> _groups = [];
  ChatLoadStatus _status = ChatLoadStatus.idle;
  bool _loadStarted = false;

  List<ChatUser> get users => List.unmodifiable(_users);
  List<ChatGroup> get groups => List.unmodifiable(_groups);
  ChatLoadStatus get status => _status;

  List<ChatThread> get conversations => [
        ..._users.map((u) => ChatThread(
              id: u.userId,
              name: u.displayName,
              lastMessage:
                  u.chatHistory.isNotEmpty ? u.chatHistory.last.content : '',
              isPro: u.isPro,
              isGroupChat: false,
            )),
        ..._groups.map((g) => ChatThread(
              id: g.groupId,
              name: g.groupName,
              lastMessage: g.groupChatHistory.isNotEmpty
                  ? g.groupChatHistory.last.content
                  : '',
              isPro: g.isPro,
              isGroupChat: true,
            )),
      ];

  ChatProvider(this._repo);

  ChatUser findUser(String id) => _users.firstWhere((u) => u.userId == id);

  ChatGroup findGroup(String id) =>
      _groups.firstWhere((g) => g.groupId == id);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    _status = ChatLoadStatus.loading;
    notifyListeners();
    try {
      _users = await _repo.fetchUsers();
      _groups = await _repo.fetchGroups();
      _status = ChatLoadStatus.loaded;
    } catch (_) {
      _status = ChatLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> sendDirect(
      String targetUserId, String currentUserId, String content) async {
    final message = DirectMessage(
      senderId: currentUserId,
      content: content,
      timestamp: DateTime.now(),
    );
    final sent = await _repo.sendDirectMessage(targetUserId, message);
    _users = [
      for (final u in _users)
        if (u.userId == targetUserId)
          u.copyWith(chatHistory: [...u.chatHistory, sent])
        else
          u,
    ];
    notifyListeners();
  }

  Future<void> sendGroup(
      String groupId, String currentUserId, String content) async {
    final message = DirectMessage(
      senderId: currentUserId,
      content: content,
      timestamp: DateTime.now(),
    );
    final sent = await _repo.sendGroupMessage(groupId, message);
    _groups = [
      for (final g in _groups)
        if (g.groupId == groupId)
          g.copyWith(
              groupChatHistory: [...g.groupChatHistory, sent])
        else
          g,
    ];
    notifyListeners();
  }
}
