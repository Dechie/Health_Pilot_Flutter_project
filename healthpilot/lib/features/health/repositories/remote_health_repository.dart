import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_health_repository.dart';
import 'package:healthpilot/features/health/health_models.dart';

class RemoteHealthRepository implements IHealthRepository {
  const RemoteHealthRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<HealthCondition>> fetchConditions() async {
    final data = await _client.get('${ApiConstants.healthBase}/conditions/');
    return (data as List)
        .map((e) => HealthCondition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<HealthCondition> addCondition(HealthCondition condition) async {
    final data = await _client.post(
      '${ApiConstants.healthBase}/conditions/',
      data: condition.toJson(),
    );
    return HealthCondition.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCondition(int id) async =>
      _client.delete('${ApiConstants.healthBase}/conditions/$id/');

  @override
  Future<void> clearConditions() async =>
      _client.delete('${ApiConstants.healthBase}/conditions/');

  @override
  Future<List<HealthSymptom>> fetchSymptoms() async {
    final data = await _client.get('${ApiConstants.healthBase}/symptoms/');
    return (data as List)
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
