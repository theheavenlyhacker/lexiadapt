class LearnerProfile {
  final String id;
  final String name;
  final int grade;
  final String language;
  double overallAccuracy;
  double phonicsScore;
  double vocabularyScore;
  double comprehensionScore;
  double fluencyWpm;
  double currentDifficulty;
  int consecutiveSuccesses;
  int consecutiveFailures;
  int level;
  int totalSessions;
  int dayStreak;
  String? lastSessionDate;
  final DateTime createdAt;

  LearnerProfile({
    required this.id,
    required this.name,
    this.grade = 2,
    this.language = 'en',
    this.overallAccuracy = 0.0,
    this.phonicsScore = 0.0,
    this.vocabularyScore = 0.0,
    this.comprehensionScore = 0.0,
    this.fluencyWpm = 0,
    this.currentDifficulty = 0.3,
    this.consecutiveSuccesses = 0,
    this.consecutiveFailures = 0,
    this.level = 1,
    this.totalSessions = 0,
    this.dayStreak = 0,
    this.lastSessionDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  void applyDifficultyAction(int action) {
    final delta = (action - 2) * 0.1;
    currentDifficulty = (currentDifficulty + delta).clamp(0.0, 1.0);
  }

  void updateFromAccuracy(double accuracy) {
    totalSessions++;
    overallAccuracy =
        ((overallAccuracy * (totalSessions - 1)) + accuracy) / totalSessions;

    if (accuracy >= 0.7) {
      consecutiveSuccesses++;
      consecutiveFailures = 0;
    } else {
      consecutiveFailures++;
      consecutiveSuccesses = 0;
    }

    level = switch (overallAccuracy) {
      >= 0.9 => 5,
      >= 0.8 => 4,
      >= 0.65 => 3,
      >= 0.5 => 2,
      _ => 1,
    };

    _updateStreak();
  }

  void _updateStreak() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastSessionDate == today) return;

    if (lastSessionDate != null) {
      final lastDate = DateTime.parse(lastSessionDate!);
      final diff = DateTime.now().difference(lastDate).inDays;
      if (diff == 1) {
        dayStreak++;
      } else if (diff > 1) {
        dayStreak = 1;
      }
    } else {
      dayStreak = 1;
    }
    lastSessionDate = today;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'grade': grade,
        'language': language,
        'overall_accuracy': overallAccuracy,
        'phonics_score': phonicsScore,
        'vocabulary_score': vocabularyScore,
        'comprehension_score': comprehensionScore,
        'fluency_wpm': fluencyWpm,
        'current_difficulty': currentDifficulty,
        'consecutive_successes': consecutiveSuccesses,
        'consecutive_failures': consecutiveFailures,
        'level': level,
        'total_sessions': totalSessions,
        'day_streak': dayStreak,
        'last_session_date': lastSessionDate,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory LearnerProfile.fromMap(Map<String, dynamic> m) => LearnerProfile(
        id: m['id'] as String,
        name: m['name'] as String,
        grade: m['grade'] as int,
        language: m['language'] as String,
        overallAccuracy: (m['overall_accuracy'] as num).toDouble(),
        phonicsScore: (m['phonics_score'] as num).toDouble(),
        vocabularyScore: (m['vocabulary_score'] as num).toDouble(),
        comprehensionScore: (m['comprehension_score'] as num).toDouble(),
        fluencyWpm: (m['fluency_wpm'] as num).toDouble(),
        currentDifficulty: (m['current_difficulty'] as num).toDouble(),
        consecutiveSuccesses: m['consecutive_successes'] as int,
        consecutiveFailures: m['consecutive_failures'] as int,
        level: m['level'] as int,
        totalSessions: m['total_sessions'] as int,
        dayStreak: m['day_streak'] as int,
        lastSessionDate: m['last_session_date'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}
