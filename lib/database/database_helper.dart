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
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
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
        status TEXT NOT NULL DEFAULT 'active'
      )
    ''');

    // Create teams table
    await db.execute('''
      CREATE TABLE teams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        color_hex TEXT,
        FOREIGN KEY (tournament_id) REFERENCES tournaments (id) ON DELETE CASCADE
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

  Future<int> updateTournament(Tournament tournament) async {
    final db = await instance.database;
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
}
