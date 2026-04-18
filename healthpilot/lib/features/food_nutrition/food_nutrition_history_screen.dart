import 'package:flutter/material.dart';

import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/theme/app_theme.dart';

/// Log of tracked meals with a vertical timeline (Figma-style history).
class FoodNutritionHistoryScreen extends StatelessWidget {
  const FoodNutritionHistoryScreen({super.key});

  static const _dayStamp = '11:30 AM, May 13, 2023';

  static const _meals = <(String, String)>[
    ('Breakfast', '350 kcal'),
    ('Lunch', '520 kcal'),
    ('Dinner', '480 kcal'),
  ];

  @override
  Widget build(BuildContext context) {
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
                      'Food and Nutrition Tracking History',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                _dayStamp,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _meals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final (name, kcal) = _meals[index];
                  final isLast = index == _meals.length - 1;
                  return _TimelineMealRow(
                    mealName: name,
                    calories: kcal,
                    showLineBelow: !isLast,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineMealRow extends StatelessWidget {
  const _TimelineMealRow({
    required this.mealName,
    required this.calories,
    required this.showLineBelow,
  });

  final String mealName;
  final String calories;
  final bool showLineBelow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const dotSize = 10.0;
    const lineWidth = 2.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (showLineBelow)
                  Expanded(
                    child: Container(
                      width: lineWidth,
                      color: scheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      mealName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    calories,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
