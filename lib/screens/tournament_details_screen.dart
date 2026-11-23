import 'package:flutter/material.dart';
import 'package:fixtura/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gap/gap.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../models/standing.dart';
import '../providers/tournament_provider.dart';
import '../logic/tournament_rules.dart';
import '../logic/share_text.dart';
import '../widgets/app_back_button.dart';
import '../widgets/circle_icon_button.dart';
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
import 'edit_tournament_screen.dart';

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
            body: Center(
              child: Text(
                AppLocalizations.of(context)!.tournamentNotFound,
                style: const TextStyle(fontFamily: 'RobotoMono', color: Colors.black),
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
        final progress = provider.calculateTournamentProgress(tournament.type, matches);

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
                    AppBackButton(
                      onTap: () {
                        provider.loadAllTournaments();
                        Navigator.pop(context);
                      },
                    ),
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      end: 58,
                      top: 10,
                      child: Semantics(
                        label: AppLocalizations.of(context)!.shareResults,
                        button: true,
                        child: CircleIconButton(
                          icon: Icons.share_rounded,
                          onTap: () => Share.share(
                            buildShareText(
                              l10n: AppLocalizations.of(context)!,
                              tournament: tournament,
                              teams: teams,
                              matches: matches,
                            ),
                            subject: tournament.name,
                          ),
                        ),
                      ),
                    ),
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      end: 10,
                      top: 10,
                      child: CircleIconButton(
                        icon: Icons.tune_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTournamentScreen(
                                tournament: tournament,
                              ),
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
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noMatchesYet,
          style: const TextStyle(fontFamily: 'RobotoMono', color: Colors.black),
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

        // List of Matches in Selected Round
        Expanded(
          child: filteredMatches.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noMatchesInRound,
                    style: const TextStyle(fontFamily: 'RobotoMono', color: Colors.black),
                  ),
                )
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: _buildRoundMatchList(tournament, teams, matches, filteredMatches, provider),
                ),
        ),
      ],
    );
  }

  List<Widget> _buildRoundMatchList(
    Tournament tournament,
    List<Team> teams,
    List<MatchModel> allMatches,
    List<MatchModel> roundMatches,
    TournamentProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isGroups = tournament.type == TournamentType.groupsKnockout;
    final sorted = [...roundMatches]
      ..sort((a, b) => (a.groupIndex ?? -1).compareTo(b.groupIndex ?? -1));
    final widgets = <Widget>[];

    if (isGroups && sorted.first.groupIndex == null && !groupStageComplete(allMatches)) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            l10n.knockoutWaitingForGroups,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 12, color: Colors.black54),
          ),
        ),
      );
    }

    int? currentGroup;
    for (final match in sorted) {
      if (match.groupIndex != null && match.groupIndex != currentGroup) {
        currentGroup = match.groupIndex;
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 12, bottom: 6),
            child: ShortSectionHeader(title: l10n.groupName(groupLetter(currentGroup!))),
          ),
        );
      }

      Team? find(int? id) => id == null ? null : teams.where((t) => t.id == id).firstOrNull;
      widgets.add(
        CustomMatchCard(
          match: match,
          homeTeam: find(match.homeTeamId),
          awayTeam: find(match.awayTeamId),
          tournamentType: stageType(tournament.type, match),
          roundNumber: match.roundNumber,
          assignedTeamResolver: (team, roundNumber) {
            if (team == null || team.id == null || roundNumber == null) return null;
            return provider.getRouletteAssignmentForTeamRound(team.id!, roundNumber);
          },
        ),
      );
    }
    return widgets;
  }

  // --- STANDINGS TAB VIEW ---
  Widget _buildStandingsTab(TournamentProvider provider) {
    final tournament = provider.activeTournament!;
    final isGroups = tournament.type == TournamentType.groupsKnockout;
    final tables = isGroups
        ? provider.calculateGroupStandings()
        : [provider.calculateStandings()].where((t) => t.isNotEmpty).toList();

    if (tables.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noStandings,
          style: const TextStyle(fontFamily: 'RobotoMono', color: Colors.black),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          for (var g = 0; g < tables.length; g++) ...[
            if (isGroups) ...[
              if (g > 0) const Gap(16),
              ShortSectionHeader(
                title: AppLocalizations.of(context)!.groupName(groupLetter(g)),
              ),
              const Gap(10),
            ],
            // Table Header (RANK, PLAYER, GD, PTS)
            const StandingsHeader(),
            const Gap(10),
            ..._buildStandingRows(tournament, tables[g]),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildStandingRows(Tournament tournament, List<Standing> standings) {
    return List.generate(standings.length, (index) {
      final standing = standings[index];
      final pts = standing.points(
        tournament.pointsForWin,
        tournament.pointsForDraw,
        tournament.pointsForLoss,
      );

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: StandingRowTile(
          rank: index + 1,
          playerName: standing.team.name,
          teamName: standing.team.assignedTeam,
          goalDifference: standing.goalDifference,
          points: pts,
        ),
      );
    });
  }

  String _draftErrorMessage(RouletteDraftError error) {
    final l10n = AppLocalizations.of(context)!;
    if (error.round != null && error.player != null) {
      return l10n.notEnoughRouletteTeams(error.round!, error.player!);
    }
    return l10n.autoDraftFailed;
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
        // Round Selector Chips (pinned at top, matching fixtures tab)
        if (rounds.isNotEmpty)
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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

        // Scrollable content below the round chips
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                // Current Player Dropdown Selector
                if (teams.isNotEmpty) ...[
                  DropdownTile(
                    title: AppLocalizations.of(context)!.currentPlayer,
                    subtitle: AppLocalizations.of(context)!.currentPlayerSubtitle,
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
                ShortSectionHeader(title: AppLocalizations.of(context)!.playersStatus),
                const Gap(12),

                ...teams.map((player) {
                  final assigned = provider.getRouletteAssignmentForTeamRound(player.id!, _selectedRouletteRound);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: PlayerStatusTile(
                      playerName: player.name,
                      teamName: assigned ?? AppLocalizations.of(context)!.notDrafted,
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
                        content: Text(_draftErrorMessage(error)),
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
                        content: Text(_draftErrorMessage(error)),
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
