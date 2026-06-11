import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

bool _isBenignFontError(String message) {
  return message.contains('GoogleFonts') ||
      message.contains('PlusJakartaSans') ||
      message.contains('allowRuntimeFetching');
}

/// Shared test bootstrap — prevents google_fonts from fetching over the network.
Future<void> testExecutable(Future<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final oldOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (_isBenignFontError(details.exceptionAsString())) {
      return;
    }
    oldOnError?.call(details);
  };

  await runZonedGuarded(
    () async => testMain(),
    (error, stack) {
      if (_isBenignFontError(error.toString())) {
        return;
      }
      Error.throwWithStackTrace(error, stack);
    },
  );
}
