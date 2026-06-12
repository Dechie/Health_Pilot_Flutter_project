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
}
