import 'package:healthpilot/features/community/community_models.dart';

abstract class ICommunityRepository {
  Future<List<SuggestedPeer>> fetchSuggestedPeers();
  Future<ConnectionRequest> sendConnectionRequest(int userId);
  Future<ConnectionRequest> respondToConnection(int requestId, String action);
  Future<List<ConnectionRequest>> getConnections();
  Future<List<ConnectionRequest>> fetchIncomingRequests();
}
