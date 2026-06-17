import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';
import 'package:lexiadapt/features/student/domain/services/difficulty_service.dart';

class MockDifficultyService implements DifficultyService {
  @override
  int getNextDifficulty(LearnerProfile profile) {
    if (profile.overallAccuracy > 0.85 && profile.consecutiveSuccesses >= 2) {
      return profile.overallAccuracy > 0.92 ? 4 : 3;
    }
    if (profile.overallAccuracy < 0.5 || profile.consecutiveFailures >= 2) {
      return profile.consecutiveFailures >= 3 ? 0 : 1;
    }
    return 2;
  }
}
