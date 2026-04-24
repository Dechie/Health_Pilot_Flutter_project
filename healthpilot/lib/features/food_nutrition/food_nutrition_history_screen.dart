import 'package:flutter/material.dart';

import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_models.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_tracking_screen.dart';
import 'package:healthpilot/theme/app_theme.dart';

/// Log of tracked meals with a vertical timeline (Figma-style history).
class FoodNutritionHistoryScreen extends StatefulWidget {
  const FoodNutritionHistoryScreen({super.key});

  @override
  State<FoodNutritionHistoryScreen> createState() =>
      _FoodNutritionHistoryScreenState();
}

class _FoodNutritionHistoryScreenState extends State<FoodNutritionHistoryScreen> {
  late Future<List<FoodDayLog>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = FoodNutritionPrefs.loadHistory();
  }

  void _reload() {
    setState(() {
      _historyFuture = FoodNutritionPrefs.loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FoodDayLog>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: SafeArea(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final days = snapshot.data ?? [];
        if (days.isEmpty) {
          return _HistoryScaffold(
            body: _EmptyHistoryBody(onSetUp: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) => const FoodNutritionTrackingScreen(),
                ),
              );
              if (mounted) {
                _reload();
              }
            }),
          );
        }
        return _HistoryScaffold(
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              for (var d = 0; d < days.length; d++) ...[
                if (d > 0) const SizedBox(height: 20),
                Text(
                  days[d].dayStamp,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < days[d].meals.length; i++)
                  _TimelineMealRow(
                    mealName: days[d].meals[i].name,
                    calories: days[d].meals[i].calories,
                    showLineBelow: i < days[d].meals.length - 1,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HistoryScaffold extends StatelessWidget {
  const _HistoryScaffold({required this.body});

  final Widget body;

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
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistoryBody extends StatelessWidget {
  const _EmptyHistoryBody({required this.onSetUp});

  final VoidCallback onSetUp;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 56,
              color: scheme.primary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 20),
            Text(
              'No nutrition history yet',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'After you finish food and nutrition setup, a sample day may appear here. '
              'Full meal logging will connect to your account when the backend is ready.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                    height: 1.35,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onSetUp,
              child: const Text('Set up tracking'),
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
