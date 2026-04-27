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
import 'package:healthpilot/features/profile/language_translation.dart';
import 'package:line_icons/line_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:healthpilot/features/chatbot/chatbot_screen.dart';
import 'package:healthpilot/features/profile/profile_screen.dart';
import 'package:healthpilot/features/tutorials/tutorials_entry_screen.dart';
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
  ScaffoldMessengerState? _scaffoldMessenger;
  late final Future<void> _tutorPrefsFuture;

  Timer? _emergencyCountdownTimer;
  int _emergencySecondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _tutorPrefsFuture = getTutorStatus();
    isOnHelp = widget.isHelpPressed;
  }

  /// First-run carousel (no subscription upsell — deferred to Branch D).
  final List<Map<String, String>> _tutorialSlides = [
    {
      'title': 'Welcome to HealthPilot',
      'description':
          'Your home base for wellbeing: see quick vitals on Home, run guided check-ins from Assessments, and use HealthBot for general questions—not emergencies.',
    },
    {
      'title': 'Stay on top of your health',
      'description':
          'Open the Health tab for medications and wellness cards, keep assessments in one place, and use Chat to stay connected with people in your care circle.',
    },
    {
      'title': 'Complete your profile when you are ready',
      'description':
          'Add emergency contacts, personal details, and preferences from Profile. You can return any time from the bottom navigation—no payment required for these basics.',
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
    _scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    _emergencyCountdownTimer?.cancel();
    _pageControllerOfTutorial.dispose();
    _scaffoldMessenger?.removeCurrentSnackBar();
    showAiAlert = false;
    super.dispose();
  }

  late SharedPreferences prefs;
  late bool isTutorGiven = false;
  late bool isOnEmeregencyCalling = false;
  late bool isOnHelp = false;

  Future<void> getTutorStatus() async {
    prefs = await SharedPreferences.getInstance();
    isTutorGiven = prefs.getBool('isTutorGiven') ?? false;
  }

  String _formatEmergencyCountdown() {
    final m = _emergencySecondsRemaining ~/ 60;
    final s = _emergencySecondsRemaining % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _startEmergencyCall() {
    _emergencyCountdownTimer?.cancel();
    setState(() {
      isOnEmeregencyCalling = true;
      _emergencySecondsRemaining = 60;
    });
    _emergencyCountdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (_emergencySecondsRemaining <= 1) {
          _emergencyCountdownTimer?.cancel();
          isOnEmeregencyCalling = false;
        } else {
          _emergencySecondsRemaining--;
        }
      });
    });
  }

  void _cancelEmergencyCall() {
    _emergencyCountdownTimer?.cancel();
    setState(() {
      isOnEmeregencyCalling = false;
    });
  }

  Future<void> _dismissTutorial() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('isTutorGiven', true);
    if (!mounted) {
      return;
    }
    setState(() {
      isTutorGiven = true;
      isOnHelp = false;
    });
  }

  Future<void> _finishTutorialToProfile() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('isTutorGiven', true);
    if (!mounted) {
      return;
    }
    setState(() {
      isTutorGiven = true;
      isOnHelp = false;
      _currentIndex = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;

    final List<Widget> pages = [
      SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.03,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hello, $userName',
                      style: AppTheme.userGreeting(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        splashColor: const Color.fromARGB(100, 0, 0, 0),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LanguageTranslation(),
                          ),
                        ),
                        child: SafeSvgAsset(
                          translateIcon,
                          width: size.width * 0.06,
                          height: size.width * 0.06,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        splashColor: const Color.fromARGB(100, 0, 0, 0),
                        onTap: _startEmergencyCall,
                        child: SafeSvgAsset(
                          triangleExclamationIcon,
                          width: size.width * 0.06,
                          height: size.width * 0.06,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SafeSvgAsset(
                        bellReminder,
                        width: size.width * 0.06,
                        height: size.width * 0.06,
                        color: cs.onSurface,
                      ),
                    ],
                  ),
                ],
              ),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    OverviewCard(
                      icon: LineIcons.heart,
                      overviewResult: '120',
                      overviewUnit: 'BPM',
                    ),
                    SizedBox(width: 12),
                    OverviewCard(
                      icon: LineIcons.weight,
                      overviewResult: '21.6',
                      overviewUnit: 'BMI',
                    ),
                    SizedBox(width: 12),
                    OverviewCard(
                      icon: LineIcons.bed,
                      overviewResult: '6.5',
                      overviewUnit: 'hours',
                    ),
                  ],
                ),
              ),
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
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      'Tell us your symptoms',
                      style: AppTheme.bodyMuted(context),
                    ),
                    Icon(
                      LineIcons.arrowRight,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(
                    Icons.menu_book_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Guides & tutorials'),
                  subtitle: const Text('Learn how to use Health Pilot'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const TutorialsEntryScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
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

    return FutureBuilder<void>(
      future: _tutorPrefsFuture,
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
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.06,
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Calling your emergency contacts',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: size.height * 0.015),
                                    Text(
                                      'Connecting in ${_formatEmergencyCountdown()}',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: size.height * 0.01),
                                    Text(
                                      'This is a demo flow—no real call is placed. Tap Cancel to stop the countdown.',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.65),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        height: 1.3,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
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
                                  onPressed: _cancelEmergencyCall,
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
                                  itemCount: _tutorialSlides.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentPageOfTutorial = index;
                                    });
                                  },
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.all(size.width * 0.02),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Text(
                                            _tutorialSlides[index]['title']!,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                            height: size.height * 0.015,
                                          ),
                                          Text(
                                            _tutorialSlides[index]
                                                ['description']!,
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
                              ),
                              if (_currentPageOfTutorial <
                                  _tutorialSlides.length - 1)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.04,
                                  ),
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 12,
                                    runSpacing: 6,
                                    children: [
                                      SizedBox(
                                        width: size.width * 0.28,
                                        height: size.height * 0.044,
                                        child: MaterialButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              size.width * 0.02,
                                            ),
                                          ),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          onPressed: () {
                                            _pageControllerOfTutorial.nextPage(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeOutCubic,
                                            );
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
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _dismissTutorial,
                                        child: const Text('Setup later'),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.04,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: size.height * 0.044,
                                          child: FilledButton(
                                            onPressed: _finishTutorialToProfile,
                                            child: const Text('Finish setup'),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SizedBox(
                                          height: size.height * 0.044,
                                          child: OutlinedButton(
                                            onPressed: _dismissTutorial,
                                            child: const Text('Setup later'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: size.height * 0.02,
                              ),
                              SmoothPageIndicator(
                                controller: _pageControllerOfTutorial,
                                count: _tutorialSlides.length,
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
