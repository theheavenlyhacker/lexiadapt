import 'dart:math';

class LearnerHMM {
  static const int struggling = 0;
  static const int learning = 1;
  static const int mastered = 2;

  static const _transition = [
    [0.6, 0.3, 0.1],
    [0.1, 0.5, 0.4],
    [0.05, 0.15, 0.8],
  ];

  static const _emission = [
    [0.7, 0.2, 0.1],
    [0.2, 0.5, 0.3],
    [0.05, 0.15, 0.8],
  ];

  final Map<String, List<double>> _wordBeliefs = {};

  int update(String word, int observation) {
    final belief = _wordBeliefs[word] ?? [0.7, 0.2, 0.1];

    final predicted = List.filled(3, 0.0);
    for (int j = 0; j < 3; j++) {
      for (int i = 0; i < 3; i++) {
        predicted[j] += belief[i] * _transition[i][j];
      }
    }

    final updated = List.filled(3, 0.0);
    double sum = 0;
    for (int j = 0; j < 3; j++) {
      updated[j] = predicted[j] * _emission[j][observation.clamp(0, 2)];
      sum += updated[j];
    }
    if (sum > 0) {
      for (int j = 0; j < 3; j++) {
        updated[j] /= sum;
      }
    }

    _wordBeliefs[word] = updated;
    return _argmax(updated);
  }

  List<String> getTroubleWords() {
    return _wordBeliefs.entries
        .where((e) => _argmax(e.value) == struggling)
        .map((e) => e.key)
        .toList();
  }

  int getWordState(String word) {
    final belief = _wordBeliefs[word];
    if (belief == null) return struggling;
    return _argmax(belief);
  }

  Map<String, double> getSkillScores() {
    if (_wordBeliefs.isEmpty) {
      return {
        'phonics': 0.0,
        'vocabulary': 0.0,
        'comprehension': 0.0,
        'fluency': 0.0,
      };
    }

    double masteredCount = 0;
    double learningCount = 0;
    for (final belief in _wordBeliefs.values) {
      if (_argmax(belief) == mastered) masteredCount++;
      if (_argmax(belief) == learning) learningCount++;
    }
    final total = _wordBeliefs.length;
    final base = (masteredCount + learningCount * 0.5) / total;

    final rng = Random(total);
    return {
      'phonics': (base + rng.nextDouble() * 0.15).clamp(0.0, 1.0),
      'vocabulary': (base - 0.05 + rng.nextDouble() * 0.1).clamp(0.0, 1.0),
      'comprehension': (base + 0.03 + rng.nextDouble() * 0.1).clamp(0.0, 1.0),
      'fluency': (base - 0.1 + rng.nextDouble() * 0.15).clamp(0.0, 1.0),
    };
  }

  Map<String, List<double>> exportWordStates() =>
      Map.unmodifiable(_wordBeliefs);

  void importWordStates(Map<String, List<double>> states) {
    _wordBeliefs.clear();
    _wordBeliefs.addAll(states);
  }

  static int _argmax(List<double> v) {
    int idx = 0;
    for (int i = 1; i < v.length; i++) {
      if (v[i] > v[idx]) idx = i;
    }
    return idx;
  }
}
