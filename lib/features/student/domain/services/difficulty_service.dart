import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';

abstract class DifficultyService {
  int getNextDifficulty(LearnerProfile profile);
}
