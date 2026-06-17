import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  AudioRecorder? _recorder;
  String? _currentPath;
  bool _isRecording = false;

  StreamSubscription? _ampSub;
  final _amplitudeController = StreamController<double>.broadcast();

  bool get isRecording => _isRecording;
  String? get lastRecordingPath => _currentPath;
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  AudioRecorder get _rec {
    _recorder ??= AudioRecorder();
    return _recorder!;
  }

  Future<bool> _ensurePermission() async {
    // Use permission_handler for reliable Android runtime permissions
    var status = await Permission.microphone.status;
    debugPrint('[Audio] Permission status: $status');

    if (status.isDenied) {
      status = await Permission.microphone.request();
      debugPrint('[Audio] Permission after request: $status');
    }

    if (status.isPermanentlyDenied) {
      debugPrint('[Audio] Permission permanently denied — open settings');
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  Future<bool> startRecording() async {
    try {
      final hasPermission = await _ensurePermission();
      if (!hasPermission) {
        debugPrint('[Audio] No microphone permission');
        return false;
      }

      final dir = await getTemporaryDirectory();
      _currentPath =
          '${dir.path}/reading_${DateTime.now().millisecondsSinceEpoch}.wav';

      debugPrint('[Audio] Starting recording to: $_currentPath');

      await _rec.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 256000,
        ),
        path: _currentPath!,
      );

      _isRecording = true;

      // Use built-in amplitude stream
      _ampSub = _rec
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen((amp) {
        // amp.current is dBFS: -160 (silence) to 0 (max)
        final normalized = ((amp.current + 50) / 50).clamp(0.0, 1.0);
        _amplitudeController.add(normalized);
      });

      debugPrint('[Audio] Recording started successfully');
      return true;
    } catch (e, st) {
      debugPrint('[Audio] Start error: $e');
      debugPrint('[Audio] Stack: $st');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    await _ampSub?.cancel();
    _ampSub = null;
    _amplitudeController.add(0.0);

    if (!_isRecording) {
      debugPrint('[Audio] Not recording, nothing to stop');
      return null;
    }

    try {
      final path = await _rec.stop();
      _isRecording = false;
      debugPrint('[Audio] Stopped. Returned path: $path');
      debugPrint('[Audio] Expected path: $_currentPath');

      // Verify the file exists and has content
      final file = File(_currentPath!);
      if (await file.exists()) {
        final size = await file.length();
        debugPrint('[Audio] File size: $size bytes');
        if (size < 100) {
          debugPrint('[Audio] WARNING: File too small, recording may have failed');
        }
      } else {
        debugPrint('[Audio] WARNING: File does not exist at $_currentPath');
        // Try the path returned by stop()
        if (path != null && await File(path).exists()) {
          _currentPath = path;
          debugPrint('[Audio] Using returned path instead: $path');
        }
      }

      return _currentPath;
    } catch (e) {
      debugPrint('[Audio] Stop error: $e');
      _isRecording = false;
      return null;
    }
  }

  Future<void> dispose() async {
    await _ampSub?.cancel();
    if (_isRecording) await stopRecording();
    await _amplitudeController.close();
    _recorder?.dispose();
    _recorder = null;
  }
}
