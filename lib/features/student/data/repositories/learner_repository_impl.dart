import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:lexiadapt/core/database/database_constants.dart';
import 'package:lexiadapt/core/database/local_database.dart';
import 'package:lexiadapt/features/student/domain/entities/learner_profile.dart';
import 'package:lexiadapt/features/student/domain/entities/reading_result.dart';
import 'package:lexiadapt/features/student/domain/repositories/learner_repository.dart';

class LearnerRepositoryImpl implements LearnerRepository {
  final LocalDatabase _db;

  LearnerRepositoryImpl(this._db);

  @override
  Future<bool> createAccount(
      String username, String displayName, String passwordHash, String role) async {
    final db = await _db.database;
    try {
      final id = username.toLowerCase().replaceAll(' ', '_');
      await db.insert(DbTables.userAccount, {
        'id': id,
        'username': username.toLowerCase(),
        'display_name': displayName,
        'password_hash': passwordHash,
        'role': role,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> authenticate(
      String username, String passwordHash) async {
    final db = await _db.database;
    final rows = await db.query(DbTables.userAccount,
        where: 'username = ? AND password_hash = ?',
        whereArgs: [username.toLowerCase(), passwordHash]);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  @override
  Future<bool> usernameExists(String username) async {
    final db = await _db.database;
    final rows = await db.query(DbTables.userAccount,
        where: 'username = ?', whereArgs: [username.toLowerCase()]);
    return rows.isNotEmpty;
  }

  @override
  Future<LearnerProfile?> getProfile(String id) async {
    final db = await _db.database;
    final rows =
        await db.query(DbTables.learner, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return LearnerProfile.fromMap(rows.first);
  }

  @override
  Future<void> saveProfile(LearnerProfile profile) async {
    final db = await _db.database;
    await db.insert(DbTables.learner, profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<ReadingResult>> getSessionHistory(String learnerId) async {
    final db = await _db.database;
    final rows = await db.query(DbTables.readingSession,
        where: 'learner_id = ?',
        whereArgs: [learnerId],
        orderBy: 'created_at DESC',
        limit: 50);

    return rows.map((r) {
      final tw = (jsonDecode(r['trouble_words'] as String? ?? '[]') as List)
          .map((e) =>
              TroubleWord(expected: e['expected'] ?? '', spoken: e['spoken'] ?? ''))
          .toList();
      return ReadingResult(
        storyText: r['story_text'] as String,
        spokenText: '',
        accuracy: (r['accuracy'] as num).toDouble(),
        wpm: (r['wpm'] as num).toDouble(),
        troubleWords: tw,
        durationMs: r['duration_ms'] as int? ?? 0,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
      );
    }).toList();
  }

  @override
  Future<void> saveSession(
      String learnerId, ReadingResult result, String? category) async {
    final db = await _db.database;
    await db.insert(DbTables.readingSession, {
      'learner_id': learnerId,
      'story_text': result.storyText,
      'category': category,
      'difficulty': 0,
      'accuracy': result.accuracy,
      'wpm': result.wpm,
      'trouble_words':
          jsonEncode(result.troubleWords.map((t) => t.toMap()).toList()),
      'duration_ms': result.durationMs,
      'created_at': result.timestamp.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> saveWordStates(
      String learnerId, Map<String, List<double>> states) async {
    final db = await _db.database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final entry in states.entries) {
      batch.insert(
          DbTables.wordMastery,
          {
            'learner_id': learnerId,
            'word': entry.key,
            'state_struggling': entry.value[0],
            'state_learning': entry.value[1],
            'state_mastered': entry.value[2],
            'last_seen': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<Map<String, List<double>>> getWordStates(String learnerId) async {
    final db = await _db.database;
    final rows = await db.query(DbTables.wordMastery,
        where: 'learner_id = ?', whereArgs: [learnerId]);
    final result = <String, List<double>>{};
    for (final r in rows) {
      result[r['word'] as String] = [
        (r['state_struggling'] as num).toDouble(),
        (r['state_learning'] as num).toDouble(),
        (r['state_mastered'] as num).toDouble(),
      ];
    }
    return result;
  }

  @override
  Future<List<String>> getEarnedBadgeIds(String learnerId) async {
    final db = await _db.database;
    final rows = await db.query(DbTables.achievement,
        where: 'learner_id = ?', whereArgs: [learnerId]);
    return rows.map((r) => r['badge_id'] as String).toList();
  }

  @override
  Future<void> unlockAchievement(String learnerId, String badgeId) async {
    final db = await _db.database;
    await db.insert(DbTables.achievement, {
      'learner_id': learnerId,
      'badge_id': badgeId,
      'earned_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<LearnerProfile>> getAllProfiles() async {
    final db = await _db.database;
    final rows = await db.query(DbTables.learner);
    return rows.map((r) => LearnerProfile.fromMap(r)).toList();
  }
}
