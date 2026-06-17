import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lexiadapt/core/di/service_locator.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/profile_notifier.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/session_notifier.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/progress_notifier.dart';
import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';
import 'package:lexiadapt/features/auth/screens/role_selection_screen.dart';

class LexiAdaptApp extends StatelessWidget {
  final ServiceContainer services;
  const LexiAdaptApp({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ProfileNotifier(services.repository)),
        ChangeNotifierProxyProvider<ProfileNotifier, SessionNotifier>(
          create: (ctx) => SessionNotifier(
            speechService: services.speechService,
            difficultyService: services.difficultyService,
            storyService: services.storyService,
            repository: services.repository,
            hmm: services.hmm,
            audioRecorder: services.audioRecorder,
            profile: LearnerProfile(id: 'default', name: 'Student'),
          ),
          update: (ctx, profile, session) {
            if (profile.profile != null) {
              session!.profile = profile.profile!;
            }
            return session!;
          },
        ),
        ChangeNotifierProvider(
            create: (_) => ProgressNotifier(services.repository, services.hmm)),
      ],
      child: MaterialApp(
        title: 'LexiAdapt',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const RoleSelectionScreen(),
      ),
    );
  }
}
