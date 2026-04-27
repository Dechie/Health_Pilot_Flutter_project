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
    final scheme = isLight ? _lightScheme() : _darkScheme();

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
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: !isLight,
        fillColor: !isLight
            ? scheme.onSurface.withValues(alpha: 0.12)
            : scheme.surface,
        hintStyle: textTheme.bodyMedium,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: isLight ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor:
            isLight ? scheme.surface : scheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.onSurface.withValues(alpha: isLight ? 0.12 : 0.18),
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        backgroundColor: scheme.surface,
      ),
    );
  }

  static ColorScheme _lightScheme() {
    final primary = AppPalette.light;
    final secondary = AppPalette.lightStrong;
    final tertiary = AppPalette.lightSoft;
    final onSurface = const Color(0xFF2A2A2A);
    final onSurfaceVariant = onSurface.withValues(alpha: 0.55);

    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: tertiary.withValues(alpha: 0.55),
      onPrimaryContainer: const Color(0xFF1A1C1E),
      secondary: secondary,
      onSecondary: Colors.white,
      tertiary: tertiary,
      onTertiary: Colors.white,
      surface: Colors.white,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: const Color(0xFFE0E0E0),
    );
  }

  /// Dark theme colors tuned to the Figma blue-surface UI.
  static ColorScheme _darkScheme() {
    const surface = AppPalette.darkStrong; // base background (blue)
    const surfaceContainer = Color(0xFF3E6A94); // cards / panels
    const primary = AppPalette.darkSoft; // buttons / highlights
    const onPrimary = Colors.white;
    const onSurface = Color(0xFFF2F6FF);
    const onSurfaceVariant = Color(0xFFC9D6E9);
    const outline = Color(0xFF5C86AE);

    return const ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
    ).copyWith(
      surfaceContainerHighest: surfaceContainer,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      primaryContainer: surfaceContainer,
      onPrimaryContainer: onSurface,
      secondaryContainer: surfaceContainer,
      onSecondaryContainer: onSurface,
      tertiary: AppPalette.dark,
      onTertiary: onPrimary,
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
