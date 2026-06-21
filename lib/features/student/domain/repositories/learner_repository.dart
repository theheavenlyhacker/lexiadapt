import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';
import 'package:lexiadapt/features/student/domain/entities/reading_result.dart';

abstract class LearnerRepository {
  // Auth
  Future<bool> createAccount(String username, String displayName, String passwordHash, String role);
  Future<Map<String, dynamic>?> authenticate(String username, String passwordHash);
  Future<bool> usernameExists(String username);

  // Profile
  Future<LearnerProfile?> getProfile(String id);
  Future<void> saveProfile(LearnerProfile profile);
  Future<List<LearnerProfile>> getAllProfiles();

  // Sessions
  Future<List<ReadingResult>> getSessionHistory(String learnerId);
  Future<void> saveSession(String learnerId, ReadingResult result, String? category);

  // Word mastery
  Future<void> saveWordStates(String learnerId, Map<String, List<double>> states);
  Future<Map<String, List<double>>> getWordStates(String learnerId);

  // Achievements
  Future<List<String>> getEarnedBadgeIds(String learnerId);
  Future<void> unlockAchievement(String learnerId, String badgeId);
}
