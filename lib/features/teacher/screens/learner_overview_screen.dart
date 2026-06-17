import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';

class LearnerOverviewScreen extends StatelessWidget {
  const LearnerOverviewScreen({super.key});

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
        title: const Text("Learner's Overview",
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
            // Student profile
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFF26A69A),
                    child: Text('JM',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22)),
                  ),
                  const SizedBox(height: 10),
                  const Text('Juan Miguel',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text('Grade 2 Student',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stats
            Row(
              children: [
                Expanded(
                    child: _statCard(
                        '58%', 'Accuracy', AppColors.success)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statCard(
                        '12', 'Sessions', AppColors.primaryBlue)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statCard(
                        '4', 'Day Streak', AppColors.orange)),
              ],
            ),
            const SizedBox(height: 24),
            // Top struggle words
            const Text('Top Struggle Words',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _wordChip('table', const Color(0xFF26A69A)),
                _wordChip('beautiful', const Color(0xFF26A69A)),
                _wordChip('feeling', const Color(0xFF26A69A)),
                _wordChip('rock', const Color(0xFFEF5350)),
                _wordChip('shut', const Color(0xFFEF5350)),
              ],
            ),
            const SizedBox(height: 24),
            // Accuracy over time
            const Text('Accuracy over time',
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
                  _weekBar('Week 1', 0.45, '45%', const Color(0xFFEF5350)),
                  const SizedBox(height: 12),
                  _weekBar('Week 2', 0.52, '52%', const Color(0xFFFF9800)),
                  const SizedBox(height: 12),
                  _weekBar('Week 3', 0.58, '58%', const Color(0xFFFF9800)),
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
        border: Border(left: BorderSide(color: color, width: 4)),
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

  Widget _wordChip(String word, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(word,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _weekBar(String label, double value, String percent, Color color) {
    return Row(
      children: [
        SizedBox(
            width: 52,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8E8E8),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
            width: 36,
            child: Text(percent,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
