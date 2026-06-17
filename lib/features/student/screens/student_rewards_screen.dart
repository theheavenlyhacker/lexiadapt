import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/features/student/domain/entities/achievement.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/profile_notifier.dart';

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
      body: FutureBuilder<List<Achievement>>(
        future: context.read<ProfileNotifier>().getAchievements(),
        builder: (context, snapshot) {
          final achievements =
              snapshot.data ?? Achievement.allAchievements();
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text('My Badges',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _imageBadge(
                        'assets/images/star_cute.png', 'Gold Star'),
                    _imageBadge(
                        'assets/images/coin_trophy.png', 'Champion'),
                    _imageBadge('assets/images/fire.png', 'Streak'),
                    _imageBadge('assets/images/strong.png', 'Strong'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Achievements',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                ...achievements.map((a) => _achievementTile(a)),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _imageBadge(String asset, String label) {
    return Column(
      children: [
        Image.asset(asset, width: 60, height: 60, fit: BoxFit.contain),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _achievementTile(Achievement a) {
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
              color: Color.fromRGBO(a.color.r.toInt(), a.color.g.toInt(),
                  a.color.b.toInt(), 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(a.icon, color: a.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(a.description,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Icon(
            a.isEarned
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: a.isEarned ? AppColors.success : Colors.grey[300],
            size: 24,
          ),
        ],
      ),
    );
  }
}
