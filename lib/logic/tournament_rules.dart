import '../models/match.dart';
import '../models/standing.dart';
import '../models/team.dart';
import '../models/tournament.dart';

/// Pure tournament rules shared by the provider, the screens and the tests.
/// Nothing here touches the database.

/// Group counts and qualifier counts the groups + knockout format offers.
/// Every combination gives a knockout bracket whose size is a power of two.
const List<int> groupCountOptions = [2, 4, 8];
const List<int> qualifierOptions = [1, 2];

/// Fewest players for [groupCount] groups: every group needs at least one
/// player more than the number who qualify from it.
int minPlayersForGroups(int groupCount, int qualifiersPerGroup) =>
    groupCount * (qualifiersPerGroup + 1);

String groupLetter(int groupIndex) => String.fromCharCode(65 + groupIndex);

bool isKnockoutStage(TournamentType type, MatchModel match) =>
    type == TournamentType.knockout ||
    (type == TournamentType.groupsKnockout && match.groupIndex == null);

/// The format a single match is played under: group matches behave like a
/// league match (draws allowed), bracket matches like a knockout match.
TournamentType stageType(TournamentType type, MatchModel match) {
  if (type != TournamentType.groupsKnockout) return type;
  return match.groupIndex == null ? TournamentType.knockout : TournamentType.roundRobin;
}

bool _isLeagueBye(TournamentType type, MatchModel m) =>
    !isKnockoutStage(type, m) && (m.homeTeamId == null || m.awayTeamId == null);

/// Matches that count toward progress: league and group BYEs are left out,
/// bracket matches all count (their BYEs are recorded as played walkovers).
List<MatchModel> countedMatches(TournamentType type, List<MatchModel> matches) =>
    matches.where((m) => !_isLeagueBye(type, m)).toList();

int tournamentProgress(TournamentType type, List<MatchModel> matches) {
  final counted = countedMatches(type, matches);
  if (counted.isEmpty) return 0;
  final played = counted.where((m) => m.isPlayed).length;
  return ((played / counted.length) * 100).round();
}

/// League table for [teams] from the played, non-BYE matches among [matches].
List<Standing> computeStandings(
  List<Team> teams,
  List<MatchModel> matches,
  int pointsWin,
  int pointsDraw,
  int pointsLoss,
) {
  final table = {for (final team in teams) team.id!: Standing(team: team)};

  for (final match in matches) {
    if (!match.isPlayed || match.homeTeamId == null || match.awayTeamId == null) continue;
    final home = table[match.homeTeamId];
    final away = table[match.awayTeamId];
    if (home == null || away == null) continue;

    final hs = match.homeScore ?? 0;
    final as = match.awayScore ?? 0;
    home
      ..played += 1
      ..goalsFor += hs
      ..goalsAgainst += as;
    away
      ..played += 1
      ..goalsFor += as
      ..goalsAgainst += hs;

    if (hs > as) {
      home.won += 1;
      away.lost += 1;
    } else if (as > hs) {
      away.won += 1;
      home.lost += 1;
    } else {
      home.drawn += 1;
      away.drawn += 1;
    }
  }

  return table.values.toList()
    ..sort((a, b) => Standing.compare(a, b, pointsWin, pointsDraw, pointsLoss));
}

/// One sorted table per group, group A first.
List<List<Standing>> computeGroupStandings(
  Tournament tournament,
  List<Team> teams,
  List<MatchModel> matches,
) {
  return List.generate(tournament.groupCount, (g) {
    return computeStandings(
      teams.where((t) => t.groupIndex == g).toList(),
      matches.where((m) => m.groupIndex == g).toList(),
      tournament.pointsForWin,
      tournament.pointsForDraw,
      tournament.pointsForLoss,
    );
  });
}

bool groupStageComplete(List<MatchModel> matches) => matches
    .where((m) => m.groupIndex != null && m.homeTeamId != null && m.awayTeamId != null)
    .every((m) => m.isPlayed);

/// Team ids for the first knockout round, as [home0, away0, home1, away1, ...]
/// in bracket order, or all nulls while group matches are still to be played.
///
/// With one qualifier per group, neighbouring group winners meet (A v B, C v D).
/// With two, each winner meets the runner-up of its neighbouring group, and
/// the two winners of a group pair start in opposite halves of the bracket:
/// [A1 v B2, C1 v D2, ..., B1 v A2, D1 v C2, ...].
List<int?> knockoutSlots(Tournament tournament, List<Team> teams, List<MatchModel> matches) {
  final slotCount = tournament.groupCount * tournament.qualifiersPerGroup;
  if (!groupStageComplete(matches)) return List.filled(slotCount, null);

  final tables = computeGroupStandings(tournament, teams, matches);
  int? at(int group, int place) =>
      place < tables[group].length ? tables[group][place].team.id : null;

  if (tournament.qualifiersPerGroup == 1) {
    return [for (var g = 0; g < tournament.groupCount; g++) at(g, 0)];
  }

  final firstHalf = <int?>[];
  final secondHalf = <int?>[];
  for (var g = 0; g < tournament.groupCount; g += 2) {
    firstHalf.addAll([at(g, 0), at(g + 1, 1)]);
    secondHalf.addAll([at(g + 1, 0), at(g, 1)]);
  }
  return [...firstHalf, ...secondHalf];
}

/// Winner of a played knockout match, or null if it has no winner yet.
int? knockoutWinner(MatchModel match) {
  if (!match.isPlayed) return null;
  final hs = match.homeScore, as = match.awayScore;
  if (hs == null || as == null) return match.homeTeamId ?? match.awayTeamId;
  if (hs == as) return null;
  return hs > as ? match.homeTeamId : match.awayTeamId;
}

/// The tournament winner once every counted match is played, else null.
int? championId(Tournament tournament, List<Team> teams, List<MatchModel> matches) {
  if (matches.isEmpty || tournamentProgress(tournament.type, matches) < 100) return null;

  if (tournament.type == TournamentType.roundRobin) {
    final table = computeStandings(
      teams,
      matches,
      tournament.pointsForWin,
      tournament.pointsForDraw,
      tournament.pointsForLoss,
    );
    return table.isEmpty ? null : table.first.team.id;
  }

  final bracket = matches.where((m) => isKnockoutStage(tournament.type, m)).toList();
  if (bracket.isEmpty) return null;
  final finalMatch = bracket.reduce((a, b) => a.roundNumber >= b.roundNumber ? a : b);
  return knockoutWinner(finalMatch);
}
