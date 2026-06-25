import 'package:healthpilot/features/subscription/subscription_models.dart';

abstract class ISubscriptionRepository {
  Future<List<SubscriptionPlan>> fetchPlans();
  Future<SubscriptionStatus> fetchStatus();
  Future<SubscriptionStatus> subscribe(String planId);
  Future<void> cancelSubscription();

  /// Start a payment — `POST /subscriptions/payment/`.
  Future<Payment> createPayment({
    required double amount,
    required String paymentMethod,
  });

  /// Confirm a payment — `POST /subscriptions/payment/confirm/`.
  Future<Payment> confirmPayment(int paymentId);

  /// Payment history — `GET /subscriptions/payment/history/`.
  Future<List<Payment>> fetchPaymentHistory();
}
