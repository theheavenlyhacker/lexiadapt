import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';

class HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawHill(canvas, size, AppColors.hillLight, 0.30, [
      [0.15, 0.10],
      [0.35, 0.25],
      [0.55, 0.40],
      [0.75, 0.18],
      [0.90, 0.10],
    ]);
    _drawHill(canvas, size, AppColors.hillMid, 0.48, [
      [0.20, 0.32],
      [0.45, 0.48],
      [0.65, 0.55],
      [0.85, 0.40],
      [0.95, 0.35],
    ]);
    _drawHill(canvas, size, AppColors.hillDark, 0.62, [
      [0.25, 0.50],
      [0.50, 0.60],
      [0.75, 0.68],
      [1.0, 0.55],
    ]);
    final p4 = Paint()..color = AppColors.grass;
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.82, size.width, size.height * 0.18),
        p4);
  }

  void _drawHill(Canvas canvas, Size size, Color color, double startY,
      List<List<double>> points) {
    final paint = Paint()..color = color;
    final path = Path()..moveTo(0, size.height * startY);
    for (final pt in points) {
      path.quadraticBezierTo(
        size.width * (pt[0] - 0.1),
        size.height * (pt[1] - 0.05),
        size.width * pt[0],
        size.height * pt[1],
      );
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
