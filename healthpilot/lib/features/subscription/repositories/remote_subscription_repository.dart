import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_subscription_repository.dart';
import 'package:healthpilot/features/subscription/subscription_models.dart';

class RemoteSubscriptionRepository implements ISubscriptionRepository {
  final ApiClient _api;
  RemoteSubscriptionRepository(this._api);

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async {
    final data = await _api.get('${ApiConstants.subscriptionsBase}/plans/');
    return (data as List<dynamic>)
        .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SubscriptionStatus> fetchStatus() async {
    final data = await _api.get('${ApiConstants.subscriptionsBase}/status/');
    return SubscriptionStatus.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<SubscriptionStatus> subscribe(String planId) async {
    // Plan is a path segment (`/subscribe/{plan}/`), not a body field.
    final data = await _api.post(
      '${ApiConstants.subscriptionsBase}/subscribe/$planId/',
    );
    return SubscriptionStatus.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> cancelSubscription() async {
    await _api.post('${ApiConstants.subscriptionsBase}/cancel/');
  }

  @override
  Future<Payment> createPayment({
    required double amount,
    required String paymentMethod,
  }) async {
    final data = await _api.post(
      '${ApiConstants.subscriptionsBase}/payment/',
      data: {'amount': amount, 'payment_method': paymentMethod},
    );
    return Payment.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Payment> confirmPayment(int paymentId) async {
    final data = await _api.post(
      '${ApiConstants.subscriptionsBase}/payment/confirm/',
      data: {'payment_id': paymentId},
    );
    // Response is `{payment: {...}, membership: {...}}`; the payment is nested.
    final map = data as Map<String, dynamic>;
    final payment =
        map['payment'] is Map ? map['payment'] as Map<String, dynamic> : map;
    return Payment.fromJson(payment);
  }

  @override
  Future<List<Payment>> fetchPaymentHistory() async {
    final data =
        await _api.get('${ApiConstants.subscriptionsBase}/payment/history/');
    final list = data is Map ? (data['results'] as List? ?? const []) : data;
    return (list as List)
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
