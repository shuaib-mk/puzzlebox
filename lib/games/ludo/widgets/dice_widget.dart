import 'dart:math';
import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final int diceValue;
  final bool isRolling;
  final bool canRoll;
  final Color playerColor;
  final VoidCallback onRoll;

  const DiceWidget({
    super.key,
    required this.diceValue,
    required this.isRolling,
    required this.canRoll,
    required this.playerColor,
    required this.onRoll,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDiceFace(int value) {
    final dotsMap = {
      1: [(1, 1)],
      2: [(0, 0), (2, 2)],
      3: [(0, 0), (1, 1), (2, 2)],
      4: [(0, 0), (0, 2), (2, 0), (2, 2)],
      5: [(0, 0), (0, 2), (1, 1), (2, 0), (2, 2)],
      6: [(0, 0), (0, 2), (1, 0), (1, 2), (2, 0), (2, 2)],
    };

    final activeDots = dotsMap[value] ?? [(1, 1)];

    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.playerColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: widget.playerColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (r) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (c) {
              final isDot = activeDots.contains((r, c));
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDot ? widget.playerColor : Colors.transparent,
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * pi;
        final displayVal = widget.isRolling
            ? (Random().nextInt(6) + 1)
            : (widget.diceValue == 0 ? 6 : widget.diceValue);

        return GestureDetector(
          onTap: widget.canRoll ? widget.onRoll : null,
          child: Opacity(
            opacity: widget.canRoll ? 1.0 : 0.6,
            child: Transform.rotate(
              angle: widget.isRolling ? angle : 0.0,
              child: _buildDiceFace(displayVal),
            ),
          ),
        );
      },
    );
  }
}
