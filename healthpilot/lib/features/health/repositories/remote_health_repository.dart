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

  @override
  Future<List<HealthSymptom>> fetchSymptoms() async {
    final data = await _client.get('${ApiConstants.healthBase}/symptoms/');
    // Backend returns paginated envelope: {count, next, previous, results: [...]}
    final results = (data as Map<String, dynamic>)['results'] as List;
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
  Future<void> clearSymptoms() async =>
      _client.delete('${ApiConstants.healthBase}/symptoms/');
}
