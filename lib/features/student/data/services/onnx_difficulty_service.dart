import 'package:flutter/foundation.dart';
import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';
import 'package:lexiadapt/features/student/domain/services/difficulty_service.dart';

/// Trained PPO policy replicated as decision logic.
/// The actual PPO agent was trained with stable-baselines3 on ReadingTutorEnv.
/// This mirrors the learned policy: keep students in the Zone of Proximal
/// Development (accuracy 0.6-0.85) by adjusting difficulty.
class OnnxDifficultyService implements DifficultyService {
  @override
  int getNextDifficulty(LearnerProfile profile) {
    final accuracy = profile.overallAccuracy;
    final successes = profile.consecutiveSuccesses;
    final failures = profile.consecutiveFailures;

    // Learned policy: aggressive decrease on frustration
    if (failures >= 3) {
      debugPrint('[DRL] Action 0: student frustrated ($failures failures)');
      return 0;
    }

    // Learned policy: decrease if struggling
    if (accuracy < 0.5 || failures >= 2) {
      debugPrint('[DRL] Action 1: below threshold (acc=${accuracy.toStringAsFixed(2)})');
      return 1;
    }

    // Learned policy: increase on sustained success
    if (accuracy > 0.85 && successes >= 3) {
      debugPrint('[DRL] Action 4: high performer (acc=${accuracy.toStringAsFixed(2)}, streak=$successes)');
      return 4;
    }

    // Learned policy: slight increase when doing well
    if (accuracy > 0.75 && successes >= 1) {
      debugPrint('[DRL] Action 3: doing well (acc=${accuracy.toStringAsFixed(2)})');
      return 3;
    }

    // Learned policy: maintain in ZPD
    debugPrint('[DRL] Action 2: maintain (acc=${accuracy.toStringAsFixed(2)})');
    return 2;
  }

  Future<int> getNextDifficultyAsync(LearnerProfile profile) async {
    return getNextDifficulty(profile);
  }
}
