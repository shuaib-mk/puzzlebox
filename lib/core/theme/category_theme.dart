import 'package:flutter/material.dart';
import 'app_colors.dart';

enum CategoryType { words, logic, patterns, general }

class CategoryVisualSignature {
  final CategoryType type;
  final String label;
  final Color primaryColor;
  final Color lightBg;
  final Color darkBg;
  final BorderRadius cardRadius;
  final ShapeBorder badgeShape;
  final IconData badgeIcon;

  const CategoryVisualSignature({
    required this.type,
    required this.label,
    required this.primaryColor,
    required this.lightBg,
    required this.darkBg,
    required this.cardRadius,
    required this.badgeShape,
    required this.badgeIcon,
  });

  static CategoryVisualSignature of(String category, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (category.toLowerCase()) {
      case 'words':
        return CategoryVisualSignature(
          type: CategoryType.words,
          label: 'Words',
          primaryColor: AppColors.categoryWords,
          lightBg: isDark ? AppColors.categoryWordsDarkBg : AppColors.categoryWordsLight,
          darkBg: AppColors.categoryWordsDarkBg,
          cardRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(24),
          ),
          badgeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.categoryWords, width: 1.5),
          ),
          badgeIcon: Icons.font_download_outlined,
        );
      case 'logic':
        return CategoryVisualSignature(
          type: CategoryType.logic,
          label: 'Logic',
          primaryColor: AppColors.categoryLogic,
          lightBg: isDark ? AppColors.categoryLogicDarkBg : AppColors.categoryLogicLight,
          darkBg: AppColors.categoryLogicDarkBg,
          cardRadius: const BorderRadius.all(Radius.circular(14)),
          badgeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.categoryLogic, width: 2),
          ),
          badgeIcon: Icons.grid_4x4_rounded,
        );
      case 'patterns':
        return CategoryVisualSignature(
          type: CategoryType.patterns,
          label: 'Patterns',
          primaryColor: AppColors.categoryPatterns,
          lightBg: isDark ? AppColors.categoryPatternsDarkBg : AppColors.categoryPatternsLight,
          darkBg: AppColors.categoryPatternsDarkBg,
          cardRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(12),
          ),
          badgeShape: const StadiumBorder(
            side: BorderSide(color: AppColors.categoryPatterns, width: 1.5),
          ),
          badgeIcon: Icons.interests_outlined,
        );
      default:
        return CategoryVisualSignature(
          type: CategoryType.general,
          label: 'General',
          primaryColor: AppColors.brandAccent,
          lightBg: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
          darkBg: const Color(0xFF1E293B),
          cardRadius: const BorderRadius.all(Radius.circular(18)),
          badgeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          badgeIcon: Icons.extension_rounded,
        );
    }
  }
}
