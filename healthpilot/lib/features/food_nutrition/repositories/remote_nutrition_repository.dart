import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_nutrition_repository.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';

class RemoteNutritionRepository implements INutritionRepository {
  final ApiClient _api;
  RemoteNutritionRepository(this._api);

  /// Fetches every page of a DRF-paginated endpoint, following `next` until
  /// it is null, returning the concatenated `results`.
  Future<List<dynamic>> _fetchAllPages(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final all = <dynamic>[];
    final seen = <String>{};
    while (true) {
      final data = await _api.get(path, queryParameters: query);
      if (data is! Map) {
        if (data is List) all.addAll(data);
        break;
      }
      final results = data['results'];
      if (results is List) all.addAll(results);
      final next = data['next'];
      if (next is! String || next.isEmpty) break;
      final nextQuery = Uri.parse(next).queryParameters;
      final key = nextQuery.toString();
      if (nextQuery.isEmpty || !seen.add(key)) break;
      query = Map<String, dynamic>.from(nextQuery);
    }
    return all;
  }

  @override
  Future<List<MealLog>> fetchHistory() async {
    final items = await _fetchAllPages('${ApiConstants.nutritionBase}/meals/');
    return items
        .map((e) => MealLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MealLog> addMeal(MealLog log) async {
    final data = await _api.post(
      '${ApiConstants.nutritionBase}/meals/',
      data: log.toJson(),
    );
    return MealLog.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<NutritionGoals> fetchGoals() async {
    final data = await _api.get('${ApiConstants.nutritionBase}/goals/');
    return NutritionGoals.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<NutritionGoals> saveGoals(NutritionGoals goals) async {
    final data = await _api.patch(
      '${ApiConstants.nutritionBase}/goals/',
      data: goals.toJson(),
    );
    return NutritionGoals.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<NutritionSummary> fetchSummary() async {
    final data = await _api.get('${ApiConstants.nutritionBase}/summary/');
    return NutritionSummary.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<FoodItem>> searchFoods(String query) async {
    final items = await _fetchAllPages(
      '${ApiConstants.nutritionBase}/search/',
      query: {'search': query},
    );
    return items
        .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
