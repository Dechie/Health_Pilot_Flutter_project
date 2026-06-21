import 'package:healthpilot/features/community/community_models.dart';

abstract class ICommunityRepository {
  Future<List<SuggestedPeer>> fetchSuggestedPeers();
  Future<ConnectionRequest> sendConnectionRequest(int userId);
  Future<ConnectionRequest> respondToConnection(int requestId, String action);
  Future<List<ConnectionRequest>> getConnections();
  Future<List<ConnectionRequest>> fetchIncomingRequests();

  // Community groups — `/community/groups/`
  Future<List<CommunityGroup>> fetchGroups();
  Future<CommunityGroup> createGroup({
    required String name,
    required String slug,
    String? description,
  });
  Future<void> joinGroup(int groupId);
  Future<void> leaveGroup(int groupId);
}
