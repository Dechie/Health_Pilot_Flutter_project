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

/// Saved emergency contact row (in-memory on hub screen).
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

/// Saved personal doctor row (in-memory on hub screen).
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
