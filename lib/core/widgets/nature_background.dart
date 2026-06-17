import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/core/painters/hills_painter.dart';

class NatureBackground extends StatelessWidget {
  final Widget child;
  const NatureBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.skyTop,
                AppColors.skyMidTop,
                AppColors.skyMidBottom,
                AppColors.skyBottom,
              ],
              stops: [0.0, 0.25, 0.45, 0.65],
            ),
          ),
        ),
        Positioned(top: 55, left: 20, child: _cloud(90, 26)),
        Positioned(top: 38, right: 60, child: _cloud(105, 30)),
        Positioned(top: 75, left: 150, child: _cloud(60, 18)),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(size.width, size.height * 0.28),
            painter: HillsPainter(),
          ),
        ),
        child,
      ],
    );
  }

  static Widget _cloud(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0x80FFFFFF),
        borderRadius: BorderRadius.circular(h),
      ),
    );
  }
}
