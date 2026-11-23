import 'dart:convert';
import 'dart:io';

import 'package:fixtura/models/tournament.dart';
import 'package:fixtura/providers/tournament_provider.dart';
import 'package:fixtura/services/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late TournamentProvider provider;
  final backup = BackupService();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = await Directory.systemTemp.createTemp('fixtura_backup_test');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    provider = TournamentProvider();
    await provider.clearAllTournaments();
  });

  test('export then import after a reset restores tournaments, results and bracket links', () async {
    final id = await provider.createTournament(
      name: 'Tournoi du vendredi',
      type: TournamentType.knockout,
      legs: 1,
      teamNames: ['A', 'B', 'C', 'D'],
      useRoulette: true,
      roulettePool: ['PSG', 'OM', 'OL', 'LOSC'],
    );
    await provider.loadTournamentDetails(id!);
    final semi = provider.activeMatches.firstWhere((m) => m.roundNumber == 1);
    await provider.updateMatchScore(semi.id!, 2, 1);
    await provider.setRouletteAssignment(provider.activeTeams.first.id!, 1, 'PSG');

    final json = await backup.exportJson();
    await provider.clearAllTournaments();
    expect(await backup.importJson(json), 1);

    await provider.loadAllTournaments();
    expect(provider.tournaments.single.name, 'Tournoi du vendredi');
    final newId = provider.tournaments.single.id!;
    await provider.loadTournamentDetails(newId);

    final matches = provider.activeMatches;
    final teamIds = provider.activeTeams.map((t) => t.id).toSet();
    final played = matches.singleWhere((m) => m.isPlayed);
    expect([played.homeScore, played.awayScore], [2, 1]);
    expect(teamIds, containsAll([played.homeTeamId, played.awayTeamId]));

    final finalMatch = matches.singleWhere((m) => m.roundNumber == 2);
    expect(matches.where((m) => m.roundNumber == 1).every((m) => m.nextMatchId == finalMatch.id), isTrue);
    final winnerSlot = played.nextMatchIsHome! ? finalMatch.homeTeamId : finalMatch.awayTeamId;
    expect(winnerSlot, played.homeTeamId);

    expect(provider.getRouletteAssignmentForTeamRound(provider.activeTeams.first.id!, 1), 'PSG');
  });

  test('importing the same backup twice adds nothing the second time', () async {
    await provider.createTournament(
      name: 'Liga', type: TournamentType.roundRobin, legs: 1, teamNames: ['A', 'B', 'C'],
    );
    final json = await backup.exportJson();
    expect(await backup.importJson(json), 0);
    await provider.loadAllTournaments();
    expect(provider.tournaments.length, 1);
  });

  test('rejects files that are not Fixtura backups', () async {
    expect(() => backup.importJson('not json'), throwsA(isA<InvalidBackupException>()));
    expect(() => backup.importJson(jsonEncode({'app': 'other', 'tournaments': []})),
        throwsA(isA<InvalidBackupException>()));
    expect(() => backup.importJson(jsonEncode({'app': 'fixtura', 'format_version': 99, 'tournaments': []})),
        throwsA(isA<InvalidBackupException>()));
  });
}
