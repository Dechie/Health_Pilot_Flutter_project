import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_community_repository.dart';
import 'package:healthpilot/features/community/community_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityProvider extends ChangeNotifier {
  final ICommunityRepository _repo;

  static const _kPendingPeerIdsKey = 'community_pending_sent_peer_ids';

  List<SuggestedPeer> _suggestedPeers = [];
  List<ConnectionRequest> _connections = [];
  List<ConnectionRequest> _incomingRequests = [];
  List<ConnectionRequest> _sentRequests = [];
  List<CommunityGroup> _groups = [];
  CommunityStatus _status = CommunityStatus.idle;
  bool _loading = false;

  List<CommunityGroup> get groups => List.unmodifiable(_groups);
  List<CommunityGroup> get joinedGroups =>
      _groups.where((g) => g.isMember).toList();
  List<SuggestedPeer> get suggestedPeers => List.unmodifiable(_suggestedPeers);
  List<ConnectionRequest> get connections => List.unmodifiable(_connections);
  List<ConnectionRequest> get incomingRequests =>
      List.unmodifiable(_incomingRequests.where((r) => r.status == 'pending'));
  List<ConnectionRequest> get sentRequests =>
      List.unmodifiable(_sentRequests.where((r) => r.status == 'pending'));
  CommunityStatus get status => _status;

  CommunityProvider(this._repo);

  SuggestedPeer? findSuggestedPeer(int id) {
    try {
      return _suggestedPeers.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  bool hasSentRequest(int peerId) =>
      _sentRequests.any((r) => r.toUserId == peerId && r.status == 'pending');

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _status = CommunityStatus.loading;
    notifyListeners();
    try {
      await _loadSentPeerIds();
      final results = await Future.wait([
        _repo.fetchSuggestedPeers(),
        _repo.getConnections(),
        _repo.fetchIncomingRequests(),
      ]);
      _suggestedPeers = results[0] as List<SuggestedPeer>;
      _connections = results[1] as List<ConnectionRequest>;
      _incomingRequests = results[2] as List<ConnectionRequest>;
      // Groups are best-effort — don't fail the whole screen if unavailable.
      try {
        _groups = await _repo.fetchGroups();
      } catch (_) {
        _groups = [];
      }
      _cleanupAcceptedSent();
      _status = CommunityStatus.loaded;
    } catch (_) {
      _status = CommunityStatus.error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> sendConnectionRequest(int userId) async {
    final request = await _repo.sendConnectionRequest(userId);
    _sentRequests = [..._sentRequests, request];
    await _saveSentPeerIds();
    notifyListeners();
  }

  Future<void> refreshIncomingRequests() async {
    _incomingRequests = await _repo.fetchIncomingRequests();
    notifyListeners();
  }

  Future<void> refreshConnections() async {
    _connections = await _repo.getConnections();
    _cleanupAcceptedSent();
    _saveSentPeerIds();
    notifyListeners();
  }

  Future<void> respondToConnection(int requestId, bool accept) async {
    final updated = await _repo.respondToConnection(
        requestId, accept ? 'accepted' : 'declined');
    _connections = [
      for (final c in _connections)
        if (c.id == requestId) updated else c,
    ];
    _incomingRequests = [
      for (final r in _incomingRequests)
        if (r.id == requestId) updated else r,
    ];
    notifyListeners();
  }

  // ── Community groups ───────────────────────────────────────────────────────

  Future<void> refreshGroups() async {
    _groups = await _repo.fetchGroups();
    notifyListeners();
  }

  Future<void> createGroup({
    required String name,
    required String slug,
    String? description,
  }) async {
    final group = await _repo.createGroup(
        name: name, slug: slug, description: description);
    _groups = [group, ..._groups];
    notifyListeners();
  }

  Future<void> joinGroup(int groupId) async {
    await _repo.joinGroup(groupId);
    _groups = [
      for (final g in _groups)
        if (g.id == groupId)
          g.copyWith(isMember: true, memberCount: g.memberCount + 1)
        else
          g,
    ];
    notifyListeners();
  }

  Future<void> leaveGroup(int groupId) async {
    await _repo.leaveGroup(groupId);
    _groups = [
      for (final g in _groups)
        if (g.id == groupId)
          g.copyWith(
              isMember: false,
              memberCount: g.memberCount > 0 ? g.memberCount - 1 : 0)
        else
          g,
    ];
    notifyListeners();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> _saveSentPeerIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _sentRequests
        .where((r) => r.status == 'pending')
        .map((r) => r.toUserId)
        .toList();
    await prefs.setString(_kPendingPeerIdsKey, jsonEncode(ids));
  }

  Future<void> _loadSentPeerIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPendingPeerIdsKey);
    if (raw == null || raw.isEmpty) return;
    final ids = (jsonDecode(raw) as List<dynamic>).cast<int>();
    _sentRequests = ids
        .map((id) => ConnectionRequest(
              id: 0,
              fromUserId: 0,
              fromUserFullName: '',
              toUserId: id,
              toUserFullName: '',
              status: 'pending',
              createdAt: DateTime.now(),
            ))
        .toList();
  }

  void _cleanupAcceptedSent() {
    final acceptedIds =
        _connections.where((c) => c.status == 'accepted').map((c) => c.toUserId).toSet();
    _sentRequests =
        _sentRequests.where((r) => !acceptedIds.contains(r.toUserId)).toList();
  }
}
