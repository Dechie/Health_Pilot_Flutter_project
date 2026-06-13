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
      status: action == 'accept' ? 'accepted' : 'rejected',
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
          status: 'accepted',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
}
