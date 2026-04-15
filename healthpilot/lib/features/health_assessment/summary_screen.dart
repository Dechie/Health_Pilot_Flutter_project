import 'package:flutter/material.dart';
import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/asset_paths.dart';
import 'package:healthpilot/features/health_assessment/assessment_history_screen.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_flow_screen.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_subject.dart';
import 'package:healthpilot/features/health_assessment/result_back_to_home_screen.dart';

class SummaryScreen extends StatelessWidget {
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SafeSvgAsset(
                          AssetPaths.assessmentSummaryIllustration,
                          width: 220,
                          height: 220,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Everything Seems Fine',
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your symptoms don’t appear urgent based on what you shared. '
                          'Keep an eye on how you feel, and consider talking to a clinician if things change.',
                          style: t.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const ResultBackToHomeScreen(),
                      ),
                    );
                  },
                  child: const Text('Finish'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AssessmentHistoryScreen(
                          latestSummary: AssessmentSummary(
                            subject: subject,
                            bloodType: bloodType,
                            allergies: allergies,
                            symptoms: symptoms,
                            symptomDuration: symptomDuration,
                            hasOtherSymptoms: hasOtherSymptoms,
                            symptomsTrend: symptomsTrend,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('View Assessment History'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

