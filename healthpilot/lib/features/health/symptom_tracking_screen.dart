import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';

import '../../theme/app_theme.dart';
import 'health_profile_screen.dart';

// ignore: must_be_immutable
class SymptomTrackingScreen extends StatefulWidget {
  late List<String> diseaseSymptoms;
  SymptomTrackingScreen({super.key, required this.diseaseSymptoms});

  @override
  State<SymptomTrackingScreen> createState() => _SymptomTrackingScreenState();
}

class _SymptomTrackingScreenState extends State<SymptomTrackingScreen> {
  bool isAddingSymptom = false;
  bool symptomFilled = false;
  int symptomSize = 0;
  final symptomController = TextEditingController();
  @override
  void dispose() {
    symptomController.dispose();
    super.dispose();
  }

  //   add new symptom
  void addSymptom(String symptom) {
    setState(() {
      if (symptom != '') {
        widget.diseaseSymptoms.insert(0, symptom);
      }
    });
  }

  int severity = 0;

  //  this function bring the selected severity from customeBarIndicator class
  void severtyOfSymptom(int selectedBar) {
    severity = selectedBar * 2;
  }

  //  clear all symptoms
  void clearSymptoms() {
    setState(() {
      widget.diseaseSymptoms = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: AppTheme.buttonStyleForAppBarBackButto,
        ),
        title: const Text(
          "Symptom Tracking",
          style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05, vertical: size.height * 0.02),
        child: isAddingSymptom
            ? symptomFilled
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        SizedBox(
                          width: size.width,
                          child: Text(
                            'How much your ${symptomController.text} now',
                            style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w500,
                                fontSize: 18),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Column(
                          children: [
                            CustomizedBarIndicator(
                              barSize: 6,
                              fun: severtyOfSymptom,
                            ),
                            SizedBox(
                              height: size.height * 0.1,
                            ),
                            const Text(
                              'Press the  + button to increase the severity and the - to reduce.',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isAddingSymptom = false;
                              symptomFilled = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(110, 182, 255, 1),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.2,
                                vertical: size.height * 0.015),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Add Traking',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ])
                // if isAddingSymptom became true this will display text input for symptom
                : Column(
                    children: [
                      SizedBox(
                        width: size.width,
                        child: const Text(
                          'Add your symptoms ',
                          style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      TextFormField(
                        controller: symptomController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Search Symptoms',
                          hintStyle: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: size.width * 0.08,
                            color: const Color.fromRGBO(41, 41, 41, 0.5),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015,
                              horizontal: size.width * 0.03),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(41, 41, 41, 0.25)),
                            borderRadius: BorderRadius.all(
                              Radius.circular(size.width * 0.03),
                            ),
                          ),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (value) {
                          addSymptom(value);

                          symptomFilled = true;
                        },
                      ),
                    ],
                  )

            //if isAddingSymptom is false  this show the list of symptoms
            : Column(
                children: [
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height * 0.035,
                        width: size.width * 0.2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                const Color.fromRGBO(110, 182, 255, 0.25),
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.001),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.015),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              isAddingSymptom = true;
                            });
                          },
                          child: const Text(
                            "Add Tracking",
                            style: TextStyle(
                              color: Color.fromRGBO(110, 182, 255, 1),
                              fontSize: 10,
                              fontFamily: "PlusJakartaSans",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      SizedBox(
                        height: size.height * 0.035,
                        width: size.width * 0.2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                const Color.fromRGBO(252, 34, 34, 0.25),
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.001),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.015),
                            ),
                          ),
                          onPressed: () {
                            clearSymptoms();
                          },
                          child: const Text(
                            "Clear History",
                            style: TextStyle(
                              color: Color.fromRGBO(252, 34, 34, 1),
                              fontSize: 10,
                              fontFamily: "PlusJakartaSans",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.7,
                    child: widget.diseaseSymptoms.isEmpty
                        ? const Center(
                            child: Text(
                              "No symptom tracking added",
                              style: TextStyle(
                                color: Color.fromRGBO(110, 182, 255, 1),
                                fontSize: 20,
                                fontFamily: "PlusJakartaSans",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: widget.diseaseSymptoms.length,
                            itemBuilder: (context, index) {
                              return SymptomTracking(
                                disorder: widget.diseaseSymptoms[index],
                                onTap: () {},
                              );
                            },
                          ),
                  ),
                ],
              ),
      )),
    );
  }
}

class CustomizedBarIndicator extends StatefulWidget {
  final int barSize;
  final Function(int) fun;
  const CustomizedBarIndicator(
      {super.key, required this.barSize, required this.fun});

  @override
  State<CustomizedBarIndicator> createState() => _CustomizedBarIndicatorState();
}

class _CustomizedBarIndicatorState extends State<CustomizedBarIndicator> {
  int selectedBar = 0;
  List<Widget> addBar(int number) {
    List<Widget> bars = [];
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < number; i++) {
      bars.add(InkWell(
        onTap: () {
          setState(() {
            selectedBar = i;
            widget.fun(selectedBar);
          });
        },
        child: Column(
          children: [
            Container(
                height: size.height * 0.01,
                width: size.width * 0.12,
                color: i < 2
                    ? const Color.fromRGBO(83, 232, 139, 1)
                    : i < 4
                        ? const Color.fromRGBO(255, 232, 21, 1)
                        : const Color.fromRGBO(252, 34, 34, 1)),
          ],
        ),
      ));
    }
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (selectedBar > 0) {
                    selectedBar--;
                  }
                });
              },
              icon: const Icon(Icons.add_circle_outline_outlined,
                  color: Color.fromRGBO(83, 232, 139, 1)),
            ),
            Text(
              (selectedBar * 2).toString(),
              style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 36,
                  color: selectedBar < 2
                      ? const Color.fromRGBO(83, 232, 139, 1)
                      : selectedBar < 4
                          ? const Color.fromRGBO(255, 232, 21, 1)
                          : const Color.fromRGBO(252, 34, 34, 1)),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (selectedBar < 5) {
                    selectedBar++;
                  }
                });
              },
              icon: const Icon(
                Icons.add_circle_outline_outlined,
                color: Color.fromRGBO(252, 34, 34, 1),
              ),
            ),
          ],
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: addBar(widget.barSize),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width:
                      size.width * 0.06 + ((size.width * 0.15) * selectedBar),
                ),
                SvgPicture.asset(barIndicatorUp,
                    // ignore: deprecated_member_use
                    color: selectedBar < 2
                        ? const Color.fromRGBO(83, 232, 139, 1)
                        : selectedBar < 4
                            ? const Color.fromRGBO(255, 232, 21, 1)
                            : const Color.fromRGBO(252, 34, 34, 1)),
              ],
            )
          ],
        ),
      ],
    );
  }
}
