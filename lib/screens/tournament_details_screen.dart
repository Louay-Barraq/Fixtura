import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../models/standing.dart';
import '../providers/tournament_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/match_card.dart';
import '../widgets/visual_bracket.dart';
import '../database/database_helper.dart';

class TournamentDetailsScreen extends StatefulWidget {
  final int tournamentId;

  const TournamentDetailsScreen({super.key, required this.tournamentId});

  @override
  State<TournamentDetailsScreen> createState() => _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _selectedRound = 1;
  bool _initializedRound = false;

  @override
  void initState() {
    super.initState();
    // Load tournament data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TournamentProvider>(context, listen: false)
          .loadTournamentDetails(widget.tournamentId);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Color _parseColor(String? hexString) {
    if (hexString == null) return AppTheme.textSecondary;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (context, provider, child) {
        final tournament = provider.activeTournament;
        final teams = provider.activeTeams;
        final matches = provider.activeMatches;

        if (provider.isLoading && tournament == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }

        if (tournament == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Tournament not found.', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          );
        }

        final isRoundRobin = tournament.type == TournamentType.roundRobin;
        
        // Initialize TabController based on tournament type
        if (_tabController == null) {
          _tabController = TabController(length: 2, vsync: this);
        }

        // Initialize smart round selector (focus on first round with unplayed matches)
        if (!_initializedRound && matches.isNotEmpty) {
          int activeRound = 1;
          // Group rounds
          final Set<int> rounds = matches.map((m) => m.roundNumber).toSet();
          final sortedRounds = rounds.toList()..sort();
          
          for (var r in sortedRounds) {
            final roundMatches = matches.where((m) => m.roundNumber == r);
            if (roundMatches.any((m) => !m.isPlayed && m.homeTeamId != null && m.awayTeamId != null)) {
              activeRound = r;
              break;
            }
          }
          _selectedRound = activeRound;
          _initializedRound = true;
        }

        final allPlayed = matches.isNotEmpty && matches.every((m) => m.isPlayed);
        final isCompleted = tournament.status == 'completed';

        return Scaffold(
          appBar: AppBar(
            title: Text(tournament.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              onPressed: () {
                // Refresh list on return
                provider.loadAllTournaments();
                Navigator.pop(context);
              },
            ),
            actions: [
              if (allPlayed && !isCompleted)
                IconButton(
                  icon: const Icon(Icons.stars, color: AppTheme.primary),
                  tooltip: 'Complete Tournament',
                  onPressed: () => _completeTournament(context, tournament, provider),
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primary,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              tabs: isRoundRobin
                  ? const [
                      Tab(icon: Icon(Icons.sports_soccer), text: 'Fixtures'),
                      Tab(icon: Icon(Icons.format_list_numbered), text: 'Standings'),
                    ]
                  : const [
                      Tab(icon: Icon(Icons.sports_soccer), text: 'Fixtures List'),
                      Tab(icon: Icon(Icons.emoji_events), text: 'Bracket Board'),
                    ],
            ),
          ),
          body: Column(
            children: [
              // Winner celebration card if completed
              if (isCompleted) _buildWinnerCard(context, tournament, teams, matches),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: isRoundRobin
                      ? [
                          // Tab 1: Standings
                          _buildStandingsTab(provider),
                          // Tab 2: Fixtures
                          _buildFixturesTab(tournament, teams, matches),
                        ]
                      : [
                          // Tab 1: Bracket Board
                          VisualBracket(tournament: tournament, teams: teams, matches: matches),
                          // Tab 2: Fixtures List
                          _buildFixturesTab(tournament, teams, matches),
                        ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Standings Tab ---
  Widget _buildStandingsTab(TournamentProvider provider) {
    final List<Standing> standings = provider.calculateStandings();

    if (standings.isEmpty) {
      return const Center(
        child: Text('No standings available.', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF222F4D)),
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 24, child: Text('Pos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary))),
                  SizedBox(width: 8),
                  Expanded(child: Text('Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary))),
                  SizedBox(width: 30, child: Text('P', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary))),
                  SizedBox(width: 30, child: Text('W', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary))),
                  SizedBox(width: 30, child: Text('D', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary))),
                  SizedBox(width: 30, child: Text('L', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary))),
                  SizedBox(width: 40, child: Text('GD', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary))),
                  SizedBox(width: 40, child: Text('PTS', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary))),
                ],
              ),
            ),
            
            // Standings Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: standings.length,
              separatorBuilder: (context, index) => const Divider(color: AppTheme.divider, height: 1),
              itemBuilder: (context, index) {
                final standing = standings[index];
                final teamColor = _parseColor(standing.team.colorHex);
                final pos = index + 1;
                
                // Styles for top 1 (leader)
                final isLeader = pos == 1;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  color: isLeader ? AppTheme.primary.withOpacity(0.02) : Colors.transparent,
                  child: Row(
                    children: [
                      // Position
                      SizedBox(
                        width: 24,
                        child: Text(
                          '$pos',
                          style: TextStyle(
                            fontWeight: isLeader ? FontWeight.bold : FontWeight.normal,
                            color: isLeader ? AppTheme.primary : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Color indicator & Team Name
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 16,
                              decoration: BoxDecoration(
                                color: teamColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                standing.team.name,
                                style: TextStyle(
                                  fontWeight: isLeader ? FontWeight.bold : FontWeight.w600,
                                  color: isLeader ? AppTheme.textPrimary : AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stats
                      SizedBox(width: 30, child: Text('${standing.played}', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary))),
                      SizedBox(width: 30, child: Text('${standing.won}', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary))),
                      SizedBox(width: 30, child: Text('${standing.drawn}', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary))),
                      SizedBox(width: 30, child: Text('${standing.lost}', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary))),
                      SizedBox(
                        width: 40, 
                        child: Text(
                          (standing.goalDifference >= 0 ? '+' : '') + '${standing.goalDifference}', 
                          textAlign: TextAlign.center, 
                          style: TextStyle(
                            color: standing.goalDifference > 0 
                                ? Colors.greenAccent 
                                : (standing.goalDifference < 0 ? AppTheme.accent : AppTheme.textSecondary),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      
                      // Points
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${standing.points(
                            provider.activeTournament!.pointsForWin,
                            provider.activeTournament!.pointsForDraw,
                            provider.activeTournament!.pointsForLoss,
                          )}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isLeader ? AppTheme.primary : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Fixtures Tab ---
  Widget _buildFixturesTab(
    Tournament tournament,
    List<Team> teams,
    List<MatchModel> matches,
  ) {
    if (matches.isEmpty) {
      return const Center(
        child: Text('No matches generated.', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    // Extract unique round numbers
    final Set<int> roundNumbersSet = matches.map((m) => m.roundNumber).toSet();
    final List<int> sortedRounds = roundNumbersSet.toList()..sort();

    if (_selectedRound == -1 && sortedRounds.isNotEmpty) {
      _selectedRound = sortedRounds.first;
    }

    final filteredMatches = matches.where((m) => m.roundNumber == _selectedRound).toList();

    return Column(
      children: [
        // Horizontal Round Selector Chips
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedRounds.length,
            itemBuilder: (context, index) {
              final rNum = sortedRounds[index];
              // Get round name
              final roundMatch = matches.firstWhere((m) => m.roundNumber == rNum);
              final rName = roundMatch.roundName;
              final isSelected = _selectedRound == rNum;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(rName),
                  selected: isSelected,
                  selectedColor: AppTheme.primary.withOpacity(0.15),
                  backgroundColor: AppTheme.surface,
                  side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.divider),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedRound = rNum);
                    }
                  },
                ),
              );
            },
          ),
        ),

        // Fixtures list for the selected round
        Expanded(
          child: filteredMatches.isEmpty
              ? const Center(child: Text('No matches in this round.', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filteredMatches.length,
                  itemBuilder: (context, index) {
                    final match = filteredMatches[index];
                    final homeTeam = teams.firstWhere(
                      (t) => t.id == match.homeTeamId,
                      orElse: () => Team(id: -1, tournamentId: -1, name: 'TBD'),
                    );
                    final awayTeam = teams.firstWhere(
                      (t) => t.id == match.awayTeamId,
                      orElse: () => Team(id: -1, tournamentId: -1, name: 'TBD'),
                    );

                    return MatchCard(
                      match: match,
                      homeTeam: homeTeam.id == -1 ? null : homeTeam,
                      awayTeam: awayTeam.id == -1 ? null : awayTeam,
                      tournamentType: tournament.type,
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- Winner Splash Banner for Completed Tournaments ---
  Widget _buildWinnerCard(
    BuildContext context,
    Tournament tournament,
    List<Team> teams,
    List<MatchModel> matches,
  ) {
    Team? winner;
    if (tournament.type == TournamentType.roundRobin) {
      // Find top team in standings
      final provider = Provider.of<TournamentProvider>(context, listen: false);
      final List<Standing> standings = provider.calculateStandings();
      if (standings.isNotEmpty) {
        winner = standings.first.team;
      }
    } else {
      // In Knockout: Winner of the final match (which is the last round, roundNumber = max)
      final Set<int> roundNumbers = matches.map((m) => m.roundNumber).toSet();
      if (roundNumbers.isNotEmpty) {
        final finalRoundNum = roundNumbers.reduce((a, b) => a > b ? a : b);
        final finalMatch = matches.firstWhere((m) => m.roundNumber == finalRoundNum);
        if (finalMatch.isPlayed && finalMatch.homeScore != null && finalMatch.awayScore != null) {
          if (finalMatch.homeScore! > finalMatch.awayScore!) {
            winner = teams.firstWhere((t) => t.id == finalMatch.homeTeamId, orElse: () => Team(id: -1, tournamentId: -1, name: 'TBD'));
          } else {
            winner = teams.firstWhere((t) => t.id == finalMatch.awayTeamId, orElse: () => Team(id: -1, tournamentId: -1, name: 'TBD'));
          }
        }
      }
    }

    if (winner == null || winner.id == -1) return const SizedBox.shrink();

    final winnerColor = _parseColor(winner.colorHex);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [winnerColor.withOpacity(0.15), AppTheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: winnerColor.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
            child: const Icon(Icons.emoji_events, size: 48, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHAMPION CROWNED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  winner.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Conquered "${tournament.name}"!',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- Complete Tournament Action ---
  void _completeTournament(
    BuildContext context,
    Tournament tournament,
    TournamentProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF222F4D)),
        ),
        title: const Text('Complete Championship', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'All matches have been played! Would you like to officially close this tournament and crown the champion?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            child: const Text('Not Yet', style: TextStyle(color: AppTheme.textSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Crown Champion', style: TextStyle(color: AppTheme.background, fontWeight: FontWeight.bold)),
            onPressed: () async {
              final completedTournament = tournament.copyWith(status: 'completed');
              await DatabaseHelper.instance.updateTournament(completedTournament);
              await provider.loadTournamentDetails(tournament.id!);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Championship finished! Champion has been crowned.'), backgroundColor: AppTheme.primary),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
