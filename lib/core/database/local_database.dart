import 'package:sqflite/sqflite.dart';
import 'package:lexiadapt/core/database/database_constants.dart';

class LocalDatabase {
  static LocalDatabase? _instance;
  Database? _database;

  LocalDatabase._();

  static LocalDatabase get instance => _instance ??= LocalDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      '$dbPath/lexiadapt.db',
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE ${DbTables.userAccount} (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'student',
        created_at INTEGER NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE ${DbTables.learner} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        grade INTEGER NOT NULL DEFAULT 2,
        language TEXT DEFAULT 'en',
        overall_accuracy REAL DEFAULT 0.0,
        phonics_score REAL DEFAULT 0.0,
        vocabulary_score REAL DEFAULT 0.0,
        comprehension_score REAL DEFAULT 0.0,
        fluency_wpm REAL DEFAULT 0,
        current_difficulty REAL DEFAULT 0.3,
        consecutive_successes INTEGER DEFAULT 0,
        consecutive_failures INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        total_sessions INTEGER DEFAULT 0,
        day_streak INTEGER DEFAULT 0,
        last_session_date TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE ${DbTables.wordMastery} (
        learner_id TEXT REFERENCES ${DbTables.learner}(id),
        word TEXT NOT NULL,
        state_struggling REAL DEFAULT 0.7,
        state_learning REAL DEFAULT 0.2,
        state_mastered REAL DEFAULT 0.1,
        attempts INTEGER DEFAULT 0,
        last_seen INTEGER,
        PRIMARY KEY (learner_id, word)
      )
    ''');

    batch.execute('''
      CREATE TABLE ${DbTables.readingSession} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        learner_id TEXT REFERENCES ${DbTables.learner}(id),
        story_text TEXT NOT NULL,
        category TEXT,
        difficulty REAL,
        accuracy REAL,
        wpm REAL,
        trouble_words TEXT,
        duration_ms INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE ${DbTables.achievement} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        learner_id TEXT REFERENCES ${DbTables.learner}(id),
        badge_id TEXT NOT NULL,
        earned_at INTEGER NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE ${DbTables.flWeightDelta} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        model_name TEXT NOT NULL,
        delta_blob BLOB NOT NULL,
        created_at INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${DbTables.userAccount} (
          id TEXT PRIMARY KEY,
          username TEXT NOT NULL UNIQUE,
          display_name TEXT NOT NULL,
          password_hash TEXT NOT NULL,
          role TEXT NOT NULL DEFAULT 'student',
          created_at INTEGER NOT NULL
        )
      ''');
      // Add last_session_date column for streak tracking
      try {
        await db.execute(
            'ALTER TABLE ${DbTables.learner} ADD COLUMN last_session_date TEXT');
      } catch (_) {}
    }
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
