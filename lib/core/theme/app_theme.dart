import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light => build(Brightness.light, 0);
  static ThemeData get dark => build(Brightness.dark, 0);
  static ThemeData build(Brightness brightness, int palette) {
    const seeds = [
      Color(0xFF2458A6),
      Color(0xFF3D7C16),
      Color(0xFFAD4930),
      Color(0xFF7048A5),
    ];
    final colors = ColorScheme.fromSeed(
      seedColor: seeds[palette.clamp(0, 3)],
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'PuzzleSans',
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      visualDensity: VisualDensity.standard,
      textTheme: Typography.material2021().black.apply(
        fontFamily: 'PuzzleSans',
        bodyColor: colors.onSurface,
        displayColor: colors.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'PuzzleSans',
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -.7,
          color: colors.onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          elevation: 4,
          textStyle: const TextStyle(
            fontFamily: 'PuzzleSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: colors.onSurface,
          side: BorderSide(color: colors.outlineVariant, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(color: colors.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: DividerThemeData(color: colors.outlineVariant, space: 16),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 4,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'PuzzleSans',
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w900
                : FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
