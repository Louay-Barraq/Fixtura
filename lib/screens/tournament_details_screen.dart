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
import '../widgets/roulette_wheel.dart';
import '../database/database_helper.dart';

class TournamentDetailsScreen extends StatefulWidget {
  final int tournamentId;

  const TournamentDetailsScreen({super.key, required this.tournamentId});

  @override
  State<TournamentDetailsScreen> createState() => _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  int _selectedRound = 1;
  int _selectedRouletteRound = -1;
  bool _initializedRound = false;
  int? _selectedPlayerId;
  bool _isRouletteMenuOpen = false;

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
        
        final showRouletteTab = tournament.useRoulette;
        final tabCount = showRouletteTab ? 3 : 2;
        // Initialize TabController based on tournament type and roulette toggle
        if (_tabController == null || _tabController!.length != tabCount) {
          _tabController?.dispose();
          _tabController = TabController(length: tabCount, vsync: this);
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

        final rouletteRounds = provider.getRouletteRounds();
        if (showRouletteTab && rouletteRounds.isNotEmpty) {
          if (_selectedRouletteRound == -1 || !rouletteRounds.contains(_selectedRouletteRound)) {
            _selectedRouletteRound = rouletteRounds.first;
            _selectedPlayerId = null;
          }
        }

        final allPlayed = matches.isNotEmpty && matches.every((m) => m.isPlayed);
        final isCompleted = tournament.status == 'completed';

        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(tournament.name),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                onPressed: () {
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
                tabs: [
                  if (isRoundRobin) ...const [
                    Tab(icon: Icon(Icons.sports_soccer), text: 'Fixtures'),
                    Tab(icon: Icon(Icons.format_list_numbered), text: 'Standings'),
                  ] else ...const [
                    Tab(icon: Icon(Icons.emoji_events), text: 'Bracket Board'),
                    Tab(icon: Icon(Icons.sports_soccer), text: 'Fixtures List'),
                  ],
                  if (showRouletteTab)
                    const Tab(icon: Icon(Icons.circle_outlined), text: 'Roulette Draft'),
                ],
              ),
            ),
            body: Column(
              children: [
                if (isCompleted) _buildWinnerCard(context, tournament, teams, matches),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      if (isRoundRobin) ...[
                        _buildFixturesTab(tournament, teams, matches, provider),
                        _buildStandingsTab(provider),
                      ] else ...[
                        VisualBracket(
                          tournament: tournament,
                          teams: teams,
                          matches: matches,
                          assignedTeamResolver: (team, roundNumber) {
                            if (team == null || team.id == null || roundNumber == null) return null;
                            return provider.getRouletteAssignmentForTeamRound(team.id!, roundNumber);
                          },
                        ),
                        _buildFixturesTab(tournament, teams, matches, provider),
                      ],
                      if (showRouletteTab)
                        _buildRouletteTab(provider, tournament, teams),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: showRouletteTab
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_isRouletteMenuOpen) ...[
                        FloatingActionButton.extended(
                          heroTag: 'roulette_reset_all',
                          onPressed: rouletteRounds.isEmpty
                              ? null
                              : () {
                                  setState(() => _isRouletteMenuOpen = false);
                                  provider.resetRouletteAllRounds();
                                },
                          backgroundColor: AppTheme.surface,
                          icon: const Icon(Icons.restart_alt, color: AppTheme.accent),
                          label: const Text('RESET ALL ROUNDS', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton.extended(
                          heroTag: 'roulette_reset_round',
                          onPressed: rouletteRounds.isEmpty
                              ? null
                              : () {
                                  setState(() => _isRouletteMenuOpen = false);
                                  provider.resetRouletteRound(_selectedRouletteRound);
                                },
                          backgroundColor: AppTheme.surface,
                          icon: const Icon(Icons.refresh, color: AppTheme.accent),
                          label: const Text('RESET THIS ROUND', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton.extended(
                          heroTag: 'roulette_auto_all',
                          onPressed: rouletteRounds.isEmpty
                              ? null
                              : () {
                                  setState(() => _isRouletteMenuOpen = false);
                                  provider.autoDraftAllRounds();
                                },
                          backgroundColor: AppTheme.surface,
                          icon: const Icon(Icons.auto_fix_high, color: AppTheme.primary),
                          label: const Text('AUTO DRAFT ALL ROUNDS', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton.extended(
                          heroTag: 'roulette_auto_round',
                          onPressed: rouletteRounds.isEmpty
                              ? null
                              : () {
                                  setState(() => _isRouletteMenuOpen = false);
                                  provider.autoDraftRound(_selectedRouletteRound);
                                },
                          backgroundColor: AppTheme.surface,
                          icon: const Icon(Icons.auto_awesome, color: AppTheme.primary),
                          label: const Text('AUTO DRAFT THIS ROUND', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                      ],
                      FloatingActionButton(
                        heroTag: 'roulette_menu_toggle',
                        onPressed: rouletteRounds.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  _isRouletteMenuOpen = !_isRouletteMenuOpen;
                                });
                              },
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Icon(
                            _isRouletteMenuOpen ? Icons.close : Icons.menu,
                            color: AppTheme.background,
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
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
                                standing.team.assignedTeam != null
                                    ? '${standing.team.name} (${standing.team.assignedTeam})'
                                    : standing.team.name,
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
    TournamentProvider provider,
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
                      roundNumber: match.roundNumber,
                      assignedTeamResolver: (team, roundNumber) {
                        if (team == null || team.id == null || roundNumber == null) return null;
                        return provider.getRouletteAssignmentForTeamRound(team.id!, roundNumber);
                      },
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

  Widget _buildRouletteTab(TournamentProvider provider, Tournament tournament, List<Team> teams) {
    final rounds = provider.getRouletteRounds();

    if (rounds.isNotEmpty && (_selectedRouletteRound == -1 || !rounds.contains(_selectedRouletteRound))) {
      _selectedRouletteRound = rounds.first;
    }

    if (_selectedPlayerId == null && teams.isNotEmpty) {
      _selectedPlayerId = teams.first.id;
    } else if (_selectedPlayerId != null && !teams.any((team) => team.id == _selectedPlayerId) && teams.isNotEmpty) {
      _selectedPlayerId = teams.first.id;
    }

    final selectedPlayer = teams.firstWhere(
      (t) => t.id == _selectedPlayerId,
      orElse: () => teams.isNotEmpty ? teams.first : Team(id: -1, tournamentId: -1, name: 'TBD'),
    );

    final availableTeams = selectedPlayer.id == -1
        ? <String>[]
        : provider.getAvailableRouletteTeamsForPlayer(selectedPlayer, _selectedRouletteRound);

    final selectedAssignment = selectedPlayer.id == -1
        ? null
        : provider.getRouletteAssignmentForTeamRound(selectedPlayer.id!, _selectedRouletteRound);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Round selector
          if (rounds.isNotEmpty) ...[
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: rounds.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final roundNumber = rounds[index];
                  final isSelected = _selectedRouletteRound == roundNumber;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRouletteRound = roundNumber;
                        _selectedPlayerId = teams.isNotEmpty ? teams.first.id : null;
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary.withOpacity(0.12) : AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Round $roundNumber',
                            style: TextStyle(
                              color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedAssignment != null && isSelected ? selectedAssignment : 'Tap to draft',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? AppTheme.textSecondary : AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Header info & Reset Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ROUND ROULETTE',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
              ),
              const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 12),

          // Main Layout: Split list and wheel
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                if (rounds.isEmpty) ...[
                  const Column(
                    children: [
                      Icon(Icons.schedule_outlined, color: AppTheme.textSecondary, size: 48),
                      SizedBox(height: 12),
                      Text('No rounds available', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 6),
                      Text('Roulette rounds will appear after fixtures are generated.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ] else ...[
                  // Player selector for the selected round
                  DropdownButtonFormField<int>(
                    value: _selectedPlayerId,
                    dropdownColor: AppTheme.surface,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Select Player for Round $_selectedRouletteRound',
                      labelStyle: const TextStyle(color: AppTheme.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primary),
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceLight,
                    ),
                    items: teams.map((t) {
                      return DropdownMenuItem<int>(
                        value: t.id,
                        child: Text(t.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedPlayerId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Roulette Wheel
                  RouletteWheel(
                    options: availableTeams,
                    size: 260,
                    onResult: (winner) {
                      provider.setRouletteAssignment(selectedPlayer.id!, _selectedRouletteRound, winner);
                      
                      // Show assignment modal
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: AppTheme.primary, width: 2),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: AppTheme.primary, size: 64),
                              const SizedBox(height: 16),
                              const Text(
                                'ROULETTE RESULT',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ShaderMask(
                                shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                                child: Text(
                                  winner.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${selectedPlayer.name} • Round $_selectedRouletteRound',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: AppTheme.background,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                ),
                                child: const Text('AWESOME', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Assignment Table
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ROUND STATUS',
              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final roundAssignment = provider.getRouletteAssignmentForTeamRound(team.id!, _selectedRouletteRound);
              final isAssigned = roundAssignment != null;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAssigned ? AppTheme.primary.withOpacity(0.3) : AppTheme.divider.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      team.name,
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    if (isAssigned)
                      Row(
                        children: [
                          const Icon(Icons.check, color: AppTheme.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            roundAssignment,
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Pending Draft',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
