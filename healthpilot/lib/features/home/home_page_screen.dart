// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/chat/general_chat_screen.dart';

import 'package:healthpilot/features/home/discover_healthpilot.dart';

import 'package:healthpilot/features/health/health_profile_screen.dart';

import 'package:healthpilot/features/health_assessment/assessment_history_screen.dart';
import 'package:healthpilot/features/onboarding/language_translation.dart';
import 'package:line_icons/line_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:healthpilot/features/chatbot/chatbot_screen.dart';
import 'package:healthpilot/features/profile/profile_screen.dart';
import 'package:healthpilot/features/home/overview_card.dart';
import 'package:healthpilot/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../data/contants.dart';
import 'ad_widget.dart';
import 'blog_reccomendation._card.dart';

class HomePageScreen extends StatefulWidget {
  final bool isHelpPressed;
  const HomePageScreen({super.key, required this.isHelpPressed});

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
                          color: Theme.of(ctx).colorScheme.surface,
                          border: Border.all(
                              color: Theme.of(ctx).colorScheme.primary),
                          borderRadius:
                              BorderRadius.circular(size.width * 0.04)),
                      padding: EdgeInsets.all(size.height * 0.02),
                      child: Text(
                          'Hello! Feel free to ask me anything, How can I assist you?',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: AppTheme.snackbarAssistiveText(ctx)),
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
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.close,
                              size: size.width * 0.02,
                              color: Theme.of(context).colorScheme.onPrimary,
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
                        color: Theme.of(context).colorScheme.primary,
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
      SingleChildScrollView(
        child: Column(
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
                    style: AppTheme.userGreeting(context),
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
                                builder: (context) =>
                                    const LanguageTranslation(),
                              )),
                          child: SafeSvgAsset(
                            translateIcon,
                            width: size.width * 0.06,
                            height: size.width * 0.06,
                          )),
                      InkWell(
                        splashColor: const Color.fromARGB(100, 0, 0, 0),
                        onTap: () => cancelEmergencyCall(),
                        child: SafeSvgAsset(
                          triangleExclamationIcon,
                          width: size.width * 0.06,
                          height: size.width * 0.06,
                        ),
                      ),
                      SafeSvgAsset(
                        bellReminder,
                        width: size.width * 0.06,
                        height: size.width * 0.06,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  left: size.width * 0.06, top: size.width * 0.06),
              width: double.infinity,
              child: Text(
                'Overview',
                style: Theme.of(context).textTheme.titleSmall,
              ),
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
              child: Text(
                'Feeling unwell? Let us help you get better',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Container(
                margin: EdgeInsets.only(
                  left: size.width * 0.06,
                ),
                width: double.infinity,
                child: Row(
                  children: [
                    Text(
                      'Tell us your symptoms',
                      style: AppTheme.bodyMuted(context),
                    ),
                    Icon(
                      LineIcons.arrowRight,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  ],
                )),
            Container(
              margin: EdgeInsets.only(
                  left: size.width * 0.06, top: size.height * 0.03),
              width: double.infinity,
              child: Text(
                'Discover HealthPilot',
                style: Theme.of(context).textTheme.titleSmall,
              ),
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
              child: Text(
                'Maintain a healthy lifestyle',
                style: Theme.of(context).textTheme.titleSmall,
              ),
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
      ),
      const HealthProfile(),
      const AssessmentHistoryScreen(),
      const GeneralChatScreen(),
      // const Center(
      //   child: Text('chat'),
      // ),
      const ProfileScreen(),
    ];

    return FutureBuilder(
      future: getTutorStatus(),
      builder: (context, snapshot) => Stack(
        children: [
          Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              selectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.bold),
              elevation: 30,
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    bottomNavBarHomeIcon,
                    colorFilter: ColorFilter.mode(
                      _currentIndex == 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    bottomNavBarHealthIcon,
                    colorFilter: ColorFilter.mode(
                      _currentIndex == 1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Health',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    bottomNavBarAssesmentIcon,
                    colorFilter: ColorFilter.mode(
                      _currentIndex == 2
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Assesment',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    bottomNavBarChatIcon,
                    colorFilter: ColorFilter.mode(
                      _currentIndex == 3
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    bottomNavBarProfileIcon,
                    colorFilter: ColorFilter.mode(
                      _currentIndex == 4
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Profile',
                ),
              ],
            ),
            body: SafeArea(child: pages[_currentIndex]),
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
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimary,
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
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SafeSvgAsset(
                                triangeExclamationPic,
                                height: size.height * 0.08,
                              ),
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
                                  color: Theme.of(context).colorScheme.primary,
                                  onPressed: () {
                                    setState(() {
                                      isOnEmeregencyCalling = false;
                                    });
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
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
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SafeSvgAsset(
                                chatBot,
                                height: size.height * 0.12,
                              ),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                                        child: Text(
                                          'Next',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        onPressed: () {
                                          setState(() {
                                            prefs.setBool('isTutorGiven', true);
                                            isTutorGiven = true;
                                            isOnHelp = false;

                                            _currentIndex = 4;
                                          });
                                        },
                                        child: Text(
                                          'Finish Setup',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
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
                                    SharedPreferences.getInstance().then((prefs) {
                                      prefs.setBool('isTutorGiven', true);
                                      if (!mounted) return;
                                      setState(() {
                                        isTutorGiven = true;
                                        isOnHelp = false;
                                      });
                                    });
                                  },
                                  child: Text(
                                    'Skip',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                effect: ExpandingDotsEffect(
                                    activeDotColor: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    dotColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
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
