import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';
import 'package:healthpilot/features/food_nutrition/nutrition_provider.dart';
import 'package:healthpilot/theme/app_theme.dart';

/// Log a meal with one or more food entries — POSTs `/nutrition/history/`.
/// The food-name field autocompletes against `/nutrition/search/` and
/// prefills calories/macros from the selected catalog item.
class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  String _mealType = kMealTypes.first;
  final _notes = TextEditingController();
  final List<_EntryControllers> _entries = [_EntryControllers()];
  bool _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  void _addEntryRow() => setState(() => _entries.add(_EntryControllers()));

  void _removeEntryRow(int i) {
    if (_entries.length == 1) return;
    setState(() {
      _entries.removeAt(i).dispose();
    });
  }

  List<MealEntry> _buildEntries() {
    final out = <MealEntry>[];
    for (final e in _entries) {
      final name = e.food.text.trim();
      if (name.isEmpty) continue;
      final qty = double.tryParse(e.qty.text.trim()) ?? 0;
      final food = e.selected;
      out.add(MealEntry(
        foodName: name,
        quantityG: qty,
        calories: double.tryParse(e.cal.text.trim()) ?? food?.caloriesFor(qty),
        // Scale catalog macros (per 100 g) to the logged quantity.
        proteinG: food?.proteinG == null ? null : food!.proteinG! * qty / 100,
        carbsG: food?.carbsG == null ? null : food!.carbsG! * qty / 100,
        fatG: food?.fatG == null ? null : food!.fatG! * qty / 100,
      ));
    }
    return out;
  }

  Future<void> _onSave() async {
    final entries = _buildEntries();
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one food with a name.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<NutritionProvider>().addMeal(
            MealLog(
              mealType: _mealType,
              notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
              entries: entries,
            ),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save meal. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Text('Log a Meal',
                        style: titleStyle, textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _mealType,
                      decoration: const InputDecoration(
                        labelText: 'Meal type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final t in kMealTypes)
                          DropdownMenuItem(
                              value: t, child: Text(mealTypeLabel(t))),
                      ],
                      onChanged: (v) =>
                          setState(() => _mealType = v ?? _mealType),
                    ),
                    const SizedBox(height: 20),
                    Text('Foods',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    for (var i = 0; i < _entries.length; i++)
                      _EntryRow(
                        key: ObjectKey(_entries[i]),
                        controllers: _entries[i],
                        onRemove:
                            _entries.length == 1 ? null : () => _removeEntryRow(i),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addEntryRow,
                        icon: const Icon(Icons.add),
                        label: const Text('Add food'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notes,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _onSave,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save meal'),
                    ),
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

class _EntryControllers {
  final food = TextEditingController();
  final qty = TextEditingController();
  final cal = TextEditingController();

  /// Set when a catalog food is picked, so macros can be scaled on save.
  FoodItem? selected;

  void dispose() {
    food.dispose();
    qty.dispose();
    cal.dispose();
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({super.key, required this.controllers, this.onRemove});

  final _EntryControllers controllers;
  final VoidCallback? onRemove;

  void _recalcCalories() {
    final food = controllers.selected;
    final qty = double.tryParse(controllers.qty.text.trim());
    if (food != null && qty != null) {
      final cals = food.caloriesFor(qty);
      if (cals != null) controllers.cal.text = cals.round().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Autocomplete<FoodItem>(
            displayStringForOption: (f) => f.name,
            optionsBuilder: (value) async {
              final q = value.text.trim();
              // Keep the plain-text name in sync for save, even without a pick.
              controllers.food.text = value.text;
              controllers.selected = null;
              if (q.length < 2) return const Iterable<FoodItem>.empty();
              try {
                return await context.read<NutritionProvider>().searchFoods(q);
              } catch (_) {
                return const Iterable<FoodItem>.empty();
              }
            },
            onSelected: (food) {
              controllers.selected = food;
              controllers.food.text = food.name;
              if (controllers.qty.text.trim().isEmpty) {
                controllers.qty.text = '100';
              }
              _recalcCalories();
            },
            fieldViewBuilder:
                (context, textController, focusNode, onSubmitted) {
              // Seed the field from any text typed before this rebuild.
              if (textController.text.isEmpty &&
                  controllers.food.text.isNotEmpty) {
                textController.text = controllers.food.text;
              }
              return TextField(
                controller: textController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Food name',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  controllers.food.text = v;
                  controllers.selected = null;
                },
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controllers.qty,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _recalcCalories(),
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    suffixText: 'g',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controllers.cal,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    suffixText: 'kcal',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Remove',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
