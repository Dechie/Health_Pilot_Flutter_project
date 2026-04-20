/// Client-side profile snapshot until backend auth provides a canonical user.
///
/// UI can hold a cached instance; later swap for repository-backed state.
class UserProfile {
  const UserProfile({
    this.displayName,
    this.email,
    this.phoneE164,
    this.avatarAssetPath,
  });

  final String? displayName;
  final String? email;
  final String? phoneE164;
  final String? avatarAssetPath;

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? phoneE164,
    String? avatarAssetPath,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneE164: phoneE164 ?? this.phoneE164,
      avatarAssetPath: avatarAssetPath ?? this.avatarAssetPath,
    );
  }
}

/// Temporary demo values for UI until persistence exists.
const UserProfile kDemoUserProfile = UserProfile(
  displayName: 'Mohammed Ibrahim',
);
