import 'team.dart';

class Standing {
  final Team team;
  int played;
  int won;
  int drawn;
  int lost;
  int goalsFor;
  int goalsAgainst;

  Standing({
    required this.team,
    this.played = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
  });

  int get goalDifference => goalsFor - goalsAgainst;

  // Points is calculated based on won/drawn/lost and the scoring rules from the tournament
  int points(int ptsWin, int ptsDraw, int ptsLoss) {
    return (won * ptsWin) + (drawn * ptsDraw) + (lost * ptsLoss);
  }

  // Sorting comparator: points (descending), goalDifference (descending), goalsFor (descending), team name (ascending)
  static int compare(Standing a, Standing b, int ptsWin, int ptsDraw, int ptsLoss) {
    final ptsA = a.points(ptsWin, ptsDraw, ptsLoss);
    final ptsB = b.points(ptsWin, ptsDraw, ptsLoss);
    if (ptsA != ptsB) return ptsB.compareTo(ptsA);
    if (a.goalDifference != b.goalDifference) return b.goalDifference.compareTo(a.goalDifference);
    if (a.goalsFor != b.goalsFor) return b.goalsFor.compareTo(a.goalsFor);
    return a.team.name.compareTo(b.team.name);
  }
}
