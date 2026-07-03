import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../providers/tournament_provider.dart';
import '../theme/app_theme.dart';

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
  late TextEditingController _homeScoreController;
  late TextEditingController _awayScoreController;
  late TextEditingController _detailsController;

  int? _homeScore;
  int? _awayScore;
  int? _penaltyWinnerId; // Holds winner team ID in case of knockout draw

  @override
  void initState() {
    super.initState();
    _homeScore = widget.match.homeScore;
    _awayScore = widget.match.awayScore;

    _homeScoreController = TextEditingController(text: _homeScore?.toString() ?? '');
    _awayScoreController = TextEditingController(text: _awayScore?.toString() ?? '');
    
    // Parse out potential penalty info or details
    _detailsController = TextEditingController();
  }

  @override
  void dispose() {
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _saveScore() {
    final homeText = _homeScoreController.text.trim();
    final awayText = _awayScoreController.text.trim();

    if (homeText.isEmpty || awayText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter scores for both teams.'), backgroundColor: AppTheme.accent),
      );
      return;
    }

    final hScore = int.tryParse(homeText);
    final aScore = int.tryParse(awayText);

    if (hScore == null || aScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers for scores.'), backgroundColor: AppTheme.accent),
      );
      return;
    }

    // For Knockouts, if scores are equal, we need a tie-breaker decision
    if (widget.tournamentType == TournamentType.knockout && hScore == aScore) {
      if (_penaltyWinnerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A draw is not allowed in Knockout matches. Please select a penalty/shootout winner.'),
            backgroundColor: AppTheme.accent,
          ),
        );
        return;
      }
    }

    // If it was a draw, adjust the scores in the database to reflect the winner for propagation
    int finalHScore = hScore;
    int finalAScore = aScore;

    if (widget.tournamentType == TournamentType.knockout && hScore == aScore) {
      // We store the score with a virtual +1 goal to the winner to denote progress in DB, 
      // or we can let the propagation use the penalty winner.
      // Actually, since the provider's propagation logic compares homeScore > awayScore,
      // if it's a draw, we can virtually adjust the database score by +1 to the penalty winner 
      // (e.g. if it is 2-2, and Home won penalties, we save it as 3-2 or let user type 3-2 after pens, 
      // or we can adjust it here so it propagates correctly!).
      // Let's adjust it by adding 1 to the winner's score to make it clear who won, 
      // and append a note in the details: "Win on penalties".
      if (_penaltyWinnerId == widget.homeTeam?.id) {
        finalHScore += 1;
      } else {
        finalAScore += 1;
      }
    }

    final provider = Provider.of<TournamentProvider>(context, listen: false);
    provider.updateMatchScore(widget.match.id!, finalHScore, finalAScore);

    Navigator.pop(context);
  }

  void _clearScore() {
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    provider.updateMatchScore(widget.match.id!, null, null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final homeName = widget.homeTeam?.name ?? 'TBD';
    final awayName = widget.awayTeam?.name ?? 'TBD';
    final isKnockout = widget.tournamentType == TournamentType.knockout;

    // Listen to changes in the text controllers to check if a tiebreaker is needed
    bool isTie = false;
    final hVal = int.tryParse(_homeScoreController.text);
    final aVal = int.tryParse(_awayScoreController.text);
    if (hVal != null && aVal != null && hVal == aVal) {
      isTie = true;
    }

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Title
            Text(
              widget.match.roundName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 24),

            // Score Entry Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home Team
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        homeName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: _homeScoreController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.divider),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceLight,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),

                const Text(
                  'VS',
                  style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w900, fontSize: 18),
                ),

                // Away Team
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        awayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: _awayScoreController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.divider),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceLight,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tie breaker option for knockout draws
            if (isKnockout && isTie) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, color: AppTheme.primary, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Knockout Tiebreaker Required',
                          style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select the team that wins penalties/advances:',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(homeName),
                            selected: _penaltyWinnerId == widget.homeTeam?.id,
                            selectedColor: AppTheme.primary.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: _penaltyWinnerId == widget.homeTeam?.id ? AppTheme.primary : AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _penaltyWinnerId = widget.homeTeam?.id);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(awayName),
                            selected: _penaltyWinnerId == widget.awayTeam?.id,
                            selectedColor: AppTheme.primary.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: _penaltyWinnerId == widget.awayTeam?.id ? AppTheme.primary : AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _penaltyWinnerId = widget.awayTeam?.id);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Save / Action buttons
            Row(
              children: [
                if (widget.match.isPlayed)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearScore,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.accent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'RESET SCORE',
                        style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (widget.match.isPlayed) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveScore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: const Text(
                          'SAVE RESULT',
                          style: TextStyle(color: AppTheme.background, fontWeight: FontWeight.bold),
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
}
