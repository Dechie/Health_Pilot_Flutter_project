import 'package:healthpilot/features/health/health_models.dart';

abstract class IHealthRepository {
  Future<List<HealthCondition>> fetchConditions();
  Future<HealthCondition> addCondition(HealthCondition condition);
  Future<void> deleteCondition(int id);
  Future<void> clearConditions();

  Future<List<HealthSymptom>> fetchSymptoms();
  Future<HealthSymptom> addSymptom(HealthSymptom symptom);
  Future<void> deleteSymptom(int id);
  Future<void> clearSymptoms();
}
