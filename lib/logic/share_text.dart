import 'package:fixtura/l10n/app_localizations.dart';

import '../models/match.dart';
import '../models/standing.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../utils/round_names.dart';
import 'tournament_rules.dart';

const String storeUrl = 'https://play.google.com/store/apps/details?id=com.louaybarraq.fixtura';

/// A plain-text summary of a tournament, made for pasting into a group chat:
/// the champion once there is one, the table(s), the latest results and the
/// next matches.
String buildShareText({
  required AppLocalizations l10n,
  required Tournament tournament,
  required List<Team> teams,
  required List<MatchModel> matches,
}) {
  final names = {for (final t in teams) t.id: t.name};
  final out = StringBuffer('🏆 ${tournament.name.toUpperCase()}\n');

  final champion = championId(tournament, teams, matches);
  if (champion != null) out.writeln(l10n.championLine(names[champion] ?? ''));

  void table(String? title, List<Standing> rows) {
    if (rows.isEmpty) return;
    out
      ..writeln()
      ..writeln(title ?? l10n.standings);
    for (var i = 0; i < rows.length; i++) {
      final s = rows[i];
      final pts = s.points(tournament.pointsForWin, tournament.pointsForDraw, tournament.pointsForLoss);
      final gd = s.goalDifference > 0 ? '+${s.goalDifference}' : '${s.goalDifference}';
      out.writeln('${i + 1}. ${s.team.name} · $pts ${l10n.pointsShort} ($gd)');
    }
  }

  if (tournament.type == TournamentType.roundRobin) {
    table(null, computeStandings(teams, matches, tournament.pointsForWin, tournament.pointsForDraw, tournament.pointsForLoss));
  } else if (tournament.type == TournamentType.groupsKnockout && !groupStageComplete(matches)) {
    final tables = computeGroupStandings(tournament, teams, matches);
    for (var g = 0; g < tables.length; g++) {
      table(l10n.groupName(groupLetter(g)), tables[g]);
    }
  }

  // A group round spans every group, so it is titled by its number alone
  String roundTitle(MatchModel m) => (m.groupIndex != null
          ? l10n.round(m.roundNumber)
          : localizedRoundName(l10n, m, stageType(tournament.type, m), matches))
      .toUpperCase();
  String groupTag(MatchModel m) => m.groupIndex == null ? '' : '[${groupLetter(m.groupIndex!)}] ';

  final realMatches = matches.where((m) => m.homeTeamId != null && m.awayTeamId != null).toList();

  final played = realMatches.where((m) => m.isPlayed).toList();
  if (played.isNotEmpty) {
    final lastRound = played.map((m) => m.roundNumber).reduce((a, b) => a > b ? a : b);
    out
      ..writeln()
      ..writeln('${l10n.latestResults} · ${roundTitle(played.firstWhere((m) => m.roundNumber == lastRound))}');
    for (final m in played.where((m) => m.roundNumber == lastRound)) {
      out.writeln('${groupTag(m)}${names[m.homeTeamId]} ${m.homeScore}–${m.awayScore} ${names[m.awayTeamId]}');
    }
  }

  final upcoming = realMatches.where((m) => !m.isPlayed).toList();
  if (upcoming.isNotEmpty) {
    final nextRound = upcoming.map((m) => m.roundNumber).reduce((a, b) => a < b ? a : b);
    out
      ..writeln()
      ..writeln('${l10n.upcomingMatches} · ${roundTitle(upcoming.firstWhere((m) => m.roundNumber == nextRound))}');
    for (final m in upcoming.where((m) => m.roundNumber == nextRound)) {
      out.writeln('${groupTag(m)}${names[m.homeTeamId]} vs ${names[m.awayTeamId]}');
    }
  }

  out
    ..writeln()
    ..writeln('${l10n.madeWithFixtura} · $storeUrl');
  return out.toString();
}
