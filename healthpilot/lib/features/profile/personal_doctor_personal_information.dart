import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_history_screen.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_tracking_screen.dart';
import 'package:healthpilot/core/navigation/app_navigation.dart';

import 'package:healthpilot/theme/app_theme.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';
import 'package:line_icons/line_icons.dart';

import 'package:healthpilot/features/personal_doctor/setup_personal_doctor.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  int doctorCount = 0;

  void addDoctor() {
    if (doctorCount < 3) {
      setState(() {
        doctorCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: size.width * 0.1,
                    height: size.width * 0.1,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(110, 182, 255, 0.25),
                      borderRadius: BorderRadius.circular(size.width * 0.05),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                      color: const Color.fromRGBO(110, 182, 255, 1),
                      iconSize: size.width * 0.055,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      size.width * 0.05,
                      0,
                      0,
                      0,
                    ),
                    child: Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.w600,
                        fontFamily: "PlusJakartaSans",
                      ),
                    ),
                  ),
                ],
              ),
              SvgPicture.asset(
                'assets/images/Vector.svg',
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: size.width * 0.1,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.height * 0.08),
                          child: Image.asset(
                            height: size.width * 0.25,
                            personPicForProfile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: size.width * 0.16, left: size.width * 0.13),
                        child:
                            // CircleAvatar(
                            //   backgroundColor: Colors.white,
                            //   radius: size.width * 0.025,
                            //   child:
                            Container(
                                height: size.width * 0.04,
                                width: size.width * 0.04,
                                padding:
                                    EdgeInsets.only(left: size.width * 0.01),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    size.width * 0.02,
                                  ),
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                ),
                                child: Icon(
                                  LineIcons.edit,
                                  size: size.width * 0.03,
                                  color: const Color.fromARGB(255, 73, 70, 70),
                                )),
                      ),
                      // ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Text(
                    'Upload your profile photo',
                    style: AppTheme.bodyMuted(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08, vertical: size.width * 0.08),
              child: Form(
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'First Name',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                          ),
                        ),
                        TextFormField(
                          maxLines: 1,
                          decoration: InputDecoration(
                            // labelText: 'First Name',
                            // labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: size.height * 0.015,
                                horizontal: size.width * 0.03),
                            border: const OutlineInputBorder(),
                            isDense: true,
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 214, 210, 210)),
                            ),
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Name',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                          ),
                        ),
                        TextFormField(
                          maxLines: 1,
                          decoration: InputDecoration(
                            // labelText: 'Last Name',
                            // labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: size.height * 0.015,
                                horizontal: size.width * 0.03),
                            // label: Text('First Name'),
                            border: const OutlineInputBorder(),
                            isDense: true,
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                          ),
                        ),
                        TextFormField(
                          maxLines: 1,
                          decoration: InputDecoration(
                            // labelText: 'Email',
                            // labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: size.height * 0.015,
                                horizontal: size.width * 0.03),
                            // label: Text('First Name'),
                            border: const OutlineInputBorder(),
                            isDense: true,
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Phone Number',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                          ),
                        ),
                        IntlMobileField(
                          disableLengthCheck: true,
                          dropdownIconPosition: Position.trailing,
                          decoration: InputDecoration(
                            // labelText: 'Phone Number',
                            // labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: size.height * 0.015,
                                horizontal: size.width * 0.03),
                            // label: Text('First Name'),
                            border: const OutlineInputBorder(),
                            isDense: true,
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Personal Doctor',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        IconButton(
                            onPressed: () {
                              // addDoctor();
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    SetupPersonalDoctor(add: addDoctor),
                              ));
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.black,
                            ))
                      ],
                    ),
                    SizedBox(
                      height: doctorCount <= 0
                          ? size.height * 0.08
                          : size.height * 0.08 * doctorCount,
                      child: doctorCount <= 0
                          ? const Center(
                              child: Text(
                                'You don\'t have a personal doctor!',
                                style: TextStyle(
                                    color: Color.fromRGBO(110, 182, 255, 1),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
                              ),
                            )
                          : ListView.builder(
                              itemCount: doctorCount,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: size.width * 0.003,
                                          height: size.height * 0.08,
                                          color: const Color.fromRGBO(
                                              110, 182, 255, 1),
                                        ),
                                        Container(
                                          width: size.width * 0.03,
                                          height: size.width * 0.03,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                size.width * 0.015),
                                            color: const Color.fromRGBO(
                                                110, 182, 255, 1),
                                          ),
                                        ),
                                        Container(
                                          width: size.width * 0.03,
                                          height: size.width * 0.03,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                size.width * 0.015),
                                            color: const Color.fromRGBO(
                                                110, 182, 255, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: size.width * 0.02),
                                      width: size.width * 0.8,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Bobby Firminio'),
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromRGBO(
                                                        110, 182, 255, 1),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5))),
                                            child: const Text(
                                              'Edit',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Food and Nutrition Tracking',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const FoodNutritionHistoryScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Color.fromRGBO(110, 182, 255, 1),
                          ),
                        ),
                      ],
                    ),
                    ..._foodHistoryPreviewRows(context, size),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(size.width * 0.02),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(183, 216, 249, 0.786),
                              Color.fromRGBO(255, 255, 255, 1)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: double.infinity,
                            child: Text(
                              'Set up food and nutrition tracking',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(42, 42, 42, 1),
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                height: 0.2,
                                letterSpacing: -0.17,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          const Text(
                            'Start setting up your food and nutrition tracking to keep hold of your data on what u eat and drink.',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Plus Jakarta Sans',
                              color: Color.fromRGBO(42, 42, 42, 0.75),
                              fontSize: 13,
                              height: 1.3,
                              letterSpacing: -0.17,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                          SizedBox(
                            height: size.height * 0.045,
                            width: size.width * 0.35,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) =>
                                        const FoodNutritionTrackingScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(110, 182, 255, 1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3))),
                              child: const Text('Start Setup',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                    fontFamily: 'Plus Jakarta Sans',
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.07,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        AppNavigation.replaceWithHome(
                          context,
                          useRootNavigator: false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(110, 182, 255, 1),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.25,
                              vertical: size.height * 0.02),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text('Finish'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _foodHistoryPreviewRows(BuildContext context, Size size) {
    void openHistory() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const FoodNutritionHistoryScreen(),
        ),
      );
    }

    Widget row(String label) {
      return InkWell(
        onTap: openHistory,
        child: Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.012),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size.width * 0.003,
                    height: size.height * 0.055,
                    color: const Color.fromRGBO(110, 182, 255, 1),
                  ),
                  Container(
                    width: size.width * 0.03,
                    height: size.width * 0.03,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(size.width * 0.015),
                      color: const Color.fromRGBO(110, 182, 255, 1),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: size.width * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Color.fromRGBO(110, 182, 255, 1),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return [
      row('11:30 AM, May 13, 2023'),
      row('2:15 PM, May 12, 2023'),
    ];
  }
}
