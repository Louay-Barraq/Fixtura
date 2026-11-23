import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

/// Thrown when a file is not a Fixtura backup or cannot be read as one.
class InvalidBackupException implements Exception {
  final String reason;
  const InvalidBackupException(this.reason);

  @override
  String toString() => 'InvalidBackupException: $reason';
}

/// Exports every tournament to a JSON document and imports such documents
/// back, adding the tournaments they hold next to the ones already saved.
///
/// Rows are copied column by column, so a backup keeps every field the
/// database has, and importing an older or newer backup only uses the
/// columns this version of the app knows about.
class BackupService {
  static const String appId = 'fixtura';
  static const int formatVersion = 1;

  final DatabaseHelper _dbHelper;

  BackupService([DatabaseHelper? dbHelper]) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Map<String, dynamic>> buildBackup() async {
    final db = await _dbHelper.database;
    final tournaments = await db.query('tournaments', orderBy: 'id ASC');
    final result = <Map<String, dynamic>>[];

    for (final t in tournaments) {
      final id = t['id'];
      result.add({
        'tournament': t,
        'teams': await db.query('teams', where: 'tournament_id = ?', whereArgs: [id], orderBy: 'id ASC'),
        'matches': await db.query('matches', where: 'tournament_id = ?', whereArgs: [id], orderBy: 'id ASC'),
        'roulette_assignments': await db.query(
          'roulette_assignments',
          where: 'tournament_id = ?',
          whereArgs: [id],
          orderBy: 'id ASC',
        ),
      });
    }

    return {
      'app': appId,
      'format_version': formatVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'tournaments': result,
    };
  }

  Future<String> exportJson() async => jsonEncode(await buildBackup());

  /// Adds the backup's tournaments and returns how many were added.
  /// A tournament already in the app (same name and creation time) is skipped,
  /// so importing the same file twice adds nothing the second time.
  Future<int> importJson(String source) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const InvalidBackupException('not JSON');
    }
    if (decoded is! Map<String, dynamic> || decoded['app'] != appId || decoded['tournaments'] is! List) {
      throw const InvalidBackupException('not a Fixtura backup');
    }
    final version = decoded['format_version'];
    if (version is! int || version > formatVersion) {
      throw const InvalidBackupException('unsupported backup version');
    }

    final entries = decoded['tournaments'] as List;
    final db = await _dbHelper.database;
    var imported = 0;

    await db.transaction((txn) async {
      final columns = {
        for (final table in const ['tournaments', 'teams', 'matches', 'roulette_assignments'])
          table: await _columnsOf(txn, table),
      };
      final existing = (await txn.query('tournaments', columns: ['name', 'created_at']))
          .map((row) => '${row['name']}|${row['created_at']}')
          .toSet();

      for (final entry in entries) {
        if (entry is! Map<String, dynamic>) throw const InvalidBackupException('bad tournament entry');
        final tournament = _asRow(entry['tournament']);
        final key = '${tournament['name']}|${tournament['created_at']}';
        if (existing.contains(key)) continue;

        final tournamentId = await txn.insert(
          'tournaments',
          _filtered(tournament, columns['tournaments']!),
        );
        existing.add(key);

        final teamIds = <Object?, int>{};
        for (final raw in _asRows(entry['teams'])) {
          final row = _filtered(raw, columns['teams']!)..['tournament_id'] = tournamentId;
          teamIds[raw['id']] = await txn.insert('teams', row);
        }

        // Matches point at each other through next_match_id, so insert them
        // first and link them once every new id is known.
        final matchIds = <Object?, int>{};
        final matchRows = _asRows(entry['matches']);
        for (final raw in matchRows) {
          final row = _filtered(raw, columns['matches']!)
            ..['tournament_id'] = tournamentId
            ..['home_team_id'] = teamIds[raw['home_team_id']]
            ..['away_team_id'] = teamIds[raw['away_team_id']]
            ..['next_match_id'] = null;
          matchIds[raw['id']] = await txn.insert('matches', row);
        }
        for (final raw in matchRows) {
          final next = matchIds[raw['next_match_id']];
          if (next == null) continue;
          await txn.update('matches', {'next_match_id': next}, where: 'id = ?', whereArgs: [matchIds[raw['id']]]);
        }

        for (final raw in _asRows(entry['roulette_assignments'])) {
          final teamId = teamIds[raw['team_id']];
          if (teamId == null) continue;
          final row = _filtered(raw, columns['roulette_assignments']!)
            ..['tournament_id'] = tournamentId
            ..['team_id'] = teamId;
          await txn.insert('roulette_assignments', row, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        imported++;
      }
    });

    return imported;
  }

  Future<Set<String>> _columnsOf(DatabaseExecutor db, String table) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    return info.map((c) => c['name'] as String).toSet();
  }

  Map<String, dynamic> _filtered(Map<String, dynamic> row, Set<String> columns) {
    return {
      for (final e in row.entries)
        if (e.key != 'id' && columns.contains(e.key)) e.key: e.value,
    };
  }

  Map<String, dynamic> _asRow(Object? value) {
    if (value is Map<String, dynamic> && value['name'] is String && value['created_at'] is String) {
      return value;
    }
    throw const InvalidBackupException('bad tournament row');
  }

  List<Map<String, dynamic>> _asRows(Object? value) {
    if (value == null) return const [];
    if (value is! List) throw const InvalidBackupException('bad row list');
    return value.map((row) {
      if (row is! Map<String, dynamic>) throw const InvalidBackupException('bad row');
      return row;
    }).toList();
  }
}
