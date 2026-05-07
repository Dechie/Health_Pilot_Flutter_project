import 'package:intl_mobile_field/mobile_number.dart';

/// Inline validators for personal info forms (local-only until API wiring).

String? validateRequiredName(String? v, String label) {
  if (v == null || v.trim().isEmpty) {
    return '$label is required';
  }
  return null;
}

String? validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) {
    return 'Email is required';
  }
  final s = v.trim();
  final ok = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(s);
  if (!ok) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validateMobileNumber(MobileNumber? m) {
  if (m == null) {
    return 'Phone number is required';
  }
  final digits = m.number.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 6) {
    return 'Enter a valid phone number';
  }
  return null;
}

/// Saved emergency contact row.
class EmergencyContactEntry {
  EmergencyContactEntry({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneComplete,
    this.relationship,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneComplete;
  final String? relationship;

  String get displayName => '$firstName $lastName'.trim();

  factory EmergencyContactEntry.fromJson(Map<String, dynamic> json) =>
      EmergencyContactEntry(
        id: json['id'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        email: json['email'] as String,
        phoneComplete: json['phone'] as String,
        relationship: json['relationship'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phoneComplete,
        if (relationship != null) 'relationship': relationship,
      };

  EmergencyContactEntry copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneComplete,
    String? relationship,
  }) {
    return EmergencyContactEntry(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneComplete: phoneComplete ?? this.phoneComplete,
      relationship: relationship ?? this.relationship,
    );
  }
}

/// Saved personal doctor row.
class PersonalDoctorEntry {
  PersonalDoctorEntry({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profession,
    required this.email,
    required this.phoneComplete,
    required this.reportFrequency,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String profession;
  final String email;
  final String phoneComplete;

  /// 1 daily, 2 weekly, 3 bi-weekly, 4 monthly
  final int reportFrequency;

  String get displayName => '$firstName $lastName'.trim();

  factory PersonalDoctorEntry.fromJson(Map<String, dynamic> json) =>
      PersonalDoctorEntry(
        id: json['id'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        profession: json['profession'] as String,
        email: json['email'] as String,
        phoneComplete: json['phone'] as String,
        reportFrequency: json['report_frequency'] as int? ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'profession': profession,
        'email': email,
        'phone': phoneComplete,
        'report_frequency': reportFrequency,
      };
}

/// Result when closing [SetupPersonalDoctor].
class DoctorSetupResult {
  const DoctorSetupResult.saved(PersonalDoctorEntry this.entry)
      : deleted = false;

  const DoctorSetupResult.removed()
      : entry = null,
        deleted = true;

  final PersonalDoctorEntry? entry;
  final bool deleted;
}
