import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_subscription_repository.dart';
import 'package:healthpilot/features/subscription/subscription_models.dart';

enum SubscriptionLoadStatus { idle, loading, loaded, error }

class SubscriptionProvider extends ChangeNotifier {
  final ISubscriptionRepository _repo;

  List<SubscriptionPlan> _plans = [];
  SubscriptionStatus? _status;
  SubscriptionLoadStatus _loadStatus = SubscriptionLoadStatus.idle;
  String? _selectedPlanId;
  bool _loadStarted = false;

  List<SubscriptionPlan> get plans => List.unmodifiable(_plans);
  SubscriptionStatus? get status => _status;
  SubscriptionLoadStatus get loadStatus => _loadStatus;
  bool get isPremium => _status?.isActive ?? false;

  SubscriptionPlan? get premiumPlan {
    for (final p in _plans) {
      if (p.isPremium) return p;
    }
    return null;
  }

  SubscriptionProvider(this._repo);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    _loadStatus = SubscriptionLoadStatus.loading;
    notifyListeners();
    try {
      _plans = await _repo.fetchPlans();
      _status = await _repo.fetchStatus();
      _loadStatus = SubscriptionLoadStatus.loaded;
    } catch (_) {
      _loadStatus = SubscriptionLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  void selectPlan(String planId) {
    _selectedPlanId = planId;
  }

  Future<void> confirmSubscription() async {
    if (_selectedPlanId == null) return;
    final updated = await _repo.subscribe(_selectedPlanId!);
    _status = updated;
    notifyListeners();
  }

  Future<void> cancelSubscription() async {
    await _repo.cancelSubscription();
    _status = const SubscriptionStatus(planId: 'free', isActive: false);
    notifyListeners();
  }
}
