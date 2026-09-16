import 'package:flutter/material.dart';
import 'ludo_token.dart';

class LudoPlayer {
  final LudoColor color;
  final bool isAI;
  final List<LudoToken> tokens;

  LudoPlayer({
    required this.color,
    required this.isAI,
  }) : tokens = List.generate(4, (i) => LudoToken(id: i, color: color));

  bool get hasWon => tokens.every((t) => t.isFinished);
  int get finishedCount => tokens.where((t) => t.isFinished).length;

  Color get displayColor {
    switch (color) {
      case LudoColor.red:
        return const Color(0xFFE53935);
      case LudoColor.green:
        return const Color(0xFF43A047);
      case LudoColor.yellow:
        return const Color(0xFFFDD835);
      case LudoColor.blue:
        return const Color(0xFF1E88E5);
    }
  }

  String get name {
    switch (color) {
      case LudoColor.red:
        return 'Red';
      case LudoColor.green:
        return 'Green';
      case LudoColor.yellow:
        return 'Yellow';
      case LudoColor.blue:
        return 'Blue';
    }
  }
}
