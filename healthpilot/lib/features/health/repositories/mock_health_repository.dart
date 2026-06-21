import 'package:healthpilot/core/repositories/i_health_repository.dart';
import 'package:healthpilot/features/health/health_models.dart';

class MockHealthRepository implements IHealthRepository {
  final List<HealthCondition> _conditions = List.generate(
    kSeedConditions.length,
    (i) => HealthCondition(
      id: i + 1,
      name: kSeedConditions[i].name,
      loggedAt: kSeedConditions[i].loggedAt,
    ),
  );

  final List<HealthSymptom> _symptoms = List.generate(
    kSeedSymptoms.length,
    (i) => HealthSymptom(
      id: i + 1,
      name: kSeedSymptoms[i].name,
      severity: kSeedSymptoms[i].severity,
      loggedAt: kSeedSymptoms[i].loggedAt,
    ),
  );

  int _nextId = 100;

  @override
  Future<List<HealthCondition>> fetchConditions() async => List.of(_conditions);

  @override
  Future<HealthCondition> addCondition(HealthCondition condition) async {
    final created = HealthCondition(
      id: _nextId++,
      name: condition.name,
      loggedAt: condition.loggedAt,
    );
    _conditions.insert(0, created);
    return created;
  }

  @override
  Future<void> deleteCondition(int id) async {
    _conditions.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> clearConditions() async => _conditions.clear();

  @override
  Future<List<HealthSymptom>> fetchSymptoms() async => List.of(_symptoms);

  @override
  Future<HealthSymptom> addSymptom(HealthSymptom symptom) async {
    final created = HealthSymptom(
      id: _nextId++,
      name: symptom.name,
      severity: symptom.severity,
      loggedAt: symptom.loggedAt,
    );
    _symptoms.insert(0, created);
    return created;
  }

  @override
  Future<void> deleteSymptom(int id) async {
    _symptoms.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> clearSymptoms() async => _symptoms.clear();

  // ── Vitals ────────────────────────────────────────────────────────────────
  final List<VitalLog> _vitals = [
    VitalLog(
      id: 1,
      systolicBp: 118,
      diastolicBp: 76,
      heartRate: 68,
      steps: 5400,
      measuredAt: DateTime(2026, 6, 20, 8),
    ),
  ];

  @override
  Future<List<VitalLog>> fetchVitals() async => List.of(_vitals);

  @override
  Future<VitalLog> addVital(VitalLog vital) async {
    final created = VitalLog(
      id: _nextId++,
      systolicBp: vital.systolicBp,
      diastolicBp: vital.diastolicBp,
      heartRate: vital.heartRate,
      temperatureC: vital.temperatureC,
      oxygenSaturation: vital.oxygenSaturation,
      bloodGlucose: vital.bloodGlucose,
      weightKg: vital.weightKg,
      steps: vital.steps,
      notes: vital.notes,
      measuredAt: vital.measuredAt ?? DateTime(2026, 6, 21),
    );
    _vitals.insert(0, created);
    return created;
  }

  // ── Goals ─────────────────────────────────────────────────────────────────
  final List<HealthGoal> _goals = [
    const HealthGoal(
      id: 1,
      goalType: 'steps',
      targetValue: 10000,
      unit: 'steps',
      description: 'Daily step target',
    ),
  ];

  @override
  Future<List<HealthGoal>> fetchGoals() async => List.of(_goals);

  @override
  Future<HealthGoal> addGoal(HealthGoal goal) async {
    final withId = HealthGoal(
      id: _nextId++,
      goalType: goal.goalType,
      targetValue: goal.targetValue,
      unit: goal.unit,
      description: goal.description,
      isActive: goal.isActive,
    );
    _goals.insert(0, withId);
    return withId;
  }

  @override
  Future<HealthGoal> updateGoal(int id, HealthGoal goal) async {
    final idx = _goals.indexWhere((g) => g.id == id);
    final updated = HealthGoal(
      id: id,
      goalType: goal.goalType,
      targetValue: goal.targetValue,
      unit: goal.unit,
      description: goal.description,
      isActive: goal.isActive,
    );
    if (idx != -1) _goals[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteGoal(int id) async => _goals.removeWhere((g) => g.id == id);

  // ── Summaries & dashboard ───────────────────────────────────────────────────
  @override
  Future<HealthSummary?> fetchLatestSummary() async => null;

  @override
  Future<HealthDashboard> fetchDashboard() async => HealthDashboard(
        periodDays: 7,
        symptomTotal: _symptoms.length,
        activeGoals: _goals.where((g) => g.isActive).toList(),
        recentSymptoms: _symptoms.take(3).toList(),
        vitalStats: const {'avg_heart_rate': 68, 'latest_weight': null},
      );
}
