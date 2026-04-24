import 'package:flutter/material.dart';
import 'package:healthpilot/features/tutorials/tutorial_detail_screen.dart';

/// Seed content for Branch G. Replace or load from backend/CMS when available.
class _TutorialSeed {
  const _TutorialSeed({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
}

const List<_TutorialSeed> _kTutorials = [
  _TutorialSeed(
    title: 'Welcome to Health Pilot',
    subtitle: 'What the app can do for you',
    body:
        'Health Pilot helps you track symptoms, run guided health assessments, '
        'and keep everyday wellness data in one place. Use the bottom tabs to '
        'move between Home, Health, Assessment, Chat, and your Profile.\n\n'
        'Tip: pull down or revisit Home later for new guides as we publish them.',
    icon: Icons.waving_hand_outlined,
  ),
  _TutorialSeed(
    title: 'Using the Health tab',
    subtitle: 'Trackers and shortcuts',
    body:
        'Open the Health tab to see statistics, symptom tracking, and shortcuts '
        'such as medications. Some tiles may require a subscription when that '
        'feature is enabled.\n\n'
        'This walkthrough is placeholder text until product copy is finalized.',
    icon: Icons.favorite_outline,
  ),
  _TutorialSeed(
    title: 'Running an assessment',
    subtitle: 'History-first flow',
    body:
        'From the Assessment tab you can review past runs and start a new guided '
        'assessment. Finish the last step to see a summary; you can return home '
        'from there.\n\n'
        'Exact steps may change as clinical content is updated.',
    icon: Icons.assignment_outlined,
  ),
  _TutorialSeed(
    title: 'Profile & settings',
    subtitle: 'Account and preferences',
    body:
        'Use the Profile tab to open Settings, update language, and access help. '
        'Language changes apply app-wide when supported by the platform.\n\n'
        'More tutorials will appear here as the product grows.',
    icon: Icons.person_outline,
  ),
];

/// Tutorials list (Branch G). Figma can refine layout and copy later.
class TutorialsEntryScreen extends StatelessWidget {
  const TutorialsEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorials'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _kTutorials.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _kTutorials[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Icon(item.icon),
              ),
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => TutorialDetailScreen(
                      title: item.title,
                      body: item.body,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
