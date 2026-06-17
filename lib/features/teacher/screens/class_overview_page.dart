import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/features/teacher/screens/learner_overview_screen.dart';

class ClassOverviewPage extends StatelessWidget {
  final Widget? leading;
  const ClassOverviewPage({super.key, this.leading});

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
        title: const Text('Class Overview',
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
            // Teacher profile
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFE8F0FE),
                    child: Icon(Icons.person_rounded,
                        size: 40, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 10),
                  const Text('Maicca Pimentel',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text('Ms. Pimentel · Grade 2 · 24 Students',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stat cards
            Row(
              children: [
                Expanded(
                    child: _statCard(
                        '78%', 'Avg Accuracy', AppColors.success)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statCard(
                        '18', 'Active Today', AppColors.primaryBlue)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statCard(
                        '6', 'Need Help', AppColors.error)),
              ],
            ),
            const SizedBox(height: 24),
            // Learners needing support
            const Text("Learner's needing support",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _learnerRow(context, 'JM', 'Juan M.',
                'Struggles: english words', 58, const Color(0xFF26A69A)),
            _learnerRow(context, 'AL', 'Anna L.',
                'Struggles: kulay', 67, const Color(0xFF7E57C2)),
            _learnerRow(context, 'RC', 'Ronald M.',
                'Missed 3 days', 71, const Color(0xFFEF5350)),
            _learnerRow(context, 'MD', 'Mark M.',
                'Missed 4 days', 80, const Color(0xFF66BB6A)),
            const SizedBox(height: 24),
            // Weekly class accuracy
            const Text('Weekly class accuracy',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
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
              child: Column(
                children: [
                  _weeklyBar('Mon', 0.88, '88%'),
                  const SizedBox(height: 10),
                  _weeklyBar('Tue', 0.72, '72%'),
                  const SizedBox(height: 10),
                  _weeklyBar('Wed', 0.85, '85%'),
                  const SizedBox(height: 10),
                  _weeklyBar('Thu', 0.78, '78%'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _learnerRow(BuildContext context, String initials, String name,
      String detail, int percent, Color avatarColor) {
    Color badgeColor;
    if (percent < 60) {
      badgeColor = const Color(0xFFEF5350);
    } else if (percent < 76) {
      badgeColor = const Color(0xFFFF9800);
    } else {
      badgeColor = const Color(0xFF66BB6A);
    }

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const LearnerOverviewScreen())),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor,
              child: Text(initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
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
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$percent%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weeklyBar(String day, double value, String label) {
    return Row(
      children: [
        SizedBox(
            width: 32,
            child: Text(day,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8E8E8),
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFF5BB8C4)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
            width: 36,
            child: Text(label,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
