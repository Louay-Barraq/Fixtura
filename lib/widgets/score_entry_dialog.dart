import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:fixtura/l10n/app_localizations.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../providers/tournament_provider.dart';
import '../utils/round_names.dart';
import 'short_section_header.dart';
import 'square_button.dart';

class ScoreEntryDialog extends StatefulWidget {
  final MatchModel match;
  final Team? homeTeam;
  final Team? awayTeam;
  final TournamentType tournamentType;

  const ScoreEntryDialog({
    super.key,
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    required this.tournamentType,
  });

  @override
  State<ScoreEntryDialog> createState() => _ScoreEntryDialogState();
}

class _ScoreEntryDialogState extends State<ScoreEntryDialog> {
  late int _homeScore;
  late int _awayScore;
  int? _penaltyWinnerId;

  @override
  void initState() {
    super.initState();
    _homeScore = widget.match.homeScore ?? 0;
    _awayScore = widget.match.awayScore ?? 0;
  }

  // Asks before a save would wipe a later match's result. True means go ahead.
  Future<bool> _confirmLaterResultCleared(int? homeScore, int? awayScore) async {
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final clearedMatch = provider.laterMatchClearedBy(widget.match, homeScore, awayScore);
    if (clearedMatch == null) return true;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          l10n.laterResultWarningTitle,
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 22,
            color: Color(0xFFD71212),
          ),
        ),
        content: Text(
          l10n.laterResultWarningBody(
            localizedRoundName(l10n, clearedMatch, widget.tournamentType, provider.activeMatches),
          ),
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.laterResultWarningContinue,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                color: Color(0xFFD71212),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _saveScore() async {
    if (widget.tournamentType == TournamentType.knockout && _homeScore == _awayScore) {
      if (_penaltyWinnerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.knockoutDrawNotAllowed),
            backgroundColor: const Color(0xFFD71212),
          ),
        );
        return;
      }
    }

    int finalHScore = _homeScore;
    int finalAScore = _awayScore;

    if (widget.tournamentType == TournamentType.knockout && _homeScore == _awayScore) {
      if (_penaltyWinnerId == widget.homeTeam?.id) {
        finalHScore += 1;
      } else {
        finalAScore += 1;
      }
    }

    if (!await _confirmLaterResultCleared(finalHScore, finalAScore) || !mounted) return;

    final provider = Provider.of<TournamentProvider>(context, listen: false);
    provider.updateMatchScore(widget.match.id!, finalHScore, finalAScore);

    Navigator.pop(context);
  }

  Future<void> _clearScore() async {
    if (!await _confirmLaterResultCleared(null, null) || !mounted) return;

    final provider = Provider.of<TournamentProvider>(context, listen: false);
    provider.updateMatchScore(widget.match.id!, null, null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final homeName = widget.homeTeam?.name ?? l10n.tbd;
    final awayName = widget.awayTeam?.name ?? l10n.tbd;
    final isKnockout = widget.tournamentType == TournamentType.knockout;
    final isTie = _homeScore == _awayScore;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Handle Indicator Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(16),

            // Header Title
            Center(
              child: ShortSectionHeader(
                title: localizedRoundName(l10n, widget.match, widget.tournamentType, provider.activeMatches).toUpperCase(),
              ),
            ),
            const Gap(24),

            // Score Entry Box Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Home Player Counter
                  Expanded(
                    child: _buildTeamCounter(
                      name: homeName,
                      score: _homeScore,
                      onDecrement: () {
                        if (_homeScore > 0) {
                          setState(() => _homeScore--);
                        }
                      },
                      onIncrement: () {
                        setState(() => _homeScore++);
                      },
                    ),
                  ),

                  // Center Dash separator
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '—',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Away Player Counter
                  Expanded(
                    child: _buildTeamCounter(
                      name: awayName,
                      score: _awayScore,
                      onDecrement: () {
                        if (_awayScore > 0) {
                          setState(() => _awayScore--);
                        }
                      },
                      onIncrement: () {
                        setState(() => _awayScore++);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20),

            // Tie breaker option for Knockout matches when scores are tied
            if (isKnockout && isTie) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD71212), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.penaltyShootoutWinner,
                      style: const TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 16,
                        color: Color(0xFFD71212),
                        letterSpacing: 1,
                      ),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPenaltyOption(
                            name: homeName,
                            isSelected: _penaltyWinnerId == widget.homeTeam?.id,
                            onTap: () {
                              setState(() => _penaltyWinnerId = widget.homeTeam?.id);
                            },
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: _buildPenaltyOption(
                            name: awayName,
                            isSelected: _penaltyWinnerId == widget.awayTeam?.id,
                            onTap: () {
                              setState(() => _penaltyWinnerId = widget.awayTeam?.id);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(20),
            ],

            // Action Buttons (SAVE RESULT / RESET SCORE)
            Row(
              children: [
                if (widget.match.isPlayed) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: _clearScore,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFD71212), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 0,
                              color: Colors.black.withValues(alpha: 0.15),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'RESET SCORE',
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: 18,
                              color: Color(0xFFD71212),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                ],
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _saveScore,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD71212),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'SAVE RESULT',
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 20,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCounter({
    required String name,
    required int score,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SquareButton(icon: Icons.remove, onTap: onDecrement),
            Container(
              width: 40,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 6),
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
                  '$score',
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SquareButton(icon: Icons.add, onTap: onIncrement),
          ],
        ),
      ],
    );
  }

  Widget _buildPenaltyOption({
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade400,
          ),
        ),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
