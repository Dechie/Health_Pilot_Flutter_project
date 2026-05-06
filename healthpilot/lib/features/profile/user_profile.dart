/// Client-side profile model. Merges data from /auth/me/ and /profile/me/.
class UserProfile {
  const UserProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneE164,
    this.weightKg,
    this.heightCm,
    this.aboutMe,
    this.isVisibleInCommunity = true,
    this.avatarAssetPath,
  });

  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneE164;
  final double? weightKg;
  final double? heightCm;
  final String? aboutMe;
  final bool isVisibleInCommunity;
  final String? avatarAssetPath;

  String? get displayName {
    final parts = [firstName, lastName].where((s) => s != null && s.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  factory UserProfile.fromAuthJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as int?,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        email: json['email'] as String?,
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        heightCm: (json['height_cm'] as num?)?.toDouble(),
      );

  factory UserProfile.fromPublicJson(Map<String, dynamic> json) => UserProfile(
        aboutMe: json['about_me'] as String?,
        isVisibleInCommunity: json['is_visible_in_community'] as bool? ?? true,
      );

  /// Returns a new profile with non-null fields from [other] taking priority.
  UserProfile mergeWith(UserProfile other) => UserProfile(
        id: other.id ?? id,
        firstName: other.firstName ?? firstName,
        lastName: other.lastName ?? lastName,
        email: other.email ?? email,
        phoneE164: other.phoneE164 ?? phoneE164,
        weightKg: other.weightKg ?? weightKg,
        heightCm: other.heightCm ?? heightCm,
        aboutMe: other.aboutMe ?? aboutMe,
        isVisibleInCommunity: other.isVisibleInCommunity,
        avatarAssetPath: other.avatarAssetPath ?? avatarAssetPath,
      );

  UserProfile copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneE164,
    double? weightKg,
    double? heightCm,
    String? aboutMe,
    bool? isVisibleInCommunity,
    String? avatarAssetPath,
  }) =>
      UserProfile(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phoneE164: phoneE164 ?? this.phoneE164,
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        aboutMe: aboutMe ?? this.aboutMe,
        isVisibleInCommunity: isVisibleInCommunity ?? this.isVisibleInCommunity,
        avatarAssetPath: avatarAssetPath ?? this.avatarAssetPath,
      );

  Map<String, dynamic> toAuthUpdateJson() => {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (email != null) 'email': email,
        if (weightKg != null) 'weight_kg': weightKg,
        if (heightCm != null) 'height_cm': heightCm,
      };

  Map<String, dynamic> toPublicUpdateJson() => {
        if (aboutMe != null) 'about_me': aboutMe,
        'is_visible_in_community': isVisibleInCommunity,
      };
}

/// Static demo values used when FF_PROFILE is false.
const UserProfile kDemoUserProfile = UserProfile(
  firstName: 'Mohammed',
  lastName: 'Ibrahim',
  email: 'mohammed@healthpilot.com',
  aboutMe: 'Health enthusiast.',
);
