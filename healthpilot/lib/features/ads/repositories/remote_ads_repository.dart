import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_ads_repository.dart';
import 'package:healthpilot/features/ads/ad_models.dart';

class RemoteAdsRepository implements IAdsRepository {
  final ApiClient _api;
  RemoteAdsRepository(this._api);

  @override
  Future<List<AdItem>> fetchAds() async {
    final data = await _api.get('${ApiConstants.adsBase}/');
    // Tolerate: null (no ads), a bare list, or a `{results}` envelope.
    final list = data is List
        ? data
        : (data is Map ? (data['results'] as List?) : null);
    if (list == null) return [];
    return list
        .map((e) => AdItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> recordClick(int id) async {
    await _api.post('${ApiConstants.adsBase}/$id/click/');
  }
}
