import 'package:flutter/material.dart';

class AreaChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  AreaChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - (data[i] * size.height);
      points.add(Offset(x, y));
    }

    final areaPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath
      ..lineTo(size.width, size.height)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(
              color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.3),
          Color.fromRGBO(
              color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final cp1x = points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 3;
      final cp2x = points[i].dx - (points[i].dx - points[i - 1].dx) / 3;
      linePath.cubicTo(cp1x, points[i - 1].dy, cp2x, points[i].dy,
          points[i].dx, points[i].dy);
    }
    canvas.drawPath(
        linePath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);

    canvas.drawCircle(points.last, 4, Paint()..color = color);
    canvas.drawCircle(points.last, 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
