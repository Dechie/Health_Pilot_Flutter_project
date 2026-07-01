import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/network/api_error.dart';
import 'package:healthpilot/core/repositories/i_assessment_repository.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';

enum AssessmentLoadStatus { idle, loading, loaded, error }

class AssessmentProvider extends ChangeNotifier {
  final IAssessmentRepository _repo;

  List<CompletedAssessmentEntry> _entries = [];
  AssessmentLoadStatus _status = AssessmentLoadStatus.idle;
  String? _error;
  bool _loadStarted = false;

  List<CompletedAssessmentEntry> get entries => List.unmodifiable(_entries);
  AssessmentLoadStatus get status => _status;
  String? get error => _error;

  AssessmentProvider(this._repo);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    await _fetchHistory();
  }

  Future<void> refresh() async {
    await _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    _status = AssessmentLoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _entries = await _repo.fetchHistory();
      _status = AssessmentLoadStatus.loaded;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = AssessmentLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Submits the wizard summary. On a 503 AI outage the backend may still
  /// persist the record — we refresh history and return the matching entry.
  Future<CompletedAssessmentEntry> submit(AssessmentSummary summary) async {
    try {
      final entry = await _repo.submitAssessment(summary);
      _upsertEntry(entry);
      return entry;
    } on ServerError catch (e) {
      if (e.statusCode != 503) rethrow;
      final recovered = await _recoverEntryAfterAiOutage(summary);
      if (recovered != null) return recovered;
      rethrow;
    }
  }

  Future<CompletedAssessmentEntry?> _recoverEntryAfterAiOutage(
    AssessmentSummary summary,
  ) async {
    try {
      final history = await _repo.fetchHistory();
      _entries = history;
      _status = AssessmentLoadStatus.loaded;
      notifyListeners();
      for (final entry in history) {
        if (entry.summary.looselyMatches(summary)) return entry;
      }
    } on ApiException {
      // Fall through to rethrow the original 503.
    }
    return null;
  }

  void _upsertEntry(CompletedAssessmentEntry entry) {
    _entries = [
      entry,
      ..._entries.where((e) => e.id != entry.id),
    ];
    notifyListeners();
  }

  /// Run an assessment without an account — `POST /assessments/guest/`.
  Future<CompletedAssessmentEntry> submitGuestAssessment(
          AssessmentSummary summary) =>
      _repo.submitGuestAssessment(summary);

  Future<void> delete(String id) async {
    await _repo.deleteEntry(id);
    _entries = _entries.where((e) => e.id != id).toList();
    notifyListeners();
  }
}
