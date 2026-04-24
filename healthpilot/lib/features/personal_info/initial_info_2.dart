import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/personal_info/initial_info_3.dart';

import '../../theme/app_theme.dart';

class InitialInfoSecond extends StatefulWidget {
  const InitialInfoSecond({super.key});

  @override
  State<InitialInfoSecond> createState() => _InitialInfoSecondState();
}

class _InitialInfoSecondState extends State<InitialInfoSecond> {
  String hypertensionAnswer = "";
  String accidentsAnswer = "";
  String smokingAnswer = "";
  String diabetesAnswer = "";
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color.fromRGBO(110, 182, 255, 1)),
            onPressed: () {
              // Define the action when the back button is pressed
              Navigator.of(context).pop();
            },
            style: AppTheme.circleBackButtonStyle(context),
          ),
          title: const Text(
            'Almost There',
            style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: Colors.black),
            maxLines: 2,
          ),
          actions: [
            SvgPicture.asset(translateIcon),
            const SizedBox(
              width: 30,
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 28.0, bottom: 28.0),
                child: buildQuestionWithRadioButtons(
                  "Do you suffer from hypertension?",
                  "hypertension",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: buildQuestionWithRadioButtons(
                  "Have you had any accidents recently?",
                  "accidents",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: buildQuestionWithRadioButtons(
                    "Do you smoke often?", "smoking"),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: buildQuestionWithRadioButtons(
                    "Do you suffer from diabetes?", "diabetes"),
              ),
              SizedBox(height: size.height * 0.2),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Set up later?",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black54),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: size.height * 0.01, bottom: size.height * 0.1),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const InitialInfoThird()), // Navigate to the DestinationPage
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
              ),
            ],
          ),
        ));
  }

  // afunction that return questions text widget and ansewrs with radio buttons
  //  also take two parameters the question and the question key Strings

  Widget buildQuestionWithRadioButtons(String question, String questionKey) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          question,
          style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black),
          maxLines: 2,
        ),
        SizedBox(
          height: size.height * 0.025,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            buildRadioButton("Yes", questionKey),
            buildRadioButton("No", questionKey),
            buildRadioButton("I don't know", questionKey),
          ],
        ),
      ],
    );
  }

  Widget buildRadioButton(String value, String questionKey) {
    return Row(
      children: <Widget>[
        CustomRadioBtn(
          groupValue: getGroupValue(questionKey)!,
          value: value,
          onChanged: (newValue) {
            setState(() {
              setAnswer(questionKey, newValue);
            });
          },
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.02,
        ),
        Text(value),
      ],
    );
  }

  String? getGroupValue(String questionKey) {
    switch (questionKey) {
      case "hypertension":
        return hypertensionAnswer;
      case "accidents":
        return accidentsAnswer;
      case "smoking":
        return smokingAnswer;
      case "diabetes":
        return diabetesAnswer;
      default:
        return null;
    }
  }

  void setAnswer(String questionKey, String? value) {
    switch (questionKey) {
      case "hypertension":
        hypertensionAnswer = value ?? "";
        break;
      case "accidents":
        accidentsAnswer = value ?? "";
        break;
      case "smoking":
        smokingAnswer = value ?? "";
        break;
      case "diabetes":
        diabetesAnswer = value ?? "";
        break;
    }
  }
}

//costumized radio button which takes value, group value and on change as parameter
// through constructor

class CustomRadioBtn extends StatefulWidget {
  final String value;
  final String groupValue;
  final Function(String value) onChanged;
  const CustomRadioBtn(
      {super.key,
      required this.value,
      required this.groupValue,
      required this.onChanged});

  @override
  State<CustomRadioBtn> createState() => _CustomRadioBtnState();
}

class _CustomRadioBtnState extends State<CustomRadioBtn> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => widget.onChanged(widget.value),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.004),
        height: size.height * 0.025,
        width: size.height * 0.025,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.height * 0.125),
          // color: Colors.blue,
          border:
              Border.all(color: const Color.fromARGB(23, 0, 0, 0), width: 2),
        ),
        child: widget.groupValue == widget.value
            ? Container(
                height: size.height * 0.015,
                width: size.height * 0.015,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.height * 0.075),
                  color: const Color.fromRGBO(110, 182, 255, 1),
                ),
              )
            : null,
      ),
    );
  }
}
