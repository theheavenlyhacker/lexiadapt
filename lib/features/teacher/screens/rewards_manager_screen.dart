import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';

class RewardsManagerScreen extends StatelessWidget {
  const RewardsManagerScreen({super.key});

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
        title: const Text('Rewards Manager',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Class progress card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFFB300), size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Class Progress',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                            'Keep it up! Your class is doing great!',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500])),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: const LinearProgressIndicator(
                                  value: 0.85,
                                  minHeight: 10,
                                  backgroundColor: Color(0xFFE0E0E0),
                                  valueColor: AlwaysStoppedAnimation(
                                      AppColors.primaryBlue),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('85%',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // My Badges
            const Text('My Badges',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _badgeItem(
                  icon: Icons.directions_walk_rounded,
                  color: const Color(0xFF8D6E63),
                  label: 'First Steps',
                  subtitle: 'Complete 5 lessons',
                ),
                _badgeItem(
                  icon: Icons.looks_one_rounded,
                  color: const Color(0xFF66BB6A),
                  label: 'Consistent Learner',
                  subtitle: '7-day streak',
                  overlayText: '7',
                ),
                _badgeItem(
                  icon: Icons.headphones_rounded,
                  color: const Color(0xFF42A5F5),
                  label: 'Good Listener',
                  subtitle: 'Read 10 stories',
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Recent Achievements
            const Text('Recent Achievements',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.primaryBlue, width: 1.5),
              ),
              child: Column(
                children: [
                  _achievementRow('JM', 'Juan M.', 'Earned Start Reader',
                      58, const Color(0xFF26A69A), true),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _achievementRow('AL', 'Anna L.', 'Earned', 67,
                      const Color(0xFF7E57C2), false),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _achievementRow('RC', 'Ronald M.', 'Missed 3 days', 71,
                      const Color(0xFFEF5350), false),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _achievementRow('MD', 'Mark M.', 'Missed 4 days', 80,
                      const Color(0xFF66BB6A), false),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Add badge button
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF26A69A), Color(0xFF00897B)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x4D26A69A),
                        blurRadius: 10,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_rounded,
                        color: Color(0xFFFFD54F), size: 24),
                    SizedBox(width: 10),
                    Text('Add a new badge',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _badgeItem({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    String? overlayText,
  }) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor:
                    Color.fromRGBO(color.r.toInt(), color.g.toInt(),
                        color.b.toInt(), 0.15),
                child: Icon(icon, color: color, size: 30),
              ),
              if (overlayText != null)
                Positioned(
                  bottom: 2,
                  right: 14,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(overlayText,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _achievementRow(String initials, String name, String detail,
      int percent, Color avatarColor, bool isFirst) {
    Color badgeColor;
    if (percent < 60) {
      badgeColor = const Color(0xFFEF5350);
    } else if (percent < 76) {
      badgeColor = const Color(0xFFFF9800);
    } else {
      badgeColor = const Color(0xFF66BB6A);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: avatarColor,
            child: Text(initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(detail,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$percent%',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
