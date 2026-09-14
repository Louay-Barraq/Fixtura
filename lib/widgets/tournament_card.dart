import 'package:flutter/material.dart';
import 'package:fixtura/l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'progress_bar_section.dart';

class TournamentCard extends StatelessWidget {
  final String tournamentName;
  final int progressValue;
  final String? player1Name;
  final String? player2Name;
  final int? player1Score;
  final int? player2Score;
  final bool hasLastMatch;
  final VoidCallback? onTap;

  const TournamentCard({
    super.key,
    required this.tournamentName,
    required this.progressValue,
    this.player1Name,
    this.player2Name,
    this.player1Score,
    this.player2Score,
    this.hasLastMatch = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 2,
            spreadRadius: 2,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tournament Name Header Box
          Container(
            width: 220,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 2,
                  spreadRadius: 2,
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ],
            ),
            child: Center(
              child: Text(
                tournamentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const Gap(12),

          // Progress Bar Section
          ProgressBarSection(progressValue: progressValue),
          const Gap(12),

          // Last Match / Pending Matches Section
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasLastMatch ? (l10n?.yourLastMatch ?? 'Your Last Match') : (l10n?.tournamentStatus ?? 'Tournament Status'),
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const Gap(4),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 2),
                      blurRadius: 2,
                      spreadRadius: 2,
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                  ],
                ),
                child: hasLastMatch
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Player 1 Name
                          Expanded(
                            child: Text(
                              player1Name ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // Central Score Pill Box
                          Container(
                            width: 110,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '${player1Score ?? 0}',
                                      style: const TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const Text('-', style: TextStyle(color: Colors.white)),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '${player2Score ?? 0}',
                                      style: const TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Player 2 Name
                          Expanded(
                            child: Text(
                              player2Name ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          progressValue == 100
                              ? (l10n?.tournamentCompleted ?? 'Tournament Completed 🎉')
                              : (l10n?.noPlayedMatches ?? 'No played matches yet'),
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          const Gap(14),

          // Open Bracket / Details Action Button
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD71212),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 2),
                      blurRadius: 2,
                      spreadRadius: 2,
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Open Bracket',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Gap(12),
                    Icon(
                      Icons.arrow_circle_right_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
