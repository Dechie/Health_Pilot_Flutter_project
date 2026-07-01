import 'package:healthpilot/features/profile/user_profile.dart';

abstract class IProfileRepository {
  Future<UserProfile> fetchMe();
  Future<UserProfile> updateMe(UserProfile profile);
  Future<UserProfile> fetchPublicProfile();
  Future<UserProfile> updatePublicProfile(UserProfile profile);

  /// Uploads a new avatar image — multipart `PATCH /auth/me/` with a
  /// `profile_picture` file field. Returns the updated profile.
  Future<UserProfile> uploadAvatar(String filePath);
}
