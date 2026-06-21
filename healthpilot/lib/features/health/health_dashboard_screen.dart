import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:healthpilot/features/health/add_goal_screen.dart';
import 'package:healthpilot/features/health/health_models.dart';
import 'package:healthpilot/features/health/health_provider.dart';
import 'package:healthpilot/features/health/log_vital_screen.dart';
import 'package:healthpilot/theme/app_theme.dart';

/// Aggregate health overview — surfaces `/health/dashboard/`, `/vitals/`,
/// `/goals/` and the latest `/summaries/`.
class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HealthProvider>();
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
                    child: Text('Health Dashboard',
                        style: titleStyle, textAlign: TextAlign.center),
                  ),
                  IconButton(
                    onPressed: () => context.read<HealthProvider>().refresh(),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            Expanded(child: _body(context, provider)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, HealthProvider provider) {
    if (provider.status == HealthLoadStatus.loading ||
        provider.status == HealthLoadStatus.idle) {
      return const Center(child: CircularProgressIndicator());
    }

    final d = provider.dashboard;
    return RefreshIndicator(
      onRefresh: () => context.read<HealthProvider>().refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          if (provider.latestSummary != null)
            _SummaryCard(summary: provider.latestSummary!),
          _StatsCard(
            periodDays: d?.periodDays ?? 7,
            symptomTotal: d?.symptomTotal ?? provider.symptoms.length,
            avgSeverity: d?.avgSymptomSeverity,
            vitalStats: d?.vitalStats ?? const {},
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            title: 'Active goals',
            actionLabel: 'Add',
            onAction: () => _push(context, const AddGoalScreen()),
          ),
          if (provider.activeGoals.isEmpty)
            const _EmptyLine('No active goals yet.')
          else
            ...provider.activeGoals.map((g) => _GoalTile(goal: g)),
          const SizedBox(height: 20),
          _SectionHeader(
            title: 'Recent vitals',
            actionLabel: 'Log',
            onAction: () => _push(context, const LogVitalScreen()),
          ),
          if (provider.vitals.isEmpty)
            const _EmptyLine('No vitals logged yet.')
          else
            ...provider.vitals.take(5).map((v) => _VitalTile(vital: v)),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context)
        .push<void>(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
  final HealthSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: scheme.primaryContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Text('AI health summary',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(summary.summary,
                style: Theme.of(context).textTheme.bodyMedium),
            if (summary.date != null) ...[
              const SizedBox(height: 6),
              Text(summary.date!,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.periodDays,
    required this.symptomTotal,
    required this.avgSeverity,
    required this.vitalStats,
  });

  final int periodDays;
  final int symptomTotal;
  final double? avgSeverity;
  final Map<String, dynamic> vitalStats;

  String _stat(dynamic v) => v == null ? '—' : v.toString();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last $periodDays days',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Metric(label: 'Symptoms', value: '$symptomTotal'),
                _Metric(
                    label: 'Avg severity',
                    value: avgSeverity == null
                        ? '—'
                        : avgSeverity!.toStringAsFixed(1)),
                _Metric(
                    label: 'Avg HR',
                    value: _stat(vitalStats['avg_heart_rate'])),
                _Metric(
                    label: 'Avg BP',
                    value: (vitalStats['avg_systolic'] == null)
                        ? '—'
                        : '${vitalStats['avg_systolic']}/${_stat(vitalStats['avg_diastolic'])}'),
                _Metric(
                    label: 'Latest weight',
                    value: _stat(vitalStats['latest_weight'])),
                _Metric(
                    label: 'Avg steps',
                    value: _stat(vitalStats['avg_steps'])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                )),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        TextButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.goal});
  final HealthGoal goal;

  @override
  Widget build(BuildContext context) {
    final target =
        goal.targetValue == goal.targetValue.roundToDouble()
            ? goal.targetValue.toInt().toString()
            : goal.targetValue.toString();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: Text(healthGoalTypeLabel(goal.goalType)),
        subtitle: Text(
          [
            'Target: $target${goal.unit != null ? ' ${goal.unit}' : ''}',
            if (goal.description != null && goal.description!.isNotEmpty)
              goal.description!,
          ].join('  ·  '),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') {
              Navigator.of(context).push<void>(MaterialPageRoute<void>(
                  builder: (_) => AddGoalScreen(existing: goal)));
            } else if (v == 'delete' && goal.id != null) {
              context.read<HealthProvider>().deleteGoal(goal.id!);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  const _VitalTile({required this.vital});
  final VitalLog vital;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (vital.bpDisplay != null) 'BP ${vital.bpDisplay}',
      if (vital.heartRate != null) 'HR ${vital.heartRate}',
      if (vital.oxygenSaturation != null) 'O₂ ${vital.oxygenSaturation}%',
      if (vital.bloodGlucose != null) 'Glucose ${vital.bloodGlucose}',
      if (vital.temperatureC != null) '${vital.temperatureC}°C',
      if (vital.weightKg != null) '${vital.weightKg} kg',
      if (vital.steps != null) '${vital.steps} steps',
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.favorite_border),
        title: Text(parts.isEmpty ? 'Reading' : parts.join('  ·  ')),
        subtitle: vital.measuredAt == null
            ? null
            : Text(vital.measuredAt!.toLocal().toString().split('.').first),
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
