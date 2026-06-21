import 'package:flutter/foundation.dart';
import 'package:lexiadapt/features/student/domain/repositories/learner_repository.dart';
import 'package:lexiadapt/features/student/domain/learner_hmm.dart';

class ProgressNotifier extends ChangeNotifier {
  final LearnerRepository _repository;
  final LearnerHMM _hmm;

  List<double> accuracyHistory = [];
  Map<String, double> skillScores = {
    'phonics': 0.0,
    'vocabulary': 0.0,
    'comprehension': 0.0,
    'fluency': 0.0,
  };

  ProgressNotifier(this._repository, this._hmm);

  Future<void> load(String learnerId) async {
    final sessions = await _repository.getSessionHistory(learnerId);
    accuracyHistory = sessions.reversed
        .map((s) => s.accuracy)
        .toList();

    if (accuracyHistory.isEmpty) {
      accuracyHistory = [0.0];
    }

    final wordStates = await _repository.getWordStates(learnerId);
    _hmm.importWordStates(wordStates);
    skillScores = _hmm.getSkillScores();

    notifyListeners();
  }
}
