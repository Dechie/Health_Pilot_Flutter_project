import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
import 'package:healthpilot/features/gadgets/addgadgetScreen.dart';

class GadgetScreen extends StatelessWidget {
  const GadgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          CustomAppBar(screenWidth: size.width, screenHeight: size.height),
          // Gap(size.width * 0.2),
          WatchImage(screenWidth: size.width, screenHeight: size.height),
          // Gap(size.width * 0.05),
          const Text1(),
          // Gap(size.width * 0.05),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
            child: const Text2(),
          ),
          // Gap(size.width * 0.3),
          Button(
            screenWidth: size.width,
            screenHeight: size.height,
            buttonText: "Start Setting Up",
            buttonAction: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddGadgetScreen(),
                  ));
            },
          )
        ],
      )),
    );
  }
}

class Gap {}

class CustomAppBar extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  const CustomAppBar(
      {super.key, required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.04,
            screenHeight * 0.02,
            0,
            0,
          ),
          child: Container(
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(110, 182, 255, 0.7),
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
            ),
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: screenWidth * 0.06,
                ),
                color: const Color.fromARGB(255, 255, 255, 255),
                iconSize: screenWidth * 0.055,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.05,
            screenHeight * 0.03,
            0,
            0,
          ),
          child: Text(
            "Gadgets",
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              fontFamily: "PlusJakartaSans",
            ),
          ),
        ),
      ],
    );
  }
}

class WatchImage extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  const WatchImage(
      {super.key, required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth * 0.7,
      height: screenHeight * 0.4,
      child: Image.asset(
        "assets/images/watch.png",
        fit: BoxFit.cover,
      ),
    );
  }
}

class Text1 extends StatelessWidget {
  const Text1({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Turn On Your Device",
      style: TextStyle(
        color: Color.fromRGBO(42, 42, 42, 1),
        fontFamily: "PlusJakartaSans",
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    );
  }
}

class Text2 extends StatelessWidget {
  const Text2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Make sure your device has Bluetooth turned on so we can find your device",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromRGBO(42, 42, 42, 1),
        fontFamily: "PlusJakartaSans",
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
    );
  }
}

class Button extends StatelessWidget {
  final String buttonText;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback? buttonAction;
  const Button(
      {Key? key,
      required this.screenWidth,
      required this.screenHeight,
      // ignore: non_constant_identifier_names
      required this.buttonText,
      this.buttonAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: buttonAction,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: screenWidth * 0.48, // 23.1% of screen width
            height: screenHeight * 0.063, // 5% of screen height
            decoration: const BoxDecoration(
              color: Color.fromRGBO(110, 182, 255, 1),
            ), // Adjust the width as needed
            child: Center(
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "PlusJakartaSans",
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.16,
                ),
              ),
            ),
          )),
    );
  }
}
