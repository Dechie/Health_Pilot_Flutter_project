import 'package:healthpilot/core/repositories/i_community_repository.dart';
import 'package:healthpilot/features/community/community_models.dart';

class MockCommunityRepository implements ICommunityRepository {
  final List<SuggestedPeer> _mockPeers = [
    const SuggestedPeer(
      id: 2,
      fullName: 'Sara M.',
      age: 32,
      score: 8,
      reason: 'Similar: diabetes, hypertension, headache',
    ),
    const SuggestedPeer(
      id: 3,
      fullName: 'Ahmed K.',
      age: 28,
      score: 3,
      reason: 'Similar: diabetes',
    ),
    const SuggestedPeer(
      id: 4,
      fullName: 'Emily R.',
      age: 35,
      score: 6,
      reason: 'Similar: blood type, chronic condition',
    ),
  ];

  @override
  Future<List<SuggestedPeer>> fetchSuggestedPeers() async =>
      List.of(_mockPeers);

  @override
  Future<ConnectionRequest> sendConnectionRequest(int userId) async {
    return ConnectionRequest(
      id: DateTime.now().millisecondsSinceEpoch,
      fromUserId: 123,
      fromUserFullName: 'Current User',
      toUserId: userId,
      toUserFullName: 'Peer User',
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<ConnectionRequest> respondToConnection(
      int requestId, String action) async {
    return ConnectionRequest(
      id: requestId,
      fromUserId: 5,
      fromUserFullName: 'Sara M.',
      toUserId: 123,
      toUserFullName: 'Current User',
      status: action == 'accepted' ? 'accepted' : 'rejected',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<ConnectionRequest>> getConnections() async => [
        ConnectionRequest(
          id: 1,
          fromUserId: 2,
          fromUserFullName: 'Sara M.',
          toUserId: 123,
          toUserFullName: 'Current User',
          status: 'accepted',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  @override
  Future<List<ConnectionRequest>> fetchIncomingRequests() async => [
        ConnectionRequest(
          id: 2,
          fromUserId: 56,
          fromUserFullName: 'puls minds',
          toUserId: 123,
          toUserFullName: 'Current User',
          status: 'pending',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

  // ── Community groups ────────────────────────────────────────────────────────
  final List<CommunityGroup> _groups = [
    const CommunityGroup(
      id: 1,
      name: 'Diabetes Support',
      slug: 'diabetes-support',
      description: 'Share tips on managing diabetes.',
      conditionTags: ['diabetes'],
      memberCount: 12,
      isMember: true,
    ),
    const CommunityGroup(
      id: 2,
      name: 'Heart Health',
      slug: 'heart-health',
      description: 'Hypertension and cardiac wellness.',
      conditionTags: ['hypertension'],
      memberCount: 8,
      isMember: false,
    ),
  ];
  int _nextGroupId = 3;

  @override
  Future<List<CommunityGroup>> fetchGroups() async => List.of(_groups);

  @override
  Future<CommunityGroup> createGroup({
    required String name,
    required String slug,
    String? description,
  }) async {
    final group = CommunityGroup(
      id: _nextGroupId++,
      name: name,
      slug: slug,
      description: description,
      memberCount: 1,
      isMember: true,
    );
    _groups.insert(0, group);
    return group;
  }

  @override
  Future<void> joinGroup(int groupId) async {
    final i = _groups.indexWhere((g) => g.id == groupId);
    if (i != -1) {
      _groups[i] = _groups[i]
          .copyWith(isMember: true, memberCount: _groups[i].memberCount + 1);
    }
  }

  @override
  Future<void> leaveGroup(int groupId) async {
    final i = _groups.indexWhere((g) => g.id == groupId);
    if (i != -1) {
      _groups[i] = _groups[i].copyWith(
          isMember: false,
          memberCount:
              _groups[i].memberCount > 0 ? _groups[i].memberCount - 1 : 0);
    }
  }
}
