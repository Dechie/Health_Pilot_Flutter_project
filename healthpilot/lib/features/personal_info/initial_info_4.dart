import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/core/navigation/app_navigation.dart';

class InitialInfoFinal extends StatefulWidget {
  const InitialInfoFinal({super.key});

  @override
  State<InitialInfoFinal> createState() => _InitialInfoFinal();
}

class _InitialInfoFinal extends State<InitialInfoFinal> {
  final PageController _pageController = PageController();

  // static Size size = const Size(0, 0);
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 43.0,
          ).copyWith(top: 70),
          child: SvgPicture.asset(doctor),
        ),
        SizedBox(
          height: size.height * 0.05,
        ),
        SizedBox(
          width: size.width * 0.79,
          child: const Text(
            initialInfoFinalTextTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: Colors.black),
          ),
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
        SizedBox(
          width: size.width * 1,
          child: const Text(
            initialInfoFinalTextDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Color.fromRGBO(41, 41, 41, 0.5)),
          ),
        ),
        SizedBox(
          height: size.height * 0.03,
        ),
        GestureDetector(
          onTap: () {
            AppNavigation.replaceWithHome(context);
          },
          child: Container(
            alignment: Alignment.center,
            width: 231,
            height: 50,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(110, 182, 255, 1),
              borderRadius: BorderRadius.all(
                Radius.elliptical(10, 10),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromRGBO(255, 255, 255, 1)),
            ),
          ),
        ),
      ]),
    ));
  }
}
