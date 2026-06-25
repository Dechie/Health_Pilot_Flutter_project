import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_ads_repository.dart';
import 'package:healthpilot/features/ads/ad_models.dart';

class AdsProvider extends ChangeNotifier {
  final IAdsRepository _repo;

  List<AdItem> _ads = [];
  bool _loadStarted = false;

  List<AdItem> get ads => List.unmodifiable(_ads);

  AdsProvider(this._repo);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    try {
      _ads = await _repo.fetchAds();
    } catch (_) {
      _ads = [];
    }
    notifyListeners();
  }

  Future<void> recordClick(int id) async {
    try {
      await _repo.recordClick(id);
    } catch (_) {/* click tracking is best-effort */}
  }
}
