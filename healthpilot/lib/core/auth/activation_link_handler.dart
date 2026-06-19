import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/auth/activation_link.dart';

/// Listens for activation email links and verified deep links.
///
/// Two signals:
/// 1. Activation token (`?token=<uuid>`) — parsed by [ActivationLink.parseToken].
/// 2. Post-activation verified signal (`/open-app?verified=true`) —
///    detected by [ActivationLink.isVerified].
class ActivationLinkHandler {
  ActivationLinkHandler({AppLinks? appLinks})
      : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;
  String? _initialToken;
  bool _initialVerified = false;

  /// Token from an activation link that launched the app (cold start).
  String? get initialToken => _initialToken;

  /// Whether the app was launched via a verified deep link (cold start).
  bool get initialVerified => _initialVerified;

  Future<void> init() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      _initialToken = ActivationLink.parseToken(initial);
      _initialVerified = ActivationLink.isVerified(initial);
      if (kDebugMode) {
        if (_initialToken != null) {
          // ignore: avoid_print
          print('[HealthPilot] Activation link token from cold start');
        }
        if (_initialVerified) {
          // ignore: avoid_print
          print('[HealthPilot] Verified deep link from cold start');
        }
      }
    }
    await _subscription?.cancel();
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      final token = ActivationLink.parseToken(uri);
      if (token != null) {
        onLinkToken?.call(token);
      } else if (ActivationLink.isVerified(uri)) {
        onVerified?.call();
      }
    });
  }

  /// Called when the app receives an activation token while running.
  void Function(String token)? onLinkToken;

  /// Called when the app receives a post-activation verified deep link
  /// (`/open-app?verified=true`) while running.
  void Function()? onVerified;

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
