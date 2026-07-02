import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../theme/app_theme.dart';
import 'match_card.dart';

class VisualBracket extends StatelessWidget {
  final Tournament tournament;
  final List<Team> teams;
  final List<MatchModel> matches;

  const VisualBracket({
    super.key,
    required this.tournament,
    required this.teams,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(
        child: Text('No matches generated yet.', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    // 1. Group matches by round number
    final Map<int, List<MatchModel>> matchesByRound = {};
    for (var match in matches) {
      matchesByRound.putIfAbsent(match.roundNumber, () => []).add(match);
    }

    // Sort round numbers ascending (1 = First round, e.g. Quarterfinals, max = Final)
    final sortedRounds = matchesByRound.keys.toList()..sort();
    
    // 2. Determine dimension constraints for alignment
    final firstRoundMatchCount = matchesByRound[1]?.length ?? 1;
    // Each match card needs about 120 pixels of height in the column to align comfortably
    final double columnHeight = firstRoundMatchCount * 130.0 + 60.0;
    const double columnWidth = 280.0;

    return InteractiveViewer(
      constrained: false, // Allows panning/scrolling in both directions
      minScale: 0.4,
      maxScale: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sortedRounds.map((roundNum) {
            final roundMatches = matchesByRound[roundNum] ?? [];
            // Sort matches in round by bracket position to preserve tree ordering
            roundMatches.sort((a, b) => (a.bracketPos ?? 0).compareTo(b.bracketPos ?? 0));
            
            final roundName = roundMatches.isNotEmpty ? roundMatches.first.roundName : 'Round $roundNum';

            return SizedBox(
              width: columnWidth,
              height: columnHeight,
              child: Column(
                children: [
                  // Round Header Chip
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Text(
                      roundName.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.background,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Matches Column (Distributed evenly to match bracket splits)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: roundMatches.map((match) {
                        final homeTeam = teams.firstWhere(
                          (t) => t.id == match.homeTeamId,
                          orElse: () => Team(id: -1, tournamentId: -1, name: 'TBD'),
                        );
                        final awayTeam = teams.firstWhere(
                          (t) => t.id == match.awayTeamId,
                          orElse: () => Team(id: -1, tournamentId: -1, name: 'TBD'),
                        );

                        return SizedBox(
                          width: columnWidth - 20,
                          child: MatchCard(
                            match: match,
                            homeTeam: homeTeam.id == -1 ? null : homeTeam,
                            awayTeam: awayTeam.id == -1 ? null : awayTeam,
                            tournamentType: TournamentType.knockout,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
