import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/env/app_env.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';

/// Prints active build config once at startup (debug builds only).
void logDevStartupConfig() {
  if (!kDebugMode) return;

  const tag = '[HealthPilot]';
  // ignore: avoid_print
  print('$tag baseUrl=${AppEnv.baseUrl} env=${AppEnv.environment.name}');
  // ignore: avoid_print
  print(
    '$tag flags: '
    'AUTH=${FeatureFlags.auth} '
    'PROFILE=${FeatureFlags.userProfile} '
    'ASSESSMENT=${FeatureFlags.assessment} '
    'AI=${FeatureFlags.aiAssistant} '
    'HEALTH=${FeatureFlags.healthData} '
    'CHAT=${FeatureFlags.chat}',
  );

  if (!FeatureFlags.auth) {
    // ignore: avoid_print
    print(
      '$tag API is OFF — run with: '
      'flutter run --dart-define-from-file=dart_defines.json',
    );
    return;
  }

  // ignore: avoid_print
  print('$tag API logging enabled — filter terminal with: [HP API]');

  if (!FeatureFlags.aiAssistant) {
    // ignore: avoid_print
    print(
      '$tag ⚠ FF_AI_ASSISTANT=false — HealthBot uses MOCK (no /chat/ai/ calls). '
      'Set FF_AI_ASSISTANT=true in dart_defines.json, then stop the app and run '
      'flutter run --dart-define-from-file=dart_defines.json '
      '(hot restart does NOT reload dart-defines).',
    );
  }
  if (!FeatureFlags.assessment) {
    // ignore: avoid_print
    print(
      '$tag ⚠ FF_ASSESSMENT=false — assessments use MOCK (no /assessments/ calls).',
    );
  }
}
