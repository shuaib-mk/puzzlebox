import 'package:flutter/material.dart';

/// Distinctive design system color tokens for Puzzlebox.
/// Formatted specifically for a tactile, newspaper & arcade puzzle workbench aesthetic.
abstract final class AppColors {
  // ── Canvas & Substrate (Paper / Slate) ──────────────────────────────────
  static const Color paperCanvas = Color(0xFFFBF7EE); // Soft newsprint canvas
  static const Color slateCanvas = Color(0xFF141416); // Dark ink slate

  static const Color cardPaper = Color(0xFFFFFFFF);
  static const Color cardSlate = Color(0xFF1E1E22);

  static const Color cardPaperVariant = Color(0xFFF3ECE0);
  static const Color cardSlateVariant = Color(0xFF26262B);

  static const Color borderPaper = Color(0xFFE2D7C3);
  static const Color borderSlate = Color(0xFF33333A);

  // ── Text Ink ────────────────────────────────────────────────────────────
  static const Color inkPrimary = Color(0xFF1C1917); // Warm black ink
  static const Color inkSecondary = Color(0xFF78716C); // Warm grey ink

  static const Color darkInkPrimary = Color(0xFFF5F5F4);
  static const Color darkInkSecondary = Color(0xFFA8A29E);

  // ── Mascot & Streak Warmth ───────────────────────────────────────────────
  static const Color mascotYellow = Color(0xFFFFC107);
  static const Color streakFlame = Color(0xFFFF6D00);
  static const Color streakFlameGlow = Color(0xFFFF9E80);

  // ── Category Visual Signatures ("Puzzle Realms") ─────────────────────────
  // Words: Newsprint Violet & Letterpress Ink
  static const Color categoryWords = Color(0xFF6B46C1);
  static const Color categoryWordsLight = Color(0xFFF3E8FF);
  static const Color categoryWordsDarkBg = Color(0xFF2E1065);

  // Logic: Blueprint Cyan & Grid Lines
  static const Color categoryLogic = Color(0xFF007796);
  static const Color categoryLogicLight = Color(0xFFE0F2FE);
  static const Color categoryLogicDarkBg = Color(0xFF0C4A6E);

  // Patterns: Mosaic Terracotta / Amber
  static const Color categoryPatterns = Color(0xFFD97706);
  static const Color categoryPatternsLight = Color(0xFFFEF3C7);
  static const Color categoryPatternsDarkBg = Color(0xFF451A03);

  // General / Default
  static const Color brandAccent = Color(0xFF2563EB);

  // ── Legacy Compatibility Tokens ─────────────────────────────────────────
  static const Color background = slateCanvas;
  static const Color surface = cardSlate;
  static const Color surfaceVariant = cardSlateVariant;
  static const Color border = borderSlate;
  static const Color textPrimary = darkInkPrimary;
  static const Color textSecondary = darkInkSecondary;
  static const Color brand = brandAccent;
  static const Color brandLight = Color(0xFF60A5FA);

  static const Color correct = Color(0xFF22C55E);
  static const Color correctLight = Color(0xFF4ECB9B);
  static const Color present = Color(0xFFEAB308);
  static const Color presentLight = Color(0xFFE4B558);
  static const Color absent = Color(0xFF475569);
  static const Color absentLight = Color(0xFF565656);
  static const Color emptyTileBorder = Color(0xFF334155);
  static const Color darkEmptyTileBorder = Color(0xFF3A3A3A);
  static const Color filledTileBorder = Color(0xFF666666);

  static const Color spangram = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF4444);

  static const Color difficultyEasy = Color(0xFFFDE047);
  static const Color difficultyMedium = Color(0xFF4ADE80);
  static const Color difficultyHard = Color(0xFF60A5FA);
  static const Color difficultyExpert = Color(0xFFC084FC);
}
