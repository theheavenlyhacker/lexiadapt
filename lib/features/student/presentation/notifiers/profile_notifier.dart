import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:lexiadapt/features/student/domain/entities/achievement.dart';
import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';
import 'package:lexiadapt/features/student/domain/repositories/learner_repository.dart';

class ProfileNotifier extends ChangeNotifier {
  final LearnerRepository _repository;
  LearnerProfile? _profile;
  String? _currentRole;

  ProfileNotifier(this._repository);

  LearnerProfile? get profile => _profile;
  String? get currentRole => _currentRole;
  bool get isLoaded => _profile != null;

  static String hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<String?> signUp(String displayName, String username, String password, String role) async {
    if (username.trim().isEmpty || password.isEmpty || displayName.trim().isEmpty) {
      return 'All fields are required';
    }
    if (password.length < 4) return 'Password must be at least 4 characters';
    if (await _repository.usernameExists(username)) {
      return 'Username already taken';
    }
    final hash = hashPassword(password);
    final ok = await _repository.createAccount(username, displayName.trim(), hash, role);
    if (!ok) return 'Could not create account';

    final id = username.toLowerCase().replaceAll(' ', '_');
    _profile = LearnerProfile(id: id, name: displayName.trim());
    await _repository.saveProfile(_profile!);
    _currentRole = role;
    notifyListeners();
    return null;
  }

  Future<String?> login(String username, String password, String role) async {
    if (username.trim().isEmpty || password.isEmpty) {
      return 'Enter username and password';
    }
    final hash = hashPassword(password);
    final account = await _repository.authenticate(username, hash);
    if (account == null) return 'Invalid username or password';

    final accountRole = account['role'] as String;
    if (accountRole != role) return 'This account is registered as a $accountRole';

    final id = account['id'] as String;
    final displayName = account['display_name'] as String;
    _profile = await _repository.getProfile(id);
    if (_profile == null) {
      _profile = LearnerProfile(id: id, name: displayName);
      await _repository.saveProfile(_profile!);
    }
    _currentRole = role;
    notifyListeners();
    return null;
  }

  void logout() {
    _profile = null;
    _currentRole = null;
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
