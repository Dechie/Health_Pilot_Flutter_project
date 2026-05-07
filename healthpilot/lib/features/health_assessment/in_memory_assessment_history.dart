import 'package:flutter/foundation.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';

export 'package:healthpilot/features/health_assessment/health_assessment_models.dart'
    show CompletedAssessmentEntry;

/// Ephemeral store kept for reference — feature screens now use AssessmentProvider.
class InMemoryAssessmentHistory extends ChangeNotifier {
  final List<CompletedAssessmentEntry> _entries = [];

  List<CompletedAssessmentEntry> get entries => List.unmodifiable(_entries);

  void recordCompleted(AssessmentSummary summary) {
    final id = '${DateTime.now().microsecondsSinceEpoch}';
    _entries.insert(
      0,
      CompletedAssessmentEntry(
        id: id,
        completedAt: DateTime.now(),
        summary: summary,
      ),
    );
    notifyListeners();
  }
}
