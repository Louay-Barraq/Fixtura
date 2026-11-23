import 'dart:io';

import 'package:fixtura/logic/tournament_rules.dart';
import 'package:fixtura/models/match.dart';
import 'package:fixtura/models/tournament.dart';
import 'package:fixtura/providers/tournament_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late TournamentProvider provider;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = await Directory.systemTemp.createTemp('fixtura_groups_test');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    provider = TournamentProvider();
    await provider.clearAllTournaments();
  });

  // 8 players, 2 groups of 4, top 2 go through: P1,P3,P5,P7 in A; P2,P4,P6,P8 in B.
  Future<int> createCup({int players = 8, int groups = 2, int qualifiers = 2}) async {
    final id = await provider.createTournament(
      name: 'Coupe du quartier',
      type: TournamentType.groupsKnockout,
      legs: 1,
      teamNames: List.generate(players, (i) => 'P${i + 1}'),
      groupCount: groups,
      qualifiersPerGroup: qualifiers,
    );
    await provider.loadTournamentDetails(id!);
    return id;
  }

  int teamId(String name) => provider.activeTeams.firstWhere((t) => t.name == name).id!;
  List<MatchModel> groupMatches() => provider.activeMatches.where((m) => m.groupIndex != null).toList();
  List<MatchModel> bracket() => provider.activeMatches.where((m) => m.groupIndex == null).toList()
    ..sort((a, b) => a.roundNumber != b.roundNumber
        ? a.roundNumber.compareTo(b.roundNumber)
        : a.bracketPos!.compareTo(b.bracketPos!));
  MatchModel fresh(MatchModel m) => provider.activeMatches.firstWhere((x) => x.id == m.id);

  // Lower player number always wins its group match, so P1 and P2 top the groups.
  Future<void> playGroups() async {
    for (final m in groupMatches()) {
      final home = provider.activeTeams.firstWhere((t) => t.id == m.homeTeamId);
      final away = provider.activeTeams.firstWhere((t) => t.id == m.awayTeamId);
      final homeWins = int.parse(home.name.substring(1)) < int.parse(away.name.substring(1));
      await provider.updateMatchScore(m.id!, homeWins ? 2 : 0, homeWins ? 0 : 2);
    }
  }

  test('rejects group setups the format does not support', () async {
    expect(await provider.createTournament(
      name: 'x', type: TournamentType.groupsKnockout, legs: 1,
      teamNames: List.generate(5, (i) => 'P$i'), groupCount: 2, qualifiersPerGroup: 2,
    ), isNull, reason: 'two groups of 2+1 need 6 players');
    expect(await provider.createTournament(
      name: 'x', type: TournamentType.groupsKnockout, legs: 1,
      teamNames: List.generate(9, (i) => 'P$i'), groupCount: 3, qualifiersPerGroup: 1,
    ), isNull, reason: '3 groups would not make a power-of-two bracket');
  });

  test('deals players into groups and builds an empty bracket after the group rounds', () async {
    await createCup();
    final a = provider.activeTeams.where((t) => t.groupIndex == 0).map((t) => t.name).toSet();
    final b = provider.activeTeams.where((t) => t.groupIndex == 1).map((t) => t.name).toSet();
    expect(a, {'P1', 'P3', 'P5', 'P7'});
    expect(b, {'P2', 'P4', 'P6', 'P8'});

    // 4 players per group -> 3 rounds of 2 matches, in each group
    expect(groupMatches().length, 12);
    expect(groupMatches().map((m) => m.roundNumber).toSet(), {1, 2, 3});

    final ko = bracket();
    expect(ko.map((m) => m.roundNumber).toList(), [4, 4, 5], reason: 'semis then final');
    expect(ko.every((m) => m.homeTeamId == null && m.awayTeamId == null), isTrue);
    expect(provider.calculateTournamentProgress(TournamentType.groupsKnockout, provider.activeMatches), 0);
  });

  test('fills the bracket with winners against neighbouring runners-up once groups finish', () async {
    await createCup();
    final last = groupMatches().last;
    for (final m in groupMatches().where((m) => m.id != last.id)) {
      await provider.updateMatchScore(m.id!, 1, 1);
    }
    expect(bracket().first.homeTeamId, isNull, reason: 'bracket waits for every group match');

    await playGroups();
    final semis = bracket().where((m) => m.roundNumber == 4).toList();
    expect([semis[0].homeTeamId, semis[0].awayTeamId], [teamId('P1'), teamId('P4')], reason: 'A1 v B2');
    expect([semis[1].homeTeamId, semis[1].awayTeamId], [teamId('P2'), teamId('P3')], reason: 'B1 v A2');

    expect(provider.calculateGroupStandings().map((g) => g.first.team.name), ['P1', 'P2']);
  });

  test('plays through to a champion', () async {
    await createCup();
    await playGroups();
    final semis = bracket().where((m) => m.roundNumber == 4).toList();
    await provider.updateMatchScore(semis[0].id!, 1, 0); // P1
    await provider.updateMatchScore(semis[1].id!, 0, 3); // P3
    final finalMatch = bracket().last;
    expect([fresh(finalMatch).homeTeamId, fresh(finalMatch).awayTeamId], [teamId('P1'), teamId('P3')]);

    await provider.updateMatchScore(finalMatch.id!, 0, 1);
    expect(provider.championTeamId, teamId('P3'));
    expect(provider.activeTournament!.status, 'completed');
  });

  test('a group result that changes the qualifiers clears the bracket results it affects', () async {
    await createCup();
    await playGroups();
    final semis = bracket().where((m) => m.roundNumber == 4).toList();
    await provider.updateMatchScore(semis[0].id!, 1, 0);
    await provider.updateMatchScore(semis[1].id!, 1, 0);

    // Group A finished P1, P3, P5, P7. Two corrected results push P5 above P3.
    final p3p5 = groupMatches().firstWhere((m) =>
        {m.homeTeamId, m.awayTeamId}.containsAll({teamId('P3'), teamId('P5')}));
    final p3p7 = groupMatches().firstWhere((m) =>
        {m.homeTeamId, m.awayTeamId}.containsAll({teamId('P3'), teamId('P7')}));
    final p5Home = p3p5.homeTeamId == teamId('P5');
    final p7Home = p3p7.homeTeamId == teamId('P7');

    // First change keeps P3 second (goal difference), so no warning
    expect(provider.laterMatchClearedBy(p3p7, p7Home ? 1 : 0, p7Home ? 0 : 1), isNull);

    // P5 beating P3 too makes P5 second in A: semi 2 (B1 v A2) changes
    await provider.updateMatchScore(p3p7.id!, p7Home ? 1 : 0, p7Home ? 0 : 1);
    final warned = provider.laterMatchClearedBy(p3p5, p5Home ? 3 : 0, p5Home ? 0 : 3);
    expect(warned?.id, semis[1].id);

    await provider.updateMatchScore(p3p5.id!, p5Home ? 3 : 0, p5Home ? 0 : 3);
    expect(fresh(semis[0]).isPlayed, isTrue, reason: 'A1 v B2 is unchanged');
    expect(fresh(semis[1]).isPlayed, isFalse);
    expect(fresh(semis[1]).awayTeamId, teamId('P5'));
    final finalMatch = fresh(bracket().last);
    expect(finalMatch.awayTeamId, isNull, reason: 'the cleared semi no longer feeds the final');
    expect(finalMatch.homeTeamId, teamId('P1'));
  });

  test('knockoutSlots pairs group winners when one player qualifies per group', () async {
    await createCup(players: 8, groups: 4, qualifiers: 1);
    await playGroups();
    final t = provider.activeTournament!;
    final slots = knockoutSlots(t, provider.activeTeams, provider.activeMatches);
    // Groups of 2: A={P1,P5}, B={P2,P6}, C={P3,P7}, D={P4,P8}
    expect(slots, [teamId('P1'), teamId('P2'), teamId('P3'), teamId('P4')]);
  });
}
