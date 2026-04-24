import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/chat/chat_screen.dart';
import 'package:healthpilot/features/chat/public_profile_screen.dart';

void _showCommunityFloatingSnackBar(
  BuildContext context, {
  required Color backgroundColor,
  required IconData icon,
  required String message,
}) {
  final size = MediaQuery.of(context).size;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(
        bottom: size.height * 0.15,
        left: size.width * 0.07,
        right: size.width * 0.07,
      ),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 15,
          ),
          SizedBox(
            width: size.width * 0.03,
          ),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class SimilarPeopleScreen extends StatelessWidget {
  const SimilarPeopleScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leadingWidth: double.infinity,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Components.customeAppBar(
                Icons.arrow_back, 'Similar People', context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IconButton(
                tooltip: 'Translate',
                onPressed: () {
                  _showCommunityFloatingSnackBar(
                    context,
                    backgroundColor: const Color.fromRGBO(252, 34, 34, 1),
                    icon: Icons.translate_outlined,
                    message:
                        'Translation unavailable. Please try again later.',
                  );
                },
                icon: SvgPicture.asset(translateIcon),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                Components.headerText('Connect with people like you'),
                const PeopleLikeYouCard(
                  userName: 'Amanda Haller,28',
                  disease: 'Suffers from Schizophrenia ',
                  photoUrl: devsImage,
                  description:
                      'I am Amanda Haller, I am a 28 year old Barista  living in  Dublin, Ireland.  I was diagnosed with Schizophrenia at the age of 21. Living gracefully and peacefully. Ready to share your experience?',
                  persentOfMatch: 98,
                ),
                SizedBox(
                  height: size.height * 0.07,
                ),
                CustomeButton(
                    titleOfButton: 'Update Public Profile',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PublicProfileScreen()));
                    }),
              ],
            ),
          ),
        ));
  }
}

class PeopleLikeYouCard extends StatelessWidget {
  final String userName;
  final String photoUrl;
  final String disease;
  final double persentOfMatch;
  final String description;

