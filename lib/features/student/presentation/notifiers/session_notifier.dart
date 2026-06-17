import 'package:flutter/foundation.dart';
import 'package:lexiadapt/core/services/audio_recorder_service.dart';
import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';
import 'package:lexiadapt/features/student/domain/entities/reading_result.dart';
import 'package:lexiadapt/features/student/domain/entities/story.dart';
import 'package:lexiadapt/features/student/domain/learner_hmm.dart';
import 'package:lexiadapt/features/student/domain/services/speech_recognition_service.dart';
import 'package:lexiadapt/features/student/domain/services/difficulty_service.dart';
import 'package:lexiadapt/features/student/domain/services/story_generator_service.dart';
import 'package:lexiadapt/features/student/domain/repositories/learner_repository.dart';
import 'package:lexiadapt/features/student/data/services/whisper_speech_recognition_service.dart';

enum SessionState { idle, recording, evaluating, results }

class SessionNotifier extends ChangeNotifier {
  final SpeechRecognitionService speechService;
  final DifficultyService difficultyService;
  final StoryGeneratorService storyService;
  final LearnerRepository repository;
  final LearnerHMM hmm;
  final AudioRecorderService audioRecorder;
  LearnerProfile profile;

  Story? currentStory;
  Story? _nextStory;
  ReadingResult? lastResult;
  SessionState state = SessionState.idle;
  StoryCategory? _currentCategory;
  DateTime? _recordingStartTime;

  Stream<double> get amplitudeStream => audioRecorder.amplitudeStream;

  SessionNotifier({
    required this.speechService,
    required this.difficultyService,
    required this.storyService,
    required this.repository,
    required this.hmm,
    required this.audioRecorder,
    required this.profile,
  });

  Future<void> startSession(StoryCategory category) async {
    _currentCategory = category;
    final wordStates = await repository.getWordStates(profile.id);
    hmm.importWordStates(wordStates);

    currentStory = await storyService.generateStory(
      category: category,
      difficulty: profile.currentDifficulty,
      troubleWords: hmm.getTroubleWords(),
    );
    lastResult = null;
    state = SessionState.idle;
    notifyListeners();
  }

  Future<void> startRecording() async {
    final started = await audioRecorder.startRecording();
    if (started) {
      _recordingStartTime = DateTime.now();
      state = SessionState.recording;
      debugPrint('[Session] Recording started — read the story aloud, tap mic to stop');
    } else {
      debugPrint('[Session] Could not start recording');
    }
    notifyListeners();
  }

  Future<void> stopRecordingAndEvaluate() async {
    if (currentStory == null) return;

    final audioPath = await audioRecorder.stopRecording();
    debugPrint('[Session] Audio saved: $audioPath');

    state = SessionState.evaluating;
    notifyListeners();

    // Pass audio path and timing to Whisper
    if (speechService case final WhisperSpeechRecognitionService whisper) {
      whisper.setAudioPath(audioPath);
      whisper.setRecordingStartTime(_recordingStartTime);
    }

    final result = await speechService.evaluateReading(currentStory!.text);

    debugPrint('[Session] Result: accuracy=${result.accuracy}, wpm=${result.wpm}, '
        'spoken="${result.spokenText}", troubles=${result.troubleWords.length}');

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
