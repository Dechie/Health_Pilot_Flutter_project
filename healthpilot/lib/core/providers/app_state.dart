import 'package:flutter/material.dart';

/// Lightweight app-wide state. [themeMode] is wired into [MaterialApp]; extend as needed.
class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }
}
