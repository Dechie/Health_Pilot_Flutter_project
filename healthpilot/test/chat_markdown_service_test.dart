import 'package:flutter_test/flutter_test.dart';
import 'package:healthpilot/features/chat/services/chat_markdown_service.dart';

void main() {
  const service = ChatMarkdownService();

  group('ChatMarkdownService.normalize', () {
    test('preserves bold and list markdown from AI responses', () {
      const raw = '''**What is it?**
Blood pressure measures the force of blood against artery walls.
- **Top number (systolic)**: Pressure when your heart beats.
- **Bottom number (diastolic)**: Pressure between beats.''';

      final normalized = service.normalize(raw);

      expect(normalized, contains('**What is it?**'));
      expect(normalized, contains('- **Top number (systolic)**:'));
      expect(normalized, contains('- **Bottom number (diastolic)**:'));
    });

    test('converts unicode bullets to markdown dashes', () {
      const raw = '• First item\n• Second item';
      final normalized = service.normalize(raw);

      expect(normalized, '- First item\n- Second item');
    });

    test('inserts blank line before list when glued to paragraph', () {
      const raw = 'Intro line\n- item one';
      final normalized = service.normalize(raw);

      expect(normalized, 'Intro line\n\n- item one');
    });

    test('plain user text passes through unchanged', () {
      const raw = 'Hello, how are you?';
      expect(service.normalize(raw), raw);
    });
  });
}
