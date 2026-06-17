import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/core/painters/waveform_painter.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/session_notifier.dart';

class ReadingSessionScreen extends StatelessWidget {
  const ReadingSessionScreen({super.key});

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
          : Column(
              children: [
                const SizedBox(height: 8),
                _buildIllustration(story.imageAsset),
                const SizedBox(height: 24),
                _buildStoryText(story.text, session),
                const SizedBox(height: 24),
                _buildWaveform(session.state),
                const SizedBox(height: 8),
                _buildControls(context, session),
                const Spacer(),
                if (session.state == SessionState.results)
                  _buildResultsBanner(session),
                _buildMicButton(context, session),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildIllustration(String asset) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 220,
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
        child: Image.asset(asset, fit: BoxFit.cover, width: double.infinity, cacheWidth: 540),
      ),
    );
  }

  Widget _buildStoryText(String text, SessionNotifier session) {
    final troubleWords = session.lastResult?.troubleWords
            .map((t) => t.expected.toLowerCase())
            .toSet() ??
        {};
    final highlights =
        session.currentStory?.highlightWords.map((w) => w.toLowerCase()).toSet() ??
            {};
    final allHighlights = {...troubleWords, ...highlights};

    final words = text.split(RegExp(r'(\s+)'));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
              height: 1.4),
          children: words.map((word) {
            final clean =
                word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
            final isHighlight = allHighlights.contains(clean);
            return TextSpan(
              text: '$word ',
              style: isHighlight
                  ? const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                      backgroundColor: Color(0x1A1565C0))
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWaveform(SessionState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        height: 50,
        child: CustomPaint(
          size: const Size(double.infinity, 50),
          painter: WaveformPainter(
            progress: state == SessionState.recording ? 0.8 : 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, SessionNotifier session) {
    if (session.state == SessionState.evaluating) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Evaluating your reading...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (session.state == SessionState.results) {
      return ElevatedButton.icon(
        onPressed: () => session.nextStory(),
        icon: const Icon(Icons.arrow_forward, size: 20),
        label: const Text('Next Story'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded, size: 32),
          color: Colors.grey[600],
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Color(0x665B9BD5),
                  blurRadius: 10,
                  offset: Offset(0, 3)),
            ],
          ),
          child: Icon(
              session.state == SessionState.recording
                  ? Icons.pause
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, size: 32),
          color: Colors.grey[600],
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildResultsBanner(SessionNotifier session) {
    final result = session.lastResult!;
    final pct = (result.accuracy * 100).round();
    final color = pct >= 80
        ? AppColors.success
        : (pct >= 60 ? AppColors.orange : const Color(0xFFEF5350));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(14),
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
          Text('$pct%',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${result.wpm.round()} WPM',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                if (result.troubleWords.isNotEmpty)
                  Text(
                      'Trouble: ${result.troubleWords.map((t) => t.expected).join(", ")}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Image.asset('assets/images/star_cute.png', width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _buildMicButton(BuildContext context, SessionNotifier session) {
    final isRecording = session.state == SessionState.recording;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (session.state == SessionState.idle) {
              session.startRecording();
            } else if (isRecording) {
              session.stopRecordingAndEvaluate();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isRecording ? 80 : 72,
            height: isRecording ? 80 : 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: isRecording
                      ? [const Color(0xFFEF5350), const Color(0xFFC62828)]
                      : [AppColors.primaryBlue, AppColors.navyBlue]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: isRecording
                        ? const Color(0x73EF5350)
                        : const Color(0x735B9BD5),
                    blurRadius: 16,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: Icon(isRecording ? Icons.stop : Icons.mic,
                color: Colors.white, size: 34),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isRecording ? 'Listening...' : 'Tap to read aloud',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }
}
