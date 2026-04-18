import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma “palette” steps (logo / accents).
abstract final class AppPalette {
  static const Color lightStrong = Color(0xFF3B9CFF);
  static const Color light = Color(0xFF6EB6FF);
  static const Color lightSoft = Color(0xFFA1D0FF);

  static const Color darkStrong = Color(0xFF365C81);
  static const Color dark = Color(0xFF487AAD);
  static const Color darkSoft = Color(0xFF6F99C3);
}

/// Application [ThemeData] and small [BuildContext]-aware style helpers.
abstract final class AppTheme {
  static const String _font = 'PlusJakartaSans';

  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final primary = isLight ? AppPalette.light : AppPalette.dark;
    final secondary = isLight ? AppPalette.lightStrong : AppPalette.darkStrong;
    final tertiary = isLight ? AppPalette.lightSoft : AppPalette.darkSoft;

    final onSurface = isLight ? const Color(0xFF2A2A2A) : const Color(0xFFE7E7E7);
    final onSurfaceVariant =
        isLight ? onSurface.withValues(alpha: 0.55) : const Color(0xFFBFC7D5);
    final surface = isLight ? Colors.white : const Color(0xFF121316);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: tertiary.withValues(alpha: isLight ? 0.55 : 0.4),
      onPrimaryContainer: isLight ? const Color(0xFF1A1C1E) : Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      tertiary: tertiary,
      onTertiary: Colors.white,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: isLight ? const Color(0xFFE0E0E0) : const Color(0xFF3D4554),
    );

    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontFamily: _font,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: _font,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.17,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: _font,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.165,
        color: scheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: _font,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: _font,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: -0.17,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: _font,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.3,
        letterSpacing: -0.165,
        color: scheme.onSurfaceVariant,
      ),
      bodySmall: TextStyle(
        fontFamily: _font,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.25,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontFamily: _font,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.16,
        color: scheme.onPrimary,
      ),
      labelSmall: TextStyle(
        fontFamily: _font,
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: _font,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.primaryContainer,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        backgroundColor: scheme.surface,
      ),
    );
  }

  // --- Prefer these over hard-coded [TextStyle]s / colors ---

  static TextStyle userGreeting(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!;
  }

  static TextStyle headlinePanel(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(fontWeight: FontWeight.w600);
  }

  static TextStyle bodyMuted(BuildContext context) {
    final t = Theme.of(context);
    return t.textTheme.bodyLarge!
        .copyWith(color: t.colorScheme.onSurfaceVariant);
  }

  static TextStyle overviewMetric(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(fontWeight: FontWeight.w500);
  }

  static TextStyle overviewUnit(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .bodySmall!
        .copyWith(color: Theme.of(context).colorScheme.onSurface);
  }

  static TextStyle snackbarAssistiveText(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall!;
  }

  static TextStyle blogCardDescription(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!;
  }

  static ButtonStyle circleBackButtonStyle(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return IconButton.styleFrom(
      backgroundColor: c.primaryContainer,
      foregroundColor: c.primary,
    );
  }

  static LinearGradient homeOverviewGradient(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return LinearGradient(
      colors: [
        c.primary.withValues(alpha: 0.35),
        c.surface,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static BoxDecoration homeOverviewBoxDecoration(BuildContext context) {
    return BoxDecoration(gradient: homeOverviewGradient(context));
  }

  static SvgTheme svgBottomNavCurrent(BuildContext context) {
    return SvgTheme(currentColor: Theme.of(context).colorScheme.primary);
  }
}
