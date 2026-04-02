// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/chat/general_chat_screen.dart';

import 'package:healthpilot/features/home/discover_healthpilot.dart';

import 'package:healthpilot/features/health/health_profile_screen.dart';

import 'package:healthpilot/features/onboarding/language_translation.dart';
import 'package:line_icons/line_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:healthpilot/features/chatbot/chatbot_screen.dart';
import 'package:healthpilot/features/onboarding/profile_and_setting_screen.dart';
import 'package:healthpilot/features/home/overview_card.dart';
import 'package:healthpilot/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../data/contants.dart';
import 'ad_widget.dart';
import 'blog_reccomendation._card.dart';

class HomePageScreen extends StatefulWidget {
  final bool isHelpPressed;
  HomePageScreen({super.key, required this.isHelpPressed});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final _pageControllerOfTutorial = PageController();
  var _currentPageOfTutorial = 0;

  @override
  void initState() {
    getTutorStatus();
    isOnHelp = widget.isHelpPressed;
    super.initState();
  }

// _tuturText holds the list of totur which displays only when the app runs for the 1st time :)
  final _tutorText = [
    {
      'title': 'Welcome to health pilot',
      'description':
          'Let’s learn a few things about what health pilot can do for you.'
    },
    {
      'title': 'Did you know? Premium users can have personal doctors',
      'description':
          'By Subscribing to a premium membership you can add your personal doctor'
    },
    {
      'title': 'Add stuff here you want to display',
      'description':
          'Details about the tutorial and things that you want to describe'
    },
    {
      'title': 'Finish setting up you account',
      'description':
          'Finish setting up your account to get full access to all features'
    },
  ];

  final userName = "Mohammed";
  // showAiAlert is true if the screen is only at home page

  bool showAiAlert = true;

