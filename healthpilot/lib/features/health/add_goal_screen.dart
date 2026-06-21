import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:healthpilot/features/health/health_models.dart';
import 'package:healthpilot/features/health/health_provider.dart';
import 'package:healthpilot/theme/app_theme.dart';

/// Create or edit a health goal — POST/PATCH `/health/goals/`.
class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key, this.existing});

  /// When non-null, the screen edits this goal instead of creating one.
  final HealthGoal? existing;

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  late String _goalType;
  late final TextEditingController _target;
  late final TextEditingController _unit;
  late final TextEditingController _description;
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _goalType = g?.goalType ?? kHealthGoalTypes.first;
    _target = TextEditingController(
        text: g == null ? '' : _trim(g.targetValue));
    _unit = TextEditingController(text: g?.unit ?? '');
    _description = TextEditingController(text: g?.description ?? '');
    _isActive = g?.isActive ?? true;
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _target.dispose();
    _unit.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final target = double.tryParse(_target.text.trim());
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a numeric target value.')),
      );
      return;
    }
    final goal = HealthGoal(
      goalType: _goalType,
      targetValue: target,
      unit: _unit.text.trim().isEmpty ? null : _unit.text.trim(),
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      isActive: _isActive,
    );
    setState(() => _saving = true);
    try {
      final provider = context.read<HealthProvider>();
      final existing = widget.existing;
      if (existing?.id != null) {
        await provider.updateGoal(existing!.id!, goal);
      } else {
        await provider.addGoal(goal);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save goal. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final editing = widget.existing != null;
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
                    child: Text(editing ? 'Edit Goal' : 'New Goal',
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
                      initialValue: _goalType,
                      decoration: const InputDecoration(
                        labelText: 'Goal type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final t in kHealthGoalTypes)
                          DropdownMenuItem(
                              value: t, child: Text(healthGoalTypeLabel(t))),
                      ],
                      onChanged: (v) =>
                          setState(() => _goalType = v ?? _goalType),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _target,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Target value',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _unit,
                      decoration: const InputDecoration(
                        labelText: 'Unit (e.g. steps, kg, hours)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _description,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _saving ? null : _onSave,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(editing ? 'Save changes' : 'Create goal'),
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
