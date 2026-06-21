import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/food_nutrition/add_meal_screen.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_tracking_screen.dart';
import 'package:healthpilot/features/food_nutrition/nutrition_provider.dart';
import 'package:healthpilot/features/profile/language_translation.dart';
import 'package:healthpilot/theme/app_theme.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _dayLabel(DateTime? d) {
  if (d == null) return 'Undated';
  final l = d.toLocal();
  return '${_months[l.month - 1]} ${l.day}, ${l.year}';
}

String _timeLabel(DateTime? d) {
  if (d == null) return '';
  final l = d.toLocal();
  final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final m = l.minute.toString().padLeft(2, '0');
  return '$h:$m ${l.hour < 12 ? 'AM' : 'PM'}';
}

/// Meal history with a daily-totals summary — reads `/nutrition/history/`
/// and `/nutrition/summary/`.
class FoodNutritionHistoryScreen extends StatelessWidget {
  const FoodNutritionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NutritionProvider>();

    if (provider.status == NutritionLoadStatus.idle ||
        provider.status == NutritionLoadStatus.loading) {
      return const _HistoryScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.status == NutritionLoadStatus.error) {
      return _HistoryScaffold(
        body: _ErrorBody(onRetry: () => context.read<NutritionProvider>().refresh()),
      );
    }

    final meals = provider.history;

    return _HistoryScaffold(
      onAddMeal: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const AddMealScreen()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
        children: [
          if (provider.summary != null)
            _SummaryCard(
              summary: provider.summary!,
              onEditGoals: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const FoodNutritionTrackingScreen(),
                ),
              ),
            ),
          const SizedBox(height: 20),
          if (meals.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'No meals logged yet. Tap + to log your first meal.',
                textAlign: TextAlign.center,
              ),
            )
          else
            ..._buildDayGroups(context, meals),
        ],
      ),
    );
  }

  List<Widget> _buildDayGroups(BuildContext context, List<MealLog> meals) {
    // Preserve incoming (newest-first) order while grouping by calendar day.
    final groups = <String, List<MealLog>>{};
    for (final m in meals) {
      groups.putIfAbsent(_dayLabel(m.loggedAt), () => []).add(m);
    }
    final widgets = <Widget>[];
    var first = true;
    groups.forEach((day, dayMeals) {
      if (!first) widgets.add(const SizedBox(height: 20));
      first = false;
      widgets.add(Text(
        day,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ));
      widgets.add(const SizedBox(height: 8));
      for (final m in dayMeals) {
        widgets.add(_MealCard(meal: m));
      }
    });
    return widgets;
  }
}

class _HistoryScaffold extends StatelessWidget {
  const _HistoryScaffold({required this.body, this.onAddMeal});

  final Widget body;
  final VoidCallback? onAddMeal;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: onAddMeal == null
          ? null
          : FloatingActionButton.extended(
              onPressed: onAddMeal,
              icon: const Icon(Icons.add),
              label: const Text('Log meal'),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: AppTheme.circleBackButtonStyle(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      'Food and Nutrition Tracking',
                      style: titleStyle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => openLanguageScreen(context),
                    icon: SafeSvgAsset(
                      translateIcon,
                      width: 24,
                      height: 24,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.onEditGoals});

  final NutritionSummary summary;
  final VoidCallback onEditGoals;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = summary.totals;
    final g = summary.goals;

    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text("Today's intake",
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                TextButton(
                  onPressed: onEditGoals,
                  child: const Text('Edit goals'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _MacroBar(
              label: 'Calories',
              value: t.calories,
              goal: g.dailyCalories.toDouble(),
              unit: 'kcal',
              color: scheme.primary,
            ),
            _MacroBar(
              label: 'Protein',
              value: t.proteinG,
              goal: g.dailyProteinG.toDouble(),
              unit: 'g',
              color: Colors.teal,
            ),
            _MacroBar(
              label: 'Carbs',
              value: t.carbsG,
              goal: g.dailyCarbsG.toDouble(),
              unit: 'g',
              color: Colors.orange,
            ),
            _MacroBar(
              label: 'Fat',
              value: t.fatG,
              goal: g.dailyFatG.toDouble(),
              unit: 'g',
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
  });

  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    final pct = goal <= 0 ? 0.0 : (value / goal).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text('${_fmt(value)} / ${_fmt(goal)} $unit',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final MealLog meal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mealTypeLabel(meal.mealType),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Text(
                  '${meal.totalCalories.toInt()} kcal',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            if (meal.loggedAt != null)
              Text(_timeLabel(meal.loggedAt),
                  style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            for (final e in meal.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${e.foodName}  ·  ${e.quantityG.toInt()} g',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (e.calories != null)
                      Text('${e.calories!.toInt()} kcal',
                          style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            if (meal.notes != null && meal.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(meal.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Couldn't load nutrition data."),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
