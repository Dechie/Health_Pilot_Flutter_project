// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/features/forgot_password/forgot_password_flow.dart';
import 'package:healthpilot/core/navigation/app_navigation.dart';
import 'package:healthpilot/features/profile/language_translation.dart';
import 'package:healthpilot/features/profile/terms_and_policy_dialog.dart';
import 'package:healthpilot/features/profile/widgets/premium_feature_dialog.dart';
import 'package:healthpilot/features/profile/widgets/profile_settings_shared.dart';
import 'package:healthpilot/features/subscription/subscription_and_payment_screen.dart';
import 'package:provider/provider.dart';

/// App settings and account-related actions (split from profile for clearer ownership).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    await context.read<AuthState>().logout();
    if (!mounted) return;
    AppNavigation.replaceWithLogin(context);
  }

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
                        AppNavigation.replaceWithHome(
                          context,
                          isHelpPressed: true,
                        );
                      },
                    ),
                    HealthInformationSettings(
                      imageAdress: 'assets/Icons/FAQ.svg',
                      settingAdress: 'FAQ',
                      iconData: Icons.arrow_forward,
                      onpressed: null,
                    ),
                    _loggingOut
                        ? Padding(
                            padding: const EdgeInsets.only(left: 30, right: 40),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: SvgPicture.asset(
                                    'assets/Icons/profile.svg',
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  title: Text(
                                    'Logging out…',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 12,
                                          letterSpacing: -0.2,
                                        ),
                                  ),
                                  horizontalTitleGap: 5,
                                  trailing: const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                                Divider(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.18),
                                  thickness: 0.5,
                                ),
                              ],
                            ),
                          )
                        : HealthInformationSettings(
                            imageAdress: 'assets/Icons/profile.svg',
                            settingAdress: 'Log Out',
                            iconData: Icons.logout,
                            onpressed: _logout,
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
