import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionBubble extends StatelessWidget {
  final String title;
  final String body;
  const QuestionBubble({super.key, required this.title, required this.body,});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            body,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
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
    );
  }
}
