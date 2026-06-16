import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_chat_repository.dart';
import 'package:healthpilot/features/chat/chat_models.dart';
import 'package:healthpilot/features/chat/data/chat_local_store.dart';
import 'package:healthpilot/features/community/community_models.dart';

enum ChatLoadStatus { idle, loading, loaded, error }

class ChatProvider extends ChangeNotifier {
  final IChatRepository _repo;
  final ChatLocalStore _localStore;

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

  ChatProvider(
    this._repo, {
    ChatLocalStore? localStore,
  }) : _localStore = localStore ?? ChatLocalStore.instance;

  ChatUser? findUser(String id) {
    try {
      return _users.firstWhere((u) => u.userId == id);
    } catch (_) {
      return null;
    }
  }

  ChatGroup findGroup(String id) => _groups.firstWhere((g) => g.groupId == id);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    _status = ChatLoadStatus.loading;
    notifyListeners();
    try {
      final users = await _repo.fetchUsers();
      final groups = await _repo.fetchGroups();
      _users = await Future.wait(
        users.map((user) async {
          final history = await _localStore.loadDirectMessages(
            user.userId,
            user.chatHistory,
          );
          return user.copyWith(chatHistory: history);
        }),
      );
      _groups = await Future.wait(
        groups.map((group) async {
          final history = await _localStore.loadGroupMessages(
            group.groupId,
            group.groupChatHistory,
          );
          return group.copyWith(groupChatHistory: history);
        }),
      );
      _status = ChatLoadStatus.loaded;
    } catch (_) {
      _status = ChatLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _loadStarted = false;
    await load();
  }

  void addConnection(int userId, String fullName, String chatId) {
    final id = userId.toString();
    if (_users.any((u) => u.userId == id)) return;
    _users = [
      ChatUser(
        userId: id,
        displayName: fullName,
        chatId: chatId,
        profilePictureUrl: '',
        status: '',
        isOnline: false,
        bio: '',
        isPro: false,
        chatHistory: [],
      ),
      ..._users,
    ];
    notifyListeners();
  }

  Future<void> sendDirect(
      String targetUserId, String currentUserId, String content) async {
    final userIdx = _users.indexWhere((u) => u.userId == targetUserId);
    if (userIdx == -1) return;
    String chatId = _users[userIdx].chatId ?? '';
    if (chatId.isEmpty) {
      final userId = int.tryParse(targetUserId);
      if (userId == null) return;
      final chat = await _repo.startPrivateChat(userId);
      chatId = chat.id;
      _users[userIdx] = _users[userIdx].copyWith(chatId: chatId);
    }
    final message = DirectMessage(
      senderId: currentUserId,
      content: content,
      timestamp: DateTime.now(),
      isDelivered: false,
    );
    _users[userIdx] = _users[userIdx].copyWith(
      chatHistory: [..._users[userIdx].chatHistory, message],
    );
    notifyListeners();
    await _localStore.insertDirectMessage(targetUserId, message);
    await _repo.sendDirectMessage(chatId, content);
    // Mark delivered in-memory using server-confirmed data
    _users[userIdx] = _users[userIdx].copyWith(
      chatHistory: [
        for (final m in _users[userIdx].chatHistory)
          if (m.timestamp == message.timestamp && m.content == message.content)
            m.copyWith(isDelivered: true)
          else
            m,
      ],
    );
    await _localStore.markDirectMessageDelivered(
        targetUserId, message.timestamp);
    notifyListeners();
  }

  Future<void> fetchPrivateMessages(String targetUserId) async {
    final user = _users.firstWhere((u) => u.userId == targetUserId);
    if (user.chatId == null) return;
    final messages = await _repo.fetchPrivateMessages(user.chatId!);
    final merged = await _localStore.loadDirectMessages(
      targetUserId,
      messages,
    );
    _users = [
      for (final u in _users)
        if (u.userId == targetUserId)
          u.copyWith(chatHistory: merged)
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
      isDelivered: false,
    );
    _groups = [
      for (final g in _groups)
        if (g.groupId == groupId)
          g.copyWith(groupChatHistory: [...g.groupChatHistory, message])
        else
          g,
    ];
    notifyListeners();
    await _localStore.insertGroupMessage(groupId, message);
    await _repo.sendGroupMessage(groupId, message);
    _markGroupDelivered(groupId, message.timestamp);
    await _localStore.markGroupMessageDelivered(groupId, message.timestamp);
    notifyListeners();
  }

  Future<PrivateChat> startPrivateChat(int userId) =>
      _repo.startPrivateChat(userId);

  Future<void> syncAcceptedConnections(
      List<ConnectionRequest> connections,
      String currentUserId) async {
    for (final conn in connections) {
      if (conn.status != 'accepted') continue;
      final peerId = conn.peerIdOf(currentUserId);
      final peerName = conn.peerNameOf(currentUserId);
      final userId = peerId.toString();
      if (_users.any((u) => u.userId == userId)) continue;
      try {
        final chat = await _repo.startPrivateChat(peerId);
        addConnection(peerId, peerName, chat.id);
      } catch (_) {}
    }
  }

  void _markGroupDelivered(String groupId, DateTime timestamp) {
    _groups = [
      for (final g in _groups)
        if (g.groupId == groupId)
          g.copyWith(
            groupChatHistory: [
              for (final m in g.groupChatHistory)
                if (m.timestamp == timestamp && !m.isDelivered)
                  m.copyWith(isDelivered: true)
                else
                  m,
            ],
          )
        else
          g,
    ];
  }
}
