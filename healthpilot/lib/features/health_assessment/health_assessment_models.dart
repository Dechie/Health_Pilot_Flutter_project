import 'package:flutter/foundation.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_subject.dart';

enum BloodType { a, b, ab, o }

class AssessmentSummary {
  const AssessmentSummary({
    required this.subject,
    required this.bloodType,
    required this.allergies,
    required this.symptoms,
    required this.symptomDuration,
    required this.hasOtherSymptoms,
    required this.symptomsTrend,
  });

  final HealthAssessmentSubject? subject;
  final BloodType? bloodType;
  final String allergies;
  final List<String> symptoms;
  final String? symptomDuration;
  final bool? hasOtherSymptoms;
  final String? symptomsTrend;

  factory AssessmentSummary.fromJson(Map<String, dynamic> json) =>
      AssessmentSummary(
        subject: json['subject'] == null
            ? null
            : HealthAssessmentSubject.values
                .firstWhere((e) => e.name == json['subject']),
        bloodType: json['blood_type'] == null
            ? null
            : BloodType.values
                .firstWhere((e) => e.name == json['blood_type']),
        allergies: json['allergies'] as String? ?? '',
        symptoms: (json['symptoms'] as List?)?.cast<String>() ?? [],
        symptomDuration: json['symptom_duration'] as String?,
        hasOtherSymptoms: json['has_other_symptoms'] as bool?,
        symptomsTrend: json['symptoms_trend'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'subject': subject?.name,
        'blood_type': bloodType?.name,
        'allergies': allergies,
        'symptoms': symptoms,
        'symptom_duration': symptomDuration,
        'has_other_symptoms': hasOtherSymptoms,
        'symptoms_trend': symptomsTrend,
      };
}

@immutable
class CompletedAssessmentEntry {
  const CompletedAssessmentEntry({
    required this.id,
    required this.completedAt,
    required this.summary,
  });

  final String id;
  final DateTime completedAt;
  final AssessmentSummary summary;

  factory CompletedAssessmentEntry.fromJson(Map<String, dynamic> json) =>
      CompletedAssessmentEntry(
        id: json['id'] as String,
        completedAt: DateTime.parse(json['completed_at'] as String),
        summary: AssessmentSummary.fromJson(
            json['summary'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'completed_at': completedAt.toIso8601String(),
        'summary': summary.toJson(),
      };
}
