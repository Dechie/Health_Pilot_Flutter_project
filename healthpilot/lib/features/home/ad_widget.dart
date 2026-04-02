import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theme/app_theme.dart';

class AdWidget extends StatefulWidget {
  const AdWidget({super.key});

  @override
  State<AdWidget> createState() => _AdWidgetState();
}

class _AdWidgetState extends State<AdWidget> {
  // const AdWidget({super.key});
  final _pageController = PageController();

  int _currentPage = 0;
  List<String> ads = [
    'Place Ad one Here',
    'Place Ad two Here',
    'Place Ad three Here',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height * 0.2,
      decoration: AppTheme.cardThemeForHomeScreenOverview,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: ads.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) => GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      ads[_currentPage],
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: const Alignment(0, 0.75),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: ads.length,
              effect: const ExpandingDotsEffect(
                  activeDotColor: Color.fromRGBO(110, 182, 255, 1),
                  dotColor: Color.fromRGBO(183, 216, 249, 0.839)),
            ),
          )
        ],
      ),
    );
  }
}
