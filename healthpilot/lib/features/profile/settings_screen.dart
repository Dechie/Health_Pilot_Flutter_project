// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:healthpilot/features/forgot_password/forgot_password_flow.dart';
import 'package:healthpilot/features/home/home_page_screen.dart';
import 'package:healthpilot/features/profile/language_translation.dart';
import 'package:healthpilot/features/profile/terms_and_policy_dialog.dart';
import 'package:healthpilot/features/profile/widgets/premium_feature_dialog.dart';
import 'package:healthpilot/features/profile/widgets/profile_settings_shared.dart';
import 'package:healthpilot/features/subscription/subscription_and_payment_screen.dart';

/// App settings and account-related actions (split from profile for clearer ownership).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsTitle(title: 'Settings'),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    HealthInformationSettings(
                      imageAdress: 'assets/Icons/Gadgets.svg',
                      settingAdress: 'Gadgets',
                      iconData: Icons.lock_outlined,
                      onpressed: () => showPremiumFeatureDialog(context),
                    ),
                    HealthInformationSettings(
                      imageAdress: 'assets/Icons/Subscription.svg',
                      settingAdress: 'Subscription',
                      iconData: Icons.arrow_forward,
                      onpressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const SubscriptionAndPaymentScreen()));
                      },
                    ),
                    const SettingsForDarkMode(
                      imageAdress: 'assets/Icons/Notfication.svg',
                      settingAdress: 'Notfication',
                    ),
                    const SettingsForDarkMode(
                      imageAdress: 'assets/Icons/DarkMode.svg',
                      settingAdress: 'Dark Mode',
                    ),
                    HealthInformationSettings(
                      imageAdress: 'assets/Icons/changePassword.svg',
                      settingAdress: 'Change Password',
                      iconData: Icons.arrow_forward,
                      onpressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordScreen()));
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
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
