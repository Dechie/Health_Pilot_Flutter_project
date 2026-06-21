import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';
import 'package:healthpilot/features/food_nutrition/nutrition_provider.dart';
import 'package:healthpilot/features/profile/language_translation.dart';
import 'package:healthpilot/theme/app_theme.dart';

/// Editor for daily macro targets — PATCHes `/nutrition/settings/`.
class FoodNutritionTrackingScreen extends StatefulWidget {
  const FoodNutritionTrackingScreen({super.key});

  @override
  State<FoodNutritionTrackingScreen> createState() =>
      _FoodNutritionTrackingScreenState();
}

class _FoodNutritionTrackingScreenState
    extends State<FoodNutritionTrackingScreen> {
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final g = context.read<NutritionProvider>().goals;
    _calories = TextEditingController(text: g.dailyCalories.toString());
    _protein = TextEditingController(text: g.dailyProteinG.toString());
    _carbs = TextEditingController(text: g.dailyCarbsG.toString());
    _fat = TextEditingController(text: g.dailyFatG.toString());
  }

  @override
  void dispose() {
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  int _val(TextEditingController c, int fallback) =>
      int.tryParse(c.text.trim()) ?? fallback;

  Future<void> _onSave() async {
    final current = context.read<NutritionProvider>().goals;
    setState(() => _saving = true);
    try {
      await context.read<NutritionProvider>().saveGoals(
            NutritionGoals(
              dailyCalories: _val(_calories, current.dailyCalories),
              dailyProteinG: _val(_protein, current.dailyProteinG),
              dailyCarbsG: _val(_carbs, current.dailyCarbsG),
              dailyFatG: _val(_fat, current.dailyFatG),
            ),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save goals. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
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
                      'Daily Nutrition Goals',
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Set your daily targets. These drive your nutrition summary.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    _GoalField(
                      controller: _calories,
                      label: 'Daily calories',
                      unit: 'kcal',
                    ),
                    _GoalField(
                      controller: _protein,
                      label: 'Protein',
                      unit: 'g',
                    ),
                    _GoalField(
                      controller: _carbs,
                      label: 'Carbohydrates',
                      unit: 'g',
                    ),
                    _GoalField(
                      controller: _fat,
                      label: 'Fat',
                      unit: 'g',
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _saving ? null : _onSave,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save goals'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalField extends StatelessWidget {
  const _GoalField({
    required this.controller,
    required this.label,
    required this.unit,
  });

  final TextEditingController controller;
  final String label;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
