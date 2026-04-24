import 'package:flutter/material.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_subject.dart';

class HealthAssessmentDetailsScreen extends StatelessWidget {
  const HealthAssessmentDetailsScreen({
    super.key,
    required this.subject,
  });

  final HealthAssessmentSubject subject;

  @override
  Widget build(BuildContext context) {
    final title = subject == HealthAssessmentSubject.myself
        ? 'Assessment for myself'
        : 'Assessment for someone else';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Next steps screen placeholder.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

