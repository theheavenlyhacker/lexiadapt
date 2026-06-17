import 'package:lexiadapt/features/student/domain/entities/reading_result.dart';

abstract class SpeechRecognitionService {
  Future<ReadingResult> evaluateReading(String expectedText);
}
