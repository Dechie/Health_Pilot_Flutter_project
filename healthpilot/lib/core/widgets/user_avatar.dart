import 'package:flutter/material.dart';
import 'package:healthpilot/core/env/app_env.dart';
import 'package:healthpilot/data/constants.dart';

/// Circular avatar that shows a network [url] when available and falls back to
/// a local asset (on null/empty url or a load error). Drop-in replacement for
/// the hardcoded `CircleAvatar(backgroundImage: AssetImage(devsImage))` sites.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.url,
    required this.radius,
    this.fallbackAsset = devsImage,
  });

  final String? url;
  final double radius;
  final String fallbackAsset;

  /// Resolves an avatar value into a loadable absolute URL. The backend is
  /// inconsistent — some endpoints return absolute URLs, others a relative
  /// `/media/...` path — so relative values are joined to the API host.
  static String? resolveUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final u = raw.trim();
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = AppEnv.baseUrl.replaceAll(RegExp(r'/+$'), '');
    return u.startsWith('/') ? '$base$u' : '$base/$u';
  }

  @override
  Widget build(BuildContext context) {
    final resolved = resolveUrl(url);
    final fallback = Image.asset(
      fallbackAsset,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
    );
    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: resolved == null
            ? fallback
            : Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
