// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/features/health/health_profile_screen.dart';
import 'package:healthpilot/features/medication/medications_screen.dart';
import 'package:healthpilot/features/onboarding/signup_and_login_screen.dart';
import 'package:healthpilot/features/profile/allergies_screen.dart';
import 'package:healthpilot/features/profile/profile_provider.dart';
import 'package:healthpilot/features/profile/settings_screen.dart';
import 'package:healthpilot/features/profile/widgets/profile_settings_shared.dart';
import 'package:provider/provider.dart';

/// Profile tab entry: identity + health information. Settings live in [SettingsScreen].
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool _isPremium = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!context.read<AuthState>().isGuest) {
      context.read<ProfileProvider>().load();
    }
  }

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
                              Builder(builder: (context) {
                                final auth = context.watch<AuthState>();
                                if (auth.isGuest) {
                                  return Text(
                                    'Guest',
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
                                  );
                                }
                                final profileP = context.watch<ProfileProvider>();
                                final isLoading = FeatureFlags.userProfile &&
                                    (profileP.status == ProfileLoadStatus.idle ||
                                     profileP.status == ProfileLoadStatus.loading);
                                if (isLoading) {
                                  return const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                }
                                final name = FeatureFlags.userProfile
                                    ? profileP.profile.displayName ?? 'Profile'
                                    : auth.fullName.isEmpty
                                        ? 'Profile'
                                        : auth.fullName;
                                return Text(
                                  name,
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
                                );
                              }),
                              const SizedBox(height: 10),
                              _isPremium
                                  ? const GradientButton(title: 'premium')
                                  : const GradientButton(title: 'Free'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (!context.watch<AuthState>().isGuest)
                          const ProfileEditButton(),
                      ],
                    ),
                  ),
                  const SettingsTitle(title: 'Health Information'),
                  Builder(builder: (context) {
                    if (context.watch<AuthState>().isGuest) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                            SignupAndLoginScreen.routeName, (_) => false),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.lock_outline,
                                    size: 32,
                                    color: Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to view your health information',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Create an account to track medications, allergies, and more.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Sign up →',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          HealthInformationSettings(
                            imageAdress: 'assets/Icons/HealthBackground.svg',
                            settingAdress: 'Health Background',
                            iconData: Icons.arrow_forward,
                            onpressed: () {
                              Navigator.of(context).push(MaterialPageRoute<void>(
                                  builder: (context) =>
                                      HealthProfile()));
                            },
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
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
