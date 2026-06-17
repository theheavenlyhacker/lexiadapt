import 'package:flutter/material.dart';

class LexiAdaptLogo extends StatelessWidget {
  final double height;
  const LexiAdaptLogo({super.key, this.height = 60});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}
