import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';

class StudentRewardsScreen extends StatelessWidget {
  const StudentRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Rewards',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('My Badges',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _badge(Icons.star_rounded, AppColors.warning, 'Gold Star'),
                _badge(Icons.emoji_events, const Color(0xFF78909C), 'Silver'),
                _badge(Icons.workspace_premium, AppColors.error, 'Bronze'),
                _badge(Icons.auto_awesome, AppColors.primaryBlue, 'Streak'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Achievements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _achievementTile(
                Icons.menu_book, AppColors.primaryBlue, 'Bookworm',
                'Read 10 stories', true),
            _achievementTile(
                Icons.mic, AppColors.success, 'Voice Star',
                'Complete 5 read-aloud sessions', true),
            _achievementTile(
                Icons.trending_up, AppColors.purple, 'Rising Reader',
                'Improve accuracy by 10%', true),
            _achievementTile(
                Icons.local_fire_department, AppColors.error, '7-Day Streak',
                'Read every day for a week', false),
            _achievementTile(
                Icons.diamond, AppColors.warning, 'Perfect Score',
                'Get 100% accuracy on a story', false),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, Color color, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Color.fromRGBO(
                color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.15),
            shape: BoxShape.circle,
            border: Border.all(
                color: Color.fromRGBO(
                    color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.4),
                width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _achievementTile(
      IconData icon, Color color, String title, String subtitle, bool done) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                  color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? AppColors.success : Colors.grey[300],
            size: 24,
          ),
        ],
      ),
    );
  }
}
