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
}
