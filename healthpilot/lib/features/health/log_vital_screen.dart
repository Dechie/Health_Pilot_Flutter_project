import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:healthpilot/features/health/health_models.dart';
import 'package:healthpilot/features/health/health_provider.dart';
import 'package:healthpilot/theme/app_theme.dart';

/// Records a vital-signs reading — POSTs `/health/vitals/`.
class LogVitalScreen extends StatefulWidget {
  const LogVitalScreen({super.key});

  @override
  State<LogVitalScreen> createState() => _LogVitalScreenState();
}

class _LogVitalScreenState extends State<LogVitalScreen> {
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  final _heartRate = TextEditingController();
  final _temperature = TextEditingController();
  final _oxygen = TextEditingController();
  final _glucose = TextEditingController();
  final _weight = TextEditingController();
  final _steps = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _systolic, _diastolic, _heartRate, _temperature, _oxygen,
      _glucose, _weight, _steps, _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _i(TextEditingController c) => int.tryParse(c.text.trim());
  double? _d(TextEditingController c) => double.tryParse(c.text.trim());

  Future<void> _onSave() async {
    final vital = VitalLog(
      systolicBp: _i(_systolic),
      diastolicBp: _i(_diastolic),
      heartRate: _i(_heartRate),
      temperatureC: _d(_temperature),
      oxygenSaturation: _i(_oxygen),
      bloodGlucose: _d(_glucose),
      weightKg: _d(_weight),
      steps: _i(_steps),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (vital.toJson().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least one measurement.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<HealthProvider>().addVital(vital);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save reading. Try again.')),
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
                    child: Text('Log Vitals',
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
                    Text('All fields optional — fill in what you measured.',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _num(_systolic, 'Systolic', 'mmHg'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _num(_diastolic, 'Diastolic', 'mmHg'),
                        ),
                      ],
                    ),
                    _num(_heartRate, 'Heart rate', 'bpm'),
                    _num(_temperature, 'Temperature', '°C'),
                    _num(_oxygen, 'Oxygen saturation', '%'),
                    _num(_glucose, 'Blood glucose', 'mg/dL'),
                    _num(_weight, 'Weight', 'kg'),
                    _num(_steps, 'Steps', ''),
                    TextField(
                      controller: _notes,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
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
                          : const Text('Save reading'),
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

  Widget _num(TextEditingController c, String label, String unit) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            suffixText: unit.isEmpty ? null : unit,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
      );
}
