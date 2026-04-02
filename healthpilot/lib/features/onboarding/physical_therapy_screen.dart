import 'package:flutter/material.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/get_started/get_started_screen.dart';
import 'package:healthpilot/features/onboarding/signup_and_login_screen.dart';
import 'package:healthpilot/theme/app_theme.dart';

class PhysicalTherapyScreen extends StatefulWidget {
  const PhysicalTherapyScreen({super.key});

  @override
  State<PhysicalTherapyScreen> createState() => _PhysicalTherapyScreenState();
}

class _PhysicalTherapyScreenState extends State<PhysicalTherapyScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
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

  List pages = [
    Builder(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 43.0,
            ).copyWith(top: 70),
            child: const Image(
              image: AssetImage(physicalTherapy),
            ),
          ),
          SizedBox(
            height: size.height * 0.052,
          ),
          SizedBox(
            width: size.width * 0.705,
            height: size.height * 0.072,
            child: const Text(descriptionTextForSpecialist,
                textAlign: TextAlign.center,
                style: AppTheme.descriptionTextForSpecialistStyle),
          ),
          SizedBox(
            height: size.height * 0.026,
          ),
          SizedBox(
            width: size.width * 0.705,
            height: size.height * 0.072,
            child: const Text(helperTextForUser,
                textAlign: TextAlign.center,
                style: AppTheme.helperTextForUserStyle),
          ),
          SizedBox(
            height: size.height * 0.026,
          ),
        ],
      );
    }),
// page two

    Builder(builder: (context) {
      final size = MediaQuery.of(context).size;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 43.0,
            ).copyWith(top: 70),
            child: Image(
              height: size.height * 0.412,
              image: const AssetImage(
                professionalHealthTeam,
              ),
            ),
          ),
          SizedBox(
            height: size.height * 0.052,
          ),
          SizedBox(
            width: size.width * 0.705,
            height: size.height * 0.072,
            child: const Text(expertAssistance,
                textAlign: TextAlign.center,
                style: AppTheme.descriptionTextForSpecialistStyle),
          ),
          SizedBox(
            height: size.height * 0.026,
          ),
          SizedBox(
            width: size.width * 0.705,
            height: size.height * 0.072,
            child: const Text(expertAssistanceDescription,
                textAlign: TextAlign.center,
                style: AppTheme.helperTextForUserStyle),
          ),
          SizedBox(
            height: size.height * 0.026,
          ),
        ],
      );
    }),

    //Third page
    Builder(builder: (context) {
      final size = MediaQuery.of(context).size;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 43.0,
            ).copyWith(top: 70),
            child: Image(
              height: size.height * 0.367,
              image: const AssetImage(chatBotImage),
            ),
          ),
          SizedBox(
            height: size.height * 0.052,
          ),
          SizedBox(
            width: size.width * 0.79,
            height: size.height * 0.103,
            child: const Text(chatBotText,
                textAlign: TextAlign.center,
                style: AppTheme.descriptionTextForSpecialistStyle),
          ),
          SizedBox(
            height: size.height * 0.026,
          ),
          SizedBox(
            width: size.width * 0.79,
            height: size.height * 0.0903,
            child: const Text(chatBotDescription,
                textAlign: TextAlign.center,
                style: AppTheme.helperTextForUserStyle),
          ),
          SizedBox(
            height: size.height * 0.026,
          ),
        ],
      );
    })
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   centerTitle: true,
        //   title: const Text('Health Pilot'),
        // ),
        body: PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Column(children: [
                pages[index],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int i = 0; i < pages.length; i++)
                      Container(
                        width: _currentPage == i
                            ? size.width * 0.07
                            : size.width * 0.024,
                        height: size.height * 0.0118,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          // shape: BoxShape.circle,
                          borderRadius:
                              const BorderRadius.all(Radius.elliptical(50, 50)),
                          color: _currentPage == i
                              ? const Color.fromRGBO(110, 182, 255, 1)
                              : const Color.fromRGBO(110, 182, 255, 0.25),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.054,
                ),
                GestureDetector(
                  onTap: () {
                    if (_currentPage < pages.length) {
                      setState(() {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      });
                    }
                    if (_currentPage == pages.length - 1) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GetStartedScreen(),
                          ));
                      // setState(() {
                      //   _pageController.previousPage(
                      //     duration: const Duration(milliseconds: 300),
                      //     curve: Curves.easeOut,
                      //   );
                      // });

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SignupAndLoginScreen(),
                      ));
                    }
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
                    child: Text(
                      _currentPage == pages.length - 1
                          ? 'Let\'s start'
                          : 'Next',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color.fromRGBO(255, 255, 255, 1)),
                    ),
                  ),
                ),
              ]);
            }),
      ),
    );
  }
}
