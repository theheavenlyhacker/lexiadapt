import 'package:lexiadapt/core/database/local_database.dart';
import 'package:lexiadapt/core/services/audio_recorder_service.dart';
import 'package:lexiadapt/features/student/data/repositories/learner_repository_impl.dart';
import 'package:lexiadapt/features/student/data/services/onnx_difficulty_service.dart';
import 'package:lexiadapt/features/student/data/services/template_story_generator_service.dart';
import 'package:lexiadapt/features/student/data/services/whisper_speech_recognition_service.dart';
import 'package:lexiadapt/features/student/domain/learner_hmm.dart';
import 'package:lexiadapt/features/student/domain/repositories/learner_repository.dart';
import 'package:lexiadapt/features/student/domain/services/difficulty_service.dart';
import 'package:lexiadapt/features/student/domain/services/speech_recognition_service.dart';
import 'package:lexiadapt/features/student/domain/services/story_generator_service.dart';

class ServiceContainer {
  final LearnerRepository repository;
  final SpeechRecognitionService speechService;
  final DifficultyService difficultyService;
  final StoryGeneratorService storyService;
  final LearnerHMM hmm;
  final AudioRecorderService audioRecorder;

  ServiceContainer({
    required this.repository,
    required this.speechService,
    required this.difficultyService,
    required this.storyService,
    required this.hmm,
    required this.audioRecorder,
  });
}

ServiceContainer createServices() {
  final db = LocalDatabase.instance;
  final repository = LearnerRepositoryImpl(db);
  final hmm = LearnerHMM();

  return ServiceContainer(
    repository: repository,
    speechService: WhisperSpeechRecognitionService(),
    difficultyService: OnnxDifficultyService(),
    storyService: TemplateStoryGeneratorService(),
    hmm: hmm,
    audioRecorder: AudioRecorderService(),
  );
}
