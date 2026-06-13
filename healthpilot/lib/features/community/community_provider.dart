import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_community_repository.dart';
import 'package:healthpilot/features/community/community_models.dart';

class CommunityProvider extends ChangeNotifier {
  final ICommunityRepository _repo;

  List<SuggestedPeer> _suggestedPeers = [];
  List<ConnectionRequest> _connections = [];
  CommunityStatus _status = CommunityStatus.idle;
  bool _loadStarted = false;

  List<SuggestedPeer> get suggestedPeers => List.unmodifiable(_suggestedPeers);
  List<ConnectionRequest> get connections => List.unmodifiable(_connections);
  CommunityStatus get status => _status;

  CommunityProvider(this._repo);

  SuggestedPeer? findSuggestedPeer(int id) {
    try {
      return _suggestedPeers.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    _status = CommunityStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repo.fetchSuggestedPeers(),
        _repo.getConnections(),
      ]);
      _suggestedPeers = results[0] as List<SuggestedPeer>;
      _connections = results[1] as List<ConnectionRequest>;
      _status = CommunityStatus.loaded;
    } catch (_) {
      _status = CommunityStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> sendConnectionRequest(int userId) async {
    await _repo.sendConnectionRequest(userId);
  }

  Future<void> respondToConnection(int requestId, bool accept) async {
    final updated =
        await _repo.respondToConnection(requestId, accept ? 'accept' : 'reject');
    _connections = [
      for (final c in _connections)
        if (c.id == requestId) updated else c,
    ];
    notifyListeners();
  }
}
