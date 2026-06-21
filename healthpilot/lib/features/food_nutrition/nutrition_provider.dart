import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_nutrition_repository.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';

enum NutritionLoadStatus { idle, loading, loaded, error }

class NutritionProvider extends ChangeNotifier {
  final INutritionRepository _repo;

  List<MealLog> _history = [];
  NutritionGoals _goals = NutritionGoals.defaults;
  NutritionSummary? _summary;
  NutritionLoadStatus _status = NutritionLoadStatus.idle;
  bool _loadStarted = false;

  List<MealLog> get history => List.unmodifiable(_history);
  NutritionGoals get goals => _goals;
  NutritionSummary? get summary => _summary;
  NutritionLoadStatus get status => _status;

  NutritionProvider(this._repo);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    _status = NutritionLoadStatus.loading;
    notifyListeners();
    try {
      _history = await _repo.fetchHistory();
      _goals = await _repo.fetchGoals();
      _summary = await _repo.fetchSummary();
      _status = NutritionLoadStatus.loaded;
    } catch (_) {
      _status = NutritionLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _loadStarted = false;
    await load();
  }

  Future<void> addMeal(MealLog log) async {
    final added = await _repo.addMeal(log);
    _history = [added, ..._history];
    // Totals changed — refresh the daily summary if available.
    try {
      _summary = await _repo.fetchSummary();
    } catch (_) {/* summary is best-effort */}
    notifyListeners();
  }

  /// Search the food catalog (transient — does not mutate provider state).
  Future<List<FoodItem>> searchFoods(String query) => _repo.searchFoods(query);

  Future<void> saveGoals(NutritionGoals goals) async {
    _goals = await _repo.saveGoals(goals);
    try {
      _summary = await _repo.fetchSummary();
    } catch (_) {/* best-effort */}
    notifyListeners();
  }
}
