import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/features/gadgets/gadgetscreen.dart';

class Gadget {
  final String gadgetName;
  final int gadgetId;

  Gadget({required this.gadgetName, required this.gadgetId});
}

class GadgetController {
  final List<Gadget> _gadgets = [];

  List<Gadget> get gadgets => _gadgets;

  void addGadget() {
    final newGadget = Gadget(gadgetName: "Google Pixel Watch", gadgetId: 1);
    _gadgets.add(newGadget);
  }
}

class AddGadgetScreen extends StatefulWidget {
  const AddGadgetScreen({super.key});

  @override
  State<AddGadgetScreen> createState() => _AddGadgetScreenState();
}

class _AddGadgetScreenState extends State<AddGadgetScreen> {
  final GadgetController _gadgetController = GadgetController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(screenWidth: size.width, screenHeight: size.height),
            // Gap(size.width * 0.1),
            Container(
              height: size.height * 0.73,
              width: double.infinity,
              color: Colors.transparent,
              child: ListView.builder(
                itemCount: _gadgetController.gadgets.length,
                itemBuilder: (context, index) {
                  return Gadgets(
                    onpressed: () {},
                    gadgetName: _gadgetController.gadgets[index].gadgetName,
                    screenHeight: size.height,
                    screenWidth: size.width,
                    onTap: () {
                      setState(() {
                        _gadgetController.gadgets.removeWhere((element) =>
                            element.gadgetId ==
                            _gadgetController.gadgets[index].gadgetId);
                      });
                    },
                  );
                },
              ),
            ),
            ButtonAdd(
              screenWidth: size.width,
              screenHeight: size.height,
              buttonText: "Add Gadget",
              buttonAction: () {
                setState(() {
                  _gadgetController.addGadget();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Gadgets extends StatelessWidget {
  final VoidCallback? onpressed;

  final String gadgetName;
  final double screenHeight;
  final double screenWidth;
  final VoidCallback onTap;

  const Gadgets({
    super.key,
    required this.onpressed,
    required this.gadgetName,
    required this.screenHeight,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
      child: ListTile(
        leading: Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.04),
          child: SizedBox(
            height: 50,
            width: 41.5,
            child: Image.asset(
              "assets/images/watch.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        contentPadding: EdgeInsets.zero,
        title: Text(
          gadgetName,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
          ),
        ),
        horizontalTitleGap: 5,
        trailing: GestureDetector(
          onTap: onTap,
          child: SvgPicture.asset('assets/Icons/xmark.svg'),
        ),
        onTap: onpressed,
      ),
    );
  }
}

class ButtonAdd extends StatelessWidget {
  final String buttonText;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback? buttonAction;
  const ButtonAdd({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.buttonText,
    this.buttonAction,
  });

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
        ),
      ),
    );
  }
}
