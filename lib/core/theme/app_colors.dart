import 'package:flutter/material.dart';

/// All named color tokens used throughout Puzzlebox.
/// Dark-mode variants are prefixed with `dark`.
abstract final class AppColors {
  // ── Background ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFF121212); // Near-black
  static const Color darkBackground = Color(0xFF121212);

  static const Color surface = Color(0xFF1E1E1E); // Card/tile default
  static const Color darkSurface = Color(0xFF1E1E1E);

  static const Color surfaceVariant = Color(0xFF2A2A2A);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);

  static const Color border = Color(0xFF3A3A3A);
  static const Color darkBorder = Color(0xFF3A3A3A);

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  // ── Accent / Brand ──────────────────────────────────────────────────────
  static const Color brand = Color(0xFF4A9EFF); // Electric Blue accent
  static const Color brandLight = Color(0xFF64B5F6);

  // ── Tile states (Daily Five) ─────────────────────────────────────────────
  /// Correct letter, correct position (Forest Teal)
  static const Color correct = Color(0xFF3AA981);
  static const Color correctLight = Color(0xFF4ECB9B);

  /// Letter in word, wrong position (Warm Amber)
  static const Color present = Color(0xFFD9A441);
  static const Color presentLight = Color(0xFFE4B558);

  /// Letter not in word (Dark Gray)
  static const Color absent = Color(0xFF3A3A3A);
  static const Color absentLight = Color(0xFF565656);

  /// Empty tile (no letter yet)
  static const Color emptyTile = Colors.transparent;
  static const Color emptyTileBorder = Color(0xFF3A3A3A);
  static const Color darkEmptyTileBorder = Color(0xFF3A3A3A);

  /// Filled but not yet submitted
  static const Color filledTileBorder = Color(0xFF666666);

  // ── Keyboard ────────────────────────────────────────────────────────────
  static const Color keyDefault = Color(0xFF565656);
  static const Color darkKeyDefault = Color(0xFF565656);

  // ── Error / Danger ──────────────────────────────────────────────────────
  static const Color error = Color(0xFFE55E5E);
  static const Color errorBg = Color(0xFF3D1E1E);

  // ── Game card & Connections difficulty colors ────────────────────────────
  static const Color difficultyEasy = Color(0xFFF9DF6D); // Yellow
  static const Color difficultyMedium = Color(0xFFA0C35A); // Green
  static const Color difficultyHard = Color(0xFFB0C4EF); // Blue
  static const Color difficultyExpert = Color(0xFFBA81C5); // Purple

  // Spangram accent
  static const Color spangram = Color(0xFFFFB74D);
}
