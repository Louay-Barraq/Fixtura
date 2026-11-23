import 'package:fixtura/l10n/app_localizations.dart';
import '../models/match.dart';
import '../models/tournament.dart';
import '../logic/tournament_rules.dart';

/// Display name for a match's round in the current language. [type] is the
/// format the match is played under (see [stageType]).
///
/// Round names are stored in English in the database, so they are rebuilt
/// here from the round number instead of being shown as stored.
String localizedRoundName(
  AppLocalizations l10n,
  MatchModel match,
  TournamentType type,
  List<MatchModel> allMatches,
) {
  if (match.groupIndex != null) {
    return '${l10n.groupName(groupLetter(match.groupIndex!))} · ${l10n.round(match.roundNumber)}';
  }
  if (type == TournamentType.roundRobin) return l10n.round(match.roundNumber);

  final lastRound = allMatches.fold<int>(
    match.roundNumber,
    (maxRound, m) => m.roundNumber > maxRound ? m.roundNumber : maxRound,
  );
  final roundsFromFinal = lastRound - match.roundNumber;
  switch (roundsFromFinal) {
    case 0:
      return l10n.finalRound;
    case 1:
      return l10n.semiFinals;
    case 2:
      return l10n.quarterFinals;
    default:
      return l10n.roundOf(1 << (roundsFromFinal + 1));
  }
}
