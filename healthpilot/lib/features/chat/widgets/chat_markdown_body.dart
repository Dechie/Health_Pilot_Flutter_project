import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:healthpilot/features/chat/services/chat_markdown_service.dart';

/// Renders chat message text as markdown (bold, lists, paragraphs).
class ChatMarkdownBody extends StatelessWidget {
  const ChatMarkdownBody({
    super.key,
    required this.rawText,
    required this.textColor,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w400,
  });

  final String rawText;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final markdown = ChatMarkdownService.instance.normalize(rawText);
    if (markdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return MarkdownBody(
      data: markdown,
      shrinkWrap: true,
      softLineBreak: true,
      listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
      styleSheet: ChatMarkdownService.instance.styleSheet(
        textColor: textColor,
        fontSize: fontSize,
        bodyWeight: fontWeight,
      ),
    );
  }
}
