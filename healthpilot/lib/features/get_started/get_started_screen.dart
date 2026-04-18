import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';
import 'package:healthpilot/features/personal_info/initial_info_2.dart';
import '/widget/custom_app_bar_title.dart';

import '../../data/constants.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() {
    return _GetStartedScreenState();
  }
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  double tickWidth = 1.0;
  int selectedAge = 18;
  int selectedWeight = 18;
  int selectedHeight = 18;
  RulerPickerController? _ageRulerPickerController;
  RulerPickerController? _heightRulerPickerController;
  RulerPickerController? _weightRulerPickerController;
  String selectedHeightUnit = 'cm';
  String selectedWeightUnit = 'kg';

  List<RulerRange> rulerRanges = const [
    RulerRange(begin: 0, end: 10, scale: 0.1),
    RulerRange(begin: 10, end: 100, scale: 1),
    RulerRange(begin: 100, end: 1000, scale: 10),
    RulerRange(begin: 1000, end: 10000, scale: 100),
    RulerRange(begin: 10000, end: 100000, scale: 1000)
  ];
  List<String> heightUnits = [
    'cm',
    'in',
    'ft',
  ];
  List<String> weightUnits = [
    'kg',
    'lb',
  ];
  HashSet selectItems = HashSet();
  @override
  void initState() {
    super.initState();
    _ageRulerPickerController = RulerPickerController(value: 0);
    _heightRulerPickerController = RulerPickerController(value: 0);
    _weightRulerPickerController = RulerPickerController(value: 0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(50, 60),
          child: CustomAppBar(
              onPressed: () {},
              suffixIconImage: appBarTitleImage,
              title: letsStartAppBarTitle,
              leadingIcon: Icons.arrow_back_rounded),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 30, top: 30),
                width: 220,
                height: 22,
                child: const Text(
                  'Choose your gender',
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Plus Jakarta Sans'),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectItems.contains('female')) {
                        selectItems.clear();
                        selectItems.add('male');
                      } else {
                        if (selectItems.isEmpty) {
                          selectItems.add('male');
                        }
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectItems.contains('male')
                          ? const Color.fromRGBO(110, 182, 255, 1)
                          : null,
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(10, 10),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Image(
                          fit: BoxFit.contain,
                          image: AssetImage('assets/images/male.png'),
                          height: 100,
                          width: 71,
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 15),
                          child: const Text(
                            'Male',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromRGBO(
                                  42,
                                  42,
                                  42,
                                  1,
                                ),
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                //female
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectItems.contains('male')) {
                        selectItems.clear();
                        selectItems.add('female');
                      } else {
                        if (selectItems.isEmpty) {
                          selectItems.add('female');
                        }
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectItems.contains('female')
                          ? const Color.fromRGBO(110, 182, 255, 1)
                          : null,
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(10, 10),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Image(
                          fit: BoxFit.contain,
                          image: AssetImage('assets/images/female.png'),
                          height: 100,
                          width: 98,
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 15),
                          child: const Text(
                            'Female',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromRGBO(
                                  42,
                                  42,
                                  42,
                                  1,
                                ),
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ]),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 24.0, top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/images/age_icon.png'),
                      height: 24,
                      width: 24,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text('Age',
                        style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Plus Jakarta Sans'))
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 10,
                ),
                child: RulerPicker(
                  controller: _ageRulerPickerController,
                  rulerBackgroundColor: Colors.transparent,

                  // beginValue: 0,
                  // endValue: 100,
                  // initValue: _rulerPickerController!.value,
                  ranges: rulerRanges,
                  rulerScaleTextStyle: const TextStyle(
                      fontStyle: FontStyle.normal,
                      color: Color.fromRGBO(42, 42, 42, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500), //
                  scaleLineStyleList: const [
                    ScaleLineStyle(
                        color: Color.fromRGBO(42, 42, 42, 1),
                        width: 1.5,
                        height: 20,
                        scale: 0),
                    ScaleLineStyle(
                        color: Color.fromRGBO(42, 42, 42, 1),
                        width: 1,
                        height: 15,
                        scale: 5),
                    ScaleLineStyle(
                        color: Color.fromRGBO(42, 42, 42, 1),
                        width: 1,
                        height: 10,
                        scale: -1)
                  ],
                  onValueChanged: (value) {
                    setState(() {
                      selectedAge = value.toInt();
                    });
                  },
                  width: MediaQuery.of(context).size.width * 1,
                  height: 40,
                  rulerMarginTop: 15,
                  onBuildRulerScaleText: (int index, num rulerScaleValue) {
                    try {
                      return rulerScaleValue.toStringAsFixed(0);
                    } catch (e) {
                      return 'Invalid Value';
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Stack(
                      children: [
                        Positioned(
                          right: 9,
                          child: Image(
                            fit: BoxFit.contain,
                            image: AssetImage('assets/images/symbols_man.png'),
                            height: 24,
                            width: 24,
                          ),
                        ),
                        Image(
                          fit: BoxFit.contain,
                          image: AssetImage('assets/images/height_icon.png'),
                          height: 24,
                          width: 24,
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    const Text(
                      'Height',
                      style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Plus Jakarta Sans'),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isDense: false,
                        elevation: 1,
                        borderRadius:
                            const BorderRadius.all(Radius.elliptical(10, 10)),
                        alignment: AlignmentDirectional.topStart,
                        focusColor: Colors.transparent,
                        items: heightUnits
                            .map((String item) => DropdownMenuItem<String>(
                                  enabled: true,
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.normal,
                                        color: Color.fromRGBO(42, 42, 42, 1)),
                                  ),
                                ))
                            .toList(),
                        value: selectedHeightUnit,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedHeightUnit = value;
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10),
                child: RulerPicker(
                  controller: _heightRulerPickerController,
                  // beginValue: 70,
                  // endValue: 200,
                  // initValue: _rulerPickerController!.value,
                  ranges: rulerRanges,
                  rulerScaleTextStyle: const TextStyle(
                      fontStyle: FontStyle.normal,
                      color: Color.fromRGBO(42, 42, 42, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500), //
                  scaleLineStyleList: const [
                    ScaleLineStyle(
                        color: Color.fromRGBO(42, 42, 42, 1),
                        width: 1.5,
                        height: 20,
                        scale: 0),
                    ScaleLineStyle(
                        color: Color.fromRGBO(42, 42, 42, 1),
                        width: 1,
                        height: 15,
                        scale: 5),
                    ScaleLineStyle(
                        color: Color.fromRGBO(42, 42, 42, 1),
                        width: 1,
                        height: 10,
                        scale: -1)
                  ],
                  onValueChanged: (value) {
                    setState(() {
                      selectedHeight = value.toInt();
                    });
                  },
                  width: MediaQuery.of(context).size.width * 1,
                  height: 40,
                  rulerMarginTop: 15,
                  onBuildRulerScaleText: (int index, num rulerScaleValue) {
                    return rulerScaleValue.toInt().toString();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Image(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/images/weight_scale.png'),
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    const Text(
                      'Weight',
                      style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Plus Jakarta Sans'),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isDense: false,
                        elevation: 1,
                        borderRadius:
                            const BorderRadius.all(Radius.elliptical(10, 10)),
                        alignment: AlignmentDirectional.topStart,
                        focusColor: Colors.transparent,
                        items: weightUnits
                            .map((String item) => DropdownMenuItem<String>(
                                  enabled: true,
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.normal,
                                        color: Color.fromRGBO(42, 42, 42, 1)),
                                  ),
                                ))
                            .toList(),
                        value: selectedWeightUnit,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedWeightUnit = value;
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: RulerPicker(
                  controller: _weightRulerPickerController,
                  // beginValue: 70,
                  // endValue: 200,
                  // initValue: _rulerPickerController!.value,
                  ranges: rulerRanges,
                  rulerScaleTextStyle: const TextStyle(
                      fontStyle: FontStyle.normal,
                      color: Color.fromRGBO(42, 42, 42, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500), //
                  scaleLineStyleList: const [
                    ScaleLineStyle(
                        color: Color.fromRGBO(42, 42, 42, 1),
                        width: 1.5,
                        height: 20,
                        scale: 0),
                    ScaleLineStyle(
                        color: Color.fromRGBO(42, 42, 42, 1),
                        width: 1,
                        height: 15,
                        scale: 5),
                    ScaleLineStyle(
                        color: Color.fromRGBO(42, 42, 42, 1),
                        width: 1,
                        height: 10,
                        scale: -1)
                  ],
                  onValueChanged: (value) {
                    setState(() {
                      selectedHeight = value.toInt();
                    });
                  },
                  width: MediaQuery.of(context).size.width * 1,
                  height: 40,
                  rulerMarginTop: 15,
                  onBuildRulerScaleText: (int index, num rulerScaleValue) {
                    try {
                      return rulerScaleValue.toInt().toString();
                    } catch (e) {
                      return 'Invalid Value';
                    }
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40.0, horizontal: 80),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InitialInfoSecond(),
                        ));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 231,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(110, 182, 255, 1),
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(10, 10),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color.fromRGBO(255, 255, 255, 1)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
