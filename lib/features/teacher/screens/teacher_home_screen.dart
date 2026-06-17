import 'package:flutter/material.dart';
import 'package:lexiadapt/core/widgets/nature_background.dart';
import 'package:lexiadapt/core/widgets/lexiadapt_logo.dart';
import 'package:lexiadapt/core/widgets/top_bar.dart';
import 'package:lexiadapt/features/teacher/screens/class_overview_page.dart';
import 'package:lexiadapt/features/teacher/screens/rewards_manager_screen.dart';
import 'package:lexiadapt/features/student/screens/student_settings_screen.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NatureBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const TopBar(),
                const SizedBox(height: 24),
                const LexiAdaptLogo(fontSize: 36),
                const SizedBox(height: 40),
                _NavButton(
                  title: 'Class Overview',
                  subtitle: 'View class performance',
                  icon: Icons.groups_rounded,
                  colors: const [Color(0xFF5B9BD5), Color(0xFF4A8AC4)],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ClassOverviewPage())),
                ),
                const SizedBox(height: 14),
                _NavButton(
                  title: 'Rewards Manager',
                  subtitle: 'Create badges and track achievements',
                  icon: Icons.emoji_events_rounded,
                  colors: const [Color(0xFFFFB300), Color(0xFFF59E00)],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RewardsManagerScreen())),
                ),
                const SizedBox(height: 14),
                _NavButton(
                  title: 'Settings',
                  subtitle: 'Customize your experience',
                  icon: Icons.settings_rounded,
                  colors: const [Color(0xFF3A5BA0), Color(0xFF2C4A82)],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StudentSettingsScreen())),
                ),
                const Spacer(),
                Text('© LexiAdapt 2026 All Rights Reserved',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _NavButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xCCFFFFFF))),
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
    );
  }
}
