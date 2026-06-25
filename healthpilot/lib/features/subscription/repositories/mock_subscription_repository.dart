import 'package:healthpilot/core/repositories/i_subscription_repository.dart';
import 'package:healthpilot/features/subscription/subscription_models.dart';

const _kPremiumPlan = SubscriptionPlan(
  id: 'premium',
  name: 'Premium Version',
  priceMonthly: 25.99,
  features: [
    'Personalized treatment & recommendation',
    'Fitness trackers Integration',
    'Health coaching',
  ],
  isPremium: true,
);

const _kFreePlan = SubscriptionPlan(
  id: 'free',
  name: 'Free Version',
  priceMonthly: 0.0,
  features: [
    'Access to chatbot',
    'Track Health and activity',
    'Symptom Tracker',
    'Personalized recommendation',
  ],
  isPremium: false,
);

class MockSubscriptionRepository implements ISubscriptionRepository {
  SubscriptionStatus _status =
      const SubscriptionStatus(planId: 'free', isActive: false);

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async =>
      const [_kPremiumPlan, _kFreePlan];

  @override
  Future<SubscriptionStatus> fetchStatus() async => _status;

  @override
  Future<SubscriptionStatus> subscribe(String planId) async {
    _status = SubscriptionStatus(
      planId: planId,
      isActive: true,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
    return _status;
  }

  @override
  Future<void> cancelSubscription() async {
    _status = const SubscriptionStatus(planId: 'free', isActive: false);
  }

  final List<Payment> _payments = [];
  int _nextPaymentId = 1;

  @override
  Future<Payment> createPayment({
    required double amount,
    required String paymentMethod,
  }) async {
    final payment = Payment(
      id: _nextPaymentId++,
      amount: amount,
      currency: 'USD',
      paymentMethod: paymentMethod,
      status: 'pending',
      createdAt: DateTime(2026, 6, 21),
    );
    _payments.insert(0, payment);
    return payment;
  }

  @override
  Future<Payment> confirmPayment(int paymentId) async {
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    final base = idx == -1
        ? Payment(
            id: paymentId,
            amount: 0,
            currency: 'USD',
            paymentMethod: '',
            status: 'pending')
        : _payments[idx];
    final confirmed = Payment(
      id: base.id,
      amount: base.amount,
      currency: base.currency,
      paymentMethod: base.paymentMethod,
      status: 'succeeded',
      membershipDays: 30,
      createdAt: base.createdAt,
    );
    if (idx != -1) _payments[idx] = confirmed;
    return confirmed;
  }

  @override
  Future<List<Payment>> fetchPaymentHistory() async => List.of(_payments);
}
