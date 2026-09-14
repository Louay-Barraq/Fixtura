import 'package:fixtura/widgets/long_section_header.dart';
import 'package:flutter/material.dart';
import 'package:fixtura/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../providers/tournament_provider.dart';
import '../models/tournament.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../widgets/main_appbar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/tournament_card.dart';
import '../widgets/quick_action_card.dart';
import 'create_tournament_screen.dart';
import 'tournament_details_screen.dart';
import 'standalone_roulette_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0; // 0 = Home, 1 = Tournaments, 2 = Roulette

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TournamentProvider>(
        context,
        listen: false,
      ).loadAllTournaments();
    });
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTournamentScreen()),
    );
  }

  void _navigateToDetails(int tournamentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TournamentDetailsScreen(tournamentId: tournamentId),
      ),
    );
  }

  void _navigateToRoulette() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StandaloneRouletteScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentNavIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentNavIndex != 0) {
          setState(() {
            _currentNavIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFCFC),
        body: SafeArea(
          child: Column(
            children: [
              // Fixed Top App Bar
              const MainAppbar(),

              // Scrollable Middle Content
              Expanded(
                child: Consumer<TournamentProvider>(
                  builder: (context, provider, child) {
                    final activeCount = provider.tournaments
                        .where((t) => t.status == 'active')
                        .length;
                    final finishedCount = provider.tournaments
                        .where((t) => t.status == 'completed')
                        .length;
                    final totalCount = provider.tournaments.length;

                    if (_currentNavIndex == 1) {
                      return _buildTournamentsTab(
                        context,
                        provider,
                        totalCount,
                        activeCount,
                        finishedCount,
                      );
                    }

                    return _buildHomeTab(
                      context,
                      provider,
                      totalCount,
                      activeCount,
                      finishedCount,
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Fixed Bottom Nav Bar
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            if (index == 2) {
              _navigateToRoulette();
            } else {
              setState(() {
                _currentNavIndex = index;
              });
            }
          },
          onCreateTap: _navigateToCreate,
        ),
      ),
    );
  }

  /// Build Tab 0: Home Screen View
  Widget _buildHomeTab(
    BuildContext context,
    TournamentProvider provider,
    int totalCount,
    int activeCount,
    int finishedCount,
  ) {
    final l10n = AppLocalizations.of(context);
    final activeTournaments = provider.tournaments
        .where((t) => t.status == 'active')
        .toList();
    final lastTournament = activeTournaments.isNotEmpty
        ? activeTournaments.last
        : (provider.tournaments.isNotEmpty ? provider.tournaments.last : null);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const Gap(12),
          LongSectionHeader(title: l10n?.tournaments ?? 'TOURNAMENTS'),
          const Gap(12),

          // Stats Cards Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: StatCard(label: l10n?.total ?? 'Total', value: '$totalCount'),
                ),
                Expanded(
                  child: StatCard(label: l10n?.active ?? 'Active', value: '$activeCount'),
                ),
                Expanded(
                  child: StatCard(label: l10n?.finished ?? 'Finished', value: '$finishedCount'),
                ),
              ],
            ),
          ),
          const Gap(24),

          // Section: QUICK ACTIONS
          LongSectionHeader(title: l10n?.quickActions ?? 'QUICK ACTIONS'),
          const Gap(12),

          // Action Button 1: Create a new tournament
          QuickActionCard(
            label: l10n?.createNewTournament ?? 'Create a new tournament',
            onTap: _navigateToCreate,
          ),
          const Gap(10),

          // Action Button 2: Quick Roulette Spin
          QuickActionCard(
            label: l10n?.quickRouletteSpin ?? 'Quick Roulette Spin',
            onTap: _navigateToRoulette,
          ),
          const Gap(24),

          // Section: LAST ACTIVE TOURNAMENT
          if (lastTournament != null) ...[
            LongSectionHeader(title: l10n?.lastActiveTournament ?? 'LAST ACTIVE TOURNAMENT'),
            const Gap(12),
            _buildTournamentWidget(lastTournament, provider),
          ] else ...[
            LongSectionHeader(title: l10n?.lastActiveTournament ?? 'LAST ACTIVE TOURNAMENT'),
            const Gap(12),
            _buildEmptyState(context),
          ],
          const Gap(20),
        ],
      ),
    );
  }

  /// Build Tab 1: Tournaments List Screen View
  Widget _buildTournamentsTab(
    BuildContext context,
    TournamentProvider provider,
    int totalCount,
    int activeCount,
    int finishedCount,
  ) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const Gap(12),
          LongSectionHeader(title: l10n?.tournaments ?? 'TOURNAMENTS'),
          const Gap(12),

          // Stats Cards Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: StatCard(label: l10n?.total ?? 'Total', value: '$totalCount'),
                ),
                Expanded(
                  child: StatCard(label: l10n?.active ?? 'Active', value: '$activeCount'),
                ),
                Expanded(
                  child: StatCard(label: l10n?.finished ?? 'Finished', value: '$finishedCount'),
                ),
              ],
            ),
          ),
          const Gap(12),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const Gap(12),

          // Full Tournaments List
          if (provider.tournaments.isEmpty)
            _buildEmptyState(context)
          else
            ...provider.tournaments.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildTournamentWidget(t, provider),
              ),
            ),
          const Gap(20),
        ],
      ),
    );
  }

  /// Helper to map Tournament data model to TournamentCard widget
  Widget _buildTournamentWidget(Tournament t, TournamentProvider provider) {
    final allMatches = t.id != null ? provider.getMatchesForTournamentId(t.id!) : <MatchModel>[];
    final teams = t.id != null ? provider.getTeamsForTournamentId(t.id!) : <Team>[];

    // Exclude dummy BYE matches (where either team is null)
    final playableMatches = allMatches.where((m) => m.homeTeamId != null && m.awayTeamId != null).toList();
    final completedMatches = playableMatches.where((m) => m.isPlayed).length;
    final progress = playableMatches.isEmpty
        ? 0
        : ((completedMatches / playableMatches.length) * 100).round();

    // Pick the most recent real played match
    final lastMatch = playableMatches.where((m) => m.isPlayed).toList().lastOrNull;

    String? player1Name;
    String? player2Name;
    final bool hasLastMatch = lastMatch != null;

    if (hasLastMatch && teams.isNotEmpty) {
      final homeTeam = lastMatch.homeTeamId != null
          ? teams.where((team) => team.id == lastMatch.homeTeamId).firstOrNull
          : null;
      final awayTeam = lastMatch.awayTeamId != null
          ? teams.where((team) => team.id == lastMatch.awayTeamId).firstOrNull
          : null;
      if (homeTeam != null) player1Name = homeTeam.name;
      if (awayTeam != null) player2Name = awayTeam.name;
    }

    return TournamentCard(
      tournamentName: t.name,
      progressValue: progress,
      hasLastMatch: hasLastMatch,
      player1Name: player1Name,
      player2Name: player2Name,
      player1Score: lastMatch?.homeScore,
      player2Score: lastMatch?.awayScore,
      onTap: () => _navigateToDetails(t.id!),
    );
  }

  /// Placeholder when no tournaments exist
  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
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
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: Colors.black,
          ),
          const Gap(12),
          Text(
            l10n?.noTournamentsFound ?? 'No Tournaments Yet',
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(6),
          Text(
            l10n?.createYourFirst ?? 'Tap the Create button below to set up your first league or bracket!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
