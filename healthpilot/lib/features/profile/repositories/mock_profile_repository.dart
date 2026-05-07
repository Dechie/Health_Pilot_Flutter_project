import 'package:healthpilot/core/repositories/i_profile_repository.dart';
import 'package:healthpilot/features/profile/user_profile.dart';

class MockProfileRepository implements IProfileRepository {
  @override
  Future<UserProfile> fetchMe() async => kDemoUserProfile;

  @override
  Future<UserProfile> updateMe(UserProfile profile) async => profile;

  @override
  Future<UserProfile> fetchPublicProfile() async => const UserProfile(
        aboutMe: 'Health enthusiast.',
        isVisibleInCommunity: true,
      );

  @override
  Future<UserProfile> updatePublicProfile(UserProfile profile) async => profile;
}
