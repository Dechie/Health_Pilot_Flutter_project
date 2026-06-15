import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/health_assessment/allergy_suggestion_catalog.dart';
import 'package:healthpilot/features/personal_info/initial_info_2.dart';
import 'package:healthpilot/features/personal_info/initial_info_4.dart';
import 'package:healthpilot/features/profile/profile_provider.dart';
import 'package:provider/provider.dart';

class InitialInfoThird extends StatefulWidget {
  const InitialInfoThird({super.key});

  @override
  State<InitialInfoThird> createState() => _InitialInfoThird();
}

class _InitialInfoThird extends State<InitialInfoThird> {
  List<String> selectedAllergies = [];
  String chronicConditionAnswer = '';
  String? selectedBloodType;
  bool _loading = false;

  static const _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  bool get _canFinish =>
      chronicConditionAnswer.isNotEmpty && selectedBloodType != null;

  @override
  void initState() {
    super.initState();
    if (FeatureFlags.auth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final auth = context.read<AuthState>();
        if (!auth.isOnboardingCompleted) auth.setOnboardingStep(3);
      });
    }
  }

  final searchController = TextEditingController();

  List<String> get _filteredAllergies =>
      AllergySuggestionCatalog.matching(searchController.text);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _clearAllergySearch() {
    searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;
    final iconMuted = cs.onSurface.withValues(alpha: 0.75);
    final filteredAllergies = _filteredAllergies;
    final hasSearchQuery = searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, size.height * 0.1),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 30,
            bottom: 10,
          ),
          child: Row(
            children: [
              Container(
                width: size.width * 0.1,
                height: size.width * 0.1,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(size.width * 0.05),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  color: cs.primary,
                  iconSize: size.width * 0.055,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(size.width * 0.05, 0, 0, 0),
                child: Text(
                  'One Last Step',
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PlusJakartaSans',
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                size.width * 0.04,
                size.height * 0.02,
                size.width * 0.04,
                24,
              ),
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildYesNoQuestion(
                      context,
                      question: 'Do you have any chronic conditions?',
                      groupValue: chronicConditionAnswer,
                      onChanged: (value) =>
                          setState(() => chronicConditionAnswer = value),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.05),
                      child: Text(
                        'Do you have any allergies?',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: cs.onSurface,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        style: TextStyle(color: cs.onSurface),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cs.surface,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          hintText: 'Search allergies',
                          hintStyle: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(Icons.search, color: iconMuted),
                          suffixIcon: hasSearchQuery
                              ? IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: _clearAllergySearch,
                                  icon: Icon(
                                    Icons.close,
                                    color: iconMuted,
                                  ),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.outline),
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.outline),
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.primary, width: 2),
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    if (hasSearchQuery) ...[
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Choose all that apply:',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                      if (filteredAllergies.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.02,
                          ),
                          child: Column(
                            children: [
                              SvgPicture.asset(itemNotFound),
                              Text(
                                'No match found',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: cs.onSurface,
                                ),
                              ),
                              SizedBox(height: size.height * 0.005),
                              Text(
                                'Check the spelling or try another term',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...filteredAllergies.map((allergy) {
                          final isSelected =
                              selectedAllergies.contains(allergy);
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.02,
                            ),
                            child: ListTile(
                              dense: true,
                              title: Text(
                                allergy,
                                style: TextStyle(color: cs.onSurface),
                              ),
                              trailing: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.add_circle_outline,
                                color: cs.primary,
                              ),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedAllergies.remove(allergy);
                                  } else {
                                    selectedAllergies.add(allergy);
                                  }
                                });
                              },
                            ),
                          );
                        }),
                    ] else if (selectedAllergies.isEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.03,
                        ),
                        child: Text(
                          'Search for allergies and tap to add them. '
                          'You can skip this if you have none.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    if (selectedAllergies.isNotEmpty) ...[
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Selected allergies',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedAllergies.map((allergy) {
                            return InputChip(
                              label: Text(allergy),
                              onDeleted: () => setState(
                                () => selectedAllergies.remove(allergy),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    SizedBox(height: size.height * 0.03),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What is your blood type?',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _bloodTypes.map((type) {
                              final selected = selectedBloodType == type;
                              return ChoiceChip(
                                label: Text(type),
                                selected: selected,
                                onSelected: (_) =>
                                    setState(() => selectedBloodType = type),
                                selectedColor:
                                    cs.primary.withValues(alpha: 0.15),
                                checkmarkColor: cs.primary,
                                labelStyle: TextStyle(
                                  color: selected ? cs.primary : cs.onSurface,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                side: BorderSide(
                                  color: selected ? cs.primary : cs.outline,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_canFinish && !_loading)
                      ? () async {
                          setState(() => _loading = true);
                          try {
                            await context
                                .read<ProfileProvider>()
                                .saveOnboardingStep3(
                                  selectedAllergies: selectedAllergies,
                                  chronicConditionAnswer:
                                      chronicConditionAnswer,
                                  bloodType: selectedBloodType!,
                                );
                          } catch (_) {
                            // Don't block onboarding if the save fails.
                          }
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InitialInfoFinal(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.25,
                      vertical: size.height * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Finish',
                          style: TextStyle(color: cs.onPrimary),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoQuestion(
    BuildContext context, {
    required String question,
    required String groupValue,
    required ValueChanged<String> onChanged,
  }) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;

    Widget radio(String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomRadioBtn(
            groupValue: groupValue,
            value: value,
            onChanged: onChanged,
          ),
          SizedBox(width: size.width * 0.02),
          Text(value, style: TextStyle(color: cs.onSurface)),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: cs.onSurface,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Row(
            children: [
              radio('Yes'),
              SizedBox(width: size.width * 0.12),
              radio('No'),
            ],
          ),
        ],
      ),
    );
  }
}
