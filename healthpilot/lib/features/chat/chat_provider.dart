import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_chat_repository.dart';
import 'package:healthpilot/features/chat/chat_models.dart';
import 'package:healthpilot/features/chat/data/chat_local_store.dart';
import 'package:healthpilot/features/community/community_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ChatLoadStatus { idle, loading, loaded, error }

class ChatProvider extends ChangeNotifier {
  final IChatRepository _repo;
  final ChatLocalStore _localStore;

  List<ChatUser> _users = [];
  List<ChatGroup> _groups = [];
  ChatLoadStatus _status = ChatLoadStatus.idle;
  bool _loadStarted = false;

  /// Current user's id, used to derive group membership from `participants`.
  String _currentUserId = '';

  /// Last time each thread was read (key = userId or groupId). Persisted, so
  /// unread badges survive restarts. A message is "unread" when it's from
  /// someone else and newer than this marker.
  final Map<String, DateTime> _lastRead = {};
  static const _lastReadPrefsKey = 'hp.chat.last_read_v1';

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

  /// Messages in [id]'s thread from other people, newer than the last-read
  /// marker. Computed from current history so it's always consistent.
  int unreadCount(String id) {
    final lastRead = _lastRead[id];
    return _threadHistory(id)
        .where((m) =>
            m.senderId != _currentUserId &&
            (lastRead == null || m.timestamp.isAfter(lastRead)))
        .length;
  }

  /// Marks every currently-known message in [id] as read and persists it.
  void markRead(String id) {
    final history = _threadHistory(id);
    final latest = history.isEmpty
        ? DateTime.now()
        : history
            .map((m) => m.timestamp)
            .reduce((a, b) => a.isAfter(b) ? a : b);
    final existing = _lastRead[id];
    _lastRead[id] = (existing != null && existing.isAfter(latest)) ? existing : latest;
    _persistLastRead();
    notifyListeners();
  }

  List<DirectMessage> _threadHistory(String id) {
    for (final u in _users) {
      if (u.userId == id) return u.chatHistory;
    }
    for (final g in _groups) {
      if (g.groupId == id) return g.groupChatHistory;
    }
    return const [];
  }

  Future<void> _loadLastRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lastReadPrefsKey);
      if (raw == null || raw.isEmpty) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _lastRead.clear();
      map.forEach((k, v) {
        final ts = DateTime.tryParse(v as String? ?? '');
        if (ts != null) _lastRead[k] = ts;
      });
    } catch (_) {/* best-effort */}
  }

  Future<void> _persistLastRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _lastReadPrefsKey,
        jsonEncode(
          _lastRead.map((k, v) => MapEntry(k, v.toIso8601String())),
        ),
      );
    } catch (_) {/* best-effort */}
  }

  List<ChatUser> get users => List.unmodifiable(_users);
  List<ChatGroup> get groups => List.unmodifiable(_groups);
  List<ChatGroup> get joinedGroups =>
      _groups.where((g) => g.isJoined).toList();
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
        ...joinedGroups.map((g) => ChatThread(
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

  Future<void> load({String? currentUserId}) async {
    if (currentUserId != null && currentUserId.isNotEmpty) {
      _currentUserId = currentUserId;
    }
    if (_loadStarted) return;
    _loadStarted = true;
    _status = ChatLoadStatus.loading;
    notifyListeners();
    try {
      await _loadLastRead();
      final users = await _repo.fetchUsers();
      // Discover all groups (joined + joinable, each with is_member) so the
      // Groups tab can offer joinable ones. Fall back to the joined-only list
      // if the discover endpoint isn't available.
      List<ChatGroup> groups;
      try {
        groups = await _repo.discoverGroups();
      } catch (_) {
        groups = await _repo.fetchGroups();
      }
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
          // The live API has no `is_joined`; membership is whether the current
          // user appears in the group's participants (mapped to membersId).
          final joined = group.isJoined ||
              (_currentUserId.isNotEmpty &&
                  group.membersId.contains(_currentUserId));
          final resolved = group.copyWith(isJoined: joined);
          if (!resolved.isJoined) return resolved;
          final history = await _localStore.loadGroupMessages(
            group.groupId,
            group.groupChatHistory,
          );
          return resolved.copyWith(groupChatHistory: history);
        }),
      );
      // Also discover peers from existing private chats — covers anyone the
      // user has an open thread with who isn't in the /users/ peer list yet.
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
    // A unique client timestamp identifies this exact optimistic message, so
    // rapid identical sends don't collapse onto one server echo.
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
      _replaceUserMessage(targetUserId, message.timestamp, sent);
    } catch (_) {
      // Keep the optimistically added message but mark it as failed.
      await _localStore.insertDirectMessage(targetUserId, message);
      _replaceUserMessage(
          targetUserId, message.timestamp, message.copyWith(sendFailed: true));
    }
    notifyListeners();
  }

  /// Replaces the pending message identified by [ts] in [userId]'s thread.
  /// Re-finds the user by id so a concurrent reload can't corrupt an index.
  void _replaceUserMessage(
      String userId, DateTime ts, DirectMessage replacement) {
    _users = [
      for (final u in _users)
        if (u.userId == userId)
          u.copyWith(chatHistory: [
            for (final m in u.chatHistory)
              if (m.timestamp == ts && !m.isDelivered) replacement else m,
          ])
        else
          u,
    ];
  }

  Future<void> fetchPrivateMessages(String targetUserId) async {
    _loadingThreads.add(targetUserId);
    notifyListeners();
    try {
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
                  if (m.timestamp == message.timestamp && !m.isDelivered)
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
    _groups = [group.copyWith(isJoined: true), ..._groups];
    notifyListeners();
  }

  Future<void> joinGroup(String groupId) async {
    await _repo.joinGroup(groupId);
    _groups = [
      for (final g in _groups)
        if (g.groupId == groupId) g.copyWith(isJoined: true) else g,
    ];
    notifyListeners();
  }

  Future<void> leaveGroup(String groupId) async {
    await _repo.leaveGroup(groupId);
    _lastRead.remove(groupId);
    _persistLastRead();
    // Drop cached history so a future rejoin starts clean (no stale merge).
    await _localStore.clearGroupMessages(groupId);
    _groups = [
      for (final g in _groups)
        if (g.groupId == groupId)
          g.copyWith(isJoined: false, groupChatHistory: [])
        else
          g,
    ];
    notifyListeners();
  }

  Future<void> fetchGroupMessages(String groupId) async {
    _loadingThreads.add(groupId);
    notifyListeners();
    try {
      if (!_groups.any((g) => g.groupId == groupId)) return;
      final messages = await _repo.fetchGroupMessages(groupId);
      final merged = await _localStore.loadGroupMessages(groupId, messages);
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
