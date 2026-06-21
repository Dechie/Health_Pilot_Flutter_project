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

  // Vitals — `/health/vitals/`
  Future<List<VitalLog>> fetchVitals();
  Future<VitalLog> addVital(VitalLog vital);

  // Goals — `/health/goals/`
  Future<List<HealthGoal>> fetchGoals();
  Future<HealthGoal> addGoal(HealthGoal goal);
  Future<HealthGoal> updateGoal(int id, HealthGoal goal);
  Future<void> deleteGoal(int id);

  // AI summaries — `/health/summaries/`
  Future<HealthSummary?> fetchLatestSummary();

  // Aggregate overview — `/health/dashboard/`
  Future<HealthDashboard> fetchDashboard();
}
