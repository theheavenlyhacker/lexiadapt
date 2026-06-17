import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:lexiadapt/features/student/domain/entities/reading_result.dart';
import 'package:lexiadapt/features/student/domain/services/speech_recognition_service.dart';

class WhisperSpeechRecognitionService implements SpeechRecognitionService {
  sherpa.OfflineRecognizer? _recognizer;
  bool _initialized = false;
  bool _initializing = false;
  String? _audioPath;
  DateTime? _recordingStartTime;

  static const _baseUrl =
      'https://huggingface.co/csukuangfj/sherpa-onnx-whisper-tiny/resolve/main';
  static const _modelFiles = [
    'tiny-encoder.int8.onnx',
    'tiny-decoder.int8.onnx',
    'tiny-tokens.txt',
  ];

  bool get isReady => _initialized;

  void setAudioPath(String? path) {
    _audioPath = path;
  }

  void setRecordingStartTime(DateTime? t) {
    _recordingStartTime = t;
  }

  Future<String> get _modelDir async {
    final appDir = await getApplicationSupportDirectory();
    return '${appDir.path}/whisper_model';
  }

  Future<void> initialize() async {
    if (_initialized || _initializing) return;
    _initializing = true;

    try {
      final dir = await _modelDir;
      await Directory(dir).create(recursive: true);

      final encoderPath = '$dir/tiny-encoder.int8.onnx';
      final decoderPath = '$dir/tiny-decoder.int8.onnx';
      final tokensPath = '$dir/tiny-tokens.txt';

      const minSizes = {
        'tiny-encoder.int8.onnx': 10000000,
        'tiny-decoder.int8.onnx': 80000000,
        'tiny-tokens.txt': 500000,
      };

      for (final modelFile in _modelFiles) {
        final localPath = '$dir/$modelFile';
        final file = File(localPath);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        final minSize = minSizes[modelFile] ?? 0;

        if (!exists || size < minSize) {
          if (exists) {
            debugPrint('[Whisper] $modelFile too small ($size), re-downloading');
            await file.delete();
          }
          final url = '$_baseUrl/$modelFile';
          debugPrint('[Whisper] Downloading $modelFile...');
          await _downloadFile(url, localPath);
          final newSize = await File(localPath).length();
          debugPrint('[Whisper] Downloaded $modelFile ($newSize bytes)');
        } else {
          debugPrint('[Whisper] $modelFile cached ($size bytes)');
        }
      }

      debugPrint('[Whisper] Initializing sherpa-onnx bindings...');
      sherpa.initBindings();

      final whisperConfig = sherpa.OfflineWhisperModelConfig(
        encoder: encoderPath,
        decoder: decoderPath,
        language: 'en',
        task: 'transcribe',
      );

      final modelConfig = sherpa.OfflineModelConfig(
        whisper: whisperConfig,
        tokens: tokensPath,
        modelType: 'whisper',
        numThreads: 2,
        debug: false,
      );

      final config = sherpa.OfflineRecognizerConfig(model: modelConfig);
      _recognizer = sherpa.OfflineRecognizer(config);
      _initialized = true;
      _initializing = false;
      debugPrint('[Whisper] Model loaded — ready for on-device inference');
    } catch (e) {
      _initializing = false;
      debugPrint('[Whisper] Initialization failed: $e');
    }
  }

