import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';

class NatureBackground extends StatelessWidget {
  final Widget child;
  const NatureBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = (size.width * dpr).round().clamp(360, 1080);
    return Stack(
      children: [
        SizedBox.expand(
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.skyTop,
                  AppColors.skyMidTop,
                  AppColors.skyMidBottom,
                  Color(0xFFD4EFFC),
                  Color(0xFFFFFFFF),
                ],
                stops: [0.0, 0.2, 0.45, 0.65, 0.85],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/bg_nature.png',
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            cacheWidth: cacheW,
          ),
        ),
        child,
      ],
    );
  }
}
