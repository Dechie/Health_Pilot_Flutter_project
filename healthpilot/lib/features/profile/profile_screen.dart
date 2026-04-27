// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:healthpilot/features/medication/medications_screen.dart';
import 'package:healthpilot/features/profile/allergies_screen.dart';
import 'package:healthpilot/features/profile/settings_screen.dart';
import 'package:healthpilot/features/profile/user_profile.dart';
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
            final screenWidth = constraints.biggest.width;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.1),
                          child: Image.asset(
                            'assets/images/personel.png',
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kDemoUserProfile.displayName ?? 'Profile',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.16,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              _isPremium
                                  ? const GradientButton(title: 'premium')
                                  : const GradientButton(title: 'Free'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const ProfileEditButton(),
                      ],
                    ),
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
                            Navigator.of(context).push(MaterialPageRoute<void>(
                                builder: (context) =>
                                    const MedicationScreen()));
                          },
                        ),
                        HealthInformationSettings(
                          imageAdress: 'assets/Icons/Allergies.svg',
                          settingAdress: 'Allergies',
                          iconData: Icons.arrow_forward,
                          onpressed: () {
                            Navigator.of(context).push(MaterialPageRoute<void>(
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
