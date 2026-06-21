import 'package:flutter/material.dart';

class LexiAdaptLogo extends StatelessWidget {
  final double widthFraction;
  const LexiAdaptLogo({super.key, this.widthFraction = 0.65});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final w = screenWidth * widthFraction;
    // The logo PNG is 200x200 but the text only occupies the middle ~40%.
    // Use negative margin via Transform.translate to eat the dead space.
    return Transform.translate(
      offset: const Offset(0, -10),
      child: SizedBox(
        width: w,
        height: w * 0.4,
        child: OverflowBox(
          maxHeight: w,
          child: Image.asset(
            'assets/images/logo.png',
            width: w,
            fit: BoxFit.contain,
            cacheWidth: (w * MediaQuery.devicePixelRatioOf(context)).round(),
          ),
        ),
      ),
    );
  }
}
