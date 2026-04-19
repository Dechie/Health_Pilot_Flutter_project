import 'package:flutter/material.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_details_screen.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_subject.dart';
import 'package:healthpilot/features/health_assessment/widgets/assessment_choice_button.dart';
import 'package:healthpilot/features/health_assessment/widgets/assessment_info_row.dart';
import 'package:healthpilot/theme/app_theme.dart';

class HealthAssessmentScreen extends StatelessWidget {
  const HealthAssessmentScreen({super.key});

  void _openWhySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why we ask',
                style: Theme.of(ctx).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'This helps tailor the assessment questions and results to the right person.',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDescriptionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What this assessment does',
                style: Theme.of(ctx).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'You’ll answer a few quick questions so we can provide guidance and next steps.',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToDetails(BuildContext context, HealthAssessmentSubject subject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthAssessmentDetailsScreen(subject: subject),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      style: AppTheme.circleBackButtonStyle(context),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Health Assessment',
                    style: t.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: c.onSurface,
                      letterSpacing: -0.165,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Who is the assessment for?',
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.165,
                  color: c.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  AssessmentChoiceButton(
                    label: 'Myself',
                    onPressed: () =>
                        _goToDetails(context, HealthAssessmentSubject.myself),
                  ),
                  const SizedBox(width: 10),
                  AssessmentChoiceButton(
                    label: 'Someone else',
                    onPressed: () => _goToDetails(
                      context,
                      HealthAssessmentSubject.someoneElse,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AssessmentInfoRow(
                label: 'Why am I being asked this',
                icon: Icons.help_outline,
                onTap: () => _openWhySheet(context),
              ),
              AssessmentInfoRow(
                label: 'Don’t understand? Here is a description',
                icon: Icons.info_outline,
                onTap: () => _openDescriptionSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

