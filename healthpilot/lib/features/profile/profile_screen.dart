// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:healthpilot/features/medication/medications_screen.dart';
import 'package:healthpilot/features/profile/allergies_screen.dart';
import 'package:healthpilot/features/profile/settings_screen.dart';
import 'package:healthpilot/features/profile/widgets/profile_settings_shared.dart';

/// Profile tab entry: identity + health information. Settings live in [SettingsScreen].
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool _isPremium = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final screenWidth = size.width;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40, left: 20),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.1),
                          child: Image.asset(
                            'assets/images/personel.png',
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              top: 58,
                              left: 0,
                            ),
                            child: Text(
                              'Mohammed Ibrahim',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18, left: 10),
                            child: _isPremium
                                ? const GradientButton(title: 'premium')
                                : const GradientButton(title: 'Free'),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 42, left: 55, right: 0),
                        child: ProfileEditButton(),
                      )
                    ],
                  ),
                  const SettingsTitle(title: 'Health Information'),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
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
                                builder: (context) => const MedicationScreen()));
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
