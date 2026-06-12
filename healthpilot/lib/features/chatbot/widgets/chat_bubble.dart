import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthpilot/features/chat/widgets/chat_markdown_body.dart';
import 'package:healthpilot/theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final String body;
  final String time;

  /// When set (e.g. "Sent" for outgoing), shown instead of [time].
  final String? footerLabel;

  /// Choose BubbleNip.leftBottom (bot) or BubbleNip.rightBottom (user).
  final BubbleNip nipPosition;

  const ChatBubble({
    super.key,
    required this.body,
    required this.time,
    this.footerLabel,
    this.nipPosition = BubbleNip.leftBottom,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    final textColor = isBot
        ? cs.onSurface
        : (isDark ? cs.onPrimary : cs.onSurface);

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
            ChatMarkdownBody(
              rawText: body,
              textColor: textColor,
              fontSize: 13,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                footerLabel ?? time,
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
