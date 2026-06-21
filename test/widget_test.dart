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
import 'package:lexiadapt/core/services/audio_recorder_service.dart';
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
              audioRecorder: AudioRecorderService(),
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
  final Map<String, Map<String, dynamic>> _accounts = {};

  @override
  Future<bool> createAccount(String username, String displayName, String passwordHash, String role) async {
    if (_accounts.containsKey(username.toLowerCase())) return false;
    final id = username.toLowerCase().replaceAll(' ', '_');
    _accounts[username.toLowerCase()] = {
      'id': id, 'username': username.toLowerCase(),
      'display_name': displayName, 'password_hash': passwordHash, 'role': role,
    };
    return true;
  }
  @override
  Future<Map<String, dynamic>?> authenticate(String username, String passwordHash) async {
    final account = _accounts[username.toLowerCase()];
    if (account != null && account['password_hash'] == passwordHash) return account;
    return null;
  }
  @override
  Future<bool> usernameExists(String username) async =>
      _accounts.containsKey(username.toLowerCase());
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
