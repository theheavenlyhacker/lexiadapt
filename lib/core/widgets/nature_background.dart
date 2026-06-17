import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';

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
                Color(0xFFFFFFFF),
              ],
              stops: [0.0, 0.2, 0.4, 0.6],
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
            cacheWidth: 720,
          ),
        ),
        child,
      ],
    );
  }
}
