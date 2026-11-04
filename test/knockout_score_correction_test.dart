import 'package:fixtura/models/match.dart';
import 'package:fixtura/models/tournament.dart';
import 'package:fixtura/providers/tournament_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late TournamentProvider provider;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    provider = TournamentProvider();
    await provider.clearAllTournaments();
  });

  Future<void> createBracket(int players) async {
    final id = await provider.createTournament(
      name: 'Tournoi l houma',
      type: TournamentType.knockout,
      legs: 1,
      teamNames: List.generate(players, (i) => 'P${i + 1}'),
    );
    await provider.loadTournamentDetails(id!);
  }

  MatchModel match(int round, int pos) => provider.activeMatches
      .firstWhere((m) => m.roundNumber == round && m.bracketPos == pos);

  Future<void> score(int round, int pos, int home, int away) =>
      provider.updateMatchScore(match(round, pos).id!, home, away);

  // Plays the whole 8-player bracket with every home side winning.
  Future<void> playAll() async {
    for (var pos = 0; pos < 4; pos++) {
      await score(1, pos, 2, 0);
    }
    await score(2, 0, 2, 0);
    await score(2, 1, 2, 0);
    await score(3, 0, 2, 0);
  }

  int? slot(MatchModel source, MatchModel next) =>
      source.nextMatchIsHome! ? next.homeTeamId : next.awayTeamId;

  test('copyWith can clear nullable fields and keeps them by default', () {
    final original = MatchModel(
      tournamentId: 1,
      homeTeamId: 1,
      awayTeamId: 2,
      homeScore: 3,
      awayScore: 2,
      roundNumber: 1,
      roundName: 'Round 1',
    );

    final kept = original.copyWith(isPlayed: true);
    expect(kept.homeTeamId, 1);
    expect(kept.homeScore, 3);

    final cleared = original.copyWith(
      homeTeamId: null,
      awayTeamId: null,
      homeScore: null,
      awayScore: null,
    );
    expect(cleared.homeTeamId, isNull);
    expect(cleared.awayTeamId, isNull);
    expect(cleared.homeScore, isNull);
    expect(cleared.awayScore, isNull);
  });

  test('changing a winner resets every later round it fed', () async {
    await createBracket(8);
    await playAll();

    final otherSemiWinner = match(2, 1).homeTeamId;
    await score(1, 0, 0, 2);

    final newWinner = match(1, 0).awayTeamId;
    final semi = match(2, 0);
    expect(slot(match(1, 0), semi), newWinner);
    expect(semi.isPlayed, isFalse);
    expect(semi.homeScore, isNull);
    expect(semi.awayScore, isNull);

    final finalMatch = match(3, 0);
    expect(slot(semi, finalMatch), isNull, reason: 'stale semi winner in final');
    expect(finalMatch.isPlayed, isFalse);
    expect(finalMatch.homeScore, isNull);
    expect(finalMatch.awayScore, isNull);

    // The untouched half of the bracket stays as it was.
    expect(match(2, 1).isPlayed, isTrue);
    expect(slot(match(2, 1), finalMatch), otherSemiWinner);

    // Replaying the semi carries the corrected team into the final.
    await provider.updateMatchScore(semi.id!, 1, 0);
    expect(slot(match(2, 0), match(3, 0)), match(2, 0).homeTeamId);
  });

  test('a correction that keeps the winner leaves later rounds alone', () async {
    await createBracket(8);
    await playAll();

    await score(1, 0, 3, 2);

    expect(match(1, 0).homeScore, 3);
    expect(match(2, 0).isPlayed, isTrue);
    expect(match(2, 0).homeScore, 2);
    expect(match(3, 0).isPlayed, isTrue);
    expect(match(3, 0).homeScore, 2);
  });

  test('changing a winner before the next match has a score swaps the team',
      () async {
    await createBracket(8);
    await score(1, 0, 2, 0);
    await score(1, 1, 2, 0);

    await score(1, 0, 0, 2);

    expect(slot(match(1, 0), match(2, 0)), match(1, 0).awayTeamId);
    expect(match(2, 0).awayTeamId, match(1, 1).homeTeamId);
    expect(match(2, 0).isPlayed, isFalse);
  });

  test('clearing a result clears it and everything after it', () async {
    await createBracket(8);
    await playAll();

    await provider.updateMatchScore(match(1, 0).id!, null, null);

    expect(match(1, 0).isPlayed, isFalse);
    expect(match(1, 0).homeScore, isNull);
    expect(slot(match(1, 0), match(2, 0)), isNull);
    expect(match(2, 0).isPlayed, isFalse);
    expect(match(2, 0).homeScore, isNull);
    expect(slot(match(2, 0), match(3, 0)), isNull);
    expect(match(3, 0).isPlayed, isFalse);
    expect(match(3, 0).homeScore, isNull);
  });

  test('byes survive a correction elsewhere in the bracket', () async {
    await createBracket(6);
    await score(1, 0, 2, 0);
    await score(1, 1, 2, 0);
    await score(2, 0, 2, 0);
    await score(2, 1, 2, 0);
    await score(3, 0, 2, 0);

    await score(1, 0, 0, 2);

    expect(match(1, 2).isPlayed, isTrue);
    expect(match(1, 3).isPlayed, isTrue);
    expect(match(2, 1).homeTeamId, match(1, 2).homeTeamId);
    expect(match(2, 1).awayTeamId, match(1, 3).homeTeamId);
    expect(match(2, 1).isPlayed, isTrue);
  });
}
