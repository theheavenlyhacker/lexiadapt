import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/core/painters/area_chart_painter.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/profile_notifier.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/progress_notifier.dart';

class StudentProgressScreen extends StatefulWidget {
  const StudentProgressScreen({super.key});

  @override
  State<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen> {
  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileNotifier>().profile;
    if (profile != null) {
      context.read<ProgressNotifier>().load(profile.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileNotifier>().profile;
    final progress = context.watch<ProgressNotifier>();
    final pct = ((profile?.overallAccuracy ?? 0.5) * 100).round();
    final level = profile?.level ?? 1;

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
        title: const Text('My Progress',
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
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Overall Accuracy',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x2666BB6A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$pct%',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.successDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: CustomPaint(
                      size: const Size(double.infinity, 120),
                      painter: AreaChartPainter(
                        data: progress.accuracyHistory.isEmpty
                            ? [0.5]
                            : progress.accuracyHistory,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Level',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...List.generate(
                          level,
                          (_) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Image.asset(
                                    'assets/images/star_cute.png',
                                    width: 32,
                                    height: 32),
                              )),
                      ...List.generate(
                          (5 - level).clamp(0, 5),
                          (_) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Opacity(
                                  opacity: 0.25,
                                  child: Image.asset(
                                      'assets/images/star_cute.png',
                                      width: 32,
                                      height: 32),
                                ),
                              )),
                      const Spacer(),
                      Text('Level $level',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Skills',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _skillBar('Phonics',
                      progress.skillScores['phonics'] ?? 0.5, AppColors.success),
                  const SizedBox(height: 12),
                  _skillBar('Vocabulary',
                      progress.skillScores['vocabulary'] ?? 0.5, AppColors.primaryBlue),
                  const SizedBox(height: 12),
                  _skillBar('Comprehension',
                      progress.skillScores['comprehension'] ?? 0.5, AppColors.purple),
                  const SizedBox(height: 12),
                  _skillBar('Fluency',
                      progress.skillScores['fluency'] ?? 0.5, AppColors.orange),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }

  Widget _skillBar(String name, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text('${(value * 100).round()}%',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: Color.fromRGBO(
                color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
