import 'package:healthpilot/core/repositories/i_nutrition_repository.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';

/// In-memory nutrition data for FF_NUTRITION=false / tests.
class MockNutritionRepository implements INutritionRepository {
  final List<MealLog> _history = [
    MealLog(
      id: 1,
      mealType: 'breakfast',
      loggedAt: DateTime(2026, 5, 13, 8, 30),
      totalCalories: 350,
      entries: const [
        MealEntry(foodName: 'Oatmeal', quantityG: 80, calories: 350),
      ],
    ),
  ];

  NutritionGoals _goals = NutritionGoals.defaults;
  int _nextId = 2;

  @override
  Future<List<MealLog>> fetchHistory() async => List.of(_history);

  @override
  Future<MealLog> addMeal(MealLog log) async {
    final total = log.entries
        .fold<double>(0, (sum, e) => sum + (e.calories ?? 0));
    final created = MealLog(
      id: _nextId++,
      mealType: log.mealType,
      notes: log.notes,
      loggedAt: log.loggedAt ?? DateTime(2026, 6, 21),
      entries: log.entries,
      totalCalories: log.totalCalories == 0 ? total : log.totalCalories,
    );
    _history.insert(0, created);
    return created;
  }

  @override
  Future<NutritionGoals> fetchGoals() async => _goals;

  @override
  Future<NutritionGoals> saveGoals(NutritionGoals goals) async {
    _goals = goals;
    return _goals;
  }

  @override
  Future<NutritionSummary> fetchSummary() async {
    final calories =
        _history.fold<double>(0, (sum, m) => sum + m.totalCalories);
    return NutritionSummary(
      date: '2026-06-21',
      totals: NutritionTotals(calories: calories),
      goals: _goals,
    );
  }

  static const _catalog = [
    FoodItem(
        name: 'Oatmeal',
        caloriesPer100g: 389,
        proteinG: 17,
        carbsG: 66,
        fatG: 7),
    FoodItem(
        name: 'Banana',
        caloriesPer100g: 89,
        proteinG: 1,
        carbsG: 23,
        fatG: 0),
    FoodItem(
        name: 'Chicken breast',
        caloriesPer100g: 165,
        proteinG: 31,
        carbsG: 0,
        fatG: 4),
  ];

  @override
  Future<List<FoodItem>> searchFoods(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _catalog
        .where((f) => f.name.toLowerCase().contains(q))
        .toList();
  }
}
