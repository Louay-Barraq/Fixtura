import 'package:fixtura/l10n/app_localizations_en.dart';
import 'package:fixtura/logic/share_text.dart';
import 'package:fixtura/models/match.dart';
import 'package:fixtura/models/team.dart';
import 'package:fixtura/models/tournament.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final teams = [
    Team(id: 1, tournamentId: 1, name: 'Louay'),
    Team(id: 2, tournamentId: 1, name: 'Sami'),
    Team(id: 3, tournamentId: 1, name: 'Yassine'),
    Team(id: 4, tournamentId: 1, name: 'Nour'),
  ];
  MatchModel m(int id, int round, int home, int away, [int? hs, int? as]) => MatchModel(
        id: id,
        tournamentId: 1,
        homeTeamId: home,
        awayTeamId: away,
        homeScore: hs,
        awayScore: as,
        isPlayed: hs != null,
        roundNumber: round,
        roundName: 'Round $round',
      );

  test('league summary has the table, the latest results and the next round', () {
    final text = buildShareText(
      l10n: l10n,
      tournament: Tournament(id: 1, name: 'Ramadan League', type: TournamentType.roundRobin, createdAt: DateTime(2026)),
      teams: teams,
      matches: [m(1, 1, 1, 2, 3, 0), m(2, 1, 3, 4, 1, 1), m(3, 2, 1, 3), m(4, 2, 2, 4)],
    );

    expect(text, startsWith('🏆 RAMADAN LEAGUE\n'));
    expect(text, contains('1. Louay · 3 pts (+3)'));
    expect(text, contains('LATEST RESULTS · ROUND 1\nLouay 3–0 Sami\nYassine 1–1 Nour'));
    expect(text, contains('UP NEXT · ROUND 2\nLouay vs Yassine\nSami vs Nour'));
    expect(text, isNot(contains('Champion')));
    expect(text.trimRight(), endsWith(storeUrl));
  });

  test('a finished knockout names the champion', () {
    final semi1 = m(1, 1, 1, 2, 2, 1);
    final semi2 = m(2, 1, 3, 4, 0, 1);
    final finalMatch = m(3, 2, 1, 4, 0, 2);
    final text = buildShareText(
      l10n: l10n,
      tournament: Tournament(id: 1, name: 'Cup', type: TournamentType.knockout, createdAt: DateTime(2026)),
      teams: teams,
      matches: [semi1, semi2, finalMatch],
    );

    expect(text, contains('🏆 Champion: Nour'));
    expect(text, contains('LATEST RESULTS · FINAL\nLouay 0–2 Nour'));
    expect(text, isNot(contains('UP NEXT')));
  });
}
