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
    _status = AssessmentLoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _entries = await _repo.fetchHistory();
      _status = AssessmentLoadStatus.loaded;
    } on ApiException catch (e) {
      _error = _msg(e);
      _status = AssessmentLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> submit(AssessmentSummary summary) async {
    final entry = await _repo.submitAssessment(summary);
    _entries = [entry, ..._entries];
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _repo.deleteEntry(id);
    _entries = _entries.where((e) => e.id != id).toList();
    notifyListeners();
  }

  static String _msg(ApiException e) => switch (e) {
        ServerError(:final message) => message,
        NetworkError() => 'No internet connection.',
        _ => 'Something went wrong.',
      };
}
