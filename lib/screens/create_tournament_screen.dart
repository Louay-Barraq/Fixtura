import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tournament_provider.dart';
import '../models/tournament.dart';
import '../theme/app_theme.dart';
import 'tournament_details_screen.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teamInputController = TextEditingController();
  final _rouletteTeamInputController = TextEditingController();

  TournamentType _type = TournamentType.roundRobin;
  int _legs = 1; // 1 = Single, 2 = Double
  int _pointsWin = 3;
  int _pointsDraw = 1;
  int _pointsLoss = 0;

  final List<String> _teamNames = [];
  bool _showAdvancedSettings = false;
  bool _useRoulette = false;
  final List<String> _roulettePool = [];
  bool _rouletteUnique = true;
  bool _rouletteRoundUnique = true;

  int _estimatedRoundCount() {
    if (_type == TournamentType.roundRobin) {
      return _legs * (_teamNames.length - 1);
    }

    var rounds = 0;
    var powerOfTwo = 1;
    while (powerOfTwo < _teamNames.length) {
      powerOfTwo <<= 1;
      rounds++;
    }
    return rounds;
  }

  void _addRouletteTeam() {
    final name = _rouletteTeamInputController.text.trim();
    if (name.isEmpty) return;
    if (_roulettePool.any((existing) => existing.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team already in pool!'), backgroundColor: AppTheme.accent),
      );
      return;
    }
    setState(() {
      _roulettePool.add(name);
      _rouletteTeamInputController.clear();
    });
  }

  void _quickAddPopularClubs() {
    final popular = [
      'Real Madrid', 'Manchester City', 'FC Barcelona', 'Liverpool',
      'Bayern Munich', 'Arsenal', 'Paris Saint-Germain', 'Inter Milan',
      'AC Milan', 'Chelsea', 'Juventus', 'Atletico Madrid', 'Borussia Dortmund',
      'Bayer Leverkusen', 'Manchester United', 'Tottenham'
    ];
    setState(() {
      for (var club in popular) {
        if (!_roulettePool.contains(club)) {
          _roulettePool.add(club);
        }
      }
    });
  }

  void _quickAddPopularNations() {
    final popular = [
      'Argentina', 'France', 'Spain', 'Germany',
      'Portugal', 'Netherlands', 'Morocco', 'England',
      'Brazil','Belgium', 'Italy', 'Tunisia'
    ];
    setState(() {
      for (var nation in popular) {
        if (!_roulettePool.contains(nation)) {
          _roulettePool.add(nation);
        }
      }
    });
  }


  @override
  void dispose() {
    _nameController.dispose();
    _teamInputController.dispose();
    _rouletteTeamInputController.dispose();
    super.dispose();
  }

  void _addTeam() {
    final name = _teamInputController.text.trim();
    if (name.isEmpty) return;

    if (_teamNames.any((existing) => existing.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team name already exists!'), backgroundColor: AppTheme.accent),
      );
      return;
    }

    setState(() {
      _teamNames.add(name);
      _teamInputController.clear();
    });
  }

  void _removeTeam(int index) {
    setState(() {
      _teamNames.removeAt(index);
    });
  }

  // Pre-fills teams with placeholders for quick testing
  void _quickAddTeams(int count) {
    setState(() {
      final startIndex = _teamNames.length;
      for (int i = 1; i <= count; i++) {
        final newName = "Player ${startIndex + i}";
        if (!_teamNames.contains(newName)) {
          _teamNames.add(newName);
        }
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_teamNames.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need at least 2 teams to create a tournament.'), backgroundColor: AppTheme.accent),
      );
      return;
    }

    if (_useRoulette) {
      if (_roulettePool.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The roulette pool cannot be empty when Team Roulette is enabled.'),
            backgroundColor: AppTheme.accent,
          ),
        );
        return;
      }
      if (_rouletteRoundUnique && _roulettePool.length < _estimatedRoundCount()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You need at least ${_estimatedRoundCount()} roulette teams to keep assignments distinct across all rounds (you have ${_roulettePool.length}).'),
            backgroundColor: AppTheme.accent,
          ),
        );
        return;
      }
      if (_rouletteUnique && _roulettePool.length < _teamNames.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You need at least ${_teamNames.length} teams in the roulette pool to ensure unique assignments (you have ${_roulettePool.length}).'),
            backgroundColor: AppTheme.accent,
          ),
        );
        return;
      }
    }

    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final tournamentId = await provider.createTournament(
      name: _nameController.text.trim(),
      type: _type,
      legs: _legs,
      teamNames: _teamNames,
      pointsWin: _pointsWin,
      pointsDraw: _pointsDraw,
      pointsLoss: _pointsLoss,
      useRoulette: _useRoulette,
      roulettePool: _useRoulette ? _roulettePool : [],
      rouletteUnique: _useRoulette ? _rouletteUnique : true,
      rouletteRoundUnique: _useRoulette ? _rouletteRoundUnique : true,
    );

    if (tournamentId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tournament created successfully!'), backgroundColor: AppTheme.primary),
      );
      // Navigate directly to the tournament details screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TournamentDetailsScreen(tournamentId: tournamentId),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create tournament.'), backgroundColor: AppTheme.accent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tournament'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Basic Info
                      const Text(
                        'TOURNAMENT DETAILS',
                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Tournament Name',
                          hintText: 'e.g. EA FC Friday League',
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primary),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.accent),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                          ),
                          filled: true,
                          fillColor: AppTheme.surface,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a tournament name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Section 2: Format Type Selection
                      const Text(
                        'FORMAT',
                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormatCard(
                              title: 'League',
                              subtitle: 'Round-Robin',
                              icon: Icons.format_list_numbered,
                              isSelected: _type == TournamentType.roundRobin,
                              onTap: () => setState(() => _type = TournamentType.roundRobin),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormatCard(
                              title: 'Brackets',
                              subtitle: 'Knockout',
                              icon: Icons.emoji_events,
                              isSelected: _type == TournamentType.knockout,
                              onTap: () => setState(() => _type = TournamentType.knockout),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Section 3: Format-Specific Settings
                      if (_type == TournamentType.roundRobin) ...[
                        const Text(
                          'LEAGUE SETTINGS',
                          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Legs', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 2),
                                  const Text('(Matches vs each opponent)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                ],
                              ),
                              DropdownButton<int>(
                                value: _legs,
                                dropdownColor: AppTheme.surface,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('1 Leg (Single)', style: TextStyle(color: AppTheme.textPrimary))),
                                  DropdownMenuItem(value: 2, child: Text('2 Legs (Double)', style: TextStyle(color: AppTheme.textPrimary))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _legs = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Collapsible Advanced Settings for scoring
                        _buildAdvancedSettingsPanel(),
                        const SizedBox(height: 20),
                      ] else ...[
                        // Knockout note
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'For Knockouts, brackets are generated based on a power of 2. If the team count is not a power of 2 (e.g. 5 teams), BYEs will be automatically assigned to balance the brackets.',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Section: Roulette Settings
                      const Text(
                        'TEAM ROULETTE',
                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Enable Team Roulette', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                                SizedBox(height: 2),
                                Text('Assign random clubs to players', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                              ],
                            ),
                            Switch(
                              value: _useRoulette,
                              activeColor: AppTheme.primary,
                              onChanged: (val) {
                                setState(() => _useRoulette = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_useRoulette) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Unique Teams Only', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 2),
                                  Text('Prevent duplicate team assignments', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                ],
                              ),
                              Switch(
                                value: _rouletteUnique,
                                activeColor: AppTheme.primary,
                                onChanged: (val) {
                                  setState(() => _rouletteUnique = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Distinct Teams Across Rounds', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 2),
                                  Text('Prevent a player from getting the same team twice', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                ],
                              ),
                              Switch(
                                value: _rouletteRoundUnique,
                                activeColor: AppTheme.primary,
                                onChanged: (val) {
                                  setState(() => _rouletteRoundUnique = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'ROULETTE TEAM POOL',
                          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _rouletteTeamInputController,
                                style: const TextStyle(color: AppTheme.textPrimary),
                                decoration: InputDecoration(
                                  labelText: 'Add Team to Pool',
                                  hintText: 'e.g. Real Madrid, PSG, Arsenal',
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
                                  fillColor: AppTheme.surface,
                                ),
                                onSubmitted: (_) => _addRouletteTeam(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _addRouletteTeam,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              child: const Icon(Icons.add, color: AppTheme.background),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            const Text('Quick Pool: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ActionChip(
                              label: const Text('Top Clubs'),
                              labelStyle: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                              backgroundColor: AppTheme.surface,
                              side: const BorderSide(color: AppTheme.divider),
                              onPressed: _quickAddPopularClubs,
                            ),
                            const SizedBox(width: 8),
                            ActionChip(
                              label: const Text('Top Nations'),
                              labelStyle: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                              backgroundColor: AppTheme.surface,
                              side: const BorderSide(color: AppTheme.divider),
                              onPressed: _quickAddPopularNations,
                            ),
                            const SizedBox(width: 8),
                            if (_roulettePool.isNotEmpty)
                              TextButton(
                                onPressed: () => setState(() => _roulettePool.clear()),
                                child: const Text('Clear All', style: TextStyle(color: AppTheme.accent, fontSize: 12)),
                              )
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (_roulettePool.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.surface.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.help_outline, color: AppTheme.textSecondary, size: 24),
                                SizedBox(height: 6),
                                Text('Pool is empty. Add teams to choose from.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              ],
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_roulettePool.length, (index) {
                              return Chip(
                                label: Text(_roulettePool[index], style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
                                backgroundColor: AppTheme.surface,
                                side: const BorderSide(color: AppTheme.divider),
                                deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.accent),
                                onDeleted: () => setState(() => _roulettePool.removeAt(index)),
                              );
                            }),
                          ),
                        const SizedBox(height: 24),
                      ],

                      // Section 4: Team Addition
                      const Text(
                        'MANAGE PARTICIPANTS / TEAMS',
                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _teamInputController,
                              style: const TextStyle(color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Add Player / Team Name',
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
                                fillColor: AppTheme.surface,
                              ),
                              onSubmitted: (_) => _addTeam(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _addTeam,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            child: const Icon(Icons.add, color: AppTheme.background),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Quick Add Helpers
                      Row(
                        children: [
                          const Text('Quick Add: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          _buildQuickAddChip(4),
                          const SizedBox(width: 8),
                          _buildQuickAddChip(8),
                          const SizedBox(width: 8),
                          _buildQuickAddChip(16),
                          const SizedBox(width: 8),
                          if (_teamNames.isNotEmpty)
                            TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                              onPressed: () => setState(() => _teamNames.clear()),
                              child: const Text('Clear All', style: TextStyle(color: AppTheme.accent, fontSize: 12)),
                            )
                        ],
                      ),
                      const SizedBox(height: 16),

                      // List of current teams
                      if (_teamNames.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.divider.withOpacity(0.5), style: BorderStyle.solid),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.people_outline, color: AppTheme.textSecondary, size: 36),
                              SizedBox(height: 8),
                              Text('No teams added yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _teamNames.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.divider.withOpacity(0.8)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _teamNames[index],
                                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: AppTheme.accent, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _removeTeam(index),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom Create Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(top: BorderSide(color: AppTheme.divider)),
                ),
                child: Consumer<TournamentProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: provider.isLoading ? null : AppTheme.primaryGradient,
                          color: provider.isLoading ? AppTheme.divider : null,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          alignment: Alignment.center,
                          child: provider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: AppTheme.background, strokeWidth: 2),
                                )
                              : const Text(
                                  'KICK OFF CHAMPIONSHIP',
                                  style: TextStyle(
                                    color: AppTheme.background,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.08) : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddChip(int count) {
    return ActionChip(
      label: Text('+$count'),
      labelStyle: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
      backgroundColor: AppTheme.surface,
      side: const BorderSide(color: AppTheme.divider),
      padding: EdgeInsets.zero,
      onPressed: () => _quickAddTeams(count),
    );
  }

  Widget _buildAdvancedSettingsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showAdvancedSettings = !_showAdvancedSettings),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  _showAdvancedSettings ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Advanced Scoring Settings (PTS Rules)',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        if (_showAdvancedSettings) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildNumberInput('Win', _pointsWin, (val) => setState(() => _pointsWin = val)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberInput('Draw', _pointsDraw, (val) => setState(() => _pointsDraw = val)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberInput('Loss', _pointsLoss, (val) => setState(() => _pointsLoss = val)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNumberInput(String label, int val, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: [
            InkWell(
              onTap: () {
                if (val > 0) onChanged(val - 1);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.remove, size: 14, color: AppTheme.textPrimary),
              ),
            ),
            Expanded(
              child: Text(
                val.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            InkWell(
              onTap: () => onChanged(val + 1),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.add, size: 14, color: AppTheme.textPrimary),
              ),
            ),
          ],
        )
      ],
    );
  }
}
