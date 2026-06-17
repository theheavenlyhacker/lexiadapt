import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/core/painters/waveform_painter.dart';

class ReadingSessionScreen extends StatefulWidget {
  const ReadingSessionScreen({super.key});

  @override
  State<ReadingSessionScreen> createState() => _ReadingSessionScreenState();
}

class _ReadingSessionScreenState extends State<ReadingSessionScreen> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Story illustration placeholder (replace with asset)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.skyTop, AppColors.success],
              ),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4)),
              ],
            ),
            child: Stack(
              children: [
                const Center(
                    child: Icon(Icons.image_outlined,
                        size: 60, color: Color(0x8AFFFFFF))),
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x4D000000),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Story illustration',
                          style: TextStyle(
                              color: Color(0xB3FFFFFF), fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Story text with highlighted word
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                    height: 1.4),
                children: [
                  TextSpan(text: 'The boy sees a '),
                  TextSpan(
                      text: 'big',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue)),
                  TextSpan(text: ' fish.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Audio waveform visualization
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              height: 50,
              child: CustomPaint(
                size: const Size(double.infinity, 50),
                painter: WaveformPainter(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 32),
                color: Colors.grey[600],
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _isPlaying = !_isPlaying),
                child: Container(
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
                      _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 32),
                color: Colors.grey[600],
                onPressed: () {},
              ),
            ],
          ),
          const Spacer(),
          // Microphone button for read-aloud (AI: Whisper-tiny will process audio)
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.navyBlue]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Color(0x735B9BD5),
                    blurRadius: 16,
                    offset: Offset(0, 5)),
              ],
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 12),
          Text('Tap to read aloud',
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
