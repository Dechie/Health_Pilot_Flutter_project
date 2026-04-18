// This is the screen where the user sees the detail of the article

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'article_comment_screen.dart';

class ArticleDetail extends StatelessWidget {
  const ArticleDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> detail = ModalRoute.of(context)!
        .settings
        .arguments as List<Map<String, dynamic>>;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final screenWidth = size.width;
          final screenHeight = size.height;

          return SingleChildScrollView(
            child: Column(
              children: [
           
                  Container(
                      width: double.infinity,
                      height: screenHeight * 0.42,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/old_woman.png'),
                              fit: BoxFit.cover)),
                      child: SafeArea(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomAppBar(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenHeight * 0.04,
                                vertical: screenHeight * 0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail[0]['title'],
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: screenWidth * 0.047,
                                    fontWeight: FontWeight.w600,
                               
                                    letterSpacing:
                                        -0.165, 
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: ColorFiltered(
                                            colorFilter: const ColorFilter.mode(
                                                Colors.white, BlendMode.srcIn),
                                            child: Image.asset(
                                                'assets/Icons/stopwatch .png'),
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.02,
                                        ),
                                        const Text(
                                          '5 min',
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            height: 1.0,
                                            letterSpacing: -0.165,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.1,
                                    ),
                                    Row(
                                      children: [
                                        ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                          child: Image.asset(
                                              'assets/Icons/like.png'),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.02,
                                        ),
                                        const Text(
                                          '25',
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            height: 1.0,
                                            letterSpacing: -0.165,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.1,
                                    ),
                                    Row(
                                      children: [
                                        ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) {
                                                  return ArticleCommentScreen();
                                                },
                                              ));
                                            },
                                            child: Image.asset(
                                                'assets/Icons/comment.png'),
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.02,
                                        ),
                                        const Text(
                                          '12',
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            height: 1.0,
                                            letterSpacing: -0.165,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ))),
                
                SizedBox(
                  height: screenHeight * 0.6,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Column(
                      children: [
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateTime.now().toString(),
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10.0,
                                fontWeight: FontWeight.w500,
                                height: 13.0 /
                                    10.0, 
                                letterSpacing:
                                    -0.165,
                              ),
                            ),
                            const Text(
                              'TeamHealthPilot',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10.0,
                                fontWeight: FontWeight.w500,
                                height: 13.0 /
                                    10.0, 
                                letterSpacing:
                                    -0.165,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Text(
                          detail[1]['detail'],
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

//  thsis is custom appbar used in the above widget tree ..................fully customizable in terms of color,sizeee

class CustomAppBar extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  const CustomAppBar(
      {super.key, required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.04,
            screenHeight * 0.02,
            0,
            0,
          ),
          child: Container(
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(110, 182, 255, 0.7),
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
            ),
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: screenWidth * 0.06,
                ),
                color: const Color.fromARGB(255, 255, 255, 255),
                iconSize: screenWidth * 0.055,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.05,
            screenHeight * 0.03,
            0,
            0,
          ),
          child: Text(
            "Articles",
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              fontFamily: "PlusJakartaSans",
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.04,
            // left: screenWidth * 0.39,
          ),
          child: Container(
            margin: EdgeInsets.only(
              left: screenWidth * 0.48,
            ),
            width: screenWidth * 0.04,
            height: screenWidth * 0.04,
            child: ColorFiltered(
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: SvgPicture.asset(
                'assets/images/Vector.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomIconsStyle extends StatelessWidget {
  final IconData icondata;
  final String text;
  const CustomIconsStyle(
      {super.key, required this.icondata, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icondata,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1.0,
            letterSpacing: -0.165,
          ),
        )
      ],
    );
  }
}
