import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/session_notifier.dart';

class ReadingSessionScreen extends StatefulWidget {
  const ReadingSessionScreen({super.key});

  @override
  State<ReadingSessionScreen> createState() => _ReadingSessionScreenState();
}

class _ReadingSessionScreenState extends State<ReadingSessionScreen> {
  final List<double> _amplitudeHistory = List.generate(40, (_) => 0.0);
  StreamSubscription<double>? _ampSub;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionNotifier>();
    _ampSub = session.amplitudeStream.listen((amp) {
      setState(() {
        _amplitudeHistory.removeAt(0);
        _amplitudeHistory.add(amp);
      });
    });
  }

  @override
  void dispose() {
    _ampSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionNotifier>();
    final story = session.currentStory;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Reading Session',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
      ),
      body: story == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildIllustration(story.imageAsset),
                    const SizedBox(height: 20),
                    _buildStoryText(story.text, session),
                    const SizedBox(height: 20),
                    _buildAudioVisualizer(session.state),
                    const SizedBox(height: 8),
                    _buildStatusText(session.state),
                    const SizedBox(height: 16),
                    if (session.state == SessionState.results)
                      _buildResultsBanner(session),
                    if (session.state == SessionState.results)
                      _buildNextButton(session),
                    if (session.state == SessionState.evaluating)
                      _buildEvaluatingIndicator(),
                    const SizedBox(height: 16),
                    _buildMicButton(session),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildIllustration(String asset) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(asset,
            fit: BoxFit.cover, width: double.infinity, cacheWidth: 540),
      ),
    );
  }

  Widget _buildStoryText(String text, SessionNotifier session) {
    final troubleSet = session.lastResult?.troubleWords
            .map((t) => t.expected.toLowerCase())
            .toSet() ??
        {};
    final highlightSet = session.currentStory?.highlightWords
            .map((w) => w.toLowerCase())
            .toSet() ??
        {};
    final allHighlights = {...troubleSet, ...highlightSet};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
              height: 1.5),
          children: text.split(RegExp(r'(\s+)')).map((word) {
            final clean =
                word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
            final isTrouble = troubleSet.contains(clean);
            final isHighlight = allHighlights.contains(clean);
            return TextSpan(
              text: '$word ',
              style: isTrouble
                  ? const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF5350),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFEF5350))
                  : isHighlight
                      ? const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue)
                      : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAudioVisualizer(SessionState sessionState) {
    final isActive = sessionState == SessionState.recording;
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFF3E0) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? const Color(0xFFFF9800)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_amplitudeHistory.length, (i) {
          final amp = isActive ? _amplitudeHistory[i] : 0.05;
          final height = (amp * 55).clamp(3.0, 55.0);
          final color = isActive
              ? Color.lerp(
                  const Color(0xFF66BB6A), const Color(0xFFEF5350), amp)!
              : const Color(0xFFBDBDBD);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: 5,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatusText(SessionState sessionState) {
    final text = switch (sessionState) {
      SessionState.idle => 'Tap the microphone and read the story aloud',
      SessionState.recording => 'Listening... tap mic when done',
      SessionState.evaluating => 'Analyzing your reading...',
      SessionState.results => 'Reading complete!',
    };
    final color = switch (sessionState) {
      SessionState.recording => const Color(0xFFEF5350),
      SessionState.evaluating => AppColors.orange,
      SessionState.results => AppColors.success,
      _ => Colors.grey[500]!,
    };
    return Text(text, style: TextStyle(fontSize: 13, color: color));
  }

  Widget _buildResultsBanner(SessionNotifier session) {
    final result = session.lastResult!;
    final pct = (result.accuracy * 100).round();
    final color = pct >= 80
        ? AppColors.success
        : (pct >= 60 ? AppColors.orange : const Color(0xFFEF5350));
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
            color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Color.fromRGBO(
                color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.3)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text('$pct%',
                  style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold, color: color)),
              Text('accuracy',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 4),
                    Text('${result.wpm.round()} WPM',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                if (result.troubleWords.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: result.troubleWords.take(5).map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF5350),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(t.expected,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                  ),
                ],
                if (result.spokenText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Heard: "${result.spokenText}"',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          Image.asset('assets/images/star_cute.png',
              width: 40, height: 40, cacheWidth: 80),
        ],
      ),
    );
  }

  Widget _buildNextButton(SessionNotifier session) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => session.nextStory(),
        icon: const Icon(Icons.arrow_forward, size: 20),
        label: const Text('Next Story'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildEvaluatingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3)),
          SizedBox(height: 8),
          Text('Whisper AI is analyzing...',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMicButton(SessionNotifier session) {
    final isRecording = session.state == SessionState.recording;
    final isIdle = session.state == SessionState.idle;
    final canTap = isIdle || isRecording;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isRecording ? 88 : 72,
      height: isRecording ? 88 : 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: isRecording
                ? [const Color(0xFFEF5350), const Color(0xFFC62828)]
                : canTap
                    ? [AppColors.primaryBlue, AppColors.navyBlue]
                    : [Colors.grey, Colors.grey.shade600]),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: isRecording
                  ? const Color(0x73EF5350)
                  : const Color(0x735B9BD5),
              blurRadius: isRecording ? 24 : 16,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: canTap
              ? () {
                  if (isIdle) {
                    session.startRecording();
                  } else if (isRecording) {
                    session.stopRecordingAndEvaluate();
                  }
                }
              : null,
          customBorder: const CircleBorder(),
          splashColor: const Color(0x33FFFFFF),
          child: Center(
            child: Icon(
              isRecording ? Icons.stop_rounded : Icons.mic,
              color: Colors.white,
              size: isRecording ? 40 : 34,
            ),
          ),
        ),
      ),
    );
  }
}
