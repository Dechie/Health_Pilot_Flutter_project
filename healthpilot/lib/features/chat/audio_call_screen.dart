import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthpilot/features/chat/vidoe_call_screen.dart';

import '../../data/constants.dart';
import 'chat_screen.dart';

class AudioCallScreen extends StatelessWidget {
  final String id;
  const AudioCallScreen({super.key, required this.id});
  Widget customButton(String svgPicture, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: const CircleBorder(),
        padding: EdgeInsets.all(15),
        backgroundColor: Color.fromRGBO(110, 182, 255, 1),
      ),
      onPressed: onPressed,
      child: SvgPicture.asset(
        svgPicture,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Users.findById(id);
    return Scaffold(
      // appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Expanded(
            child: Image.asset(
              audioCallBackImg,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: size.height * 0.1,
              ),
              Text(
                user.displayName,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
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
                'Voice Call',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: size.height * 0.55,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    customButton(videoCallIcon, () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => VideoCallScreen(id: id)));
                    }),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: const Color.fromRGBO(252, 34, 34, 1),
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
                    }),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
