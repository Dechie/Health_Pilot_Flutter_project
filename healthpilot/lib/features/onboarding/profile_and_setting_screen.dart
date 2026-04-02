// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/features/health/health_profile_screen.dart';
import 'package:healthpilot/features/home/home_page_screen.dart';
import 'package:healthpilot/features/meet_the_devs/meet_the_devs.dart';
import 'package:healthpilot/features/onboarding/language_translation.dart';
import 'package:healthpilot/features/onboarding/terms_dialogBox.dart';

import 'package:healthpilot/features/personal_info/initial_info_3.dart';
import 'medications._screen.dart';
import 'personal_information_screen.dart';
import 'signup_and_login_screen.dart';
import 'subscription_and_payment_screen.dart';

class ProfileAndSettingScreen extends StatefulWidget {
  const ProfileAndSettingScreen({super.key});

  @override
  State<ProfileAndSettingScreen> createState() =>
      _ProfileAndSettingScreenState();
}

class _ProfileAndSettingScreenState extends State<ProfileAndSettingScreen> {
  int _currentIndex = 0;
  List<Widget> body = [];

  final bool _isPremium = false;

  void showAlertDialogue() {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10), // Adjust the radius as needed
            ),
            title: const Text(
              "Premium Feature",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Plus Jakarta Sans",
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.165,
              ),
            ),
            content: const Text(
              "This feature is only available to premium users. To access this feature please upgrade to a premium subscription",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Plus Jakarta Sans",
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.165,
              ),
            ),
            actions: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>// go to gadget screen }));
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        const Color.fromRGBO(110, 182, 255, 1),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    child: Container(
                      width: 100,
                      height: 28,
                      alignment: Alignment.center,
                      child: const Text(
                        "Subscribe",
                        style: TextStyle(
                          fontFamily: "Plus Jakarta Sans",
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
        final size = constraints.biggest;
        final screenWidth = size.width;
        // ignore: unused_local_variable
        final screenHeight = size.height;
        return SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.1), // Adjust the borderRadius
                    child: Image.asset(
                      'assets/images/personel.png',
                      width: screenWidth * 0.15, // Adjust the width
                      height: screenWidth * 0.15, // Adjust the height
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 58,
                        left: 0,
                      ),
                      child: Text(
                        "Mohammed Ibrahim",
                        style: TextStyle(
                          fontFamily: "PlusJakartaSans",
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 18, left: 10),
                      child: _isPremium
                          ? GradientButton(title: "premium")
                          : GradientButton(title: "Free"),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 42, left: 55, right: 0),
                  child: Button(),
                )
              ],
            ),
            const SettingsTitle(title: "Health Information"),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  HealthInformationSettings(
                    imageAdress: 'assets/Icons/HealthBackground.svg',
                    settingAdress: 'Health Background',
                    iconData: Icons.arrow_forward,
                    onpressed: null,
                  ),
                  HealthInformationSettings(
                    imageAdress: 'assets/Icons/Medication.svg',
                    settingAdress: 'Medications',
                    iconData: Icons.arrow_forward,
                    onpressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MedicationScreen()));
                    },
                  ),
                  HealthInformationSettings(
                    imageAdress: 'assets/Icons/Allergies.svg',
                    settingAdress: 'Allergies',
                    iconData: Icons.arrow_forward,
                    onpressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => InitialInfoThird()));
                    },
                  ),
                ],
              ),
            ),
            SettingsTitle(title: "Settings"),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                // ignore: duplicate_ignore
                children: [
                  HealthInformationSettings(
                    imageAdress: 'assets/Icons/Gadgets.svg',
                    settingAdress: 'Gadgets',
                    iconData: Icons.lock_outlined,
                    onpressed: showAlertDialogue,
                  ),
                  HealthInformationSettings(
                    imageAdress: 'assets/Icons/Subscription.svg',
                    settingAdress: 'Subscription',
                    iconData: Icons.arrow_forward,
                    onpressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              SubscriptionAndPaymentScreen()));
                    },
                  ),
                  SettingsForDarkMode(
                    imageAdress: 'assets/Icons/Notfication.svg',
                    settingAdress: 'Notfication',
                  ),
                  SettingsForDarkMode(
                    imageAdress: 'assets/Icons/DarkMode.svg',
                    settingAdress: 'Dark Mode',
                  ),
                  HealthInformationSettings(
                    imageAdress: 'assets/Icons/changePassword.svg',
                    settingAdress: 'Change Password',
                    iconData: Icons.arrow_forward,
                    onpressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen()));
                    },
                  ),
                  HealthInformationSettings(
                    imageAdress: 'assets/Icons/Language.svg',
                    settingAdress: 'Language',
                    iconData: Icons.arrow_forward,
                    onpressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LanguageTranslation()));
                    },
                  ),
                  HealthInformationSettings(
                    imageAdress: 'assets/Icons/TermsAndPolicy.svg',
                    settingAdress: 'Terms And Policy',
                    onpressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Policy(
                              mdFile: 'privacy_policy.md',
                              radius: 8,
                            );
                          });
                    },
                    iconData: Icons.arrow_forward,
                  ),
                  HealthInformationSettings(
                    imageAdress: 'assets/Icons/help.svg',
                    settingAdress: 'Help',
                    iconData: Icons.arrow_forward,
                    onpressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => HomePageScreen(
                                isHelpPressed: true,
                              )));
                    },
                  ),
                  HealthInformationSettings(
                    imageAdress: 'assets/Icons/FAQ.svg',
                    settingAdress: 'FAQ',
                    iconData: Icons.arrow_forward,
                    onpressed: null,
                  ),
                  HealthInformationSettings(
                    imageAdress: 'assets/Icons/MeettheDevelopers.svg',
                    settingAdress: 'Meet the Developers',
                    iconData: Icons.arrow_forward,
                    onpressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MeetTheDevs()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
      })),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String title;
  const GradientButton({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
          width: 72,
          height: 28,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(110, 182, 255, 0.3),
                Color.fromRGBO(110, 182, 255, 0.26),
                Color.fromRGBO(110, 182, 255, 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ), // Adjust the width as needed
          child: Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "PlusJakartaSans",
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.16,
                ),
              ),
            ),
          )),
    );
  }
}

