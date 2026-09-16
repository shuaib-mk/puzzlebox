import 'package:flutter/material.dart';

class PawnPromotionDialog extends StatelessWidget {
  final bool isWhite;

  const PawnPromotionDialog({super.key, required this.isWhite});

  static Future<String?> show(BuildContext context, bool isWhite) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PawnPromotionDialog(isWhite: isWhite),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final options = [
      ('q', 'Queen', isWhite ? '♕' : '♛'),
      ('r', 'Rook', isWhite ? '♖' : '♜'),
      ('b', 'Bishop', isWhite ? '♗' : '♝'),
      ('n', 'Knight', isWhite ? '♘' : '♞'),
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Promote Pawn',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.map((opt) {
          return InkWell(
            onTap: () => Navigator.of(context).pop(opt.$1),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    opt.$3,
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opt.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
