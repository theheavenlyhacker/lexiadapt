import 'package:flutter/foundation.dart';
import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';
import 'package:lexiadapt/features/student/domain/entities/reading_result.dart';
import 'package:lexiadapt/features/student/domain/entities/story.dart';
import 'package:lexiadapt/features/student/domain/learner_hmm.dart';
import 'package:lexiadapt/features/student/domain/services/speech_recognition_service.dart';
import 'package:lexiadapt/features/student/domain/services/difficulty_service.dart';
import 'package:lexiadapt/features/student/domain/services/story_generator_service.dart';
import 'package:lexiadapt/features/student/domain/repositories/learner_repository.dart';
import 'package:lexiadapt/features/student/data/services/mock_speech_recognition_service.dart';

enum SessionState { idle, recording, evaluating, results }

class SessionNotifier extends ChangeNotifier {
  final SpeechRecognitionService speechService;
  final DifficultyService difficultyService;
  final StoryGeneratorService storyService;
  final LearnerRepository repository;
  final LearnerHMM hmm;
  LearnerProfile profile;

  Story? currentStory;
  Story? _nextStory;
  ReadingResult? lastResult;
  SessionState state = SessionState.idle;
  StoryCategory? _currentCategory;

  SessionNotifier({
    required this.speechService,
    required this.difficultyService,
    required this.storyService,
    required this.repository,
    required this.hmm,
    required this.profile,
  });

  Future<void> startSession(StoryCategory category) async {
    _currentCategory = category;
    final wordStates = await repository.getWordStates(profile.id);
    hmm.importWordStates(wordStates);

    if (speechService case final MockSpeechRecognitionService mock) {
      mock.difficultyHint = profile.currentDifficulty;
    }

    currentStory = await storyService.generateStory(
      category: category,
      difficulty: profile.currentDifficulty,
      troubleWords: hmm.getTroubleWords(),
    );
    lastResult = null;
    state = SessionState.idle;
    notifyListeners();
  }

  void startRecording() {
    state = SessionState.recording;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      if (state == SessionState.recording) {
        stopRecordingAndEvaluate();
      }
    });
  }

  Future<void> stopRecordingAndEvaluate() async {
    if (currentStory == null) return;

    state = SessionState.evaluating;
    notifyListeners();

    if (speechService case final MockSpeechRecognitionService mock) {
      mock.difficultyHint = profile.currentDifficulty;
    }

    final result =
        await speechService.evaluateReading(currentStory!.text);

    for (final word in currentStory!.text.split(RegExp(r'\s+'))) {
      final clean = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
      if (clean.isEmpty) continue;
      hmm.update(clean, result.observationForWord(clean));
    }

    await repository.saveSession(
        profile.id, result, _currentCategory?.name);
    await repository.saveWordStates(profile.id, hmm.exportWordStates());

    profile.updateFromAccuracy(result.accuracy);
    final skills = hmm.getSkillScores();
    profile.phonicsScore = skills['phonics']!;
    profile.vocabularyScore = skills['vocabulary']!;
    profile.comprehensionScore = skills['comprehension']!;
    await repository.saveProfile(profile);

    final action = difficultyService.getNextDifficulty(profile);
    profile.applyDifficultyAction(action);

    _nextStory = await storyService.generateStory(
      category: _currentCategory ?? StoryCategory.animals,
      difficulty: profile.currentDifficulty,
      troubleWords: hmm.getTroubleWords(),
    );

    await _checkAchievements(result);

    lastResult = result;
    state = SessionState.results;
    notifyListeners();
  }

  void nextStory() {
    currentStory = _nextStory;
    _nextStory = null;
    lastResult = null;
    state = SessionState.idle;
    notifyListeners();
  }

  Future<void> _checkAchievements(ReadingResult result) async {
    final earned = await repository.getEarnedBadgeIds(profile.id);

    if (!earned.contains('voice_star') && profile.totalSessions >= 5) {
      await repository.unlockAchievement(profile.id, 'voice_star');
    }
    if (!earned.contains('bookworm') && profile.totalSessions >= 10) {
      await repository.unlockAchievement(profile.id, 'bookworm');
    }
    if (!earned.contains('perfect') && result.accuracy >= 1.0) {
      await repository.unlockAchievement(profile.id, 'perfect');
    }
    if (!earned.contains('streak_7') && profile.dayStreak >= 7) {
      await repository.unlockAchievement(profile.id, 'streak_7');
    }
    if (!earned.contains('rising_reader') && profile.overallAccuracy >= 0.7) {
      await repository.unlockAchievement(profile.id, 'rising_reader');
    }
  }
}
