class TroubleWord {
  final String expected;
  final String spoken;

  const TroubleWord({required this.expected, required this.spoken});

  Map<String, dynamic> toMap() => {'expected': expected, 'spoken': spoken};

  factory TroubleWord.fromMap(Map<String, dynamic> m) =>
      TroubleWord(expected: m['expected'] as String, spoken: m['spoken'] as String);
}

class ReadingResult {
  final String storyText;
  final String spokenText;
  final double accuracy;
  final double wpm;
  final List<TroubleWord> troubleWords;
  final int durationMs;
  final DateTime timestamp;

  const ReadingResult({
    required this.storyText,
    required this.spokenText,
    required this.accuracy,
    required this.wpm,
    required this.troubleWords,
    required this.durationMs,
    required this.timestamp,
  });

  int observationForWord(String word) {
    final isTrouble = troubleWords.any((t) => t.expected == word);
    if (isTrouble) return 0;
    if (wpm < 60) return 1;
    return 2;
  }
}
