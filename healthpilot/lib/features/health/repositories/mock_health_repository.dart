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
}
