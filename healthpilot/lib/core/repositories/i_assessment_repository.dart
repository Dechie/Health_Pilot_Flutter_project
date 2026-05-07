import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';

abstract class IAssessmentRepository {
  Future<List<CompletedAssessmentEntry>> fetchHistory();
  Future<CompletedAssessmentEntry> submitAssessment(AssessmentSummary summary);
  Future<void> deleteEntry(String id);
}
