import 'dart:math';
import 'package:flutter/material.dart';

void showCelebrationBurst(BuildContext context) {
  if (MediaQuery.disableAnimationsOf(context)) return;
  late OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => _Celebration(onDone: entry.remove));
  Overlay.of(context).insert(entry);
}

class _Celebration extends StatefulWidget {
  final VoidCallback onDone;
  const _Celebration({required this.onDone});
  @override
  State<_Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<_Celebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: controller,
      builder: (_, child) => CustomPaint(
        painter: _BurstPainter(controller.value, Theme.of(context).colorScheme),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _BurstPainter extends CustomPainter {
  final double t;
  final ColorScheme colors;
  _BurstPainter(this.t, this.colors);
  @override
  void paint(Canvas canvas, Size size) {
    final palette = [
      colors.primary,
      colors.tertiary,
      const Color(0xFFFFC800),
      const Color(0xFFFF6B6B),
    ];
    for (var i = 0; i < 24; i++) {
      final angle = i * pi * 2 / 24;
      final distance =
          Curves.easeOutCubic.transform(t) * min(size.width, size.height) * .52;
      final center = Offset(
        size.width / 2 + cos(angle) * distance,
        size.height * .42 + sin(angle) * distance,
      );
      final paint = Paint()
        ..color = palette[i % palette.length].withValues(alpha: 1 - t);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + t * 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-4, -8, 8, 16),
          const Radius.circular(3),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t || old.colors != colors;
}
