import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/health/health_tracking_screen.dart';

import 'symptom_tracking_screen.dart';

class HealthProfile extends StatefulWidget {
  const HealthProfile({super.key});

  @override
  State<HealthProfile> createState() => _HealthProfileState();
}

class _HealthProfileState extends State<HealthProfile> {
  List<Map<String, String>> disorders = [
    {
      'name': 'Schizophrenia',
      'dateTime': '11:30 AM, May 13, 2023',
    },
    {
      'name': 'Bipolar Disorder',
      'dateTime': '11:30 AM, May 13, 2023',
    },
    {
      'name': 'Major Depressive Disorder',
      'dateTime': '11:30 AM, May 13, 2023',
    },
    {
      'name': 'Post-Traumatic Stress Disorder (PTSD)',
      'dateTime': '11:30 AM, May 13, 2023',
    },
    {
      'name': 'Obsessive-Compulsive Disorder (OCD)',
      'dateTime': '11:30 AM, May 13, 2023',
    },
    {
      'name': 'Generalized Anxiety Disorder (GAD)',
      'dateTime': '11:30 AM, May 13, 2023',
    },
    {
      'name': 'Borderline Personality Disorder (BPD)',
      'dateTime': '11:30 AM, May 13, 2023',
    },
  ];
  List<String> diseaseSymptoms = [
    "Fever",
    "Cough",
    "Shortness of breath",
    "Fatigue",
    "Loss of taste or smell",
    "Muscle or body aches",
    "Headache",
    "Sore throat",
    "Congestion or runny nose",
    "Nausea or vomiting",
    "Diarrhea",
  ];

