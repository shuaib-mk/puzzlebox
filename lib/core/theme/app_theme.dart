import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => build(Brightness.light, 0);
  static ThemeData get dark => build(Brightness.dark, 0);

  static ThemeData build(Brightness brightness, int palette) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.brandAccent,
      onPrimary: Colors.white,
      primaryContainer: isDark ? const Color(0xFF1E293B) : AppColors.cardPaperVariant,
      onPrimaryContainer: isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary,
      secondary: AppColors.streakFlame,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? const Color(0xFF451A03) : const Color(0xFFFFF7ED),
      onSecondaryContainer: isDark ? const Color(0xFFFFEDD5) : const Color(0xFF9A3412),
      surface: isDark ? AppColors.cardSlate : AppColors.paperCanvas,
      onSurface: isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary,
      onSurfaceVariant: isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary,
      outline: isDark ? AppColors.borderSlate : AppColors.borderPaper,
      outlineVariant: isDark ? const Color(0xFF2E2E36) : const Color(0xFFE7DFD3),
      error: const Color(0xFFEF4444),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'PuzzleSans',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      visualDensity: VisualDensity.standard,
      textTheme: Typography.material2021().black.apply(
        fontFamily: 'PuzzleSans',
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'PuzzleSans',
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
          color: colorScheme.onSurface,
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(
          isDark ? const Color(0xFF26262C) : Colors.white,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
          ),
        ),
        hintStyle: WidgetStatePropertyAll(
          TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
        selectedColor: colorScheme.primary,
        secondarySelectedColor: colorScheme.primary,
        disabledColor: colorScheme.outlineVariant,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'PuzzleSans',
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'PuzzleSans',
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w900
                : FontWeight.w700,
            fontSize: 12,
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
