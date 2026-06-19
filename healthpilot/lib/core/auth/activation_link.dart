/// Parses activation tokens from email deep links.
///
/// Backend emails link to:
/// `GET /api/v1/auth/activate/?token=<uuid>`
///
/// After activation the backend redirects to a page at
/// `https://healthpilot.com/open-app?verified=true` with a button that
/// opens the app — `isVerified` detects that signal.
abstract final class ActivationLink {
  static String? parseToken(Uri uri) {
    final token = uri.queryParameters['token']?.trim();
    if (token != null && token.isNotEmpty) return token;

    if (!uri.path.contains('activate')) return null;
    final segments =
        uri.pathSegments.where((s) => s.isNotEmpty && s != 'activate').toList();
    if (segments.length == 1 && _looksLikeUuid(segments.single)) {
      return segments.single;
    }
    return null;
  }

  /// Returns `true` when the URI is a post-activation verified link from the
  /// backend redirect page (`/open-app?verified=true`).
  static bool isVerified(Uri uri) {
    return uri.host == 'healthpilot.com' &&
        uri.path == '/open-app' &&
        uri.queryParameters['verified'] == 'true';
  }

  static bool _looksLikeUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }
}