  List<String> peoples = [
    "Yaikob zeray",
    "Abel sisay",
    "Kirubel hailu",
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: size.width * 0.5,
                    child: const Text(
                      'Hello, UserName',
                      style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            splashColor: const Color.fromARGB(100, 0, 0, 0),
                            onTap: () => {},
                            // Navigator.of(context).push(MaterialPageRoute(
                            //   // builder: (context) => const LanguageTranslation(),
                            // )),
                            child: SvgPicture.asset(translateIcon)),
                        InkWell(
                          splashColor: const Color.fromARGB(100, 0, 0, 0),
                          onTap: () {},
                          child: SvgPicture.asset(triangleExclamationIcon),
                        ),
                        SvgPicture.asset(bellReminder),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Row(
                children: [
                  const Text(
                    "My Statistics",
                    style: TextStyle(
                      fontFamily: "PlusJakartaSans",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  const Text(
                    "premium",
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: "PlusJakartaSans",
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(110, 182, 255, 1)),
                  )
                ],
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PremiumTags(),
                  PremiumTags(),
                  PremiumTags(),
                ],
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Health Tracking',
                    style: TextStyle(
                        fontFamily: "PlusJakartaSans",
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HealthTrackingScreen(
                                healthTrakingList: disorders),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward))
                ],
              ),
              SizedBox(
                height: size.height * 0.3,
                child: ListView.builder(
                  itemCount: disorders.length,
                  itemBuilder: (context, index) {
                    return HealthTracking(
                      disorder: disorders[index]['name']!,
                      date: disorders[index]['dateTime']!,
                    );
                  },
                ),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Symptom Tracking',
                    style: TextStyle(
                        fontFamily: "PlusJakartaSans",
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SymptomTrackingScreen(
                              diseaseSymptoms: diseaseSymptoms),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: size.height * 0.3,
                child: ListView.builder(
                  itemCount: diseaseSymptoms.length,
                  itemBuilder: (context, index) {
                    return SymptomTracking(
                      disorder: diseaseSymptoms[index],
                      onTap: () {},
                    );
                  },
                ),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Health Profiles',
                    style: TextStyle(
                        fontFamily: "PlusJakartaSans",
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle_outline))
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: size.height * 0.3,
                child: ListView.builder(
                  itemCount: peoples.length,
                  itemBuilder: (context, index) {
                    return HealthProfileModel(
                      disorder: peoples[index],
                      onTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

// this calss contains abutton to unlock the premium version
class PremiumTags extends StatelessWidget {
  const PremiumTags({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.width * 0.02),
            color: const Color.fromRGBO(255, 255, 255, 1),
            boxShadow: [
              BoxShadow(
                blurRadius: 35,
                spreadRadius: 0,
                color: const Color.fromRGBO(46, 46, 46, 1.000).withOpacity(0.1),
              ),
            ],
          ),
          height: size.height * 0.08,
          width: size.width * 0.28,
          alignment: const Alignment(0, 0),
          child: const Text(
            "Subscribed",
            style: TextStyle(fontSize: 40),
          ),
        ),
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: size.height * 0.08,
              width: size.width * 0.28,
              alignment: const Alignment(0, 0),
              child: MaterialButton(
                minWidth: size.width * 0.28,
                height: size.height * 0.03,
                elevation: 0,
                color: const Color.fromRGBO(110, 182, 255, 1),
                onPressed: () {},
                child: const Text(
                  'Subscribe',
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: "PlusJakartaSans",
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// health tracking model
class HealthTracking extends StatelessWidget {
  final String disorder;
  final String date;
  const HealthTracking({super.key, required this.disorder, required this.date});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size.width * 0.003,
              height: size.height * 0.08,
              color: const Color.fromRGBO(110, 182, 255, 0.25),
            ),
            Container(
              width: size.width * 0.03,
              height: size.width * 0.03,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * 0.015),
                color: const Color.fromRGBO(110, 182, 255, 0.25),
              ),
            ),
            Container(
              width: size.width * 0.03,
              height: size.width * 0.03,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * 0.015),
                color: const Color.fromRGBO(110, 182, 255, 0.25),
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(left: size.width * 0.02),
          width: size.width * 0.8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.4,
                child: Text(
                  disorder,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "PlusJakartaSans",
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: "PlusJakartaSans",
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(110, 182, 255, 1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//  symptom tracking model
class SymptomTracking extends StatelessWidget {
  final String disorder;
  final Function onTap;
  const SymptomTracking({
    super.key,
    required this.disorder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size.width * 0.003,
                height: size.height * 0.08,
                color: const Color.fromRGBO(110, 182, 255, 0.25),
              ),
              Container(
                width: size.width * 0.03,
                height: size.width * 0.03,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * 0.015),
                  color: const Color.fromRGBO(110, 182, 255, 0.25),
                ),
              ),
              Container(
                width: size.width * 0.03,
                height: size.width * 0.03,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * 0.015),
                  color: const Color.fromRGBO(110, 182, 255, 0.25),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.73,
                child: Text(
                  disorder,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "PlusJakartaSans",
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward,
                    color: Color.fromRGBO(42, 42, 42, 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//  Health Profilemodel
class HealthProfileModel extends StatelessWidget {
  final String disorder;
  final Function onTap;
  const HealthProfileModel({
    super.key,
    required this.disorder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size.width * 0.003,
                height: size.height * 0.08,
                color: const Color.fromRGBO(110, 182, 255, 0.25),
              ),
              Container(
                width: size.width * 0.03,
                height: size.width * 0.03,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * 0.015),
                  color: const Color.fromRGBO(110, 182, 255, 0.25),
                ),
              ),
              Container(
                width: size.width * 0.03,
                height: size.width * 0.03,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * 0.015),
                  color: const Color.fromRGBO(110, 182, 255, 0.25),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.6,
                child: Text(
                  disorder,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "PlusJakartaSans",
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: size.height * 0.035,
                width: size.width * 0.2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color.fromRGBO(110, 182, 255, 1),
                    padding:
                        EdgeInsets.symmetric(vertical: size.height * 0.001),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * 0.015),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Edit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: "PlusJakartaSans",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: size.width * 0.04,
              )
            ],
          ),
        ],
      ),
    );
  }
}
