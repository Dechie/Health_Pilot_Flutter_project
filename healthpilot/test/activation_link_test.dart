import 'package:flutter_test/flutter_test.dart';
import 'package:healthpilot/core/auth/activation_link.dart';

void main() {
  group('ActivationLink.parseToken', () {
    test('reads token from email activation query string', () {
      final uri = Uri.parse(
        'https://pulsminds-healthpilot.chickenkiller.com/api/v1/auth/activate/?token=11111111-2222-3333-4444-555555555555',
      );
      expect(
        ActivationLink.parseToken(uri),
        '11111111-2222-3333-4444-555555555555',
      );
    });

    test('returns null for unrelated URLs', () {
      expect(
        ActivationLink.parseToken(Uri.parse('https://example.com/')),
        isNull,
      );
    });
  });

  group('ActivationLink.isVerified', () {
    test('returns true for valid verified URL', () {
      final uri = Uri.parse('https://healthpilot.com/open-app?verified=true');
      expect(ActivationLink.isVerified(uri), isTrue);
    });

    test('returns false for wrong domain', () {
      final uri = Uri.parse('https://evil.com/open-app?verified=true');
      expect(ActivationLink.isVerified(uri), isFalse);
    });

    test('returns false for wrong path', () {
      final uri = Uri.parse('https://healthpilot.com/other?verified=true');
      expect(ActivationLink.isVerified(uri), isFalse);
    });

    test('returns false when verified param is missing', () {
      final uri = Uri.parse('https://healthpilot.com/open-app');
      expect(ActivationLink.isVerified(uri), isFalse);
    });

    test('returns false when verified param is not true', () {
      final uri = Uri.parse('https://healthpilot.com/open-app?verified=no');
      expect(ActivationLink.isVerified(uri), isFalse);
    });

    test('returns false for unrelated URL', () {
      final uri = Uri.parse('https://example.com/page');
      expect(ActivationLink.isVerified(uri), isFalse);
    });
  });
}
