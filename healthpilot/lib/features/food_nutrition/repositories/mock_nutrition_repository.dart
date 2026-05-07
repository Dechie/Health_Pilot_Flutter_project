import 'package:healthpilot/core/repositories/i_nutrition_repository.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';

class MockNutritionRepository implements INutritionRepository {
  @override
  Future<List<FoodDayLog>> fetchHistory() async {
    final stored = await FoodNutritionPrefs.loadHistory();
    if (stored.isNotEmpty) return stored;
    // Seed sample day so timeline is visible on first run.
    final sample = FoodDayLog.sampleFirstDay();
    await FoodNutritionPrefs.saveHistory(sample);
    return sample;
  }

  @override
  Future<FoodDayLog> addDayLog(FoodDayLog log) async {
    final current = await FoodNutritionPrefs.loadHistory();
    await FoodNutritionPrefs.saveHistory([...current, log]);
    return log;
  }

  @override
  Future<FoodNutritionSettings> fetchSettings() =>
      FoodNutritionPrefs.loadSettings();

  @override
  Future<FoodNutritionSettings> saveSettings(
      FoodNutritionSettings settings) async {
    await FoodNutritionPrefs.saveSettings(settings);
    return settings;
  }
}
