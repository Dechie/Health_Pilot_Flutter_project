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
}
