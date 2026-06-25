import 'package:healthpilot/features/ads/ad_models.dart';

abstract class IAdsRepository {
  /// Active ads — `GET /ads/` (returns `[]` when none).
  Future<List<AdItem>> fetchAds();

  /// Record an ad click — `POST /ads/{id}/click/`.
  Future<void> recordClick(int id);
}