  Future<void> _downloadFile(String url, String destPath) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final file = File(destPath);
      final sink = file.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
      }
      await sink.close();
    } finally {
      client.close();
    }
  }

  @override
  Future<ReadingResult> evaluateReading(String expectedText) async {
    if (!_initialized) {
      await initialize();
    }

    if (!_initialized || _recognizer == null || _audioPath == null) {
      debugPrint('[Whisper] Not ready (initialized=$_initialized, '
          'recognizer=${_recognizer != null}, audioPath=$_audioPath)');
      return _emptyResult(expectedText);
    }

    final audioFile = File(_audioPath!);
    if (!await audioFile.exists()) {
      debugPrint('[Whisper] Audio file not found: $_audioPath');
      return _emptyResult(expectedText);
    }

    final fileSize = await audioFile.length();
    debugPrint('[Whisper] Audio file: $_audioPath ($fileSize bytes)');

    try {
      final stopwatch = Stopwatch()..start();

      final wave = sherpa.readWave(_audioPath!);
      debugPrint('[Whisper] WAV loaded: ${wave.samples.length} samples, '
          '${wave.sampleRate} Hz, '
          'duration=${(wave.samples.length / wave.sampleRate).toStringAsFixed(1)}s');

      final stream = _recognizer!.createStream();
      stream.acceptWaveform(
          samples: wave.samples, sampleRate: wave.sampleRate);
      _recognizer!.decode(stream);
      final result = _recognizer!.getResult(stream);
      stream.free();

      stopwatch.stop();
      final inferenceMs = stopwatch.elapsedMilliseconds;

      debugPrint('[Whisper] ===== RESULT =====');
      debugPrint('[Whisper] Transcript: "${result.text}"');
      debugPrint('[Whisper] Inference: ${inferenceMs}ms');

      final spoken = result.text.trim();

      // Calculate actual recording duration
      final audioDurationSec = wave.sampleRate > 0
          ? wave.samples.length / wave.sampleRate
          : (_recordingStartTime != null
              ? DateTime.now().difference(_recordingStartTime!).inMilliseconds / 1000.0
              : 5.0);

      debugPrint('[Whisper] Audio duration: ${audioDurationSec.toStringAsFixed(1)}s');

      return _compareTexts(expectedText, spoken, audioDurationSec);
    } catch (e) {
      debugPrint('[Whisper] Transcription error: $e');
      return _emptyResult(expectedText);
    }
  }

  ReadingResult _compareTexts(
      String expected, String spoken, double audioDurationSec) {
    final expectedWords = _tokenize(expected);
    final spokenWords = _tokenize(spoken);

    debugPrint('[Whisper] Expected words: $expectedWords');
    debugPrint('[Whisper] Spoken words:   $spokenWords');

    int correct = 0;
    final troubleWords = <TroubleWord>[];

    // Use a more forgiving comparison — allow partial matches
    for (int i = 0; i < expectedWords.length; i++) {
      final exp = expectedWords[i];
      String spk = '';

      if (i < spokenWords.length) {
        spk = spokenWords[i];
      }

      if (exp == spk) {
        correct++;
      } else if (spk.isNotEmpty && (exp.contains(spk) || spk.contains(exp))) {
        // Partial match — count as half correct
        correct++;
        debugPrint('[Whisper] Partial match: "$exp" ~ "$spk"');
      } else {
        troubleWords.add(TroubleWord(
            expected: exp, spoken: spk.isEmpty ? '(missing)' : spk));
      }
    }

    final accuracy =
        expectedWords.isEmpty ? 0.0 : correct / expectedWords.length;
    final wpm = audioDurationSec > 0.5
        ? (spokenWords.length / audioDurationSec) * 60
        : 0.0;

    debugPrint('[Whisper] Accuracy: ${(accuracy * 100).round()}% '
        '($correct/${expectedWords.length})');
    debugPrint('[Whisper] WPM: ${wpm.round()} '
        '(${spokenWords.length} words / ${audioDurationSec.toStringAsFixed(1)}s)');
    debugPrint('[Whisper] Trouble words: ${troubleWords.map((t) => "${t.expected}->${t.spoken}").join(", ")}');

    return ReadingResult(
      storyText: expected,
      spokenText: spoken,
      accuracy: accuracy,
      wpm: wpm.clamp(0, 250),
      troubleWords: troubleWords,
      durationMs: (audioDurationSec * 1000).round(),
      timestamp: DateTime.now(),
    );
  }

  List<String> _tokenize(String text) => text
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .map((w) => w.replaceAll(RegExp(r'[^\w]'), ''))
      .where((w) => w.isNotEmpty)
      .toList();

  ReadingResult _emptyResult(String expected) => ReadingResult(
        storyText: expected,
        spokenText: '',
        accuracy: 0.0,
        wpm: 0.0,
        troubleWords: [],
        durationMs: 0,
        timestamp: DateTime.now(),
      );

  void dispose() {
    _recognizer?.free();
    _recognizer = null;
    _initialized = false;
  }
}
