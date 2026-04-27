import 'package:flutter/widgets.dart';

/// Central place for app locale codes and [Locale] constants.
///
/// Keep this file in sync with the language picker UI and any backend language
/// support. Prefer referencing these constants instead of duplicating strings.
abstract final class AppLocales {
  static const Locale en = Locale('en');
  static const Locale am = Locale('am');
  static const Locale es = Locale('es');
  static const Locale fr = Locale('fr');
  static const Locale ur = Locale('ur');
  static const Locale ar = Locale('ar');

  static const List<Locale> supportedLocales = [
    en,
    am,
    es,
    fr,
    ur,
    ar,
  ];

  /// Language codes in the same order as [supportedLocales].
  static const List<String> supportedLanguageCodes = [
    'en',
    'am',
    'es',
    'fr',
    'ur',
    'ar',
  ];
}

