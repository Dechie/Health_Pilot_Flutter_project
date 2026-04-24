import 'package:flutter/material.dart';

import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';
import 'package:healthpilot/theme/app_theme.dart';

/// Preferences for food and nutrition reports (Figma-style setup).
class FoodNutritionTrackingScreen extends StatefulWidget {
  const FoodNutritionTrackingScreen({super.key});

  @override
  State<FoodNutritionTrackingScreen> createState() =>
      _FoodNutritionTrackingScreenState();
}

class _FoodNutritionTrackingScreenState
    extends State<FoodNutritionTrackingScreen> {
  bool _prefsLoaded = false;
  FoodReportFrequency _frequency = FoodReportFrequency.biWeekly;
  bool _pushNotifications = true;
  final Set<String> _diets = {};

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final s = await FoodNutritionPrefs.loadSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _frequency = s.frequency;
      _pushNotifications = s.pushNotificationsEnabled;
      _diets
        ..clear()
        ..addAll(s.diets.where(kFoodNutritionDietChoices.contains));
      if (_diets.isEmpty) {
        _diets.addAll({'Vegetarian', 'Vegan'});
      }
      _prefsLoaded = true;
    });
  }

  Future<void> _onFinish() async {
    await FoodNutritionPrefs.saveSettings(
      FoodNutritionSettings(
        frequency: _frequency,
        pushNotificationsEnabled: _pushNotifications,
        diets: Set<String>.from(_diets),
      ),
    );
    await FoodNutritionPrefs.seedHistoryIfEmpty();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    if (!_prefsLoaded) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

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
                      'Food and Nutrition Tracking',
                      style: titleStyle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SafeSvgAsset(
                      translateIcon,
                      width: 24,
                      height: 24,
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
                      'How frequently do you want your report to be sent',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _frequencyTile(
                                FoodReportFrequency.daily,
                                'Daily',
                              ),
                            ),
                            Expanded(
                              child: _frequencyTile(
                                FoodReportFrequency.biWeekly,
                                'Bi-weekly',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _frequencyTile(
                                FoodReportFrequency.weekly,
                                'Weekly',
                              ),
                            ),
                            Expanded(
                              child: _frequencyTile(
                                FoodReportFrequency.monthly,
                                'Monthly',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enable push notifications',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'When on, we will remind you around meal times to eat regularly and keep a balanced diet. '
                                'Reminders follow your device notification settings; server-delivered push is not wired yet.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _pushNotifications,
                          onChanged: (v) =>
                              setState(() => _pushNotifications = v),
                          activeThumbColor: scheme.onPrimary,
                          activeTrackColor: scheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Select any diets you follow',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kFoodNutritionDietChoices.map((d) {
                        final selected = _diets.contains(d);
                        return FilterChip(
                          label: Text(d),
                          selected: selected,
                          onSelected: (on) {
                            setState(() {
                              if (on) {
                                _diets.add(d);
                              } else {
                                _diets.remove(d);
                              }
                            });
                          },
                          selectedColor:
                              scheme.primary.withValues(alpha: 0.35),
                          checkmarkColor: scheme.primary,
                          labelStyle:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: selected
                                        ? scheme.primary
                                        : scheme.onSurface,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                          side: BorderSide(color: scheme.outline),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _onFinish,
                      child: const Text('Finish'),
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

  Widget _frequencyTile(FoodReportFrequency value, String label) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _frequency == value;
    return InkWell(
      onTap: () => setState(() => _frequency = value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: scheme.primary,
              size: 22,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? scheme.primary : scheme.onSurface,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
