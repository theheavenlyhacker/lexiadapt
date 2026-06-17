import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/core/widgets/nature_background.dart';
import 'package:lexiadapt/core/widgets/lexiadapt_logo.dart';
import 'package:lexiadapt/core/widgets/top_bar.dart';
import 'package:lexiadapt/features/student/screens/category_screen.dart';
import 'package:lexiadapt/features/student/screens/student_progress_screen.dart';
import 'package:lexiadapt/features/student/screens/student_rewards_screen.dart';
import 'package:lexiadapt/features/student/screens/student_settings_screen.dart';
import 'package:lexiadapt/features/student/screens/record_debug_screen.dart';
import 'package:lexiadapt/features/student/widgets/home_button.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NatureBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const TopBar(),
                const SizedBox(height: 24),
                const LexiAdaptLogo(height: 48),
                const SizedBox(height: 40),
                HomeButton(
                  label: 'Continue Reading',
                  icon: Icons.menu_book_rounded,
                  colors: const [AppColors.primaryBlue, Color(0xFF4A8AC4)],
                  trailing: const Icon(Icons.play_circle_fill,
                      color: AppColors.success, size: 28),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CategoryScreen())),
                ),
                const SizedBox(height: 12),
                HomeButton(
                  label: 'My Progress',
                  icon: Icons.bar_chart_rounded,
                  colors: const [AppColors.purple, Color(0xFF8E44AD)],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StudentProgressScreen())),
                ),
                const SizedBox(height: 12),
                HomeButton(
                  label: 'Rewards',
                  icon: Icons.emoji_events_rounded,
                  colors: const [AppColors.warning, AppColors.error],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StudentRewardsScreen())),
                ),
                const SizedBox(height: 12),
                HomeButton(
                  label: 'Settings',
                  icon: Icons.settings_rounded,
                  colors: const [Color(0xFF607D8B), Color(0xFF455A64)],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StudentSettingsScreen())),
                ),
                const SizedBox(height: 12),
                HomeButton(
                  label: 'Debug Recording',
                  icon: Icons.bug_report,
                  colors: const [Color(0xFFEF5350), Color(0xFFC62828)],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RecordDebugScreen())),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
