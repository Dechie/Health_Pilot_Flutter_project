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

  /// Local / wizard JSON (mock storage, POST request body).
  factory AssessmentSummary.fromJson(Map<String, dynamic> json) =>
      AssessmentSummary(
        subject: json['subject'] == null
            ? null
            : HealthAssessmentSubject.values
                .firstWhere((e) => e.name == json['subject']),
        bloodType: _parseBloodType(json['blood_type'] as String?),
        allergies: json['allergies'] as String? ?? '',
        symptoms: (json['symptoms'] as List?)?.cast<String>() ?? [],
        symptomDuration: json['symptom_duration'] as String?,
        hasOtherSymptoms: json['has_other_symptoms'] as bool?,
        symptomsTrend: json['symptoms_trend'] as String?,
      );

  /// Maps a backend assessment record (list item or detail) to the wizard model.
  factory AssessmentSummary.fromApiJson(Map<String, dynamic> json) {
    final forWhom = json['for_whom'] as String? ?? json['subject'] as String?;
    final subject = _parseSubject(forWhom);

    final rawSymptoms = json['symptoms'];
    final List<String> symptoms;
    if (rawSymptoms is List) {
      symptoms = rawSymptoms.cast<String>();
    } else if (rawSymptoms is String && rawSymptoms.isNotEmpty) {
      symptoms = rawSymptoms
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      symptoms = [];
    }

    final notes = json['additional_notes'] as String? ?? '';
    bool? hasOtherSymptoms = json['has_other_symptoms'] as bool?;
    String? symptomsTrend = json['symptoms_trend'] as String?;
    if (notes.contains('additional symptoms')) {
      hasOtherSymptoms = true;
    }
    for (final (pattern, trend) in [
      ('trend: worse', 'worse'),
      ('trend: better', 'better'),
      ('trend: no_change', 'no_change'),
    ]) {
      if (notes.contains(pattern)) {
        symptomsTrend = trend;
        break;
      }
    }

    return AssessmentSummary(
      subject: subject,
      bloodType: _parseBloodType(json['blood_type'] as String?),
      allergies: json['allergies'] as String? ?? '',
      symptoms: symptoms,
      symptomDuration: json['symptom_duration'] as String?,
      hasOtherSymptoms: hasOtherSymptoms,
      symptomsTrend: symptomsTrend,
    );
  }

  Map<String, dynamic> toJson() => {
        'subject': subject?.name,
        'blood_type': bloodType?.name,
        'allergies': allergies,
        'symptoms': symptoms,
        'symptom_duration': symptomDuration,
        'has_other_symptoms': hasOtherSymptoms,
        'symptoms_trend': symptomsTrend,
      };

  /// Loose match for recovering a saved record after a 503 AI failure.
  bool looselyMatches(AssessmentSummary other) {
    if (subject != other.subject) return false;
    if (symptoms.length != other.symptoms.length) return false;
    final a = symptoms.map((s) => s.toLowerCase()).toSet();
    final b = other.symptoms.map((s) => s.toLowerCase()).toSet();
    return a.containsAll(b) && b.containsAll(a);
  }
}

HealthAssessmentSubject? _parseSubject(String? forWhom) {
  if (forWhom == null || forWhom.isEmpty) return null;
  if (forWhom == 'someone_else' || forWhom == 'someoneElse') {
    return HealthAssessmentSubject.someoneElse;
  }
  for (final subject in HealthAssessmentSubject.values) {
    if (subject.name == forWhom) return subject;
  }
  return null;
}

BloodType? _parseBloodType(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final normalized = raw.toLowerCase();
  for (final type in BloodType.values) {
    if (type.name == normalized) return type;
  }
  return null;
}

@immutable
class PossibleCause {
  const PossibleCause({
    required this.name,
    this.description,
    this.urgency,
  });

  final String name;
  final String? description;
  final String? urgency;

  factory PossibleCause.fromJson(Map<String, dynamic> json) => PossibleCause(
        name: json['name'] as String? ??
            json['condition'] as String? ??
            json['disease'] as String? ??
            'Unknown',
        description: json['description'] as String?,
        urgency: json['urgency'] as String? ?? json['severity']?.toString(),
      );
}

@immutable
class AssessmentAiResult {
  const AssessmentAiResult({
    required this.possibleCauses,
    this.generalAdvice,
    this.seekEmergencyCare = false,
  });

  final List<PossibleCause> possibleCauses;
  final String? generalAdvice;
  final bool seekEmergencyCare;

  factory AssessmentAiResult.fromJson(Map<String, dynamic> json) =>
      AssessmentAiResult(
        possibleCauses: (json['possible_causes'] as List?)
                ?.map(
                  (e) => PossibleCause.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        generalAdvice: json['general_advice'] as String?,
        seekEmergencyCare: json['seek_emergency_care'] as bool? ?? false,
      );
}

@immutable
class CompletedAssessmentEntry {
  const CompletedAssessmentEntry({
    required this.id,
    required this.completedAt,
    required this.summary,
    this.status,
    this.result,
  });

  final String id;
  final DateTime completedAt;
  final AssessmentSummary summary;
  final String? status;
  final AssessmentAiResult? result;

  bool get isAiPendingOrFailed =>
      status == 'failed' || status == 'pending' || result == null;

  /// Local mock / legacy nested JSON.
  factory CompletedAssessmentEntry.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('summary')) {
      return CompletedAssessmentEntry(
        id: json['id'] as String,
        completedAt: DateTime.parse(json['completed_at'] as String),
        summary: AssessmentSummary.fromJson(
          json['summary'] as Map<String, dynamic>,
        ),
      );
    }
    return CompletedAssessmentEntry.fromApiJson(json);
  }

  /// Backend list item, detail, or POST response.
  factory CompletedAssessmentEntry.fromApiJson(Map<String, dynamic> json) =>
      CompletedAssessmentEntry(
        id: json['id'] as String,
        completedAt: DateTime.parse(json['created_at'] as String),
        summary: AssessmentSummary.fromApiJson(json),
        status: json['status'] as String?,
        result: json['result'] is Map<String, dynamic>
            ? AssessmentAiResult.fromJson(
                json['result'] as Map<String, dynamic>,
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'completed_at': completedAt.toIso8601String(),
        'summary': summary.toJson(),
        if (status != null) 'status': status,
        if (result != null)
          'result': {
            'possible_causes': result!.possibleCauses
                .map((c) => {
                      'name': c.name,
                      if (c.description != null) 'description': c.description,
                      if (c.urgency != null) 'urgency': c.urgency,
                    })
                .toList(),
            if (result!.generalAdvice != null)
              'general_advice': result!.generalAdvice,
            'seek_emergency_care': result!.seekEmergencyCare,
          },
      };
}
