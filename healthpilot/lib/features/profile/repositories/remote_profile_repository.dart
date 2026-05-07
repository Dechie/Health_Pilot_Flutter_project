import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_profile_repository.dart';
import 'package:healthpilot/features/profile/user_profile.dart';

class RemoteProfileRepository implements IProfileRepository {
  final ApiClient _client;

  const RemoteProfileRepository(this._client);

  @override
  Future<UserProfile> fetchMe() async {
    final data = await _client.get('${ApiConstants.authBase}/me/');
    return UserProfile.fromAuthJson(data as Map<String, dynamic>);
  }

  @override
  Future<UserProfile> updateMe(UserProfile profile) async {
    final data = await _client.patch(
      '${ApiConstants.authBase}/me/',
      data: profile.toAuthUpdateJson(),
    );
    return UserProfile.fromAuthJson(data as Map<String, dynamic>);
  }

  @override
  Future<UserProfile> fetchPublicProfile() async {
    final data = await _client.get('${ApiConstants.profileBase}/me/');
    return UserProfile.fromPublicJson(data as Map<String, dynamic>);
  }

  @override
  Future<UserProfile> updatePublicProfile(UserProfile profile) async {
    final data = await _client.patch(
      '${ApiConstants.profileBase}/me/',
      data: profile.toPublicUpdateJson(),
    );
    return UserProfile.fromPublicJson(data as Map<String, dynamic>);
  }
}
