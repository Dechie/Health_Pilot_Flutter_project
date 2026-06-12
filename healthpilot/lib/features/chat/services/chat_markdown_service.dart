import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';

/// Normalizes API / user message text into consistent markdown for chat bubbles.
class ChatMarkdownService {
  const ChatMarkdownService();

  static const ChatMarkdownService instance = ChatMarkdownService();

  /// Prepares raw message text for [MarkdownBody] rendering.
  String normalize(String raw) {
    if (raw.isEmpty) return raw;

    var text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Common unicode bullets → markdown list markers.
    text = text.replaceAllMapped(
      RegExp(r'^[\u2022\u2023\u25E6\u2043\u00B7]\s*', multiLine: true),
      (_) => '- ',
    );

  // Ensure list blocks are separated from preceding paragraphs (not list items).
    final lines = text.split('\n');
    final normalizedLines = <String>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isListItem = line.startsWith('- ');
      if (i > 0 &&
          isListItem &&
          lines[i - 1].trim().isNotEmpty &&
          !lines[i - 1].startsWith('- ')) {
        normalizedLines.add('');
      }
      normalizedLines.add(line);
    }
    text = normalizedLines.join('\n');

    return text.trim();
  }

  MarkdownStyleSheet styleSheet({
    required Color textColor,
    double fontSize = 13,
    FontWeight bodyWeight = FontWeight.w400,
    FontWeight strongWeight = FontWeight.w600,
  }) {
    final base = GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: bodyWeight,
      color: textColor,
      height: 1.35,
    );

    return MarkdownStyleSheet(
      p: base,
      strong: base.copyWith(fontWeight: strongWeight),
      em: base.copyWith(fontStyle: FontStyle.italic),
      listBullet: base,
      listIndent: 22,
      blockSpacing: 6,
      pPadding: EdgeInsets.zero,
      h1: base.copyWith(fontSize: fontSize + 2, fontWeight: strongWeight),
      h2: base.copyWith(fontSize: fontSize + 1, fontWeight: strongWeight),
      h3: base.copyWith(fontWeight: strongWeight),
    );
  }
}
