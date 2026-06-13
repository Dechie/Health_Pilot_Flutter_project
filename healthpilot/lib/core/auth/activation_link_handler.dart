import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/auth/activation_link.dart';

/// Listens for activation email links and exposes tokens to the auth flow.
class ActivationLinkHandler {
  ActivationLinkHandler({AppLinks? appLinks})
      : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;
  String? _initialToken;

  String? get initialToken => _initialToken;

  Future<void> init() async {
    final initial = await _appLinks.getInitialLink();
    _initialToken = initial != null ? ActivationLink.parseToken(initial) : null;
    if (kDebugMode && _initialToken != null) {
      // ignore: avoid_print
      print('[HealthPilot] Activation link token from cold start');
    }
    await _subscription?.cancel();
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      final token = ActivationLink.parseToken(uri);
      if (token != null) onLinkToken?.call(token);
    });
  }

  /// Called when the app receives an activation link while running.
  void Function(String token)? onLinkToken;

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