  //list of blogs
  final _blogs = [
    [
      womanReading,
      'Read our articles',
      'Get insights on the latest news and tips from our experts.',
      'articles'
    ],
    [
      gynecologyConsultation,
      'Consult our doctors ',
      'Talk to our doctors to get better insight about your health.',
      'consult'
    ],
    [
      womanReading,
      'Read our articles',
      'Get insights on the latest news and tips from our experts.',
      'articles'
    ],
    [
      gynecologyConsultation,
      'Consult our doctors ',
      'Talk to our doctors to get better insight about your health.',
      'consult'
    ],
  ];

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    //for navigation bar
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 0) {
        _showAlertAiBot(context);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  void _showAlertAiBot(BuildContext ctx) {
    final size = MediaQuery.of(ctx).size;
    setState(
      () {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 10),
            padding: const EdgeInsets.all(0),
            content: Container(
                height: size.height * 0.1,
                padding: const EdgeInsets.only(bottom: 12, right: 5, top: 5),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: const Color.fromRGBO(110, 182, 255, 1)),
                          borderRadius:
                              BorderRadius.circular(size.width * 0.04)),
                      padding: EdgeInsets.all(size.height * 0.02),
                      child: const Text(
                          'Hello! Feel free to ask me anything, How can I assist you?',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: AppTheme.floatingActionButtonAlertText),
                    ),
                    Positioned(
                      right: size.width * -0.01,
                      top: size.width * -0.01,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromRGBO(110, 182, 255, 1),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.close,
                              size: size.width * 0.02,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: size.width * -0.09,
                      left: size.width * 0.35,
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: size.width * 0.15,
                        color: const Color.fromRGBO(110, 182, 255, 1),
                      ),
                    ),
                  ],
                )),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                left: size.width * 0.45,
                right: size.width * 0.05,
                bottom: size.height * 0.02),
            elevation: 0,
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    showAiAlert = false;
    super.dispose();
  }

  late SharedPreferences prefs;
  late bool isTutorGiven = false;
  late bool isOnEmeregencyCalling = false;
  late bool isOnHelp = false;

  Future getTutorStatus() async {
    prefs = await SharedPreferences.getInstance();

    isTutorGiven = prefs.getBool('isTutorGiven') ?? false;
  }

  void cancelEmergencyCall() {
    setState(() {
      isOnEmeregencyCalling = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final List<Widget> pages = [
      Column(
        children: [
          SizedBox(
            height: size.height * 0.03,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(left: size.width * 0.06),
                width: size.width * 0.5,
                child: Text(
                  'Hello, $userName',
                  style: AppTheme.homePageUserNameTextStyle,
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: size.width * 0.08),
                width: size.width * 0.2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        splashColor: const Color.fromARGB(100, 0, 0, 0),
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const LanguageTranslation(),
                            )),
                        child: SvgPicture.asset(translateIcon)),
                    InkWell(
                      splashColor: const Color.fromARGB(100, 0, 0, 0),
                      onTap: () => cancelEmergencyCall(),
                      child: SvgPicture.asset(triangleExclamationIcon),
                    ),
                    SvgPicture.asset(bellReminder),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(
                left: size.width * 0.06, top: size.width * 0.06),
            width: double.infinity,
            child: const Text('Overview'),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
            child: const Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OverviewCard(
                      icon: LineIcons.heart,
                      overviewResult: '120',
                      overviewUnit: 'BPM'),
                  OverviewCard(
                      icon: LineIcons.weight,
                      overviewResult: '21.6',
                      overviewUnit: 'BMI'),
                  OverviewCard(
                      icon: LineIcons.bed,
                      overviewResult: '6.5',
                      overviewUnit: 'hours'),
                ]),
          ),
          Container(
            margin: EdgeInsets.only(
                left: size.width * 0.06, top: size.height * 0.04),
            width: double.infinity,
            child: const Text(
              'Feeling unwell? Let us help you get better',
              textAlign: TextAlign.left,
            ),
          ),
          Container(
              margin: EdgeInsets.only(
                left: size.width * 0.06,
              ),
              width: double.infinity,
              child: Row(
                children: [
                  const Text(
                    'Tell us your symptoms',
                    style: AppTheme.helperTextForUserStyle,
                  ),
                  Icon(
                    LineIcons.arrowRight,
                    color: AppTheme.helperTextForUserStyle.color,
                  )
                ],
              )),
          Container(
            margin: EdgeInsets.only(
                left: size.width * 0.06, top: size.height * 0.03),
            width: double.infinity,
            child: const Text('Discover HealthPilot'),
          ),
          const DiscoverHealthpilot(),
          SizedBox(
            height: size.height * 0.02,
          ),
          const AdWidget(),
          SizedBox(
            height: size.height * 0.01,
          ),
          Container(
            margin: EdgeInsets.only(
                left: size.width * 0.06, top: size.height * 0.03),
            width: double.infinity,
            child: const Text('Maintain a healthy lifestyle'),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          SizedBox(
            width: double.infinity,
            height: size.height * 0.35,
            child: ListView.builder(
              itemCount: _blogs.length,
              itemBuilder: (context, index) {
                return BlogRecomendationCard(
                  img: _blogs[index][0],
                  title: _blogs[index][1],
                  description: _blogs[index][2],
                  blogType: _blogs[index][3],
                );
              },
              scrollDirection: Axis.horizontal,
            ),
          )
        ],
      ),
      SingleChildScrollView(
        child: SizedBox(
          height: size.height * 0.9,
          child: const HealthProfile(),
        ),
      ),
      const Center(
        child: Text('Assesment'),
      ),
      SingleChildScrollView(
          child: SizedBox(
              height: size.height * 0.9, child: const GeneralChatScreen())),
      // const Center(
      //   child: Text('chat'),
      // ),
      SingleChildScrollView(
        child: SizedBox(
          height: size.height * 0.9,
          child: const ProfileAndSettingScreen(),
        ),
      ),
    ];

    return FutureBuilder(
      future: getTutorStatus(),
      builder: (context, snapshot) => Stack(
        children: [
          Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor:
                  AppTheme.buttonStyleForFloatingActionBtn.backgroundColor,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              elevation: 30,
              // type: BottomNavigationBarType.shifting,
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    bottomNavBarHomeIcon,
                    color: _currentIndex == 0
                        ? const Color.fromARGB(255, 72, 162, 252)
                        : Colors.grey,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    bottomNavBarHealthIcon,
                    color: _currentIndex == 1
                        ? const Color.fromRGBO(110, 182, 255, 1)
                        : Colors.grey,
                  ),
                  label: 'Health',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    bottomNavBarAssesmentIcon,
                    color: _currentIndex == 2
                        ? const Color.fromRGBO(110, 182, 255, 1)
                        : Colors.grey,
                  ),
                  label: 'Assesment',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    bottomNavBarChatIcon,
                    color: _currentIndex == 3
                        ? const Color.fromRGBO(110, 182, 255, 1)
                        : Colors.grey,
                  ),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    bottomNavBarProfileIcon,
                    color: _currentIndex == 4
                        ? const Color.fromRGBO(110, 182, 255, 1)
                        : Colors.grey,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
            body: SingleChildScrollView(
                child: SafeArea(
              child: pages[_currentIndex],
            )),
            floatingActionButton: _currentIndex == 0
                ? FloatingActionButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ChatbotScreen(),
                        ),
                      );
                    },
                    backgroundColor: AppTheme
                        .buttonStyleForFloatingActionBtn.backgroundColor,
                    foregroundColor: AppTheme
                        .buttonStyleForFloatingActionBtn.foregroundColor,
                    child: const Icon(LineIcons.robot),
                  )
                : null,
          ),
          if (isOnEmeregencyCalling)
            Dialog(
              backgroundColor: Colors.transparent,
              child: SizedBox(
                height: size.height * 0.3,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.03),
                      child: Card(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(triangeExclamationPic),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.02),
                                ),
                                height: size.height * 0.1,
                                width: size.width * 0.9,
                                child: PageView.builder(
                                  controller: _pageControllerOfTutorial,
                                  itemCount: _tutorText.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentPageOfTutorial = index;
                                    });
                                  },
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.all(size.width * 0.02),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Calling your emergency contacts',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: size.height * 0.01,
                                        ),
                                        const Text(
                                          "You have 1 minute to cancel ",
                                          style: TextStyle(
                                              color:
                                                  Color.fromARGB(105, 0, 0, 0),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              SizedBox(
                                width: size.width * 0.2,
                                height: size.height * 0.04,
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * 0.02)),
                                  color: const Color.fromRGBO(110, 182, 255, 1),
                                  onPressed: () {
                                    setState(() {
                                      isOnEmeregencyCalling = false;
                                    });
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!isTutorGiven || isOnHelp)
            Dialog(
              backgroundColor: Colors.transparent,
              child: SizedBox(
                height: size.height * 0.6,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.03),
                      child: Card(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(chatBot),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.02),
                                ),
                                height: size.height * 0.2,
                                width: size.width * 0.9,
                                child: PageView.builder(
                                  controller: _pageControllerOfTutorial,
                                  itemCount: _tutorText.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentPageOfTutorial = index;
                                    });
                                  },
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.all(size.width * 0.02),
                                    child: Column(
                                      children: [
                                        Text(
                                          _tutorText[index]['title']!,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: size.height * 0.02,
                                        ),
                                        Text(
                                          _tutorText[index]['description']!,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              _currentPageOfTutorial < _tutorText.length - 1
                                  ? SizedBox(
                                      width: size.width * 0.2,
                                      height: size.height * 0.04,
                                      child: MaterialButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * 0.02)),
                                        color: const Color.fromRGBO(
                                            110, 182, 255, 1),
                                        onPressed: () {
                                          _currentPageOfTutorial++;
                                          setState(() {
                                            if (_currentPageOfTutorial <
                                                _tutorText.length) {
                                              _pageControllerOfTutorial
                                                  .nextPage(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.bounceIn);
                                            }
                                          });
                                        },
                                        child: const Text(
                                          'Next',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: size.width * 0.3,
                                      height: size.height * 0.04,
                                      child: MaterialButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * 0.02)),
                                        color: const Color.fromRGBO(
                                            110, 182, 255, 1),
                                        onPressed: () {
                                          setState(() {
                                            prefs.setBool('isTutorGiven', true);
                                            isTutorGiven = true;
                                            isOnHelp = false;

                                            _currentIndex = 4;
                                          });
                                        },
                                        child: const Text(
                                          'Finish Setup',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                              SizedBox(
                                width: size.width * 0.2,
                                height: size.height * 0.04,
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * 0.02)),
                                  onPressed: () {
                                    setState(() async {
                                      final prefs =
                                          await SharedPreferences.getInstance();

                                      setState(() {
                                        prefs.setBool('isTutorGiven', true);
                                        isTutorGiven = true;
                                        isOnHelp = false;
                                      });
                                    });
                                  },
                                  child: const Text(
                                    'Skip',
                                    style: TextStyle(
                                      color: Color.fromRGBO(42, 42, 42, 1),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.02,
                              ),
                              SmoothPageIndicator(
                                controller: _pageControllerOfTutorial,
                                count: _tutorText.length,
                                effect: const ExpandingDotsEffect(
                                    activeDotColor:
                                        Color.fromRGBO(110, 182, 255, 1),
                                    dotColor:
                                        Color.fromRGBO(183, 216, 249, 0.839)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