class Button extends StatelessWidget {
  const Button({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
          width: 74,
          height: 30,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(10, 182, 255, 0.2),
          ), // Adjust the width as needed
          child: Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PersonalInformationScreen()));
              },
              child: const Text(
                "Edit",
                style: TextStyle(
                  color: Color.fromRGBO(110, 182, 255, 1),
                  fontFamily: "PlusJakartaSans",
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.16,
                ),
              ),
            ),
          )),
    );
  }
}

class SettingsTitle extends StatelessWidget {
  final String title;
  const SettingsTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 42, left: 30),
      child: Text(
        title,
        // textAlign: TextAlign.left,
        style: const TextStyle(
          color: Color.fromRGBO(42, 42, 42, 1),

          fontFamily: "PlusJakartaSans",
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.25, // Corresponds to line height of 20px
          letterSpacing: -0.165,
        ),
      ),
    );
  }
}

class HealthInformationSettings extends StatelessWidget {
  final String imageAdress;
  final String settingAdress;
  final IconData? iconData;
  final VoidCallback? onpressed;

  // ignore: non_constant_identifier_names
  const HealthInformationSettings({
    super.key,
    required this.imageAdress,
    required this.settingAdress,
    this.iconData,
    required this.onpressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 30, right: 40),
      child: SizedBox(
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SvgPicture.asset(
                imageAdress,
              ),
              title: Text(
                settingAdress,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.2,
                ),
              ),
              horizontalTitleGap: 5,
              trailing: Icon(iconData),
              onTap: onpressed,
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SettingsForDarkMode extends StatefulWidget {
  final String imageAdress;
  final String settingAdress;
  final IconData? iconData;

  // ignore: non_constant_identifier_names
  const SettingsForDarkMode({
    super.key,
    required this.imageAdress,
    required this.settingAdress,
    this.iconData,
  });

  @override
  State<SettingsForDarkMode> createState() => _SettingsForDarkModeState();
}

class _SettingsForDarkModeState extends State<SettingsForDarkMode> {
  bool _isInnerContainerSwitched = false;
  // ignore: unused_field
  Color _containerColor = Colors.grey; // Initial color

  void _toggleInnerContainer() {
    setState(() {
      _isInnerContainerSwitched = !_isInnerContainerSwitched;

      if (_isInnerContainerSwitched) {
        _containerColor = Colors.blue;
      } else {
        _containerColor = Colors.grey;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, left: 30, right: 40),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: SvgPicture.asset(widget.imageAdress),
            title: Text(
              widget.settingAdress,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
            horizontalTitleGap: 5,
            trailing: GestureDetector(
              onTap: _toggleInnerContainer,
              child: Container(
                width: 28,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    width: 1,
                    color: Colors.blue, // You can change the color as needed
                  ),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  alignment: _isInnerContainerSwitched
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color:
                            Colors.blue, // You can change the color as needed
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),
        ],
      ),
    );
  }
}
