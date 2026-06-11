import 'package:flutter/material.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/personal_info/initial_info_2.dart';
import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/features/profile/profile_provider.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';

class InitialInfoFirst extends StatefulWidget {
  const InitialInfoFirst({super.key});

  @override
  State<InitialInfoFirst> createState() => _InitialInfoFirstState();
}

class _InitialInfoFirstState extends State<InitialInfoFirst> {
  Color textColor = const Color.fromRGBO(42, 42, 42, 0.5);

  double tickWidth = 1.0;
  String? selectedGender;
  int selectedAge = 20;
  int selectedWeight = 50;
  int selectedHeight = 140;
  RulerPickerController? _rulerPickerAgeController;
  RulerPickerController? _rulerPickerHeightController;
  RulerPickerController? _rulerPickerWeightController;

  @override
  void initState() {
    _rulerPickerAgeController = RulerPickerController(value: selectedAge);
    _rulerPickerHeightController = RulerPickerController(value: selectedHeight);
    _rulerPickerWeightController = RulerPickerController(value: selectedWeight);
    super.initState();
    if (FeatureFlags.auth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final auth = context.read<AuthState>();
        if (!auth.isOnboardingCompleted) auth.setOnboardingStep(1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: AppTheme.circleBackButtonStyle(context),
          ),
          title: const Text(
            'Let’s Get Started',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
            maxLines: 2,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.03,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                child: const Text(
                  "Choose your gender",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: ' PlusJakartaSans',
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(
                height: size.height * 0.04,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _GenderOption(
                      assetPath: maleForinital,
                      label: 'Male',
                      selected: selectedGender == 'male',
                      onTap: () => setState(() => selectedGender = 'male'),
                    ),
                    _GenderOption(
                      assetPath: femaleForinital,
                      label: 'Female',
                      selected: selectedGender == 'female',
                      onTap: () => setState(() => selectedGender = 'female'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.04,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(brainIcon),
                        SizedBox(
                          width: size.height * 0.02,
                        ),
                        const Text(
                          "Age",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontFamily: ' PlusJakartaSans',
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "years",
                          style: TextStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            fontFamily: ' PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$selectedAge',
                          style: const TextStyle(
                            color: Color.fromRGBO(110, 182, 255, 1),
                            fontFamily: ' PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 15,
                      ),
                      child: RulerPicker(
                        marker: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            SvgPicture.asset(triangleMarker),
                            SvgPicture.asset(lineMarker, height: 10),
                          ],
                        ),
                        ranges: const [
                          RulerRange(begin: 0, end: 100, scale: 1),
                        ],
                        controller: _rulerPickerAgeController,
                        // beginValue: 0,
                        // endValue: 100,
                        // initValue: _rulerPickerController!.value,
                        rulerBackgroundColor: Colors.transparent,

                        rulerScaleTextStyle: const TextStyle(
                            fontFamily: ' PlusJakartaSans',
                            color: Color.fromRGBO(42, 42, 42, 1),
                            fontSize: 14,
                            fontWeight: FontWeight.w500), //
                        scaleLineStyleList: const [
                          ScaleLineStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            width: 1.5,
                            height: 20,
                            scale: 0,
                          ),
                          ScaleLineStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            width: 1,
                            height: 15,
                            scale: 5,
                          ),
                          ScaleLineStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            width: 1,
                            height: 10,
                            scale: -1,
                          )
                        ],
                        onValueChanged: (value) {
                          setState(() {
                            selectedAge = value.toInt();
                          });
                        },
                        width: MediaQuery.of(context).size.width * 1,
                        height: size.height * 0.06,
                        rulerMarginTop: 15,

                        onBuildRulerScaleText:
                            (int index, num rulerScaleValue) {
                          return rulerScaleValue.toInt().toString();
                        },

                        // onBuildRulerScaleText: (int index, num rulerScaleValue) {  },
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.04,
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(height),
                        SizedBox(
                          width: size.height * 0.01,
                        ),
                        const Text(
                          "Height",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontFamily: ' PlusJakartaSans',
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "cm",
                          style: TextStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            fontFamily: ' PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$selectedHeight',
                          style: const TextStyle(
                            color: Color.fromRGBO(110, 182, 255, 1),
                            fontFamily: ' PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                      ),
                      child: RulerPicker(
                        rulerBackgroundColor: Colors.transparent,
                        marker: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            SvgPicture.asset(triangleMarker),
                            SvgPicture.asset(lineMarker, height: 10),
                          ],
                        ),
                        ranges: const [
                          RulerRange(begin: 40, end: 200, scale: 1),
                        ],
                        controller: _rulerPickerHeightController,

                        rulerScaleTextStyle: const TextStyle(
                            fontFamily: ' PlusJakartaSans',
                            color: Color.fromRGBO(42, 42, 42, 1),
                            fontSize: 14,
                            fontWeight: FontWeight.w500), //
                        scaleLineStyleList: const [
                          ScaleLineStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            width: 1.5,
                            height: 20,
                            scale: 0,
                          ),
                          ScaleLineStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            width: 1,
                            height: 15,
                            scale: 5,
                          ),
                          ScaleLineStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            width: 1,
                            height: 10,
                            scale: -1,
                          )
                        ],
                        onValueChanged: (num value) {
                          setState(() {
                            selectedHeight = value.toInt();
                          });
                        },
                        width: size.width,
                        height: size.height * 0.06,
                        rulerMarginTop: 15,

                        onBuildRulerScaleText:
                            (int index, num rulerScaleValue) {
                          return rulerScaleValue.toInt().toString();
                        },
                        // onBuildRulerScaleText: (int index, num rulerScaleValue) {  },
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.04,
                    ),
                    Row(
                      children: [
                        // SizedBox(
                        //   width: size.height * 0.01,
                        // ),
                        ClipRRect(child: SvgPicture.asset(weight)),
                        SizedBox(
                          width: size.height * 0.02,
                        ),
                        const Text(
                          "Weight",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontFamily: ' PlusJakartaSans',
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "kg",
                          style: TextStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            fontFamily: ' PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$selectedWeight',
                          style: const TextStyle(
                            color: Color.fromRGBO(110, 182, 255, 1),
                            fontFamily: ' PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                      ),
                      child: RulerPicker(
                        rulerBackgroundColor: Colors.transparent,
                        marker: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            SvgPicture.asset(triangleMarker),
                            SvgPicture.asset(lineMarker, height: 10),
                          ],
                        ),
                        ranges: const [
                          RulerRange(begin: 0, end: 120, scale: 1),
                        ],
                        controller: _rulerPickerWeightController,
                        // beginValue: 0,
                        // endValue: 100,
                        // initValue: _rulerPickerController!.value,

                        rulerScaleTextStyle: const TextStyle(
                            fontFamily: ' PlusJakartaSans',
                            color: Color.fromRGBO(42, 42, 42, 1),
                            fontSize: 14,
                            fontWeight: FontWeight.w500), //
                        scaleLineStyleList: const [
                          ScaleLineStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            width: 1.5,
                            height: 20,
                            scale: 0,
                          ),
                          ScaleLineStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            width: 1,
                            height: 15,
                            scale: 5,
                          ),
                          ScaleLineStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                            width: 1,
                            height: 10,
                            scale: -1,
                          )
                        ],
                        onValueChanged: (value) {
                          setState(() {
                            selectedWeight = value.toInt();
                          });
                        },

                        width: MediaQuery.of(context).size.width * 1,
                        height: size.height * 0.06,
                        rulerMarginTop: 15,
                        onBuildRulerScaleText:
                            (int index, num rulerScaleValue) {
                          return rulerScaleValue.toInt().toString();
                        },

                        // onBuildRulerScaleText: (int index, num rulerScaleValue) {  },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 48.0, bottom: 48),
                      child: ElevatedButton(
                        onPressed: selectedGender == null
                            ? null
                            : () async {
                          final double heightCm = selectedHeight.toDouble();
                          final double weightKg = selectedWeight.toDouble();
                          try {
                            await context
                                .read<ProfileProvider>()
                                .saveOnboardingStep1(
                                  gender: selectedGender,
                                  age: selectedAge,
                                  heightCm: heightCm,
                                  weightKg: weightKg,
                                );
                          } catch (_) {
                            // Don't block onboarding if the save fails.
                          }
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const InitialInfoSecond()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(110, 182, 255, 1),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.25,
                              vertical: size.height * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.assetPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color.fromRGBO(110, 182, 255, 1);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? selectedColor : Colors.transparent,
                width: 3,
              ),
              color: selected
                  ? selectedColor.withValues(alpha: 0.08)
                  : Colors.transparent,
            ),
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: selected ? selectedColor : const Color.fromRGBO(42, 42, 42, 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
