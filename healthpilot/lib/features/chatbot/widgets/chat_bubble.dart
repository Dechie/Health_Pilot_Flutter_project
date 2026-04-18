import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final String body;
  final String time;
  ///choose BubbleNip.leftBottom or BubbleNip.rightBottom
  final BubbleNip nipPosition;
  const ChatBubble({
    super.key,
    required this.body,
    required this.time,
    this.nipPosition = BubbleNip.leftBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Bubble(
        radius: Radius.circular(5),
        nip:nipPosition,
        margin: BubbleEdges.all(0),
        padding: BubbleEdges.all(0),
        showNip: true,
        color: nipPosition == BubbleNip.leftBottom ? Color.fromRGBO(110, 182, 255, 0.30) : Color.fromRGBO(110, 182, 255, 0.08),
        shadowColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    body,
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.transparent,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 8, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(colors: [
                    Color.fromRGBO(110, 182, 255, 0.30),
                    Color.fromRGBO(110, 182, 255, 0.26),
                    Color.fromRGBO(110, 182, 255, 0.08),
                  ], stops: [
                    0.17,
                    0.75,
                    1
                  ])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(body,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 8, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
