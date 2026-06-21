import 'package:flutter/material.dart';

class Achievement {
  final String badgeId;
  final String title;
  final String description;
  final String asset;
  final Color color;
  bool isEarned;
  DateTime? earnedAt;

  Achievement({
    required this.badgeId,
    required this.title,
    required this.description,
    required this.asset,
    required this.color,
    this.isEarned = false,
    this.earnedAt,
  });

  static List<Achievement> allAchievements() => [
        Achievement(
          badgeId: 'voice_star',
          title: 'First Steps',
          description: 'Complete 5 read-aloud sessions',
          asset: 'assets/images/BADGE_FIRSTSTEP.png',
          color: const Color(0xFF66BB6A),
        ),
        Achievement(
          badgeId: 'bookworm',
          title: 'Good Listener',
          description: 'Read 10 stories',
          asset: 'assets/images/BADGE_GOOD_LISTENER.png',
          color: const Color(0xFF5B9BD5),
        ),
        Achievement(
          badgeId: 'rising_reader',
          title: 'Star Reader',
          description: 'Reach 85% accuracy',
          asset: 'assets/images/BADGE_STAR_READER.png',
          color: const Color(0xFFFFB300),
        ),
        Achievement(
          badgeId: 'perfect',
          title: 'Word Explorer',
          description: 'Learn 50 words',
          asset: 'assets/images/BADGE_WORD_EXPLORER.png',
          color: const Color(0xFF4CAF50),
        ),
        Achievement(
          badgeId: 'story_master',
          title: 'Story Master',
          description: 'Finish 20 stories',
          asset: 'assets/images/BADGE_STORY_MASTER.png',
          color: const Color(0xFF42A5F5),
        ),
        Achievement(
          badgeId: 'streak_7',
          title: 'Consistent Learner',
          description: 'Read every day for a week',
          asset: 'assets/images/BADGE_CONSISTENT_LEARNER.png',
          color: const Color(0xFFFF7043),
        ),
      ];
}
