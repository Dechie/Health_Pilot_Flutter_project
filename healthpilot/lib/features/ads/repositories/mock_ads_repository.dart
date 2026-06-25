import 'package:healthpilot/core/repositories/i_ads_repository.dart';
import 'package:healthpilot/features/ads/ad_models.dart';

class MockAdsRepository implements IAdsRepository {
  @override
  Future<List<AdItem>> fetchAds() async => const [
        AdItem(id: 1, title: 'Place Ad one Here'),
        AdItem(id: 2, title: 'Place Ad two Here'),
        AdItem(id: 3, title: 'Place Ad three Here'),
      ];

  @override
  Future<void> recordClick(int id) async {}
}
