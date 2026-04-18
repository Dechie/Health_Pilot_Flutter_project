// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/core/providers/app_state.dart';
import 'package:healthpilot/features/onboarding/personal_information_screen.dart';
import 'package:provider/provider.dart';

class GradientButton extends StatelessWidget {
  final String title;
  const GradientButton({super.key, required this.title});

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
          ),
          child: Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'PlusJakartaSans',
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

class ProfileEditButton extends StatelessWidget {
  const ProfileEditButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
          width: 74,
          height: 30,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(10, 182, 255, 0.2),
          ),
          child: Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PersonalInformationScreen()));
              },
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: Color.fromRGBO(110, 182, 255, 1),
                  fontFamily: 'PlusJakartaSans',
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
        style: const TextStyle(
          color: Color.fromRGBO(42, 42, 42, 1),
          fontFamily: 'PlusJakartaSans',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.25,
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

  @override
  void initState() {
    super.initState();
    if (widget.settingAdress == 'Dark Mode') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final mode = context.read<AppState>().themeMode;
        setState(() {
          _isInnerContainerSwitched = mode == ThemeMode.dark;
        });
      });
    }
  }

  void _toggleInnerContainer() {
    setState(() {
      _isInnerContainerSwitched = !_isInnerContainerSwitched;
    });
    if (widget.settingAdress == 'Dark Mode') {
      context.read<AppState>().setThemeMode(
            _isInnerContainerSwitched ? ThemeMode.dark : ThemeMode.light,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
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
                    color: primary,
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
                        color: primary,
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
