import 'package:flutter/material.dart';

/// Original, resolution-independent Puzzlebox character.
class PuzzlePal extends StatefulWidget {
  final double size;
  const PuzzlePal({super.key, this.size = 100});
  @override
  State<PuzzlePal> createState() => _PuzzlePalState();
}

class _PuzzlePalState extends State<PuzzlePal>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (_, child) => Transform.translate(
      offset: MediaQuery.disableAnimationsOf(context)
          ? Offset.zero
          : Offset(0, -3 * controller.value),
      child: child,
    ),
    child: ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(painter: _PalPainter(Theme.of(context).colorScheme)),
      ),
    ),
  );
}

class _PalPainter extends CustomPainter {
  final ColorScheme colors;
  const _PalPainter(this.colors);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final paint = Paint()..color = colors.primary.withValues(alpha: .16);
    canvas.drawOval(const Rect.fromLTWH(13, 87, 76, 10), paint);
    paint.color = colors.primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 28, 74, 60),
        const Radius.circular(20),
      ),
      paint,
    );
    canvas.drawCircle(const Offset(50, 25), 14, paint);
    canvas.drawCircle(const Offset(86, 55), 10, paint);
    paint.color = colors.onPrimary;
    canvas.drawOval(const Rect.fromLTWH(30, 43, 13, 17), paint);
    canvas.drawOval(const Rect.fromLTWH(57, 43, 13, 17), paint);
    paint.color = colors.primary;
    canvas.drawCircle(const Offset(38, 52), 3.5, paint);
    canvas.drawCircle(const Offset(65, 52), 3.5, paint);
    paint
      ..color = colors.onPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(const Rect.fromLTWH(39, 57, 22, 16), .2, 2.7, false, paint);
    paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFD568);
    final star = Path()
      ..moveTo(83, 5)
      ..lineTo(86, 13)
      ..lineTo(95, 16)
      ..lineTo(86, 19)
      ..lineTo(83, 27)
      ..lineTo(80, 19)
      ..lineTo(72, 16)
      ..lineTo(80, 13)
      ..close();
    canvas.drawPath(star, paint);
  }

  @override
  bool shouldRepaint(_PalPainter oldDelegate) => colors != oldDelegate.colors;
}
