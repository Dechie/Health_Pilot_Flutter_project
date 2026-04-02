import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:line_icons/line_icons.dart';

import '../../theme/app_theme.dart';

class DiscoverHealthpilot extends StatelessWidget {
  const DiscoverHealthpilot({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.all(size.width * 0.06),
      child: Stack(
        children: [
          Container(
            // color: Colors.amber,
            width: size.width * 0.9,
            height: size.height * 0.2,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                blurRadius: 35,
                spreadRadius: 0,
                color:
                    const Color.fromRGBO(46, 46, 46, 1.000).withOpacity(0.07),
              )
            ]),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * 0.02),
                gradient: AppTheme.cardThemeForHomeScreenOverview.gradient),
            child: Stack(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Container(
                  margin: EdgeInsets.only(left: size.height * 0.03),
                  width: size.width * 0.55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.02),
                        child: Image(
                          image: const AssetImage(welcomeLogo),
                          height: size.height * 0.03,
                          alignment: Alignment.topLeft,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      const Text(
                        'Take a quick tour on what Health Pilot can do to simplify your life.',
                        textAlign: TextAlign.left,
                        style: AppTheme.homePageOverviewUnitTextStyle,
                        maxLines: 2,
                      ),
                      Row(
                        children: [
                          Icon(
                            LineIcons.clock,
                            size: size.height * 0.025,
                            color: AppTheme.helperTextForUserStyle.color,
                          ),
                          SizedBox(
                            width: size.width * 0.01,
                            height: size.height * 0.05,
                          ),
                          const Text(
                            '3-5 mins',
                            style: AppTheme.helperTextForUserStyle,
                          )
                        ],
                      ),
                      Row(children: [
                        const Text('Let\'s begin',
                            style: AppTheme.homePageOverviewUnitTextStyle),
                        Icon(
                          LineIcons.arrowRight,
                          size: AppTheme.homePageOverviewUnitTextStyle.fontSize,
                        )
                      ])
                    ],
                  ),
                ),
                SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [SvgPicture.asset(dicoverHelthBotSvg)],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
