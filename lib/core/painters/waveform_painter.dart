import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:lexiadapt/core/theme/app_colors.dart';

class WaveformPainter extends CustomPainter {
  final double progress;

  WaveformPainter({this.progress = 0.4});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    const barWidth = 3.0;
    const gap = 2.5;
    final count = (size.width / (barWidth + gap)).floor();
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i < count; i++) {
      final x = i * (barWidth + gap) + barWidth / 2;
      final h = 8 + rng.nextDouble() * (size.height - 16);
      final top = (size.height - h) / 2;
      paint.color = i < count * progress
          ? AppColors.primaryBlue
          : const Color(0x595B9BD5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, top, barWidth, h), const Radius.circular(2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
