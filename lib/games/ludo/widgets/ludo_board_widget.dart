import 'package:flutter/material.dart';
import '../logic/ludo_engine.dart';
import '../models/ludo_token.dart';

class LudoBoardWidget extends StatelessWidget {
  final LudoEngine engine;
  final List<LudoToken> moveableTokens;
  final ValueChanged<LudoToken> onTokenTap;

  const LudoBoardWidget({
    super.key,
    required this.engine,
    required this.moveableTokens,
    required this.onTokenTap,
  });

  // Muted minimal modern colors
  static const Color redColor = Color(0xFFEF5350);
  static const Color greenColor = Color(0xFF66BB6A);
  static const Color yellowColor = Color(0xFFFFCA28);
  static const Color blueColor = Color(0xFF42A5F5);

  Color _getTileColor(int r, int c) {
    // 6x6 Corner Home Yards
    if (r < 6 && c < 6) return redColor.withValues(alpha: 0.15);
    if (r < 6 && c > 8) return greenColor.withValues(alpha: 0.15);
    if (r > 8 && c > 8) return yellowColor.withValues(alpha: 0.15);
    if (r > 8 && c < 6) return blueColor.withValues(alpha: 0.15);

    // Home Stretches
    if (r == 7 && c >= 1 && c <= 5) return redColor.withValues(alpha: 0.35);
    if (c == 7 && r >= 1 && r <= 5) return greenColor.withValues(alpha: 0.35);
    if (r == 7 && c >= 9 && c <= 13) return yellowColor.withValues(alpha: 0.35);
    if (c == 7 && r >= 9 && r <= 13) return blueColor.withValues(alpha: 0.35);

    // 4 Center Finish Target Boxes
    if (r == 7 && c == 6) return redColor.withValues(alpha: 0.55);
    if (r == 6 && c == 7) return greenColor.withValues(alpha: 0.55);
    if (r == 7 && c == 8) return yellowColor.withValues(alpha: 0.55);
    if (r == 8 && c == 7) return blueColor.withValues(alpha: 0.55);

    // Start spots
    if (r == 6 && c == 1) return redColor.withValues(alpha: 0.45);
    if (r == 1 && c == 8) return greenColor.withValues(alpha: 0.45);
    if (r == 8 && c == 13) return yellowColor.withValues(alpha: 0.45);
    if (r == 13 && c == 6) return blueColor.withValues(alpha: 0.45);

    // Corner cells of 3x3 center and all track tiles are pure white
    return Colors.white;
  }

  bool _isStarTile(int r, int c) {
    return (r == 2 && c == 6) ||
        (r == 6 && c == 12) ||
        (r == 12 && c == 8) ||
        (r == 8 && c == 2);
  }

  @override
  Widget build(BuildContext context) {
    // Map tokens to grid position
    final Map<(int, int), List<LudoToken>> tokensOnGrid = {};
    for (final p in engine.players) {
      for (final t in p.tokens) {
        final pos = engine.getTokenGridPosition(t);
        tokensOnGrid.putIfAbsent(pos, () => []).add(t);
      }
    }

    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: List.generate(15, (r) {
              return Expanded(
                child: Row(
                  children: List.generate(15, (c) {
                    final tileColor = _getTileColor(r, c);
                    final isStar = _isStarTile(r, c);
                    final tokensHere = tokensOnGrid[(r, c)] ?? [];

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(0.4),
                        decoration: BoxDecoration(
                          color: tileColor,
                          border: Border.all(
                            color: const Color(0xFFE5E5E5),
                            width: 0.4,
                          ),
                        ),
                        child: Stack(
                          children: [
                            if (isStar)
                              const Center(
                                child: Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFB300),
                                  size: 15,
                                ),
                              ),
                            // Render Tokens on cell
                            if (tokensHere.isNotEmpty)
                              Center(
                                child: Wrap(
                                  spacing: 1,
                                  runSpacing: 1,
                                  alignment: WrapAlignment.center,
                                  children: tokensHere.map((token) {
                                    final isSelectable = moveableTokens.contains(token);
                                    final playerColor = engine.players
                                        .firstWhere((p) => p.color == token.color)
                                        .displayColor;

                                    return GestureDetector(
                                      onTap: isSelectable ? () => onTokenTap(token) : null,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: tokensHere.length > 1 ? 13 : 21,
                                        height: tokensHere.length > 1 ? 13 : 21,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: playerColor,
                                          border: Border.all(
                                            color: isSelectable ? Colors.amber : Colors.white,
                                            width: isSelectable ? 3.0 : 2.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 3,
                                              offset: const Offset(0, 2),
                                            ),
                                            if (isSelectable)
                                              BoxShadow(
                                                color: Colors.amber.withValues(alpha: 0.9),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
