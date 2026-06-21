import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final Widget? trailing;
  final VoidCallback onTap;

  const HomeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.colors,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(colors[0].r.toInt(),
                  colors[0].g.toInt(), colors[0].b.toInt(), 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: const Color(0x33FFFFFF),
          highlightColor: const Color(0x1AFFFFFF),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                trailing ??
                    const Icon(Icons.chevron_right,
                        color: Color(0xB3FFFFFF), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
