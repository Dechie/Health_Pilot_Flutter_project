import 'package:flutter/material.dart';

/// Lightweight app-wide state. [themeMode] and [locale] are wired into [MaterialApp].
class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;

  /// When non-null, overrides the platform locale for [MaterialApp].
  Locale? get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  /// Sets [locale] from a parallel list of BCP 47 language codes (e.g. language picker).
  void setLocaleFromLanguageIndex(int index, List<String> languageCodes) {
    if (index < 0 || index >= languageCodes.length) return;
    final next = Locale(languageCodes[index]);
    if (_locale == next) return;
    _locale = next;
    notifyListeners();
  }

  /// Clears override and returns to device locale.
  void clearLocaleOverride() {
    if (_locale == null) return;
    _locale = null;
    notifyListeners();
  }
}
