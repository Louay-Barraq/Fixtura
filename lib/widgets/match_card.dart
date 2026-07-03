import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../theme/app_theme.dart';
import 'score_entry_dialog.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final Team? homeTeam;
  final Team? awayTeam;
  final TournamentType tournamentType;
  final int? roundNumber;
  final String? Function(Team? team, int? roundNumber)? assignedTeamResolver;

  const MatchCard({
    super.key,
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    required this.tournamentType,
    this.roundNumber,
    this.assignedTeamResolver,
  });

  Color _parseColor(String? hexString) {
    if (hexString == null) return AppTheme.textSecondary;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isByeMatch = match.homeTeamId == null || match.awayTeamId == null;
    final isPlayed = match.isPlayed;
    final homeAssignedTeam = assignedTeamResolver?.call(homeTeam, roundNumber) ?? homeTeam?.assignedTeam;
    final awayAssignedTeam = assignedTeamResolver?.call(awayTeam, roundNumber) ?? awayTeam?.assignedTeam;

    // Resolve displayed names
    final homeName = homeTeam != null 
      ? (homeAssignedTeam != null ? '${homeTeam!.name} ($homeAssignedTeam)' : homeTeam!.name)
        : (match.homeTeamId == null && isByeMatch ? 'BYE' : 'TBD');
    final awayName = awayTeam != null
      ? (awayAssignedTeam != null ? '${awayTeam!.name} ($awayAssignedTeam)' : awayTeam!.name)
        : (match.awayTeamId == null && isByeMatch ? 'BYE' : 'TBD');

    final homeColor = homeTeam != null ? _parseColor(homeTeam!.colorHex) : AppTheme.divider;
    final awayColor = awayTeam != null ? _parseColor(awayTeam!.colorHex) : AppTheme.divider;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: isByeMatch
            ? null // Do nothing for BYE matches
            : () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ScoreEntryDialog(
                    match: match,
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                    tournamentType: tournamentType,
                  ),
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            children: [
              // Round badge/tag
              if (tournamentType == TournamentType.roundRobin)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      match.roundName,
                      style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    if (isPlayed && !isByeMatch)
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.greenAccent, size: 12),
                          SizedBox(width: 4),
                          Text('Full Time', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      )
                    else if (isByeMatch)
                      const Text('Resting', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11))
                    else
                      const Text('Scheduled', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              if (tournamentType == TournamentType.roundRobin) const SizedBox(height: 12),

              // Match Display Row
              Row(
                children: [
                  // Home Team Info
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                homeTeam!.name,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: homeTeam == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "$homeAssignedTeam",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: homeTeam == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 8,
                          height: 24,
                          decoration: BoxDecoration(
                            color: homeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Score Center Box
                  Container(
                    width: 90,
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF222F4D)),
                      ),
                      child: isPlayed
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${match.homeScore}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Text(':', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                                ),
                                Text(
                                  '${match.awayScore}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  // Away Team Info
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 24,
                          decoration: BoxDecoration(
                            color: awayColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                awayTeam!.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: awayTeam == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              Text(
                                "$awayAssignedTeam",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: awayTeam == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
