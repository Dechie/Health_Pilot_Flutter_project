import 'package:flutter/foundation.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';

/// One completed run through the health assessment flow (in-memory only).
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
}

/// Ephemeral store until persistence is added.
class InMemoryAssessmentHistory extends ChangeNotifier {
  final List<CompletedAssessmentEntry> _entries = [];

  /// Newest first.
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
