import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';

// import '../../data/contants.dart';
import '../../theme/app_theme.dart';

class DevsCard extends StatelessWidget {
  const DevsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color.fromRGBO(110, 182, 255, 0.3),
            Color.fromRGBO(110, 182, 255, 0.15),
            Color.fromRGBO(110, 182, 255, 0.08),
          ]),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size.width * 0.04),
            topRight: Radius.circular(size.width * 0.04),
            bottomLeft: Radius.circular(size.width * 0.015),
            bottomRight: Radius.circular(size.width * 0.015),
          )),
      margin: EdgeInsets.all(size.width * 0.03),
      child: SizedBox(
        height: size.height * 0.5,
        width: size.width * 0.4,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size.width * 0.04),
                  topRight: Radius.circular(size.width * 0.04)),
              child: Image(
                image: const AssetImage(devsImage),
                fit: BoxFit.cover,
                height: size.height * 0.2,
              ),
            ),
            SizedBox(
              height: size.height * 0.015,
            ),
            const Text('John Doe '),
            const Text(
              'Flutter Developer',
              style: AppTheme.helperTextForUserStyle,
            ),
            SizedBox(
              height: size.height * 0.015,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    width: size.height * 0.02,
                    child: SvgPicture.asset(githubLogo),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(linkedinLogo),
                ),
                GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                      width: size.height * 0.02,
                      child: SvgPicture.asset(gmailLogo)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
