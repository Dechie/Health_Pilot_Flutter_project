/// Maps onboarding UI gender labels to API values (`M` / `F`).
String? genderToApi(String? uiGender) {
  switch (uiGender) {
    case 'male':
      return 'M';
    case 'female':
      return 'F';
    default:
      return null;
  }
}

/// Approximates [date_of_birth] from an age picker value (Jan 1 of birth year).
String dateOfBirthFromAge(int age) {
  final year = DateTime.now().year - age;
  return '${year.toString().padLeft(4, '0')}-01-01';
}

/// Maps Yes/No radio answers to API Y/N flags. Unknown answers are omitted.
String? yesNoToYn(String? answer) {
  switch (answer) {
    case 'Yes':
      return 'Y';
    case 'No':
      return 'N';
    default:
      return null;
  }
}

String _formatApiDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Client-side profile model. Merges data from /auth/me/ and /profile/me/.
class UserProfile {
  const UserProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneE164,
    this.gender,
    this.dateOfBirth,
    this.age,
    this.weightKg,
    this.heightCm,
    this.allergies,
    this.bloodType,
    this.hasHypertension,
    this.hasDiabetes,
    this.hasChronicCondition,
    this.isSmoker,
    this.hadRecentSurgery,
    this.aboutMe,
    this.isVisibleInCommunity = true,
    this.avatarAssetPath,
  });

  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneE164;
  final String? gender;
  final DateTime? dateOfBirth;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final String? allergies;
  final String? bloodType;
  final String? hasHypertension;
  final String? hasDiabetes;
  final String? hasChronicCondition;
  final String? isSmoker;
  final String? hadRecentSurgery;
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
        gender: json['gender'] as String?,
        dateOfBirth: _parseApiDate(json['date_of_birth'] as String?),
        age: (json['age'] as num?)?.toInt(),
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        allergies: json['allergies'] as String?,
        bloodType: json['blood_type'] as String?,
        hasHypertension: json['has_hypertension'] as String?,
        hasDiabetes: json['has_diabetes'] as String?,
        hasChronicCondition: json['has_chronic_condition'] as String?,
        isSmoker: json['is_smoker'] as String?,
        hadRecentSurgery: json['had_recent_surgery'] as String?,
      );

  static DateTime? _parseApiDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

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
        gender: other.gender ?? gender,
        dateOfBirth: other.dateOfBirth ?? dateOfBirth,
        age: other.age ?? age,
        weightKg: other.weightKg ?? weightKg,
        heightCm: other.heightCm ?? heightCm,
        allergies: other.allergies ?? allergies,
        bloodType: other.bloodType ?? bloodType,
        hasHypertension: other.hasHypertension ?? hasHypertension,
        hasDiabetes: other.hasDiabetes ?? hasDiabetes,
        hasChronicCondition: other.hasChronicCondition ?? hasChronicCondition,
        isSmoker: other.isSmoker ?? isSmoker,
        hadRecentSurgery: other.hadRecentSurgery ?? hadRecentSurgery,
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
    String? gender,
    DateTime? dateOfBirth,
    int? age,
    double? weightKg,
    double? heightCm,
    String? allergies,
    String? bloodType,
    String? hasHypertension,
    String? hasDiabetes,
    String? hasChronicCondition,
    String? isSmoker,
    String? hadRecentSurgery,
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
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        age: age ?? this.age,
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        allergies: allergies ?? this.allergies,
        bloodType: bloodType ?? this.bloodType,
        hasHypertension: hasHypertension ?? this.hasHypertension,
        hasDiabetes: hasDiabetes ?? this.hasDiabetes,
        hasChronicCondition: hasChronicCondition ?? this.hasChronicCondition,
        isSmoker: isSmoker ?? this.isSmoker,
        hadRecentSurgery: hadRecentSurgery ?? this.hadRecentSurgery,
        aboutMe: aboutMe ?? this.aboutMe,
        isVisibleInCommunity: isVisibleInCommunity ?? this.isVisibleInCommunity,
        avatarAssetPath: avatarAssetPath ?? this.avatarAssetPath,
      );

  Map<String, dynamic> toAuthUpdateJson() => {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (email != null) 'email': email,
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null) 'date_of_birth': _formatApiDate(dateOfBirth!),
        if (weightKg != null) 'weight_kg': weightKg,
        if (heightCm != null) 'height_cm': heightCm,
        if (allergies != null) 'allergies': allergies,
        if (bloodType != null) 'blood_type': bloodType,
        if (hasHypertension != null) 'has_hypertension': hasHypertension,
        if (hasDiabetes != null) 'has_diabetes': hasDiabetes,
        if (hasChronicCondition != null) 'has_chronic_condition': hasChronicCondition,
        if (isSmoker != null) 'is_smoker': isSmoker,
        if (hadRecentSurgery != null) 'had_recent_surgery': hadRecentSurgery,
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
