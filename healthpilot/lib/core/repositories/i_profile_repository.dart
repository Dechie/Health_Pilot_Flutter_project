import 'package:healthpilot/features/profile/user_profile.dart';

abstract class IProfileRepository {
  Future<UserProfile> fetchMe();
  Future<UserProfile> updateMe(UserProfile profile);
  Future<UserProfile> fetchPublicProfile();
  Future<UserProfile> updatePublicProfile(UserProfile profile);
}
