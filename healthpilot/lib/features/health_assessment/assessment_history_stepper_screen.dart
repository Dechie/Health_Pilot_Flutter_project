import 'package:flutter/material.dart';
import 'package:healthpilot/features/health_assessment/assessment_detail_screen.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';

class AssessmentHistoryStepperScreen extends StatefulWidget {
  const AssessmentHistoryStepperScreen({
    super.key,
    required this.summary,
    this.result,
  });

  final AssessmentSummary summary;

  /// The completed AI result for this assessment, when available. Null for a
  /// freshly-built summary (no result yet) or a pending/failed assessment.
  final AssessmentAiResult? result;

  @override
  State<AssessmentHistoryStepperScreen> createState() =>
      _AssessmentHistoryStepperScreenState();
}

class _AssessmentHistoryStepperScreenState
    extends State<AssessmentHistoryStepperScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    final steps = <Step>[
      Step(
        title: const Text('Who is it for'),
        content: Text(s.subject?.name ?? 'Not provided'),
        isActive: _step >= 0,
      ),
      Step(
        title: const Text('Blood type'),
        content: Text(s.bloodType?.name.toUpperCase() ?? 'Skipped'),
        isActive: _step >= 1,
      ),
      Step(
        title: const Text('Allergies'),
        content: Text(s.allergies.isEmpty ? 'Skipped' : s.allergies),
        isActive: _step >= 2,
      ),
      Step(
        title: const Text('Symptoms'),
        content:
            Text(s.symptoms.isEmpty ? 'None selected' : s.symptoms.join(', ')),
        isActive: _step >= 3,
      ),
      Step(
        title: const Text('Duration'),
        content: Text(s.symptomDuration ?? 'Not provided'),
        isActive: _step >= 4,
      ),
      Step(
        title: const Text('Other symptoms'),
        content: Text(s.hasOtherSymptoms == null
            ? 'Not provided'
            : (s.hasOtherSymptoms! ? 'Yes' : 'No')),
        isActive: _step >= 5,
      ),
      Step(
        title: const Text('Trend'),
        content: Text(s.symptomsTrend ?? 'Not provided'),
        isActive: _step >= 6,
      ),
      Step(
        title: const Text('Result'),
        content: Align(
          alignment: Alignment.centerLeft,
          child: _buildResultContent(),
        ),
        isActive: _step >= 7,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Assessment History')),
      body: Stepper(
        currentStep: _step,
        steps: steps,
        onStepTapped: (i) => setState(() => _step = i),
        onStepContinue:
            _step < steps.length - 1 ? () => setState(() => _step++) : null,
        onStepCancel: _step > 0 ? () => setState(() => _step--) : null,
        controlsBuilder: (context, details) {
          return Row(
            children: [
              if (details.onStepContinue != null)
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: const Text('Next'),
                ),
              const SizedBox(width: 10),
              if (details.onStepCancel != null)
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultContent() {
    final result = widget.result;
    if (result == null || result.possibleCauses.isEmpty) {
      return Text(
        'AI result is not available for this assessment.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    // Top cause + urgency drive the detail view (no hardcoded diagnosis).
    final topCause = result.possibleCauses.first;
    final severity = result.seekEmergencyCare
        ? AssessmentSeverity.urgent
        : AssessmentSeverity.mild;
    return FilledButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AssessmentDetailScreen(
              disease: topCause.name,
              severity: severity,
            ),
          ),
        );
      },
      child: const Text('Open assessment detail'),
    );
  }
}