  const PeopleLikeYouCard(
      {super.key,
      required this.userName,
      required this.photoUrl,
      required this.disease,
      required this.persentOfMatch,
      required this.description});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.05),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: size.height * 0.58,
            width: size.width * 0.5,
            // color: Colors.amber,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0.00),
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0.00),
                    Color.fromRGBO(110, 182, 255, 0.00),
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0.04),
                    Color.fromRGBO(110, 182, 255, 0.04),
                    Color.fromRGBO(110, 182, 255, 0.04),
                    Color.fromRGBO(110, 182, 255, 0.00),
                    Color.fromRGBO(110, 182, 255, 0.00),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )),
          ),
          Container(
            width: size.width * 0.72,
            height: size.height * 0.54,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0),
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0.08),
                    Color.fromRGBO(110, 182, 255, 0.06),
                    Color.fromRGBO(110, 182, 255, 0.0),
                    Color.fromRGBO(110, 182, 255, 0.0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )),
          ),
          Container(
            width: size.width * 0.85,
            height: size.height * 0.5,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(110, 182, 255, 0.6),
                  Color.fromRGBO(110, 182, 255, 0.5),
                  Color.fromRGBO(110, 182, 255, 0.4),
                  Color.fromRGBO(110, 182, 255, 0.3),
                  Color.fromRGBO(110, 182, 255, 0.2),
                  Color.fromRGBO(110, 182, 255, 0.1),
                  Color.fromRGBO(110, 182, 255, 0.05),
                  Color.fromRGBO(110, 182, 255, 0.025),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.28,
                  width: double.infinity,
                  child: Stack(
                    // fit: StackFit.expand,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          child: Image.asset(
                            photoUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: const Alignment(0.05, -0.7),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () {
                                  _showCommunityFloatingSnackBar(
                                    context,
                                    backgroundColor:
                                        const Color.fromRGBO(76, 217, 100, 1),
                                    icon: Icons.how_to_reg_outlined,
                                    message: 'Vote to connect sent.',
                                  );
                                },
                                child: Ink(
                                  width: size.width * 0.36,
                                  height: size.height * 0.03,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: const Color.fromRGBO(
                                        42, 42, 42, 0.65),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Vote to connect',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      disease,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromRGBO(110, 182, 255, 1),
                                    borderRadius: BorderRadius.circular(4)),
                                width: size.width * 0.3,
                                padding: const EdgeInsets.all(3),
                                child: Text(
                                  '$persentOfMatch% Symptoms match',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          description,
                          style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(42, 42, 42, 1),
                              height: 1.08,
                              letterSpacing: -0.17),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircularFloatingButton(
                              svgIcon: closeIcon,
                              onPress: () {
                                _showCommunityFloatingSnackBar(
                                  context,
                                  backgroundColor:
                                      const Color.fromRGBO(120, 120, 120, 1),
                                  icon: Icons.swipe_left_alt_outlined,
                                  message: 'Skipped this suggestion.',
                                );
                              }),
                          RoundedRectFloatingButton(
                            svgIcon: handShakeIcon,
                            onPress: () {
                              _showCommunityFloatingSnackBar(
                                context,
                                backgroundColor:
                                    const Color.fromRGBO(76, 217, 100, 1),
                                icon: Icons.done_rounded,
                                message: 'Connection request sent.',
                              );
                            },
                          ),
                          CircularFloatingButton(
                              svgIcon: chatIcon,
                              onPress: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                          senderId: '5',
                                          userId: '122',
                                        )));
                              }),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircularFloatingButton extends StatelessWidget {
  final String svgIcon;
  final VoidCallback onPress;

  const CircularFloatingButton({
    super.key,
    required this.svgIcon,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: FloatingActionButton(
        splashColor: const Color.fromRGBO(110, 182, 255, 0.5),
        onPressed: onPress,
        backgroundColor: Colors.white,
        elevation: 0,
        child: SvgPicture.asset(
          svgIcon,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class RoundedRectFloatingButton extends StatelessWidget {
  final String svgIcon;
  final VoidCallback onPress;

  const RoundedRectFloatingButton({
    super.key,
    required this.svgIcon,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: FloatingActionButton(
        splashColor: const Color.fromRGBO(110, 182, 255, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        onPressed: onPress,
        backgroundColor: Colors.white,
        elevation: 0,
        child: SvgPicture.asset(
          svgIcon,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class CustomeButton extends StatelessWidget {
  final String titleOfButton;
  final VoidCallback onPressed;
  const CustomeButton(
      {super.key, required this.titleOfButton, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        splashFactory: null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        backgroundColor: const Color.fromRGBO(110, 182, 255, 1),
      ),
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: size.height * 0.06,
        width: size.width * 0.5,
        child: Text(
          titleOfButton,
          style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:healthpilot/widget/custom_app_bar_title.dart';

// import '../../data/constants.dart';
// import 'widgets/custom_update_button.dart';

// class SimilarPeopleScreen extends StatelessWidget {
//   const SimilarPeopleScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size(50, 60),
//         child: CustomAppBar(
//           onPressed: () {},
//           title: 'Similar People',
//           suffixIconImage: appBarTitleImage,
//           leadingIcon: Icons.arrow_back_outlined,
//         ),
//       ),
//       body: SingleChildScrollView(child: _buildBody(context)),
//     ));
//   }

//   Widget _buildBody(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 34),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         _buildHeaderText(),
//         const SizedBox(
//           height: 60,
//         ),
//         _buildImageBannerWithText(),
//         const SizedBox(
//           height: 80,
//         ),
//         Align(
//             child: CustomUpdateButton(
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SimilarPeopleScreen(),
//                       ));
//                 },
//                 title: 'Update Public Profile'))
//       ]),
//     );
//   }

//   Widget _buildHeaderText() {
//     return Text(
//       'Connect with people like you',
//       style: TextStyle(
//           color: const Color.fromRGBO(42, 42, 42, 1),
//           fontFamily: 'Plus Jakarta Sans',
//           fontSize: 16.sp,
//           fontStyle: FontStyle.normal,
//           fontWeight: FontWeight.w600,
//           letterSpacing: -0.165),
//     );
//   }

//   Widget _buildImageBannerWithText() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(colors: [
//           Color.fromRGBO(110, 182, 255, 1),
//           Color.fromRGBO(110, 182, 255, 0.85),
//           Color.fromRGBO(110, 182, 255, 0.25)
//         ]),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                     topRight: Radius.circular(10),
//                     topLeft: Radius.circular(10)),
//                 child: Image.asset(devsImage,
//                     height: 240, width: double.infinity, fit: BoxFit.cover),
//               ),
//               Positioned(
//                 top: 16,
//                 child: _buildWButtonOnBanner(
//                     'Wants to connect', const Color.fromRGBO(42, 42, 42, 0.65)),
//               ),
//               Positioned(
//                 bottom: 24,
//                 right: 7,
//                 child: _buildWButtonOnBanner('98% Symptoms match',
//                     const Color.fromRGBO(110, 182, 255, 1)),
//               ),
//               Positioned(
//                 bottom: 34,
//                 left: 11,
//                 child: _buildTextCardOnBanner(
//                   'Amanda Haller,28',
//                   16,
//                 ),
//               ),
//               Positioned(
//                 bottom: 16,
//                 left: 11,
//                 child: _buildTextCardOnBanner(
//                   'Suffers from Schizophrenia ',
//                   12,
//                 ),
//               ),
//             ],
//           ),
//           Padding(
//               padding: const EdgeInsets.fromLTRB(12.0, 15, 12, 15),
//               child: Text(
//                 similarPeopleAbout,
//                 style: TextStyle(
//                     color: const Color.fromRGBO(42, 42, 42, 1),
//                     fontFamily: 'Plus Jakarta Sans',
//                     fontSize: 12.sp,
//                     fontStyle: FontStyle.normal,
//                     fontWeight: FontWeight.w500,
//                     height: 1.8,
//                     letterSpacing: -0.165),
//               )),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 30.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildIconButton(
//                     Icons.close, () {}, const Color.fromRGBO(252, 34, 34, 1)),
//                 _buildIconButton(Icons.handshake_outlined, () {},
//                     const Color.fromRGBO(110, 182, 255, 1)),
//                 _buildIconButton(Icons.messenger_outline, () {},
//                     const Color.fromRGBO(76, 217, 100, 1)),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildIconButton(
//       IconData icon, VoidCallback onPressed, Color iconColor) {
//     return CircleAvatar(
//       radius: 30,
//       backgroundColor: Colors.white,
//       child: IconButton(
//           onPressed: onPressed,
//           icon: Icon(
//             icon,
//             color: iconColor,
//           )),
//     );
//   }

//   Widget _buildWButtonOnBanner(String title, Color color) {
//     return TextButton(
//         onPressed: () {},
//         style: TextButton.styleFrom(
//           minimumSize: const Size(109, 19),
//           foregroundColor: Colors.transparent,
//           backgroundColor: color,
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//               color: Colors.white,
//               fontFamily: ' Plus Jakarta Sans',
//               fontSize: 12.sp,
//               fontStyle: FontStyle.normal,
//               fontWeight: FontWeight.w500,
//               letterSpacing: -0.165),
//         ));
//   }

//   Widget _buildTextCardOnBanner(String text, int fontSize) {
//     return Text(
//       text,
//       style: TextStyle(
//           color: Colors.white,
//           fontFamily: 'Plus Jakarta Sans',
//           fontSize: fontSize.sp,
//           fontStyle: FontStyle.normal,
//           fontWeight: FontWeight.w600,
//           letterSpacing: -0.165),
//     );
//   }
// }
