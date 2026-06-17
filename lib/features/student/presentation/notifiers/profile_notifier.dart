import 'package:flutter/foundation.dart';
import 'package:lexiadapt/features/student/domain/entities/achievement.dart';
import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';
import 'package:lexiadapt/features/student/domain/repositories/learner_repository.dart';

class ProfileNotifier extends ChangeNotifier {
  final LearnerRepository _repository;
  LearnerProfile? _profile;

  ProfileNotifier(this._repository);

  LearnerProfile? get profile => _profile;
  bool get isLoaded => _profile != null;

  Future<void> loadOrCreate(String id, String name) async {
    _profile = await _repository.getProfile(id);
    if (_profile == null) {
      _profile = LearnerProfile(id: id, name: name);
      await _repository.saveProfile(_profile!);
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_profile == null) return;
    _profile = await _repository.getProfile(_profile!.id);
    notifyListeners();
  }

  Future<List<Achievement>> getAchievements() async {
    if (_profile == null) return Achievement.allAchievements();
    final earned = await _repository.getEarnedBadgeIds(_profile!.id);
    final all = Achievement.allAchievements();
    for (final a in all) {
      a.isEarned = earned.contains(a.badgeId);
    }
    return all;
  }
}
