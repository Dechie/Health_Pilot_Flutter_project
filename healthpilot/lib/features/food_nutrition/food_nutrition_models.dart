import 'package:flutter/foundation.dart';

/// Nutrition models mirror the live backend (`/api/v1/nutrition/...`):
///   • settings/goals → daily macro targets
///   • history        → meal logs, each with food entries
///   • summary        → today's totals vs goals
///
/// All decimal fields arrive as strings (DRF `DecimalField`, e.g. "80.00").

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// Daily macro targets — `GET/PATCH /nutrition/goals/`.
@immutable
class NutritionGoals {
  const NutritionGoals({
    required this.dailyCalories,
    required this.dailyProteinG,
    required this.dailyCarbsG,
    required this.dailyFatG,
  });

  final int dailyCalories;
  final int dailyProteinG;
  final int dailyCarbsG;
  final int dailyFatG;

  /// Backend defaults, used before the first fetch.
  static const NutritionGoals defaults = NutritionGoals(
    dailyCalories: 2000,
    dailyProteinG: 50,
    dailyCarbsG: 250,
    dailyFatG: 65,
  );

  NutritionGoals copyWith({
    int? dailyCalories,
    int? dailyProteinG,
    int? dailyCarbsG,
    int? dailyFatG,
  }) =>
      NutritionGoals(
        dailyCalories: dailyCalories ?? this.dailyCalories,
        dailyProteinG: dailyProteinG ?? this.dailyProteinG,
        dailyCarbsG: dailyCarbsG ?? this.dailyCarbsG,
        dailyFatG: dailyFatG ?? this.dailyFatG,
      );

  factory NutritionGoals.fromJson(Map<String, dynamic> json) => NutritionGoals(
        dailyCalories: _toInt(json['daily_calories']),
        dailyProteinG: _toInt(json['daily_protein_g']),
        dailyCarbsG: _toInt(json['daily_carbs_g']),
        dailyFatG: _toInt(json['daily_fat_g']),
      );

  Map<String, dynamic> toJson() => {
        'daily_calories': dailyCalories,
        'daily_protein_g': dailyProteinG,
        'daily_carbs_g': dailyCarbsG,
        'daily_fat_g': dailyFatG,
      };
}

/// One food item within a meal log.
@immutable
class MealEntry {
  const MealEntry({
    this.id,
    required this.foodName,
    required this.quantityG,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });

  final int? id;
  final String foodName;
  final double quantityG;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
        id: json['id'] as int?,
        foodName: json['food_name'] as String? ?? '',
        quantityG: _toDouble(json['quantity_g']) ?? 0,
        calories: _toDouble(json['calories']),
        proteinG: _toDouble(json['protein_g']),
        carbsG: _toDouble(json['carbs_g']),
        fatG: _toDouble(json['fat_g']),
      );

  /// Decimal fields are sent as strings to match the backend's DecimalField.
  Map<String, dynamic> toJson() => {
        'food_name': foodName,
        'quantity_g': quantityG.toString(),
        if (calories != null) 'calories': calories!.toString(),
        if (proteinG != null) 'protein_g': proteinG!.toString(),
        if (carbsG != null) 'carbs_g': carbsG!.toString(),
        if (fatG != null) 'fat_g': fatG!.toString(),
      };
}

/// Valid `meal_type` values (matches backend enum).
const List<String> kMealTypes = [
  'breakfast',
  'lunch',
  'dinner',
  'snack',
  'other',
];

String mealTypeLabel(String type) =>
    type.isEmpty ? 'Meal' : '${type[0].toUpperCase()}${type.substring(1)}';

/// A logged meal — `GET/POST /nutrition/meals/`.
@immutable
class MealLog {
  const MealLog({
    this.id,
    required this.mealType,
    this.notes,
    this.loggedAt,
    this.entries = const [],
    this.totalCalories = 0,
  });

  final int? id;
  final String mealType;
  final String? notes;
  final DateTime? loggedAt;
  final List<MealEntry> entries;
  final double totalCalories;

  factory MealLog.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    return MealLog(
      id: json['id'] as int?,
      mealType: json['meal_type'] as String? ?? 'other',
      notes: json['notes'] as String?,
      loggedAt: DateTime.tryParse(json['logged_at'] as String? ?? ''),
      entries: rawEntries is List
          ? rawEntries
              .map((e) => MealEntry.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
      totalCalories: _toDouble(json['total_calories']) ?? 0,
    );
  }

  /// Create payload — `logged_at` is omitted so the server stamps "now".
  Map<String, dynamic> toJson() => {
        'meal_type': mealType,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        'entries': entries.map((e) => e.toJson()).toList(),
      };
}

/// A food from the catalog — `GET /nutrition/search/?search=`.
/// Macros are per 100 g.
@immutable
class FoodItem {
  const FoodItem({
    this.id,
    required this.name,
    this.caloriesPer100g,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.fiberG,
  });

  final int? id;
  final String name;
  final double? caloriesPer100g;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? fiberG;

  /// Calories for [grams] of this food, if per-100g calories are known.
  double? caloriesFor(double grams) =>
      caloriesPer100g == null ? null : caloriesPer100g! * grams / 100;

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] as int?,
        name: json['name'] as String? ?? '',
        caloriesPer100g: _toDouble(json['calories_per_100g']),
        proteinG: _toDouble(json['protein_g']),
        carbsG: _toDouble(json['carbs_g']),
        fatG: _toDouble(json['fat_g']),
        fiberG: _toDouble(json['fiber_g']),
      );
}

/// Today's totals against goals — `GET /nutrition/summary/`.
@immutable
class NutritionTotals {
  const NutritionTotals({
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  factory NutritionTotals.fromJson(Map<String, dynamic> json) =>
      NutritionTotals(
        calories: _toDouble(json['calories']) ?? 0,
        proteinG: _toDouble(json['protein_g']) ?? 0,
        carbsG: _toDouble(json['carbs_g']) ?? 0,
        fatG: _toDouble(json['fat_g']) ?? 0,
      );
}

@immutable
class NutritionSummary {
  const NutritionSummary({
    required this.date,
    required this.totals,
    required this.goals,
  });

  final String date;
  final NutritionTotals totals;
  final NutritionGoals goals;

  factory NutritionSummary.fromJson(Map<String, dynamic> json) =>
      NutritionSummary(
        date: json['date'] as String? ?? '',
        totals: NutritionTotals.fromJson(
            Map<String, dynamic>.from(json['totals'] as Map? ?? const {})),
        goals: NutritionGoals.fromJson(
            Map<String, dynamic>.from(json['goals'] as Map? ?? const {})),
      );
}
