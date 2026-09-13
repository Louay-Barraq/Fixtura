import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import 'score_entry_dialog.dart';

class CustomMatchCard extends StatelessWidget {
  final MatchModel match;
  final Team? homeTeam;
  final Team? awayTeam;
  final TournamentType tournamentType;
  final int? roundNumber;
  final String? Function(Team? team, int? roundNumber)? assignedTeamResolver;

  const CustomMatchCard({
    super.key,
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    required this.tournamentType,
    this.roundNumber,
    this.assignedTeamResolver,
  });

  @override
  Widget build(BuildContext context) {
    final isByeMatch = match.homeTeamId == null || match.awayTeamId == null;
    final isPlayed = match.isPlayed;

    final homePlayerName = homeTeam?.name ?? (match.homeTeamId == null && isByeMatch ? 'BYE' : 'TBD');
    final awayPlayerName = awayTeam?.name ?? (match.awayTeamId == null && isByeMatch ? 'BYE' : 'TBD');

    final homeAssignedTeam = assignedTeamResolver?.call(homeTeam, roundNumber) ?? homeTeam?.assignedTeam;
    final awayAssignedTeam = assignedTeamResolver?.call(awayTeam, roundNumber) ?? awayTeam?.assignedTeam;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ],
      ),
      child: InkWell(
        onTap: isByeMatch
            ? null
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
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            // Home Player & Assigned Team Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    homePlayerName,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (homeAssignedTeam != null && homeAssignedTeam.isNotEmpty) ...[
                    const Gap(2),
                    Text(
                      homeAssignedTeam,
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Center Score Box / VS Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Home Score Pill
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 2),
                          blurRadius: 3,
                          spreadRadius: 0,
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isPlayed ? '${match.homeScore ?? 0}' : '-',
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Center Dash separator
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '—',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Away Score Pill
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 2),
                          blurRadius: 3,
                          spreadRadius: 0,
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isPlayed ? '${match.awayScore ?? 0}' : '-',
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Away Player & Assigned Team Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    awayPlayerName,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (awayAssignedTeam != null && awayAssignedTeam.isNotEmpty) ...[
                    const Gap(2),
                    Text(
                      awayAssignedTeam,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
