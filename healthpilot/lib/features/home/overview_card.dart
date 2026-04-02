import 'package:flutter/material.dart';
import 'package:healthpilot/theme/app_theme.dart';

class OverviewCard extends StatelessWidget {
  final IconData icon;
  final String overviewResult;
  final String overviewUnit;
  const OverviewCard(
      {super.key,
      required this.icon,
      required this.overviewResult,
      required this.overviewUnit});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          height: size.height * 0.08,
          width: size.width * 0.18,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color:
                    const Color.fromRGBO(46, 46, 46, 1.000).withOpacity(0.07),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 0))
          ]),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color:
                      const Color.fromRGBO(46, 46, 46, 1.000).withOpacity(0.1)),
              borderRadius: BorderRadius.circular(size.width * 0.02),
              gradient: AppTheme.cardThemeForHomeScreenOverview.gradient),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * 0.02),
                gradient: AppTheme.cardThemeForHomeScreenOverview.gradient),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: size.width * 0.01, horizontal: size.width * 0.03),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: size.height * 0.004,
                      right: size.height * 0.01,
                    ),
                    child: Icon(
                      icon,
                      size: size.width * 0.06,
                    ),
                  ),
                  Column(children: [
                    Text(
                      overviewResult,
                      style: AppTheme.homePageOverviewResultTextStyle,
                    ),
                    Text(
                      overviewUnit,
                      style: AppTheme.homePageOverviewUnitTextStyle,
                    )
                  ]),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
