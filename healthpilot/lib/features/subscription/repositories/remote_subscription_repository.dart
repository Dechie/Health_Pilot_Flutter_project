import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_subscription_repository.dart';
import 'package:healthpilot/features/subscription/subscription_models.dart';

class RemoteSubscriptionRepository implements ISubscriptionRepository {
  final ApiClient _api;
  RemoteSubscriptionRepository(this._api);

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async {
    final response =
        await _api.get('${ApiConstants.subscriptionsBase}/plans/');
    return (response.data['data'] as List<dynamic>)
        .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SubscriptionStatus> fetchStatus() async {
    final response =
        await _api.get('${ApiConstants.subscriptionsBase}/status/');
    return SubscriptionStatus.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<SubscriptionStatus> subscribe(String planId) async {
    final response = await _api.post(
      '${ApiConstants.subscriptionsBase}/subscribe/',
      data: {'plan_id': planId},
    );
    return SubscriptionStatus.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> cancelSubscription() async {
    await _api.delete('${ApiConstants.subscriptionsBase}/cancel/');
  }
}
