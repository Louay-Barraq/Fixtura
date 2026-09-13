import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../models/standing.dart';
import '../providers/tournament_provider.dart';
import '../widgets/tournament_appbar.dart';
import '../widgets/tournament_tab_bar.dart';
import '../widgets/round_chip.dart';
import '../widgets/custom_match_card.dart';
import '../widgets/standings_header.dart';
import '../widgets/short_section_header.dart';
import '../widgets/standing_row_tile.dart';
import '../widgets/custom_roulette_wheel.dart';
import '../widgets/dropdown_tile.dart';
import '../widgets/player_status_tile.dart';
import '../widgets/roulette_actions_bottom_bar.dart';

class TournamentDetailsScreen extends StatefulWidget {
  final int tournamentId;

  const TournamentDetailsScreen({super.key, required this.tournamentId});

  @override
  State<TournamentDetailsScreen> createState() => _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen> {
  TournamentTab _activeTab = TournamentTab.fixtures;
  int _selectedRound = 1;
  int _selectedRouletteRound = -1;
  bool _initializedRound = false;
  int? _selectedPlayerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TournamentProvider>(context, listen: false)
          .loadTournamentDetails(widget.tournamentId);
    });
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
            backgroundColor: Color(0xFFFFFCFC),
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        if (tournament == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFFCFC),
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(
              child: Text(
                'Tournament not found.',
                style: TextStyle(fontFamily: 'RobotoMono', color: Colors.black),
              ),
            ),
          );
        }

        final showRouletteTab = tournament.useRoulette;

        // Initialize smart round selector (focus on first round with unplayed matches)
        if (!_initializedRound && matches.isNotEmpty) {
          int activeRound = 1;
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

        // Calculate progress percentage
        final completedMatches = matches.where((m) => m.isPlayed).length;
        final progress = matches.isEmpty ? 0 : ((completedMatches / matches.length) * 100).round();

        return Scaffold(
          backgroundColor: const Color(0xFFFFFCFC),
          body: SafeArea(
            child: Column(
              children: [
                // Fixed Top App Bar with back button navigation & Progress Bar
                Stack(
                  children: [
                    TournamentAppbar(
                      tournamentName: tournament.name,
                      progressValue: progress,
                    ),
                    Positioned(
                      left: 0,
                      top: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          provider.loadAllTournaments();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFD71212)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text(
                                'DELETE TOURNAMENT',
                                style: TextStyle(
                                  fontFamily: 'BebasNeue',
                                  fontSize: 22,
                                  color: Colors.black,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to delete "${tournament.name}"? This action cannot be undone.',
                                style: const TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text(
                                    'CANCEL',
                                    style: TextStyle(
                                      fontFamily: 'RobotoMono',
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    if (tournament.id != null) {
                                      await provider.deleteTournament(tournament.id!);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'DELETE',
                                    style: TextStyle(
                                      fontFamily: 'RobotoMono',
                                      color: Color(0xFFD71212),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const Gap(12),

                // Tournament Tab Bar (FIXTURES / STANDINGS / ROULETTE)
                TournamentTabBar(
                  isRouletteEnabled: showRouletteTab,
                  initialTab: _activeTab,
                  onTabSelected: (tab) {
                    setState(() {
                      _activeTab = tab;
                    });
                  },
                ),
                const Gap(16),

                // Active Tab Content View
                Expanded(
                  child: _buildActiveTabContent(provider, tournament, teams, matches),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build Content view based on active selected tab
  Widget _buildActiveTabContent(
    TournamentProvider provider,
    Tournament tournament,
    List<Team> teams,
    List<MatchModel> matches,
  ) {
    switch (_activeTab) {
      case TournamentTab.fixtures:
        return _buildFixturesTab(tournament, teams, matches, provider);
      case TournamentTab.standings:
        return _buildStandingsTab(provider);
      case TournamentTab.roulette:
        return _buildRouletteTab(provider, tournament, teams);
    }
  }

  // --- FIXTURES TAB VIEW ---
  Widget _buildFixturesTab(
    Tournament tournament,
    List<Team> teams,
    List<MatchModel> matches,
    TournamentProvider provider,
  ) {
    if (matches.isEmpty) {
      return const Center(
        child: Text(
          'No matches generated yet.',
          style: TextStyle(fontFamily: 'RobotoMono', color: Colors.black),
        ),
      );
    }

    final Set<int> roundNumbersSet = matches.map((m) => m.roundNumber).toSet();
    final List<int> sortedRounds = roundNumbersSet.toList()..sort();

    if (_selectedRound == -1 && sortedRounds.isNotEmpty) {
      _selectedRound = sortedRounds.first;
    }

    final filteredMatches = matches.where((m) => m.roundNumber == _selectedRound).toList();

    return Column(
      children: [
        // Horizontally Scrollable Round Chips Selector
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            itemCount: sortedRounds.length,
            itemBuilder: (context, index) {
              final rNum = sortedRounds[index];
              return RoundChip(
                label: '$rNum',
                isSelected: _selectedRound == rNum,
                onTap: () {
                  setState(() => _selectedRound = rNum);
                },
              );
            },
          ),
        ),
        // const Gap(50),

        // List of Matches in Selected Round
        Expanded(
          child: filteredMatches.isEmpty
              ? const Center(
                  child: Text(
                    'No matches in this round.',
                    style: TextStyle(fontFamily: 'RobotoMono', color: Colors.black),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
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

                    return CustomMatchCard(
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

  // --- STANDINGS TAB VIEW ---
  Widget _buildStandingsTab(TournamentProvider provider) {
    final List<Standing> standings = provider.calculateStandings();

    if (standings.isEmpty) {
      return const Center(
        child: Text(
          'No standings available.',
          style: TextStyle(fontFamily: 'RobotoMono', color: Colors.black),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Table Header (RANK, PLAYER, GD, PTS)
          const StandingsHeader(),
          const Gap(10),

          // List of Standing Rows
          ...List.generate(standings.length, (index) {
            final standing = standings[index];
            final rank = index + 1;
            final pts = standing.points(
              provider.activeTournament!.pointsForWin,
              provider.activeTournament!.pointsForDraw,
              provider.activeTournament!.pointsForLoss,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: StandingRowTile(
                rank: rank,
                playerName: standing.team.name,
                teamName: standing.team.assignedTeam,
                goalDifference: standing.goalDifference,
                points: pts,
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- ROULETTE TAB VIEW ---
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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                // Round Selector Chips
                if (rounds.isNotEmpty) ...[
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: rounds.length,
                      itemBuilder: (context, index) {
                        final rNum = rounds[index];
                        return RoundChip(
                          label: '$rNum',
                          isSelected: _selectedRouletteRound == rNum,
                          onTap: () {
                            setState(() {
                              _selectedRouletteRound = rNum;
                              _selectedPlayerId = teams.isNotEmpty ? teams.first.id : null;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const Gap(16),
                ],

                // Current Player Dropdown Selector
                if (teams.isNotEmpty) ...[
                  DropdownTile(
                    title: 'Current Player',
                    subtitle: 'Select active player to spin for',
                    initialValue: selectedPlayer.name,
                    options: teams.map((t) => t.name).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final chosen = teams.firstWhere((t) => t.name == val);
                        setState(() {
                          _selectedPlayerId = chosen.id;
                        });
                      }
                    },
                  ),
                  const Gap(16),
                ],

                // Custom Roulette Wheel Widget
                CustomRouletteWheel(
                  items: availableTeams,
                  onResult: (winner) {
                    if (selectedPlayer.id != null && selectedPlayer.id != -1) {
                      provider.setRouletteAssignment(
                        selectedPlayer.id!,
                        _selectedRouletteRound,
                        winner,
                      );
                    }
                  },
                ),
                const Gap(24),

                // PLAYERS STATUS SECTION
                const ShortSectionHeader(title: 'PLAYERS STATUS'),
                const Gap(12),

                ...teams.map((player) {
                  final assigned = provider.getRouletteAssignmentForTeamRound(player.id!, _selectedRouletteRound);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: PlayerStatusTile(
                      playerName: player.name,
                      teamName: assigned ?? 'NOT DRAFTED',
                    ),
                  );
                }),
                const Gap(16),
              ],
            ),
          ),
        ),

        // Roulette Bottom Action Buttons (AUTO DRAFT & RESET)
        RouletteActionsBottomBar(
          onAutoDraftAllRounds: rounds.isEmpty
              ? () {}
              : () async {
                  final error = await provider.autoDraftAllRounds();
                  if (error != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                        backgroundColor: const Color(0xFFD71212),
                      ),
                    );
                  }
                },
          onAutoDraftThisRound: rounds.isEmpty
              ? () {}
              : () async {
                  final error = await provider.autoDraftRound(_selectedRouletteRound);
                  if (error != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                        backgroundColor: const Color(0xFFD71212),
                      ),
                    );
                  }
                },
          onResetThisRound: rounds.isEmpty ? () {} : () => provider.resetRouletteRound(_selectedRouletteRound),
          onResetAllRounds: rounds.isEmpty ? () {} : () => provider.resetRouletteAllRounds(),
        ),
      ],
    );
  }
}
