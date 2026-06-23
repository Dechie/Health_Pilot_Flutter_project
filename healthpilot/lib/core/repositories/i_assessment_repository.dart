import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';

abstract class IAssessmentRepository {
  Future<List<CompletedAssessmentEntry>> fetchHistory();
  Future<CompletedAssessmentEntry> submitAssessment(AssessmentSummary summary);

  /// Run an assessment without an account — `POST /assessments/guest/`.
  Future<CompletedAssessmentEntry> submitGuestAssessment(
      AssessmentSummary summary);

  /// Fetch a single assessment — `GET /assessments/{id}/`.
  Future<CompletedAssessmentEntry> fetchEntry(String id);

  Future<void> deleteEntry(String id);
}
