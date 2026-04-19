import 'package:flutter/material.dart';
import 'package:healthpilot/theme/app_theme.dart';

enum AssessmentSeverity { urgent, mild }

class AssessmentDetailScreen extends StatelessWidget {
  const AssessmentDetailScreen({
    super.key,
    required this.disease,
    required this.severity,
  });

  final String disease;
  final AssessmentSeverity severity;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    final buttonColor = severity == AssessmentSeverity.urgent
        ? Colors.red
        : c.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Detail'),
        leading: IconButton(
          style: AppTheme.circleBackButtonStyle(context),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Possible disease:', style: t.bodyMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(disease, style: t.titleSmall),
                  const SizedBox(width: 8),
                  Icon(Icons.info_outline,
                      size: 16,
                      color: severity == AssessmentSeverity.urgent
                          ? Colors.red
                          : c.primary),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.medical_information, size: 84),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You might need to seek medical attention soon.\n'
                'Most people with similar symptoms require immediate medical attention.\n\n'
                '2 out of 10 people who suffer from this disease end up losing their lives.\n\n'
                'You might need to seek medical attention soon.\n'
                'Most people with similar symptoms require immediate medical attention.',
                style: t.bodySmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: buttonColor),
                  onPressed: () {},
                  child: const Text('Show nearest hospitals'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

