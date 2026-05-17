import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/network/api_error.dart';
import 'package:healthpilot/core/repositories/i_health_repository.dart';
import 'package:healthpilot/features/health/health_models.dart';

enum HealthLoadStatus { idle, loading, loaded, error }

class HealthProvider extends ChangeNotifier {
  final IHealthRepository _repo;

  List<HealthCondition> _conditions = [];
  List<HealthSymptom> _symptoms = [];
  HealthLoadStatus _status = HealthLoadStatus.idle;
  String? _error;
  bool _loadStarted = false;

  List<HealthCondition> get conditions => List.unmodifiable(_conditions);
  List<HealthSymptom> get symptoms => List.unmodifiable(_symptoms);
  HealthLoadStatus get status => _status;
  String? get error => _error;

  HealthProvider(this._repo);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    _status = HealthLoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _conditions = await _repo.fetchConditions();
      _symptoms = await _repo.fetchSymptoms();
      _status = HealthLoadStatus.loaded;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = HealthLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> addCondition(HealthCondition condition) async {
    final created = await _repo.addCondition(condition);
    _conditions = [created, ..._conditions];
    notifyListeners();
  }

  Future<void> deleteCondition(int id) async {
    await _repo.deleteCondition(id);
    _conditions = _conditions.where((c) => c.id != id).toList();
    notifyListeners();
  }

  Future<void> clearConditions() async {
    await _repo.clearConditions();
    _conditions = [];
    notifyListeners();
  }

  Future<void> addSymptom(HealthSymptom symptom) async {
    final created = await _repo.addSymptom(symptom);
    _symptoms = [created, ..._symptoms];
    notifyListeners();
  }

  Future<void> deleteSymptom(int id) async {
    await _repo.deleteSymptom(id);
    _symptoms = _symptoms.where((s) => s.id != id).toList();
    notifyListeners();
  }

  Future<void> clearSymptoms() async {
    await _repo.clearSymptoms();
    _symptoms = [];
    notifyListeners();
  }

  static String errorMessage(ApiException e) => e.userMessage;
}
