import 'package:flutter/material.dart';

class Achievement {
  final String badgeId;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  bool isEarned;
  DateTime? earnedAt;

  Achievement({
    required this.badgeId,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isEarned = false,
    this.earnedAt,
  });

  static List<Achievement> allAchievements() => [
        Achievement(
          badgeId: 'bookworm',
          title: 'Bookworm',
          description: 'Read 10 stories',
          icon: Icons.menu_book,
          color: const Color(0xFF5B9BD5),
        ),
        Achievement(
          badgeId: 'voice_star',
          title: 'Voice Star',
          description: 'Complete 5 read-aloud sessions',
          icon: Icons.mic,
          color: const Color(0xFF66BB6A),
        ),
        Achievement(
          badgeId: 'rising_reader',
          title: 'Rising Reader',
          description: 'Improve accuracy by 10%',
          icon: Icons.trending_up,
          color: const Color(0xFF9B59B6),
        ),
        Achievement(
          badgeId: 'streak_7',
          title: '7-Day Streak',
          description: 'Read every day for a week',
          icon: Icons.local_fire_department,
          color: const Color(0xFFFF7043),
        ),
        Achievement(
          badgeId: 'perfect',
          title: 'Perfect Score',
          description: 'Get 100% accuracy on a story',
          icon: Icons.diamond,
          color: const Color(0xFFFFB300),
        ),
      ];
}
