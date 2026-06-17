import 'package:flutter/material.dart';

class LexiAdaptLogo extends StatelessWidget {
  final double fontSize;
  const LexiAdaptLogo({super.key, this.fontSize = 42});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: const Offset(2, 3),
          child: Text(
            'LexiAdapt',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: const Color(0x1F000000),
              letterSpacing: 1,
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFE53935),
              Color(0xFFFF9800),
              Color(0xFFFDD835),
              Color(0xFF43A047),
              Color(0xFF1E88E5),
              Color(0xFF5C6BC0),
              Color(0xFF7B1FA2),
              Color(0xFFE91E63),
            ],
          ).createShader(bounds),
          child: Text(
            'LexiAdapt',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
