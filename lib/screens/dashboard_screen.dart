import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/tournament_provider.dart';
import '../models/tournament.dart';
import '../theme/app_theme.dart';
import 'create_tournament_screen.dart';
import 'tournament_details_screen.dart';
import 'standalone_roulette_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    // Load tournaments when dashboard initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TournamentProvider>(context, listen: false).loadAllTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<TournamentProvider>(
          builder: (context, provider, child) {
            final activeCount = provider.tournaments.where((t) => t.status == 'active').length;
            final completedCount = provider.tournaments.where((t) => t.status == 'completed').length;

            return CustomScrollView(
              slivers: [
                // Header & Branding
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                          child: const Center(
                            child: Text(
                            'EL BOUTOULA',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Host and manage local leagues & brackets',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats Dashboard Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            provider.tournaments.length.toString(),
                            Icons.emoji_events,
                            AppTheme.primaryGradient,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Active',
                            activeCount.toString(),
                            Icons.bolt,
                            const LinearGradient(colors: [Color(0xFFFF007F), Color(0xFF7B2CBF)]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Finished',
                            completedCount.toString(),
                            Icons.check_circle_outline,
                            const LinearGradient(colors: [Color(0xFF34C759), Color(0xFF00D2FF)]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section Title: My Tournaments
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0, bottom: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Tournaments',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        if (provider.tournaments.isNotEmpty)
                          Text(
                            '${provider.tournaments.length} Created',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ),

                // List of Tournaments or Empty Placeholder
                if (provider.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                  )
                else if (provider.tournaments.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF222F4D)),
                        ),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                              child: const Icon(
                                Icons.sports_soccer,
                                size: 72,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Tournaments Yet',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Kick off your first league or knockout brackets with your friends right now!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            ),
                            const SizedBox(height: 24),
                            _buildCreateButton(context),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tournament = provider.tournaments[index];
                          return _buildTournamentCard(context, tournament, provider);
                        },
                        childCount: provider.tournaments.length,
                      ),
                    ),
                  ),

                // Bottom spacer for Floating Button overlay
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                )
              ],
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isMenuOpen) ...[
            // Button 1: Standalone Roulette
            FloatingActionButton.extended(
              heroTag: 'menu_roulette',
              onPressed: () {
                setState(() => _isMenuOpen = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StandaloneRouletteScreen()),
                );
              },
              backgroundColor: AppTheme.surface,
              icon: const Icon(Icons.circle_outlined, color: AppTheme.primary),
              label: const Text('ROULETTE DRAFT', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            // Button 2: New Tournament
            FloatingActionButton.extended(
              heroTag: 'menu_tournament',
              onPressed: () {
                setState(() => _isMenuOpen = false);
                _navigateToCreateScreen(context);
              },
              backgroundColor: AppTheme.surface,
              icon: const Icon(Icons.emoji_events, color: AppTheme.primary),
              label: const Text('NEW TOURNAMENT', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
          ],
          // Main Toggle Button
          FloatingActionButton(
            heroTag: 'menu_toggle',
            onPressed: () {
              setState(() {
                _isMenuOpen = !_isMenuOpen;
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
                _isMenuOpen ? Icons.close : Icons.menu,
                color: AppTheme.background,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222F4D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              ShaderMask(
                shaderCallback: (bounds) => gradient.createShader(bounds),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _navigateToCreateScreen(context),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: 200, minHeight: 48),
          alignment: Alignment.center,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: AppTheme.background),
              SizedBox(width: 8),
              Text(
                'Create Tournament',
                style: TextStyle(color: AppTheme.background, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentCard(BuildContext context, Tournament tournament, TournamentProvider provider) {
    final isRoundRobin = tournament.type == TournamentType.roundRobin;
    final isCompleted = tournament.status == 'completed';
    final dateStr = DateFormat('MMM dd, yyyy').format(tournament.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TournamentDetailsScreen(tournamentId: tournament.id!),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tournament.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(isCompleted),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppTheme.divider, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isRoundRobin ? Icons.format_list_numbered : Icons.emoji_events,
                        color: AppTheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isRoundRobin ? 'League (Round-Robin)' : 'Brackets (Knockout)',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isRoundRobin)
                    Text(
                      'Legs: ${tournament.legs} | Win: ${tournament.pointsForWin}pts',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    )
                  else
                    const Text(
                      'Single Elimination',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.accent, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _confirmDelete(context, tournament, provider),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withOpacity(0.15) : AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green.withOpacity(0.4) : AppTheme.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        isCompleted ? 'Finished' : 'Live',
        style: TextStyle(
          color: isCompleted ? Colors.greenAccent : AppTheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _navigateToCreateScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTournamentScreen()),
    );
  }

  void _confirmDelete(BuildContext context, Tournament tournament, TournamentProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF222F4D)),
        ),
        title: const Text('Delete Tournament', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${tournament.name}"? This action is permanent and will delete all teams and matches.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              provider.deleteTournament(tournament.id!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
