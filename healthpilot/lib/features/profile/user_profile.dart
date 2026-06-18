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
    this.bmi,
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
  final double? bmi;
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
    final parts =
        [firstName, lastName].where((s) => s != null && s.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  factory UserProfile.fromAuthJson(Map<String, dynamic> json) {
    final data = _unwrapEnvelope(json);
    final (firstName, lastName) = _nameFields(data);
    return UserProfile(
      id: _parseApiInt(data['id']),
      firstName: firstName,
      lastName: lastName,
      email: data['email'] as String?,
      gender: data['gender'] as String?,
      dateOfBirth: _parseApiDate(data['date_of_birth'] as String?),
      age: _parseApiInt(data['age']),
      weightKg: _parseApiDouble(data['weight_kg']),
      heightCm: _parseApiDouble(data['height_cm']),
      bmi: _parseApiDouble(data['bmi']),
      allergies: data['allergies'] as String?,
      bloodType: data['blood_type'] as String?,
      hasHypertension: data['has_hypertension'] as String?,
      hasDiabetes: data['has_diabetes'] as String?,
      hasChronicCondition: data['has_chronic_condition'] as String?,
      isSmoker: data['is_smoker'] as String?,
      hadRecentSurgery: data['had_recent_surgery'] as String?,
    );
  }

  static DateTime? _parseApiDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static Map<String, dynamic> _unwrapEnvelope(Map<String, dynamic> json) {
    final inner = json['data'];
    if (inner is Map) return Map<String, dynamic>.from(inner);
    return json;
  }

  static (String?, String?) _nameFields(Map<String, dynamic> json) {
    var first = json['first_name'] as String?;
    var last = json['last_name'] as String?;
    if ((first == null || first.isEmpty) && (last == null || last.isEmpty)) {
      final full = json['full_name'] as String?;
      if (full != null && full.isNotEmpty) {
        final space = full.indexOf(' ');
        if (space < 0) return (full, null);
        return (full.substring(0, space), full.substring(space + 1).trim());
      }
    }
    return (first, last);
  }

  static int? _parseApiInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseApiDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory UserProfile.fromPublicJson(Map<String, dynamic> json) {
    final data = _unwrapEnvelope(json);
    return UserProfile(
      aboutMe: data['about_me'] as String?,
      isVisibleInCommunity: data['is_visible_in_community'] as bool? ?? true,
    );
  }

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
        bmi: other.bmi ?? bmi,
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
    double? bmi,
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
        bmi: bmi ?? this.bmi,
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
        if (bmi != null) 'bmi': bmi,
        if (allergies != null) 'allergies': allergies,
        if (bloodType != null) 'blood_type': bloodType,
        if (hasHypertension != null) 'has_hypertension': hasHypertension,
        if (hasDiabetes != null) 'has_diabetes': hasDiabetes,
        if (hasChronicCondition != null)
          'has_chronic_condition': hasChronicCondition,
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
