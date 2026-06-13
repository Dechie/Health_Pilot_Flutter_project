import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_community_repository.dart';
import 'package:healthpilot/features/community/community_models.dart';

class RemoteCommunityRepository implements ICommunityRepository {
  final ApiClient _api;
  RemoteCommunityRepository(this._api);

  @override
  Future<List<SuggestedPeer>> fetchSuggestedPeers() async {
    final data = await _api.get(
      '${ApiConstants.communityBase}/peers/suggested/',
    );
    return (data as List<dynamic>)
        .map((e) => SuggestedPeer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ConnectionRequest> sendConnectionRequest(int userId) async {
    final data = await _api.post(
      '${ApiConstants.communityBase}/peers/connect/',
      data: {'user_id': userId},
    );
    return ConnectionRequest.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<ConnectionRequest> respondToConnection(
      int requestId, String action) async {
    final data = await _api.patch(
      '${ApiConstants.communityBase}/peers/$requestId/',
      data: {'action': action},
    );
    return ConnectionRequest.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<ConnectionRequest>> getConnections() async {
    final data = await _api.get(
      '${ApiConstants.communityBase}/peers/connections/',
    );
    return (data as List<dynamic>)
        .map((e) => ConnectionRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
