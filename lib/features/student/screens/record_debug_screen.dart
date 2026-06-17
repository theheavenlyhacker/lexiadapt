import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class RecordDebugScreen extends StatefulWidget {
  const RecordDebugScreen({super.key});
  @override
  State<RecordDebugScreen> createState() => _RecordDebugScreenState();
}

class _RecordDebugScreenState extends State<RecordDebugScreen> {
  final List<String> _logs = ['Tap button to test recording'];
  bool _recording = false;
  AudioRecorder? _rec;

  void _log(String msg) {
    debugPrint('[RecordDebug] $msg');
    setState(() => _logs.add(msg));
  }

  Future<void> _testRecord() async {
    _rec ??= AudioRecorder();
    setState(() => _logs.clear());

    try {
      _log('=== RECORD DEBUG ===');

      // 1. permission_handler
      var perm = await Permission.microphone.status;
      _log('1. Mic permission: $perm');
      if (!perm.isGranted) {
        perm = await Permission.microphone.request();
        _log('1b. After request: $perm');
      }
      if (!perm.isGranted) {
        _log('FAILED: No permission. Go to Settings > Apps > LexiAdapt > Permissions');
        return;
      }

      // 2. record package permission
      final recPerm = await _rec!.hasPermission();
      _log('2. record.hasPermission: $recPerm');

      // 3. Encoder check
      for (final enc in [AudioEncoder.wav, AudioEncoder.aacLc, AudioEncoder.opus]) {
        final ok = await _rec!.isEncoderSupported(enc);
        _log('3. ${enc.name} supported: $ok');
      }

      // 4. Start recording
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/debug_${DateTime.now().millisecondsSinceEpoch}.wav';
      _log('4. Path: $path');

      _log('5. Calling start()...');
      await _rec!.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
      setState(() => _recording = true);
      _log('6. start() returned OK. SPEAK NOW!');

      // Poll amplitude
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          final amp = await _rec!.getAmplitude();
          _log('   Amplitude[$i]: current=${amp.current.toStringAsFixed(1)} max=${amp.max.toStringAsFixed(1)}');
        } catch (e) {
          _log('   Amplitude error: $e');
        }
      }

      // Stop
      _log('7. Calling stop()...');
      final result = await _rec!.stop();
      setState(() => _recording = false);
      _log('8. stop() returned: $result');

      // Check file at our path
      final f1 = File(path);
      if (await f1.exists()) {
        final size = await f1.length();
        _log('9. File at path: $size bytes ${size > 1000 ? "OK" : "TOO SMALL"}');
      } else {
        _log('9. File NOT found at path');
      }

      // Check file at returned path
      if (result != null && result != path) {
        final f2 = File(result);
        if (await f2.exists()) {
          final size = await f2.length();
          _log('10. File at returned path: $size bytes');
        }
      }

      // List temp dir
      _log('11. Temp files:');
      final files = dir.listSync().where((f) => f.path.contains('debug_'));
      for (final f in files) {
        final stat = await f.stat();
        _log('    ${f.path.split('/').last}: ${stat.size} bytes');
      }

    } catch (e, st) {
      _log('ERROR: $e');
      _log(st.toString().split('\n').take(5).join('\n'));
    }
  }

  @override
  void dispose() {
    _rec?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Debug'),
        backgroundColor: Colors.red.shade100,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _recording ? null : _testRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _recording ? Colors.red : Colors.blue,
                ),
                child: Text(
                  _recording ? 'RECORDING... (5 sec)' : 'START RECORD TEST',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _logs[i],
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: _logs[i].contains('ERROR') || _logs[i].contains('FAILED')
                        ? Colors.red
                        : _logs[i].contains('OK') || _logs[i].contains('SUCCESS')
                            ? Colors.green
                            : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
