// Deprecated path: profile UI lives under `package:healthpilot/features/profile/`.
// Keep this barrel so older imports keep working until cleaned up.
import 'package:healthpilot/features/profile/profile_screen.dart';

export 'package:healthpilot/features/profile/profile_screen.dart' show ProfileScreen;

@Deprecated(
  'Use `package:healthpilot/features/profile/profile_screen.dart` instead.',
)
typedef ProfileAndSettingScreen = ProfileScreen;
