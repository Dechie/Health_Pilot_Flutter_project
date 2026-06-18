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

  /// Tracks messages not yet seen per user/group thread (key = userId or groupId).
  final Map<String, int> _unreadCounts = {};

  /// Threads currently being fetched (key = userId or groupId).
  final Set<String> _loadingThreads = {};

  bool isLoadingThread(String id) => _loadingThreads.contains(id);

  @visibleForTesting
  void setLoadingThread(String id, bool loading) {
    if (loading) {
      _loadingThreads.add(id);
    } else {
      _loadingThreads.remove(id);
    }
    notifyListeners();
  }

  @visibleForTesting
  void setUserChatHistory(String userId, List<DirectMessage> history) {
    final idx = _users.indexWhere((u) => u.userId == userId);
    if (idx == -1) return;
    _users[idx] = _users[idx].copyWith(chatHistory: history);
    notifyListeners();
  }

  int unreadCount(String id) => _unreadCounts[id] ?? 0;

  void markRead(String id) {
    _unreadCounts.remove(id);
    notifyListeners();
  }

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

  ChatGroup? findGroup(String id) {
    try {
      return _groups.firstWhere((g) => g.groupId == id);
    } catch (_) {
      return null;
    }
  }

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
          final localCount =
              (await _localStore.fetchDirectMessages(user.userId)).length;
          final history = await _localStore.loadDirectMessages(
            user.userId,
            user.chatHistory,
          );
          final unread = history.length - localCount;
          if (unread > 0) _unreadCounts[user.userId] = unread;
          return user.copyWith(chatHistory: history);
        }),
      );
      _groups = await Future.wait(
        groups.map((group) async {
          final localCount =
              (await _localStore.fetchGroupMessages(group.groupId)).length;
          final history = await _localStore.loadGroupMessages(
            group.groupId,
            group.groupChatHistory,
          );
          final unread = history.length - localCount;
          if (unread > 0) _unreadCounts[group.groupId] = unread;
          return group.copyWith(groupChatHistory: history);
        }),
      );
      // Load existing private chats to discover connected peers (the /users/
      // endpoint only returns the current user's own profile).
      final privateChats = await _repo.listPrivateChats();
      for (final chat in privateChats) {
        for (final participant in chat.participants) {
          final id = participant.id.toString();
          if (_users.any((u) => u.userId == id)) continue;
          _users.add(ChatUser(
            userId: id,
            displayName: participant.fullName,
            profilePictureUrl: participant.profilePicture ?? '',
            status: '',
            isOnline: false,
            bio: '',
            isPro: false,
            chatId: chat.id,
            chatHistory: [],
          ));
          // Peers discovered via private chats have their full history remotely.
          // Pre-populate to avoid spurious unread counts on next fetch.
          _unreadCounts[id] = 0;
        }
      }
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
    try {
      final sent = await _repo.sendDirectMessage(chatId, content);
      // Persist the server-returned version (with server timestamp) so that
      // subsequent fetchPrivateMessages deduplicates correctly.
      await _localStore.insertDirectMessage(targetUserId, sent);
      _users[userIdx] = _users[userIdx].copyWith(
        chatHistory: [
          for (final m in _users[userIdx].chatHistory)
            if (m.content == content && m.senderId == currentUserId && !m.isDelivered)
              sent
            else
              m,
        ],
      );
    } catch (_) {
      // Keep the optimistically added message but mark it as failed.
      await _localStore.insertDirectMessage(targetUserId, message);
      _users[userIdx] = _users[userIdx].copyWith(
        chatHistory: [
          for (final m in _users[userIdx].chatHistory)
            if (m.content == content && m.senderId == currentUserId && !m.isDelivered)
              m.copyWith(sendFailed: true)
            else
              m,
        ],
      );
    }
    notifyListeners();
  }

  Future<void> fetchPrivateMessages(String targetUserId) async {
    _loadingThreads.add(targetUserId);
    notifyListeners();
    try {
      final user = _users.firstWhere((u) => u.userId == targetUserId);
      if (user.chatId == null) return;
      final localCount =
          (await _localStore.fetchDirectMessages(targetUserId)).length;
      final messages = await _repo.fetchPrivateMessages(user.chatId!);
      final merged = await _localStore.loadDirectMessages(
        targetUserId,
        messages,
      );
      final unread = merged.length - localCount;
      if (unread > 0) {
        _unreadCounts.update(
          targetUserId,
          (v) => v + unread,
          ifAbsent: () => unread,
        );
      }
      _users = [
        for (final u in _users)
          if (u.userId == targetUserId)
            u.copyWith(chatHistory: merged)
          else
            u,
      ];
    } finally {
      _loadingThreads.remove(targetUserId);
      notifyListeners();
    }
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
    try {
      final sent = await _repo.sendGroupMessage(groupId, content);
      await _localStore.insertGroupMessage(groupId, sent);
      _groups = [
        for (final g in _groups)
          if (g.groupId == groupId)
            g.copyWith(
              groupChatHistory: [
                for (final m in g.groupChatHistory)
                  if (m.content == content &&
                      m.senderId == currentUserId &&
                      !m.isDelivered)
                    sent
                  else
                    m,
              ],
            )
          else
            g,
      ];
    } catch (_) {
      await _localStore.insertGroupMessage(groupId, message);
      _markGroupFailed(groupId, message.timestamp);
    }
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

  Future<void> createGroup(String name, String description) async {
    final group = await _repo.createGroup(name, description);
    _groups = [group, ..._groups];
    notifyListeners();
  }

  Future<void> joinGroup(String groupId) async {
    await _repo.joinGroup(groupId);
    final groups = await _repo.fetchGroups();
    _groups = groups;
    notifyListeners();
  }

  Future<void> leaveGroup(String groupId) async {
    await _repo.leaveGroup(groupId);
    _groups = _groups.where((g) => g.groupId != groupId).toList();
    notifyListeners();
  }

  Future<void> fetchGroupMessages(String groupId) async {
    _loadingThreads.add(groupId);
    notifyListeners();
    try {
      if (!_groups.any((g) => g.groupId == groupId)) return;
      final localCount =
          (await _localStore.fetchGroupMessages(groupId)).length;
      final messages = await _repo.fetchGroupMessages(groupId);
      final merged = await _localStore.loadGroupMessages(groupId, messages);
      final unread = merged.length - localCount;
      if (unread > 0) {
        _unreadCounts.update(
          groupId,
          (v) => v + unread,
          ifAbsent: () => unread,
        );
      }
      _groups = [
        for (final g in _groups)
          if (g.groupId == groupId)
            g.copyWith(groupChatHistory: merged)
          else
            g,
      ];
    } finally {
      _loadingThreads.remove(groupId);
      notifyListeners();
    }
  }

  void _markGroupFailed(String groupId, DateTime timestamp) {
    _groups = [
      for (final g in _groups)
        if (g.groupId == groupId)
          g.copyWith(
            groupChatHistory: [
              for (final m in g.groupChatHistory)
                if (m.timestamp == timestamp && !m.sendFailed)
                  m.copyWith(sendFailed: true)
                else
                  m,
            ],
          )
        else
          g,
    ];
  }
}
