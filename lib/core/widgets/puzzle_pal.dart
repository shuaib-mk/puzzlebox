import 'package:flutter/material.dart';

/// Original, resolution-independent Puzzlebox character.
class PuzzlePal extends StatelessWidget {
  final double size;
  const PuzzlePal({super.key, this.size = 100});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _PalPainter(Theme.of(context).colorScheme)),
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
