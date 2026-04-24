import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Report cadence for food & nutrition summaries (local prefs only).
enum FoodReportFrequency { daily, weekly, biWeekly, monthly }

String foodReportFrequencyToStorage(FoodReportFrequency f) {
  switch (f) {
    case FoodReportFrequency.daily:
      return 'daily';
    case FoodReportFrequency.weekly:
      return 'weekly';
    case FoodReportFrequency.biWeekly:
      return 'biWeekly';
    case FoodReportFrequency.monthly:
      return 'monthly';
  }
}

FoodReportFrequency parseFoodReportFrequency(String? raw) {
  switch (raw) {
    case 'daily':
      return FoodReportFrequency.daily;
    case 'weekly':
      return FoodReportFrequency.weekly;
    case 'monthly':
      return FoodReportFrequency.monthly;
    case 'biWeekly':
    default:
      return FoodReportFrequency.biWeekly;
  }
}

/// Ordered, deduplicated diet chip labels (single source of truth).
const List<String> kFoodNutritionDietChoices = [
  'Vegetarian',
  'Vegan',
  'Mediterranean',
  'Keto',
  'Halal',
  'Atkins',
];

/// One meal line on the history timeline.
class FoodMealEntry {
  const FoodMealEntry({required this.name, required this.calories});

  final String name;
  final String calories;

  Map<String, dynamic> toJson() => {'name': name, 'calories': calories};

  factory FoodMealEntry.fromJson(Map<String, dynamic> json) {
    return FoodMealEntry(
      name: json['name'] as String? ?? '',
      calories: json['calories'] as String? ?? '',
    );
  }
}

/// One day group in history (header + meals).
class FoodDayLog {
  const FoodDayLog({required this.dayStamp, required this.meals});

  final String dayStamp;
  final List<FoodMealEntry> meals;

  Map<String, dynamic> toJson() => {
        'day': dayStamp,
        'meals': meals.map((m) => m.toJson()).toList(),
      };

  factory FoodDayLog.fromJson(Map<String, dynamic> json) {
    final raw = json['meals'];
    final meals = raw is List
        ? raw
            .map((e) => FoodMealEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <FoodMealEntry>[];
    return FoodDayLog(
      dayStamp: json['day'] as String? ?? '',
      meals: meals,
    );
  }

  /// Demo shape matching design board; shown once after first successful setup save.
  static List<FoodDayLog> sampleFirstDay() {
    return const [
      FoodDayLog(
        dayStamp: '11:30 AM, May 13, 2023',
        meals: [
          FoodMealEntry(name: 'Breakfast', calories: '350 kcal'),
          FoodMealEntry(name: 'Lunch', calories: '520 kcal'),
          FoodMealEntry(name: 'Dinner', calories: '480 kcal'),
        ],
      ),
    ];
  }
}

/// Editable food & nutrition tracking preferences (no backend).
class FoodNutritionSettings {
  const FoodNutritionSettings({
    required this.frequency,
    required this.pushNotificationsEnabled,
    required this.diets,
  });

  final FoodReportFrequency frequency;
  final bool pushNotificationsEnabled;
  final Set<String> diets;

  FoodNutritionSettings copyWith({
    FoodReportFrequency? frequency,
    bool? pushNotificationsEnabled,
    Set<String>? diets,
  }) {
    return FoodNutritionSettings(
      frequency: frequency ?? this.frequency,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      diets: diets ?? this.diets,
    );
  }
}

/// Load/save nutrition UI state via [SharedPreferences].
class FoodNutritionPrefs {
  FoodNutritionPrefs._();

  static const _kFrequency = 'food_nutrition_frequency_v1';
  static const _kPush = 'food_nutrition_push_v1';
  static const _kDiets = 'food_nutrition_diets_v1';
  static const _kHistory = 'food_nutrition_history_v1';

  static Future<FoodNutritionSettings> loadSettings() async {
    final p = await SharedPreferences.getInstance();
    final freq = parseFoodReportFrequency(p.getString(_kFrequency));
    final push = p.getBool(_kPush) ?? true;
    final dietList = p.getStringList(_kDiets);
    final diets = dietList == null || dietList.isEmpty
        ? <String>{'Vegetarian', 'Vegan'}
        : dietList.toSet();
    return FoodNutritionSettings(
      frequency: freq,
      pushNotificationsEnabled: push,
      diets: diets,
    );
  }

  static Future<void> saveSettings(FoodNutritionSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kFrequency, foodReportFrequencyToStorage(s.frequency));
    await p.setBool(_kPush, s.pushNotificationsEnabled);
    await p.setStringList(_kDiets, s.diets.toList()..sort());
  }

  static Future<List<FoodDayLog>> loadHistory() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kHistory);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => FoodDayLog.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on Object {
      return [];
    }
  }

  static Future<void> saveHistory(List<FoodDayLog> days) async {
    final p = await SharedPreferences.getInstance();
    final encoded = jsonEncode(days.map((d) => d.toJson()).toList());
    await p.setString(_kHistory, encoded);
  }

  /// After first setup save, seed one sample day so timeline layout is visible until real logging exists.
  static Future<void> seedHistoryIfEmpty() async {
    final existing = await loadHistory();
    if (existing.isNotEmpty) {
      return;
    }
    await saveHistory(FoodDayLog.sampleFirstDay());
  }
}
