import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_nutrition_repository.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';

enum NutritionLoadStatus { idle, loading, loaded, error }

class NutritionProvider extends ChangeNotifier {
  final INutritionRepository _repo;

  List<FoodDayLog> _history = [];
  FoodNutritionSettings _settings = const FoodNutritionSettings(
    frequency: FoodReportFrequency.biWeekly,
    pushNotificationsEnabled: true,
    diets: {'Vegetarian', 'Vegan'},
  );
  NutritionLoadStatus _status = NutritionLoadStatus.idle;
  bool _loadStarted = false;
  bool _setupCompleted = false;

  List<FoodDayLog> get history => List.unmodifiable(_history);
  FoodNutritionSettings get settings => _settings;
  NutritionLoadStatus get status => _status;
  bool get setupCompleted => _setupCompleted;

  NutritionProvider(this._repo);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    _status = NutritionLoadStatus.loading;
    notifyListeners();
    try {
      _history = await _repo.fetchHistory();
      _settings = await _repo.fetchSettings();
      _setupCompleted = await FoodNutritionPrefs.isSetupDone();
      _status = NutritionLoadStatus.loaded;
    } catch (_) {
      _status = NutritionLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> addLog(FoodDayLog log) async {
    final added = await _repo.addDayLog(log);
    _history = [..._history, added];
    notifyListeners();
  }

  Future<void> updateSettings(FoodNutritionSettings s) async {
    _settings = await _repo.saveSettings(s);
    await FoodNutritionPrefs.markSetupDone();
    _setupCompleted = true;
    _history = await _repo.fetchHistory();
    notifyListeners();
  }
}
