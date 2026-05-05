import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthpilot/theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final String body;
  final String time;
  /// Choose BubbleNip.leftBottom (bot) or BubbleNip.rightBottom (user).
  final BubbleNip nipPosition;

  const ChatBubble({
    super.key,
    required this.body,
    required this.time,
    this.nipPosition = BubbleNip.leftBottom,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isBot = nipPosition == BubbleNip.leftBottom;

    final decoration = isBot
        ? BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          )
        : BoxDecoration(
            gradient: AppTheme.chatBubbleGradient(context),
            borderRadius: BorderRadius.circular(10),
          );

    final textColor = isBot ? cs.onSurface : cs.onPrimary;

    return Bubble(
      radius: const Radius.circular(10),
      nip: nipPosition,
      margin: const BubbleEdges.symmetric(vertical: 5),
      padding: const BubbleEdges.all(0),
      showNip: true,
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: decoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: textColor.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
