import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';
import 'package:lexiadapt/features/student/domain/entities/reading_result.dart';

abstract class LearnerRepository {
  Future<LearnerProfile?> getProfile(String id);
  Future<void> saveProfile(LearnerProfile profile);
  Future<List<ReadingResult>> getSessionHistory(String learnerId);
  Future<void> saveSession(String learnerId, ReadingResult result, String? category);
  Future<void> saveWordStates(String learnerId, Map<String, List<double>> states);
  Future<Map<String, List<double>>> getWordStates(String learnerId);
  Future<List<String>> getEarnedBadgeIds(String learnerId);
  Future<void> unlockAchievement(String learnerId, String badgeId);
  Future<List<LearnerProfile>> getAllProfiles();
}
