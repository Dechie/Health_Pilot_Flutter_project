import 'package:healthpilot/core/repositories/i_assessment_repository.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';

class MockAssessmentRepository implements IAssessmentRepository {
  final List<CompletedAssessmentEntry> _entries = [];

  @override
  Future<List<CompletedAssessmentEntry>> fetchHistory() async =>
      List.of(_entries);

  @override
  Future<CompletedAssessmentEntry> submitAssessment(
      AssessmentSummary summary) async {
    final entry = CompletedAssessmentEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      completedAt: DateTime.now(),
      summary: summary,
    );
    _entries.insert(0, entry);
    return entry;
  }

  @override
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
  }
}
