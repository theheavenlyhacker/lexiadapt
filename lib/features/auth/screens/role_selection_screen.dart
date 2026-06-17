import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/core/widgets/nature_background.dart';
import 'package:lexiadapt/core/widgets/lexiadapt_logo.dart';
import 'package:lexiadapt/core/widgets/top_bar.dart';
import 'package:lexiadapt/features/auth/screens/login_screen.dart';
import 'package:lexiadapt/features/auth/widgets/role_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

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
                const SizedBox(height: 20),
                const LexiAdaptLogo(),
                const SizedBox(height: 28),
                const Text('Welcome!',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text("Choose how you'll use LexiAdapt.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 28),
                RoleCard(
                  title: "I'm a Student",
                  description:
                      'Start your reading journey,\ntrack your progress, and\nearn rewards!',
                  gradient: const [AppColors.primaryBlue, AppColors.lavender],
                  icon: Icons.school_outlined,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const LoginScreen(role: 'student'))),
                ),
                const SizedBox(height: 14),
                RoleCard(
                  title: "I'm a Teacher",
                  description:
                      'Manage your class, support\nlearners, and track reading\nprogress.',
                  gradient: const [AppColors.purple, AppColors.deepPurple],
                  icon: Icons.groups_outlined,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const LoginScreen(role: 'teacher'))),
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
