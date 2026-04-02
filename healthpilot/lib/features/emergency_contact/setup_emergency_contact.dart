import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/home/home_page_screen.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';

import '../../theme/app_theme.dart';

class SetupEmergencyContact extends StatelessWidget {
  const SetupEmergencyContact({super.key});

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
                    child: SizedBox(
                      width: size.width * 0.6,
                      child: Text(
                        "Setup Emergency Contact",
                        style: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.w600,
                          fontFamily: "PlusJakartaSans",
                        ),
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
        child: Padding(
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
                  height: size.height * 0.28,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(110, 182, 255, 1),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.25,
                          vertical: size.height * 0.02),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
