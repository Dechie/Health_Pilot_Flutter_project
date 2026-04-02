import 'package:flutter/material.dart';
import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:line_icons/line_icons.dart';

import '../../theme/app_theme.dart';

class DiscoverHealthpilot extends StatelessWidget {
  const DiscoverHealthpilot({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.all(size.width * 0.06),
      child: Stack(
        children: [
          Container(
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
              gradient: AppTheme.homeOverviewGradient(context),
            ),
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(left: size.height * 0.03),
                  width: size.width * 0.55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.02),
                        child: SafeRasterAsset(
                          welcomeLogo,
                          height: size.height * 0.03,
                          fit: BoxFit.contain,
                          alignment: Alignment.topLeft,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Text(
                        'Take a quick tour on what Health Pilot can do to simplify your life.',
                        textAlign: TextAlign.left,
                        style: AppTheme.overviewUnit(context),
                        maxLines: 2,
                      ),
                      Row(
                        children: [
                          Icon(
                            LineIcons.clock,
                            size: size.height * 0.025,
                            color: cs.onSurfaceVariant,
                          ),
                          SizedBox(
                            width: size.width * 0.01,
                            height: size.height * 0.05,
                          ),
                          Text(
                            '3-5 mins',
                            style: AppTheme.bodyMuted(context),
                          )
                        ],
                      ),
                      Row(children: [
                        Text('Let\'s begin',
                            style: AppTheme.overviewUnit(context)),
                        Icon(
                          LineIcons.arrowRight,
                          size: Theme.of(context).textTheme.bodySmall?.fontSize,
                        )
                      ])
                    ],
                  ),
                ),
                SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SafeSvgAsset(
                          dicoverHelthBotSvg,
                          height: size.height * 0.16,
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
