import 'package:flutter/material.dart';

class KanjiGridPainter extends CustomPainter {
  final Color color;
  KanjiGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw border rect
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw dashed lines
    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double dashWidth = 5, dashSpace = 5;

    // Horizontal center line
    double y = size.height / 2;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), dashPaint);
      startX += dashWidth + dashSpace;
    }

    // Vertical center line
    double x = size.width / 2;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(x, startY), Offset(x, startY + dashWidth), dashPaint);
      startY += dashWidth + dashSpace;
    }

    // Diagonal dashed lines
    double startD = 0;
    while (startD < size.width) {
      canvas.drawLine(
        Offset(startD, startD),
        Offset(startD + dashWidth, startD + dashWidth),
        dashPaint,
      );
      canvas.drawLine(
        Offset(size.width - startD, startD),
        Offset(size.width - (startD + dashWidth), startD + dashWidth),
        dashPaint,
      );
      startD += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
