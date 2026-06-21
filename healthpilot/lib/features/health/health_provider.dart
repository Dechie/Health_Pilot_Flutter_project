import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/network/api_error.dart';
import 'package:healthpilot/core/repositories/i_health_repository.dart';
import 'package:healthpilot/features/health/health_models.dart';

enum HealthLoadStatus { idle, loading, loaded, error }

class HealthProvider extends ChangeNotifier {
  final IHealthRepository _repo;

  List<HealthCondition> _conditions = [];
  List<HealthSymptom> _symptoms = [];
  List<VitalLog> _vitals = [];
  List<HealthGoal> _goals = [];
  HealthSummary? _latestSummary;
  HealthDashboard? _dashboard;
  HealthLoadStatus _status = HealthLoadStatus.idle;
  String? _error;
  bool _loadStarted = false;

  List<HealthCondition> get conditions => List.unmodifiable(_conditions);
  List<HealthSymptom> get symptoms => List.unmodifiable(_symptoms);
  List<VitalLog> get vitals => List.unmodifiable(_vitals);
  List<HealthGoal> get goals => List.unmodifiable(_goals);
  List<HealthGoal> get activeGoals =>
      _goals.where((g) => g.isActive).toList();
  HealthSummary? get latestSummary => _latestSummary;
  HealthDashboard? get dashboard => _dashboard;
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
      // conditions endpoint may not exist on backend yet — fail silently
      try {
        _conditions = await _repo.fetchConditions();
      } catch (_) {
        _conditions = [];
      }
      _symptoms = await _repo.fetchSymptoms();
      // Vitals, goals, summary and dashboard are independent and best-effort:
      // a failure in one shouldn't blank the whole health screen.
      _vitals = await _safe(_repo.fetchVitals, const <VitalLog>[]);
      _goals = await _safe(_repo.fetchGoals, const <HealthGoal>[]);
      _latestSummary = await _safe(_repo.fetchLatestSummary, null);
      _dashboard = await _safe<HealthDashboard?>(_repo.fetchDashboard, null);
      _status = HealthLoadStatus.loaded;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = HealthLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<T> _safe<T>(Future<T> Function() op, T fallback) async {
    try {
      return await op();
    } catch (_) {
      return fallback;
    }
  }

  Future<void> refresh() async {
    _loadStarted = false;
    await load();
  }

  // ── Vitals ────────────────────────────────────────────────────────────────
  Future<void> addVital(VitalLog vital) async {
    final created = await _repo.addVital(vital);
    _vitals = [created, ..._vitals];
    _dashboard = await _safe<HealthDashboard?>(_repo.fetchDashboard, _dashboard);
    notifyListeners();
  }

  // ── Goals ─────────────────────────────────────────────────────────────────
  Future<void> addGoal(HealthGoal goal) async {
    final created = await _repo.addGoal(goal);
    _goals = [created, ..._goals];
    notifyListeners();
  }

  Future<void> updateGoal(int id, HealthGoal goal) async {
    final updated = await _repo.updateGoal(id, goal);
    _goals = [
      for (final g in _goals) if (g.id == id) updated else g,
    ];
    notifyListeners();
  }

  Future<void> deleteGoal(int id) async {
    await _repo.deleteGoal(id);
    _goals = _goals.where((g) => g.id != id).toList();
    notifyListeners();
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
