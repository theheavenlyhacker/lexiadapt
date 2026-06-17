import 'dart:math';
import 'package:lexiadapt/features/student/domain/entities/reading_result.dart';
import 'package:lexiadapt/features/student/domain/services/speech_recognition_service.dart';

class MockSpeechRecognitionService implements SpeechRecognitionService {
  final Random _rng = Random();
  double difficultyHint;

  MockSpeechRecognitionService({this.difficultyHint = 0.3});

  @override
  Future<ReadingResult> evaluateReading(String expectedText) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final words = expectedText.split(RegExp(r'\s+'));
    final targetAccuracy = (0.9 - difficultyHint * 0.4).clamp(0.4, 0.95);
    final troubleWords = <TroubleWord>[];
    final spokenWords = <String>[];

    for (final word in words) {
      final clean = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
      if (clean.isEmpty) {
        spokenWords.add(word);
        continue;
      }
      if (_rng.nextDouble() > targetAccuracy) {
        final mangled = _mangle(clean);
        troubleWords.add(TroubleWord(expected: clean, spoken: mangled));
        spokenWords.add(mangled);
      } else {
        spokenWords.add(word);
      }
    }

    final accuracy = words.isEmpty
        ? 0.0
        : (words.length - troubleWords.length) / words.length;
    final wpm = 50.0 + _rng.nextDouble() * 70 * (1.0 - difficultyHint * 0.3);

    return ReadingResult(
      storyText: expectedText,
      spokenText: spokenWords.join(' '),
      accuracy: accuracy,
      wpm: wpm,
      troubleWords: troubleWords,
      durationMs: (words.length / (wpm / 60) * 1000).round(),
      timestamp: DateTime.now(),
    );
  }

  String _mangle(String word) {
    if (word.length <= 2) return '${word}s';
    final i = _rng.nextInt(word.length);
    return word.replaceRange(i, i + 1, '');
  }
}
