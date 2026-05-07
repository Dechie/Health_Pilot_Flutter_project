import 'package:healthpilot/features/subscription/subscription_models.dart';

abstract class ISubscriptionRepository {
  Future<List<SubscriptionPlan>> fetchPlans();
  Future<SubscriptionStatus> fetchStatus();
  Future<SubscriptionStatus> subscribe(String planId);
  Future<void> cancelSubscription();
}
