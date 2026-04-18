import 'package:flutter/material.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/personal_info/initial_info_2.dart';

import '../../theme/app_theme.dart';

class InitialInfoFirst extends StatefulWidget {
  const InitialInfoFirst({Key? key}) : super(key: key);

  @override
  State<InitialInfoFirst> createState() => _InitialInfoFirstState();
}

class _InitialInfoFirstState extends State<InitialInfoFirst> {
  Color textColor = const Color.fromRGBO(42, 42, 42, 0.5);

  double tickWidth = 1.0;
  int selectedAge = 20;
  int selectedWeight = 50;
  int selectedHeight = 180;
  RulerPickerController? _rulerPickerAgeController;
  RulerPickerController? _rulerPickerHeightController;
  RulerPickerController? _rulerPickerWeightController;
  String selectedHeightUnit = 'cm';
  String selectedWeightUnit = 'kg';
  String? mesurementTypeForWeight = "kg";
  List listItemsForWeight = ["kg", "gm"];
  String? mesurementTypeForHeight = "cm";
  List listItemsForHeight = ["cm", "ft"];

  @override
  void initState() {
    _rulerPickerAgeController = RulerPickerController(value: selectedAge);
    _rulerPickerHeightController = RulerPickerController(value: selectedHeight);
    _rulerPickerWeightController = RulerPickerController(value: selectedWeight);
    super.initState();
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
          actions: [
            SvgPicture.asset(translateIcon),
            SizedBox(
              width: size.width * 0.06,
            )
          ],
        ),
        body: SingleChildScrollView(
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
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child:
                            ClipRRect(child: SvgPicture.asset(maleForinital)),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        child:
                            ClipRRect(child: SvgPicture.asset(femaleForinital)),
                      ),
                    )
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
                          RulerRange(begin: 0, end: 10, scale: 0.1),
                          RulerRange(begin: 10, end: 100, scale: 1),
                          RulerRange(begin: 100, end: 1000, scale: 10),
                          RulerRange(begin: 1000, end: 10000, scale: 100),
                          RulerRange(begin: 10000, end: 100000, scale: 1000)
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
                        SizedBox(
                          width: size.height * 0.02,
                        ),
                        DropdownButton(
                          elevation: 0,
                          isDense: true,
                          underline: const Text(''),
                          iconEnabledColor:
                              const Color.fromRGBO(42, 42, 42, 0.5),
                          hint: Text(
                            mesurementTypeForHeight!,
                          ),
                          style: const TextStyle(
                            color: Color.fromRGBO(42, 42, 42, 0.5),
                          ),
                          value: mesurementTypeForHeight,
                          onChanged: (newValue) {
                            setState(() {
                              mesurementTypeForHeight = newValue! as String?;
                            });
                          },
                          items: listItemsForHeight.map((valueItem) {
                            return DropdownMenuItem(
                              value: valueItem,
                              child: Text(valueItem),
                            );
                          }).toList(),
                        )
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
                          RulerRange(begin: 0, end: 10, scale: 0.1),
                          RulerRange(begin: 10, end: 100, scale: 1),
                          RulerRange(begin: 100, end: 1000, scale: 10),
                          RulerRange(begin: 1000, end: 10000, scale: 100),
                          RulerRange(begin: 10000, end: 100000, scale: 1000)
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
                            selectedAge = value.toInt();
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
                        SizedBox(
                          width: size.height * 0.02,
                        ),
                        DropdownButton(
                          underline: const Text(''),
                          elevation: 0,
                          iconEnabledColor:
                              const Color.fromRGBO(42, 42, 42, 0.5),
                          hint: Text(
                            mesurementTypeForWeight!,
                          ),
                          style: const TextStyle(
                              color: Color.fromRGBO(42, 42, 42, 0.5)),
                          value: mesurementTypeForWeight,
                          onChanged: (newValue) {
                            setState(() {
                              mesurementTypeForWeight = newValue! as String?;
                            });
                          },
                          items: listItemsForWeight.map((valueItem) {
                            return DropdownMenuItem(
                              value: valueItem,
                              child: Text(valueItem),
                            );
                          }).toList(),
                        )
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
                          RulerRange(begin: 0, end: 10, scale: 0.1),
                          RulerRange(begin: 10, end: 100, scale: 1),
                          RulerRange(begin: 100, end: 1000, scale: 10),
                          RulerRange(begin: 1000, end: 10000, scale: 100),
                          RulerRange(begin: 10000, end: 100000, scale: 1000)
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
                    Padding(
                      padding: const EdgeInsets.only(top: 48.0, bottom: 48),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const InitialInfoSecond()), // Navigate to the DestinationPage
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
