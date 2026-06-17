import 'package:lexiadapt/features/student/domain/entities/story.dart';

abstract class StoryGeneratorService {
  Future<Story> generateStory({
    required StoryCategory category,
    required double difficulty,
    required List<String> troubleWords,
  });
}
