import 'package:flutter/material.dart';
import 'package:healthpilot/features/health_assessment/assessment_history_stepper_screen.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_subject.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_flow_screen.dart';
import 'package:healthpilot/features/health_assessment/in_memory_assessment_history.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AssessmentHistoryScreen extends StatefulWidget {
  const AssessmentHistoryScreen({super.key});

  @override
  State<AssessmentHistoryScreen> createState() => _AssessmentHistoryScreenState();
}

class _AssessmentHistoryScreenState extends State<AssessmentHistoryScreen> {
  /// Field initializers (not [late] + [initState]) so hot reload / reused [State] never hits LateInitializationError.
  final ScrollController _assessmentScrollController = ScrollController();
  final ScrollController _symptomScrollController = ScrollController();

  static final _dateFmt = DateFormat('h:mm a, MMM d, y');

  @override
  void dispose() {
    _assessmentScrollController.dispose();
    _symptomScrollController.dispose();
    super.dispose();
  }

  static List<({CompletedAssessmentEntry entry, String symptom})> _symptomRows(
    List<CompletedAssessmentEntry> entries,
  ) {
    final rows = <({CompletedAssessmentEntry entry, String symptom})>[];
    for (final e in entries) {
      for (final s in e.summary.symptoms) {
        rows.add((entry: e, symptom: s));
      }
    }
    rows.sort((a, b) => b.entry.completedAt.compareTo(a.entry.completedAt));
    return rows;
  }

  static String _whoLabel(HealthAssessmentSubject? s) {
    return switch (s) {
      HealthAssessmentSubject.myself => 'Myself',
      HealthAssessmentSubject.someoneElse => 'Someone else',
      null => 'Unknown',
    };
  }

  static String _assessmentRowTitle(AssessmentSummary s) {
    final who = _whoLabel(s.subject);
    if (s.symptoms.isEmpty) return '$who · No symptoms listed';
    final parts = s.symptoms.take(3).toList();
    final sym = parts.join(', ');
    final suffix = s.symptoms.length > 3 ? '…' : '';
    return '$who · $sym$suffix';
  }

  /// Title + hint + bordered scroll pane with [Scrollbar] so each list reads as independently scrollable.
  Widget _historyHalf({
    required BuildContext context,
    required String heading,
    required ScrollController scrollController,
    required List<Widget> scrollChildren,
  }) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: t.titleSmall),
          const SizedBox(height: 2),
          Text(
            'Scroll this list',
            style: t.labelSmall?.copyWith(color: c.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: c.outline.withValues(alpha: 0.35),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  thickness: 5,
                  radius: const Radius.circular(3),
                  interactive: true,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    children: scrollChildren,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Assessment History')),
      body: SafeArea(
        child: Consumer<InMemoryAssessmentHistory>(
          builder: (context, store, _) {
            final t = Theme.of(context).textTheme;
            final assessmentEntries = store.entries;
            final symptomRows = _symptomRows(assessmentEntries);

            final assessmentScrollChildren = <Widget>[
              if (assessmentEntries.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    'No assessments yet. Use + below or start the flow from elsewhere.',
                    style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
                  ),
                )
              else
                for (var i = 0; i < assessmentEntries.length; i++)
                  _TimelineHistoryRow(
                    title: _assessmentRowTitle(assessmentEntries[i].summary),
                    trailing: _dateFmt
                        .format(assessmentEntries[i].completedAt.toLocal()),
                    showConnector: i != assessmentEntries.length - 1,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AssessmentHistoryStepperScreen(
                            summary: assessmentEntries[i].summary,
                          ),
                        ),
                      );
                    },
                  ),
            ];

            final symptomScrollChildren = <Widget>[
              if (symptomRows.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    assessmentEntries.isEmpty
                        ? 'Symptoms from completed assessments will appear here.'
                        : 'No symptoms were recorded on these assessments.',
                    style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
                  ),
                )
              else
                for (var i = 0; i < symptomRows.length; i++)
                  _TimelineHistoryRow(
                    title: symptomRows[i].symptom,
                    trailing: _dateFmt
                        .format(symptomRows[i].entry.completedAt.toLocal()),
                    showConnector: i != symptomRows.length - 1,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AssessmentHistoryStepperScreen(
                            summary: symptomRows[i].entry.summary,
                          ),
                        ),
                      );
                    },
                  ),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _historyHalf(
                    context: context,
                    heading: 'Assessment History',
                    scrollController: _assessmentScrollController,
                    scrollChildren: assessmentScrollChildren,
                  ),
                ),
                Expanded(
                  child: _historyHalf(
                    context: context,
                    heading: 'Symptom History',
                    scrollController: _symptomScrollController,
                    scrollChildren: symptomScrollChildren,
                  ),
                ),
                Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Add New Assessment',
                            style: t.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            final sessionKey = Object();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => HealthAssessmentFlowScreen(
                                  key: ValueKey(sessionKey),
                                ),
                              ),
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
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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
