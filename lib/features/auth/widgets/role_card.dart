import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  final String title, description;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(gradient[0].r.toInt(),
                  gradient[0].g.toInt(), gradient[0].b.toInt(), 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: const Color(0x33FFFFFF),
          highlightColor: const Color(0x1AFFFFFF),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(description,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xE6FFFFFF),
                              height: 1.3)),
                    ],
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x40FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child:
                        Icon(Icons.chevron_right, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
