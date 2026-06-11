import 'package:flutter/material.dart';
import 'package:healthpilot/core/network/api_error.dart';
import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/asset_paths.dart';
import 'package:healthpilot/features/health_assessment/assessment_history_stepper_screen.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_subject.dart';
import 'package:healthpilot/features/health_assessment/assessment_provider.dart';
import 'package:healthpilot/features/health_assessment/result_back_to_home_screen.dart';
import 'package:provider/provider.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({
    super.key,
    required this.subject,
    required this.bloodType,
    required this.allergies,
    required this.symptoms,
    required this.symptomDuration,
    required this.hasOtherSymptoms,
    required this.symptomsTrend,
  });

  final HealthAssessmentSubject? subject;
  final BloodType? bloodType;
  final String allergies;
  final List<String> symptoms;
  final String? symptomDuration;
  final bool? hasOtherSymptoms;
  final String? symptomsTrend;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _submitting = false;
  CompletedAssessmentEntry? _entry;

  AssessmentSummary get _summary => AssessmentSummary(
        subject: widget.subject,
        bloodType: widget.bloodType,
        allergies: widget.allergies,
        symptoms: widget.symptoms,
        symptomDuration: widget.symptomDuration,
        hasOtherSymptoms: widget.hasOtherSymptoms,
        symptomsTrend: widget.symptomsTrend,
      );

  Future<void> _onPrimaryPressed() async {
    if (_entry != null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const ResultBackToHomeScreen(),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final entry =
          await context.read<AssessmentProvider>().submit(_summary);
      if (!mounted) return;
      setState(() {
        _entry = entry;
        _submitting = false;
      });
      if (entry.result?.seekEmergencyCare == true) {
        await _showEmergencyDialog();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submit failed: $e')),
      );
    }
  }

  Future<void> _showEmergencyDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seek medical attention'),
        content: const Text(
          'Based on your symptoms, you should seek emergency care or contact '
          'a clinician as soon as possible. This app does not replace '
          'professional medical advice.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('I understand'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SafeSvgAsset(
                            AssetPaths.assessmentSummaryIllustration,
                            width: 220,
                            height: 220,
                          ),
                          const SizedBox(height: 20),
                          ..._buildResultContent(t),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: _submitting ? null : _onPrimaryPressed,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_entry != null ? 'Continue' : 'Finish'),
                ),
              ),
              if (_entry == null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AssessmentHistoryStepperScreen(
                                  summary: _summary,
                                ),
                              ),
                            );
                          },
                    child: const Text('Review this assessment'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResultContent(TextTheme t) {
    final entry = _entry;
    if (entry == null) {
      return [
        Text(
          'Ready to analyze',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Tap Finish to run your health assessment. We will share possible '
          'causes and guidance based on what you entered.',
          style: t.bodySmall,
          textAlign: TextAlign.center,
        ),
      ];
    }

    final result = entry.result;
    if (result != null && result.possibleCauses.isNotEmpty) {
      return [
        Text(
          result.seekEmergencyCare
              ? 'Urgent attention recommended'
              : 'Assessment results',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        if (result.generalAdvice != null) ...[
          const SizedBox(height: 10),
          Text(
            result.generalAdvice!,
            style: t.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Possible causes', style: t.titleSmall),
        ),
        const SizedBox(height: 8),
        for (final cause in result.possibleCauses)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              tileColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(cause.name, style: t.bodyMedium),
              subtitle: () {
                final details = [
                  if (cause.description != null) cause.description,
                  if (cause.likelihood != null)
                    'Likelihood: ${cause.likelihood}',
                  if (cause.urgency != null) 'Urgency: ${cause.urgency}',
                  if (cause.nextSteps != null) cause.nextSteps,
                ].whereType<String>().join('\n');
                if (details.isEmpty) return null;
                return Text(details, style: t.bodySmall);
              }(),
            ),
          ),
      ];
    }

    if (entry.isAiPendingOrFailed) {
      return [
        Text(
          'Assessment saved',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Your symptoms were recorded, but AI analysis is temporarily '
          'unavailable. You can find this entry in your assessment history '
          'and try again later.',
          style: t.bodySmall,
          textAlign: TextAlign.center,
        ),
      ];
    }

    return [
      Text(
        'Everything seems fine',
        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Text(
        'Your symptoms do not appear urgent based on what you shared. '
        'Keep an eye on how you feel, and consider talking to a clinician '
        'if things change.',
        style: t.bodySmall,
        textAlign: TextAlign.center,
      ),
    ];
  }
}
