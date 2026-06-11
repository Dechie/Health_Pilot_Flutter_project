import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_assessment_repository.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';

class RemoteAssessmentRepository implements IAssessmentRepository {
  const RemoteAssessmentRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<CompletedAssessmentEntry>> fetchHistory() async {
    final data = await _client.get('${ApiConstants.assessmentsBase}/');
    final list = data is Map ? (data['results'] as List? ?? data['data'] as List?) : (data as List);
    if (list == null) return [];
    return list
        .map((e) =>
            CompletedAssessmentEntry.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CompletedAssessmentEntry> submitAssessment(
      AssessmentSummary summary) async {
    final data = await _client.post(
      '${ApiConstants.assessmentsBase}/',
      data: summary.toApiJson(),
    );
    return CompletedAssessmentEntry.fromApiJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteEntry(String id) async =>
      _client.delete('${ApiConstants.assessmentsBase}/$id/');
}
