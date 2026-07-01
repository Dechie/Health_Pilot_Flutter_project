import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';

abstract class INutritionRepository {
  /// Logged meals, newest first — `GET /nutrition/meals/`.
  Future<List<MealLog>> fetchHistory();

  /// Log a new meal — `POST /nutrition/meals/`.
  Future<MealLog> addMeal(MealLog log);

  /// Daily macro targets — `GET /nutrition/goals/`.
  Future<NutritionGoals> fetchGoals();

  /// Update daily macro targets — `PATCH /nutrition/goals/`.
  Future<NutritionGoals> saveGoals(NutritionGoals goals);

  /// Today's totals vs goals — `GET /nutrition/summary/`.
  Future<NutritionSummary> fetchSummary();

  /// Search the food catalog — `GET /nutrition/search/?search=`.
  Future<List<FoodItem>> searchFoods(String query);
}
