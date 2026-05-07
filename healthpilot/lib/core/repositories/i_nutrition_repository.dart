import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';

abstract class INutritionRepository {
  Future<List<FoodDayLog>> fetchHistory();
  Future<FoodDayLog> addDayLog(FoodDayLog log);
  Future<FoodNutritionSettings> fetchSettings();
  Future<FoodNutritionSettings> saveSettings(FoodNutritionSettings settings);
}
