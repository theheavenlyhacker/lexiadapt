import 'package:flutter_test/flutter_test.dart';
import 'package:lexiadapt/features/student/domain/learner_hmm.dart';

void main() {
  group('LearnerHMM', () {
    late LearnerHMM hmm;

    setUp(() => hmm = LearnerHMM());

    test('new word starts as struggling', () {
      final state = hmm.getWordState('hello');
      expect(state, LearnerHMM.struggling);
    });

    test('repeated correct observations move word toward mastered', () {
      for (int i = 0; i < 10; i++) {
        hmm.update('hello', 2); // observation 2 = correct
      }
      expect(hmm.getWordState('hello'), LearnerHMM.mastered);
    });

    test('repeated incorrect observations keep word struggling', () {
      for (int i = 0; i < 5; i++) {
        hmm.update('difficult', 0); // observation 0 = incorrect
      }
      expect(hmm.getWordState('difficult'), LearnerHMM.struggling);
    });

    test('getTroubleWords returns struggling words', () {
      hmm.update('easy', 2);
      hmm.update('easy', 2);
      hmm.update('easy', 2);
      hmm.update('hard', 0);
      hmm.update('hard', 0);

      final trouble = hmm.getTroubleWords();
      expect(trouble, contains('hard'));
      expect(trouble, isNot(contains('easy')));
    });

    test('getSkillScores returns values in 0-1 range', () {
      hmm.update('word1', 2);
      hmm.update('word2', 0);
      hmm.update('word3', 1);

      final scores = hmm.getSkillScores();
      expect(scores.keys, containsAll(['phonics', 'vocabulary', 'comprehension', 'fluency']));
      for (final v in scores.values) {
        expect(v, greaterThanOrEqualTo(0.0));
        expect(v, lessThanOrEqualTo(1.0));
      }
    });

    test('export and import preserves state', () {
      hmm.update('cat', 2);
      hmm.update('cat', 2);
      hmm.update('dog', 0);

      final exported = hmm.exportWordStates();
      final hmm2 = LearnerHMM();
      hmm2.importWordStates(Map.from(exported.map((k, v) => MapEntry(k, List<double>.from(v)))));

      expect(hmm2.getWordState('cat'), hmm.getWordState('cat'));
      expect(hmm2.getWordState('dog'), hmm.getWordState('dog'));
    });
  });
}
