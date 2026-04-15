import 'package:flutter/material.dart';
import 'package:healthpilot/features/health_assessment/assessment_history_stepper_screen.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_flow_screen.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_subject.dart';

class AssessmentSummary {
  AssessmentSummary({
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
}

class AssessmentHistoryScreen extends StatefulWidget {
  const AssessmentHistoryScreen({
    super.key,
    required this.latestSummary,
  });

  final AssessmentSummary latestSummary;

  @override
  State<AssessmentHistoryScreen> createState() => _AssessmentHistoryScreenState();
}

class _AssessmentHistoryScreenState extends State<AssessmentHistoryScreen> {
  static const int _collapsedCount = 4;
  bool _showAllAssessmentHistory = false;
  bool _showAllSymptomHistory = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    final items = List.generate(
      8,
      (i) => (
        'Schizophrenia',
        DateTime.now().subtract(Duration(days: i * 7)),
      ),
    );

    final assessmentItems = items.take(4).toList();
    final symptomItems = items.skip(4).toList();

    final visibleAssessmentCount = _showAllAssessmentHistory
        ? assessmentItems.length
        : (_collapsedCount < assessmentItems.length
            ? _collapsedCount
            : assessmentItems.length);
    final visibleSymptomCount = _showAllSymptomHistory
        ? symptomItems.length
        : (_collapsedCount < symptomItems.length
            ? _collapsedCount
            : symptomItems.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Assessment History')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Assessment History', style: t.titleSmall),
          const SizedBox(height: 8),
          for (var i = 0; i < visibleAssessmentCount; i++)
            _TimelineHistoryRow(
              title: assessmentItems[i].$1,
              trailing: _formatTrailing(assessmentItems[i].$2),
              showConnector: i != visibleAssessmentCount - 1,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AssessmentHistoryStepperScreen(
                      summary: widget.latestSummary,
                    ),
                  ),
                );
              },
            ),
          if (assessmentItems.length > _collapsedCount)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() {
                  _showAllAssessmentHistory = !_showAllAssessmentHistory;
                }),
                child: Text(_showAllAssessmentHistory ? 'Show less' : 'Show more'),
              ),
            ),
          const SizedBox(height: 12),
          Text('Symptom History', style: t.titleSmall),
          const SizedBox(height: 8),
          for (var i = 0; i < visibleSymptomCount; i++)
            _TimelineHistoryRow(
              title: symptomItems[i].$1,
              trailing: _formatTrailing(symptomItems[i].$2),
              showConnector: i != visibleSymptomCount - 1,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AssessmentHistoryStepperScreen(
                      summary: widget.latestSummary,
                    ),
                  ),
                );
              },
            ),
          if (symptomItems.length > _collapsedCount)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() {
                  _showAllSymptomHistory = !_showAllSymptomHistory;
                }),
                child: Text(_showAllSymptomHistory ? 'Show less' : 'Show more'),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add New Assessment', style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HealthAssessmentFlowScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.outline),
                  ),
                  child: Icon(Icons.add, color: c.primary, size: 18),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  String _formatTrailing(DateTime date) {
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$hh:$mm AM, ${_monthName(date.month)} ${date.day}, ${date.year}';
  }
}

class _TimelineHistoryRow extends StatelessWidget {
  const _TimelineHistoryRow({
    required this.title,
    required this.trailing,
    required this.showConnector,
    required this.onTap,
  });

  final String title;
  final String trailing;
  final bool showConnector;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    final indicatorColor = c.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 18,
              child: Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (showConnector)
                    Container(
                      width: 2,
                      height: 34,
                      decoration: BoxDecoration(
                        color: indicatorColor.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  title,
                  style: t.bodyLarge?.copyWith(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                trailing,
                style: t.bodySmall?.copyWith(
                  fontSize: 11,
                  color: c.onSurfaceVariant,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _monthName(int month) {
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return '';
  }
}

