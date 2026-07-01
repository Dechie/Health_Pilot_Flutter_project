import 'package:dio/dio.dart';
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

  @override
  Future<UserProfile> uploadAvatar(String filePath) async {
    // The backend expects `profile_picture` as a multipart file (not a URL);
    // Dio sets the multipart content-type automatically for FormData.
    final fileName = filePath.split('/').last;
    final form = FormData.fromMap({
      'profile_picture': await MultipartFile.fromFile(
        filePath,
        filename: fileName.isEmpty ? 'avatar.jpg' : fileName,
      ),
    });
    final data = await _client.patch(
      '${ApiConstants.authBase}/me/',
      data: form,
    );
    return UserProfile.fromAuthJson(data as Map<String, dynamic>);
  }
}
