import 'package:flutter/material.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_subject.dart';
import 'package:healthpilot/features/health_assessment/summary_screen.dart';
import 'package:healthpilot/theme/app_theme.dart';

enum BloodType { a, b, ab, o }

class HealthAssessmentFlowScreen extends StatefulWidget {
  const HealthAssessmentFlowScreen({super.key});

  @override
  State<HealthAssessmentFlowScreen> createState() =>
      _HealthAssessmentFlowScreenState();
}

class _HealthAssessmentFlowScreenState extends State<HealthAssessmentFlowScreen> {
  final _pageController = PageController();

  int _page = 0;
  static const int _otherSymptomsPageIndex = 5;
  static const int _addMoreSymptomsPageIndex = 6;
  static const int _trendPageIndex = 7;
  HealthAssessmentSubject? _subject;
  BloodType? _bloodType;
  final _allergiesController = TextEditingController();

  final _symptomController = TextEditingController(text: 'Cough');
  final Set<String> _selectedSymptoms = {'Cough'};

  String? _symptomDuration; // Less than a week | More than a week | More than a month
  bool? _hasOtherSymptoms; // Yes/No
  String? _symptomsTrend; // worse/better/no_change

  @override
  void dispose() {
    _pageController.dispose();
    _allergiesController.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_page == _otherSymptomsPageIndex && _hasOtherSymptoms == false) {
      _pageController.animateToPage(
        _trendPageIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }

    if (_page < _trendPageIndex) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SummaryScreen(
          subject: _subject,
          bloodType: _bloodType,
          allergies: _allergiesController.text.trim(),
          symptoms: _selectedSymptoms.toList()..sort(),
          symptomDuration: _symptomDuration,
          hasOtherSymptoms: _hasOtherSymptoms,
          symptomsTrend: _symptomsTrend,
        ),
      ),
    );
  }

  void _goBack() {
    if (_page == 0) return;
    if (_page == _trendPageIndex && _hasOtherSymptoms == false) {
      _pageController.animateToPage(
        _otherSymptomsPageIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }
    _pageController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'Health Assessment',
              onBack: _page == 0 ? null : _goBack,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) => setState(() => _page = idx),
                children: [
                  _WhoForPage(
                    value: _subject,
                    onChanged: (v) => setState(() => _subject = v),
                  ),
                  _BloodTypePage(
                    value: _bloodType,
                    onChanged: (v) => setState(() => _bloodType = v),
                  ),
                  _AllergiesPage(controller: _allergiesController),
                  _SymptomsPage(
                    title: 'Add your symptoms',
                    controller: _symptomController,
                    selected: _selectedSymptoms,
                    onToggle: (s) {
                      setState(() {
                        if (_selectedSymptoms.contains(s)) {
                          _selectedSymptoms.remove(s);
                        } else {
                          _selectedSymptoms.add(s);
                        }
                      });
                    },
                  ),
                  _DurationPage(
                    value: _symptomDuration,
                    onChanged: (v) => setState(() => _symptomDuration = v),
                  ),
                  _OtherSymptomsPage(
                    value: _hasOtherSymptoms,
                    onChanged: (v) => setState(() => _hasOtherSymptoms = v),
                  ),
                  _SymptomsPage(
                    title: 'Add other symptoms',
                    controller: _symptomController,
                    selected: _selectedSymptoms,
                    onToggle: (s) {
                      setState(() {
                        if (_selectedSymptoms.contains(s)) {
                          _selectedSymptoms.remove(s);
                        } else {
                          _selectedSymptoms.add(s);
                        }
                      });
                    },
                  ),
                  _TrendPage(
                    value: _symptomsTrend,
                    onChanged: (v) => setState(() => _symptomsTrend = v),
                  ),
                ],
              ),
            ),
            const _BottomInfoLinks(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: _goNext,
                  child: Text(_page == _trendPageIndex ? 'Finish' : 'Next'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 12, 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              style: AppTheme.circleBackButtonStyle(context),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.165,
                  ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _WhoForPage extends StatelessWidget {
  const _WhoForPage({required this.value, required this.onChanged});

  final HealthAssessmentSubject? value;
  final ValueChanged<HealthAssessmentSubject> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 26),
          Text('Who is the assessment for?',
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: -0.165,
                color: c.onSurface,
              )),
          const SizedBox(height: 18),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OutlinedChoice(
                    label: 'Myself',
                    selected: value == HealthAssessmentSubject.myself,
                    onTap: () => onChanged(HealthAssessmentSubject.myself),
                  ),
                  const SizedBox(height: 12),
                  _OutlinedChoice(
                    label: 'Someone else',
                    selected: value == HealthAssessmentSubject.someoneElse,
                    onTap: () => onChanged(HealthAssessmentSubject.someoneElse),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BloodTypePage extends StatelessWidget {
  const _BloodTypePage({required this.value, required this.onChanged});

  final BloodType? value;
  final ValueChanged<BloodType> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    Widget option(String label, BloodType v) {
      return _OutlinedChoice(
        label: label,
        selected: value == v,
        onTap: () => onChanged(v),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 26),
          Text(
            'What is their blood type?',
            style: t.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: c.onSurface,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  option('Type A', BloodType.a),
                  const SizedBox(height: 10),
                  option('Type B', BloodType.b),
                  const SizedBox(height: 10),
                  option('Type AB', BloodType.ab),
                  const SizedBox(height: 10),
                  option('Type O', BloodType.o),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergiesPage extends StatelessWidget {
  const _AllergiesPage({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 26),
          Text(
            'Add any known allergies',
            style: t.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Type here...',
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomsPage extends StatelessWidget {
  const _SymptomsPage({
    required this.title,
    required this.controller,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final TextEditingController controller;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    final suggestions = const [
      ('Dry Cough', 'Dry cough with no mucus'),
      ('Dry Cough', 'Dry cough after running'),
      ('Dry Cough', 'Very dry cough with sore throat'),
      ('Headache', 'Persistent headache'),
      ('Fever', 'High temperature'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 26),
          Text(title,
              style: t.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w400)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Search symptom',
              filled: true,
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          if (selected.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selected
                  .map((s) => InputChip(
                        label: Text(s),
                        selected: true,
                        onDeleted: () => onToggle(s),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final (title, subtitle) = suggestions[idx];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: c.outline),
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: ListTile(
                    title: Text(title, style: t.bodyLarge?.copyWith(fontSize: 13)),
                    subtitle: Text(subtitle, style: t.bodySmall?.copyWith(fontSize: 11)),
                    trailing: IconButton(
                      onPressed: () => onToggle(title),
                      icon: Icon(
                        selected.contains(title) ? Icons.check_circle : Icons.add_circle_outline,
                        color: c.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationPage extends StatelessWidget {
  const _DurationPage({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 26),
          Text('How long have you had this symptom?',
              style: t.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w400)),
          const SizedBox(height: 18),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OutlinedChoice(
                    label: 'Less than a week',
                    selected: value == 'Less than a week',
                    onTap: () => onChanged('Less than a week'),
                  ),
                  const SizedBox(height: 10),
                  _OutlinedChoice(
                    label: 'More than a week',
                    selected: value == 'More than a week',
                    onTap: () => onChanged('More than a week'),
                  ),
                  const SizedBox(height: 10),
                  _OutlinedChoice(
                    label: 'More than a month',
                    selected: value == 'More than a month',
                    onTap: () => onChanged('More than a month'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherSymptomsPage extends StatelessWidget {
  const _OtherSymptomsPage({required this.value, required this.onChanged});

  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 26),
          Text('Do you have any other symptoms?',
              style: t.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w400)),
          const SizedBox(height: 18),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OutlinedChoice(
                    label: 'No, I don’t',
                    selected: value == false,
                    onTap: () => onChanged(false),
                  ),
                  const SizedBox(height: 10),
                  _OutlinedChoice(
                    label: 'Yes, I do',
                    selected: value == true,
                    onTap: () => onChanged(true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPage extends StatelessWidget {
  const _TrendPage({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 26),
          Text(
            'Okay, final question. How are your symptoms changing overtime?',
            style: t.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 18),
          Center(
            child: Column(
              children: [
                _OutlinedChoice(
                  label: 'They’re getting worse',
                  selected: value == 'worse',
                  onTap: () => onChanged('worse'),
                ),
                const SizedBox(height: 10),
                _OutlinedChoice(
                  label: 'They’re getting better',
                  selected: value == 'better',
                  onTap: () => onChanged('better'),
                ),
                const SizedBox(height: 10),
                _OutlinedChoice(
                  label: 'There is no change',
                  selected: value == 'no_change',
                  onTap: () => onChanged('no_change'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedChoice extends StatelessWidget {
  const _OutlinedChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return SizedBox(
      width: 180,
      height: 36,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: selected ? c.primary : c.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          foregroundColor: c.onSurface,
          backgroundColor: selected ? c.primaryContainer : null,
          textStyle: t.bodyMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

class _BottomInfoLinks extends StatelessWidget {
  const _BottomInfoLinks();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    Widget row(String label) {
      return InkWell(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) {
              final size = MediaQuery.of(context).size;
              return SizedBox(
                width: double.infinity,
                height: size.height * 0.58,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: c.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: t.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: c.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row('Don’t understand? Here is a description'),
            row('Why am I being asked this'),
          ],
        ),
      ),
    );
  }
}

