import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/profile_notifier.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/session_notifier.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/progress_notifier.dart';
import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';
import 'package:lexiadapt/features/student/domain/entities/reading_result.dart';
import 'package:lexiadapt/features/student/domain/repositories/learner_repository.dart';
import 'package:lexiadapt/features/student/data/services/mock_speech_recognition_service.dart';
import 'package:lexiadapt/features/student/data/services/mock_difficulty_service.dart';
import 'package:lexiadapt/features/student/data/services/template_story_generator_service.dart';
import 'package:lexiadapt/features/student/domain/learner_hmm.dart';
import 'package:lexiadapt/features/auth/screens/role_selection_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App renders role selection screen', (WidgetTester tester) async {
    final hmm = LearnerHMM();
    final mockRepo = _InMemoryRepo();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProfileNotifier(mockRepo)),
          ChangeNotifierProvider(
            create: (_) => SessionNotifier(
              speechService: MockSpeechRecognitionService(),
              difficultyService: MockDifficultyService(),
              storyService: TemplateStoryGeneratorService(),
              repository: mockRepo,
              hmm: hmm,
              profile: LearnerProfile(id: 'test', name: 'Test'),
            ),
          ),
          ChangeNotifierProvider(
              create: (_) => ProgressNotifier(mockRepo, hmm)),
        ],
        child: const MaterialApp(home: RoleSelectionScreen()),
      ),
    );

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text("I'm a Student"), findsOneWidget);
    expect(find.text("I'm a Teacher"), findsOneWidget);
  });
}

class _InMemoryRepo implements LearnerRepository {
  final Map<String, LearnerProfile> _profiles = {};

  @override
  Future<LearnerProfile?> getProfile(String id) async => _profiles[id];
  @override
  Future<void> saveProfile(LearnerProfile p) async => _profiles[p.id] = p;
  @override
  Future<List<ReadingResult>> getSessionHistory(String id) async => [];
  @override
  Future<void> saveSession(String id, ReadingResult r, String? c) async {}
  @override
  Future<void> saveWordStates(String id, Map<String, List<double>> s) async {}
  @override
  Future<Map<String, List<double>>> getWordStates(String id) async => {};
  @override
  Future<List<String>> getEarnedBadgeIds(String id) async => [];
  @override
  Future<void> unlockAchievement(String id, String badge) async {}
  @override
  Future<List<LearnerProfile>> getAllProfiles() async =>
      _profiles.values.toList();
}
