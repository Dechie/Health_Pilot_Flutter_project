import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight app-wide state. [themeMode] and [locale] are wired into [MaterialApp].
class AppState extends ChangeNotifier {
  static const _kThemeModeKey = 'app.themeMode';

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  AppState() {
    _loadPrefs();
  }

  ThemeMode get themeMode => _themeMode;

  /// When non-null, overrides the platform locale for [MaterialApp].
  Locale? get locale => _locale;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, _encodeThemeMode(mode));
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

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kThemeModeKey);
    final loaded = _decodeThemeMode(raw);
    if (loaded == null || loaded == _themeMode) return;
    _themeMode = loaded;
    notifyListeners();
  }

  static String _encodeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  static ThemeMode? _decodeThemeMode(String? raw) {
    switch (raw) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return null;
    }
  }
}
