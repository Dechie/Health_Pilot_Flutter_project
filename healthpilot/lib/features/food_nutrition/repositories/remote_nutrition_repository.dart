import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_nutrition_repository.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';

class RemoteNutritionRepository implements INutritionRepository {
  final ApiClient _api;
  RemoteNutritionRepository(this._api);

  @override
  Future<List<FoodDayLog>> fetchHistory() async {
    final data = await _api.get('${ApiConstants.nutritionBase}/history/');
    final raw = data is Map<String, dynamic> ? data['results'] : data;
    return (raw as List<dynamic>)
        .map((e) => FoodDayLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FoodDayLog> addDayLog(FoodDayLog log) async {
    final data = await _api.post(
      '${ApiConstants.nutritionBase}/history/',
      data: log.toJson(),
    );
    return FoodDayLog.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<FoodNutritionSettings> fetchSettings() async {
    final data = await _api.get('${ApiConstants.nutritionBase}/settings/');
    return FoodNutritionSettings.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<FoodNutritionSettings> saveSettings(
      FoodNutritionSettings settings) async {
    final data = await _api.patch(
      '${ApiConstants.nutritionBase}/settings/',
      data: settings.toJson(),
    );
    return FoodNutritionSettings.fromJson(data as Map<String, dynamic>);
  }
}
