import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthpilot/features/chat/audio_call_screen.dart';
import 'package:healthpilot/features/chat/similar_people_screen.dart';

import '../../data/constants.dart';
import 'chat_screen.dart';

class videoCallScreen extends StatefulWidget {
  final String id;
  const videoCallScreen({super.key, required this.id});

  @override
  State<videoCallScreen> createState() => _videoCallScreenState();
}

class _videoCallScreenState extends State<videoCallScreen> {
  bool isCameraOpened = false;
  bool isFullScreen = false;
  void openCamera() {
    setState(() {
      isCameraOpened = !isCameraOpened;
    });
  }

  Widget customButton(String svgPicture, VoidCallback onPressed, Color color,
      EdgeInsets padding) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: SvgPicture.asset(
          svgPicture,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Users.findById(widget.id);
    return Scaffold(
      // appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Expanded(
            child: Image.asset(
              videoCallBackImg,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: size.height * 0.1,
              ),
              SizedBox(
                width: size.width * 0.6,
                child: Row(
                  children: [
                    Text(
                      user.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: openCamera,
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Text(
                '02:51',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Text(
                'Video Call',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: size.height * 0.53,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    customButton(voiceIcon, () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) =>
                              AudioCallScreen(id: user.userId)));
                    }, const Color.fromRGBO(110, 182, 255, 1),
                        EdgeInsets.all(20)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                        backgroundColor: Color.fromRGBO(252, 34, 34, 1),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                      ),
                    ),
                    customButton(profileChatIcon, () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatScreen(
                                senderId: user.userId,
                                userId: '123',
                              )));
                    }, const Color.fromRGBO(110, 182, 255, 1),
                        EdgeInsets.all(17)),
                  ],
                ),
              )
            ],
          ),
          if (isCameraOpened)
            Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                height: size.height * 0.3,
                child: Image.asset(
                  videoCallerBackImg,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (isCameraOpened)
            Positioned(
              top: size.height * 0.25,
              right: 0,
              child: SizedBox(
                width: size.width * 0.38,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customButton(cameraRotateIcon, () {}, Colors.transparent,
                        EdgeInsets.zero),
                    SizedBox(
                      width: size.width * 0.2,
                    ),
                    customButton(
                        expandIcon, () {}, Colors.transparent, EdgeInsets.zero),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
