import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_health_repository.dart';
import 'package:healthpilot/features/health/health_models.dart';

class RemoteHealthRepository implements IHealthRepository {
  const RemoteHealthRepository(this._client);
  final ApiClient _client;

  // conditions/ endpoint does not exist on the backend — stubs return empty/throw.
  @override
  Future<List<HealthCondition>> fetchConditions() async => [];

  @override
  Future<HealthCondition> addCondition(HealthCondition condition) =>
      throw UnimplementedError('conditions endpoint not available');

  @override
  Future<void> deleteCondition(int id) =>
      throw UnimplementedError('conditions endpoint not available');

  @override
  Future<void> clearConditions() =>
      throw UnimplementedError('conditions endpoint not available');

  /// Fetches every page of a DRF-paginated endpoint, following `next` until
  /// it is null, returning the concatenated `results`.
  Future<List<dynamic>> _fetchAllPages(String path) async {
    final all = <dynamic>[];
    Map<String, dynamic>? query;
    final seen = <String>{};
    while (true) {
      final data = await _client.get(path, queryParameters: query);
      if (data is! Map) {
        if (data is List) all.addAll(data);
        break;
      }
      final results = data['results'];
      if (results is List) all.addAll(results);
      final next = data['next'];
      if (next is! String || next.isEmpty) break;
      final nextQuery = Uri.parse(next).queryParameters;
      final key = nextQuery.toString();
      if (nextQuery.isEmpty || !seen.add(key)) break;
      query = Map<String, dynamic>.from(nextQuery);
    }
    return all;
  }

  @override
  Future<List<HealthSymptom>> fetchSymptoms() async {
    // Backend returns paginated envelope: {count, next, previous, results}.
    final results = await _fetchAllPages('${ApiConstants.healthBase}/symptoms/');
    return results
        .map((e) => HealthSymptom.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<HealthSymptom> addSymptom(HealthSymptom symptom) async {
    final data = await _client.post(
      '${ApiConstants.healthBase}/symptoms/',
      data: symptom.toJson(),
    );
    return HealthSymptom.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSymptom(int id) async =>
      _client.delete('${ApiConstants.healthBase}/symptoms/$id/');

  @override
  Future<void> clearSymptoms() async {
    // Backend has no bulk DELETE for symptoms; UI clears local state only.
  }

  // ── Vitals ────────────────────────────────────────────────────────────────
  @override
  Future<List<VitalLog>> fetchVitals() async {
    final results = await _fetchAllPages('${ApiConstants.healthBase}/vitals/');
    return results
        .map((e) => VitalLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<VitalLog> fetchVital(int id) async {
    final data = await _client.get('${ApiConstants.healthBase}/vitals/$id/');
    return VitalLog.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<VitalLog> addVital(VitalLog vital) async {
    final data = await _client.post(
      '${ApiConstants.healthBase}/vitals/',
      data: vital.toJson(),
    );
    return VitalLog.fromJson(data as Map<String, dynamic>);
  }

  // ── Goals ─────────────────────────────────────────────────────────────────
  @override
  Future<List<HealthGoal>> fetchGoals() async {
    final results = await _fetchAllPages('${ApiConstants.healthBase}/goals/');
    return results
        .map((e) => HealthGoal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<HealthGoal> fetchGoal(int id) async {
    final data = await _client.get('${ApiConstants.healthBase}/goals/$id/');
    return HealthGoal.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<HealthGoal> addGoal(HealthGoal goal) async {
    final data = await _client.post(
      '${ApiConstants.healthBase}/goals/',
      data: goal.toJson(),
    );
    return HealthGoal.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<HealthGoal> updateGoal(int id, HealthGoal goal) async {
    final data = await _client.patch(
      '${ApiConstants.healthBase}/goals/$id/',
      data: goal.toJson(),
    );
    return HealthGoal.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteGoal(int id) async =>
      _client.delete('${ApiConstants.healthBase}/goals/$id/');

  // ── Summaries ───────────────────────────────────────────────────────────────
  @override
  Future<HealthSummary?> fetchLatestSummary() async {
    final data = await _client.get('${ApiConstants.healthBase}/summaries/latest/');
    // Empty body `{}` means "no summary available yet".
    return HealthSummary.fromJsonOrNull(data as Map<String, dynamic>);
  }

  @override
  Future<List<HealthSummary>> fetchSummaries() async {
    final results = await _fetchAllPages('${ApiConstants.healthBase}/summaries/');
    return results
        .map((e) => HealthSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Dashboard ───────────────────────────────────────────────────────────────
  @override
  Future<HealthDashboard> fetchDashboard() async {
    final data = await _client.get('${ApiConstants.healthBase}/dashboard/');
    return HealthDashboard.fromJson(data as Map<String, dynamic>);
  }
}
