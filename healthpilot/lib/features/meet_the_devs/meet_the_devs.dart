import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/features/meet_the_devs/devs_card.dart';

import '../../theme/app_theme.dart';

class MeetTheDevs extends StatelessWidget {
  const MeetTheDevs({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, size.height * 0.12),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 30,
              bottom: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: size.width * 0.1,
                      height: size.width * 0.1,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(110, 182, 255, 0.25),
                        borderRadius: BorderRadius.circular(size.width * 0.05),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: const Color.fromRGBO(110, 182, 255, 1),
                        iconSize: size.width * 0.055,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        size.width * 0.05,
                        0,
                        0,
                        0,
                      ),
                      child: Text(
                        "Meet The Developers",
                        style: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.w600,
                          fontFamily: "PlusJakartaSans",
                        ),
                      ),
                    ),
                  ],
                ),
                SvgPicture.asset(
                  'assets/images/Vector.svg',
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisExtent: size.height * 0.35),
            itemBuilder: (context, index) => const DevsCard(),
            itemCount: 10, // itemCount: 10,for test added
          ),
        ));
  }
}
