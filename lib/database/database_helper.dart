import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/tournament.dart';
import '../models/team.dart';
import '../models/match.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('elboutoula.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tournaments ADD COLUMN use_roulette INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE tournaments ADD COLUMN roulette_pool TEXT');
      await db.execute('ALTER TABLE teams ADD COLUMN assigned_team TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE tournaments ADD COLUMN roulette_unique INTEGER NOT NULL DEFAULT 1');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE tournaments ADD COLUMN roulette_round_unique INTEGER NOT NULL DEFAULT 1');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS roulette_assignments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tournament_id INTEGER NOT NULL,
          team_id INTEGER NOT NULL,
          round_number INTEGER NOT NULL,
          assigned_team TEXT NOT NULL,
          UNIQUE(tournament_id, team_id, round_number) ON CONFLICT REPLACE,
          FOREIGN KEY (tournament_id) REFERENCES tournaments (id) ON DELETE CASCADE,
          FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Create tournaments table
    await db.execute('''
      CREATE TABLE tournaments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        legs INTEGER NOT NULL DEFAULT 1,
        points_for_win INTEGER NOT NULL DEFAULT 3,
        points_for_draw INTEGER NOT NULL DEFAULT 1,
        points_for_loss INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        use_roulette INTEGER NOT NULL DEFAULT 0,
        roulette_pool TEXT,
        roulette_unique INTEGER NOT NULL DEFAULT 1,
        roulette_round_unique INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create teams table
    await db.execute('''
      CREATE TABLE teams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        color_hex TEXT,
        assigned_team TEXT,
        FOREIGN KEY (tournament_id) REFERENCES tournaments (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE roulette_assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id INTEGER NOT NULL,
        team_id INTEGER NOT NULL,
        round_number INTEGER NOT NULL,
        assigned_team TEXT NOT NULL,
        UNIQUE(tournament_id, team_id, round_number) ON CONFLICT REPLACE,
        FOREIGN KEY (tournament_id) REFERENCES tournaments (id) ON DELETE CASCADE,
        FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE
      )
    ''');


    // Create matches table
    await db.execute('''
      CREATE TABLE matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id INTEGER NOT NULL,
        home_team_id INTEGER,
        away_team_id INTEGER,
        home_score INTEGER,
        away_score INTEGER,
        is_played INTEGER NOT NULL DEFAULT 0,
        round_number INTEGER NOT NULL,
        round_name TEXT NOT NULL,
        bracket_pos INTEGER,
        next_match_id INTEGER,
        next_match_is_home INTEGER,
        FOREIGN KEY (tournament_id) REFERENCES tournaments (id) ON DELETE CASCADE,
        FOREIGN KEY (home_team_id) REFERENCES teams (id) ON DELETE SET NULL,
        FOREIGN KEY (away_team_id) REFERENCES teams (id) ON DELETE SET NULL,
        FOREIGN KEY (next_match_id) REFERENCES matches (id) ON DELETE SET NULL
      )
    ''');
  }

  // --- Tournament Operations ---

  Future<int> insertTournament(Tournament tournament, [DatabaseExecutor? executor]) async {
    final db = executor ?? await instance.database;
    return await db.insert('tournaments', tournament.toMap());
  }

  Future<List<Tournament>> getAllTournaments() async {
    final db = await instance.database;
    final result = await db.query('tournaments', orderBy: 'created_at DESC');
    return result.map((json) => Tournament.fromMap(json)).toList();
  }

  Future<Tournament?> getTournament(int id, [DatabaseExecutor? executor]) async {
    final db = executor ?? await instance.database;
    final result = await db.query(
      'tournaments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Tournament.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<int> updateTournament(Tournament tournament, [DatabaseExecutor? executor]) async {
    final db = executor ?? await instance.database;
    return await db.update(
      'tournaments',
      tournament.toMap(),
      where: 'id = ?',
      whereArgs: [tournament.id],
    );
  }

  Future<int> deleteTournament(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tournaments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Team Operations ---

  Future<int> insertTeam(Team team, [DatabaseExecutor? executor]) async {
    final db = executor ?? await instance.database;
    return await db.insert('teams', team.toMap());
  }

  Future<List<Team>> getTeamsForTournament(int tournamentId) async {
    final db = await instance.database;
    final result = await db.query(
      'teams',
      where: 'tournament_id = ?',
      whereArgs: [tournamentId],
      orderBy: 'name ASC',
    );
    return result.map((json) => Team.fromMap(json)).toList();
  }

  Future<int> updateTeam(Team team, [DatabaseExecutor? executor]) async {
    final db = executor ?? await instance.database;
    return await db.update(
      'teams',
      team.toMap(),
      where: 'id = ?',
      whereArgs: [team.id],
    );
  }

  Future<int> deleteTeam(int id) async {
    final db = await instance.database;
    return await db.delete(
      'teams',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Match Operations ---

  Future<int> insertMatch(MatchModel match, [DatabaseExecutor? executor]) async {
    final db = executor ?? await instance.database;
    return await db.insert('matches', match.toMap());
  }

  Future<List<MatchModel>> getMatchesForTournament(int tournamentId) async {
    final db = await instance.database;
    final result = await db.query(
      'matches',
      where: 'tournament_id = ?',
      whereArgs: [tournamentId],
      orderBy: 'round_number ASC, bracket_pos ASC, id ASC',
    );
    return result.map((json) => MatchModel.fromMap(json)).toList();
  }

  Future<MatchModel?> getMatch(int id, [DatabaseExecutor? executor]) async {
    final db = executor ?? await instance.database;
    final result = await db.query(
      'matches',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return MatchModel.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<int> updateMatch(MatchModel match, [DatabaseExecutor? executor]) async {
    final db = executor ?? await instance.database;
    return await db.update(
      'matches',
      match.toMap(),
      where: 'id = ?',
      whereArgs: [match.id],
    );
  }

  // --- Roulette Assignments ---

  Future<List<Map<String, dynamic>>> getRouletteAssignmentsForTournament(int tournamentId) async {
    final db = await instance.database;
    return await db.query(
      'roulette_assignments',
      where: 'tournament_id = ?',
      whereArgs: [tournamentId],
      orderBy: 'round_number ASC, team_id ASC',
    );
  }

  Future<int> upsertRouletteAssignment({
    required int tournamentId,
    required int teamId,
    required int roundNumber,
    required String assignedTeam,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await instance.database;
    return await db.insert(
      'roulette_assignments',
      {
        'tournament_id': tournamentId,
        'team_id': teamId,
        'round_number': roundNumber,
        'assigned_team': assignedTeam,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteRouletteAssignments({
    required int tournamentId,
    int? roundNumber,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await instance.database;
    return await db.delete(
      'roulette_assignments',
      where: roundNumber == null ? 'tournament_id = ?' : 'tournament_id = ? AND round_number = ?',
      whereArgs: roundNumber == null ? [tournamentId] : [tournamentId, roundNumber],
    );
  }
}
