import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../models/tournament.dart';
import '../providers/tournament_provider.dart';
import '../widgets/main_appbar.dart';
import '../widgets/short_section_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/points_settings_card.dart';
import '../widgets/toggle_setting_tile.dart';
import '../widgets/dynamic_input.dart';
import '../widgets/create_tournament_button.dart';
import '../widgets/delete_tournament_button.dart';

class EditTournamentScreen extends StatefulWidget {
  final Tournament tournament;

  const EditTournamentScreen({super.key, required this.tournament});

  @override
  State<EditTournamentScreen> createState() => _EditTournamentScreenState();
}

class _EditTournamentScreenState extends State<EditTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  late int _pointsWin;
  late int _pointsDraw;
  late int _pointsLoss;

  late bool _useRoulette;
  late bool _rouletteUnique;
  late bool _rouletteRoundUnique;
  late List<String> _roulettePool;

  final Map<int, TextEditingController> _playerControllers = {};

  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tournament.name);
    _pointsWin = widget.tournament.pointsForWin;
    _pointsDraw = widget.tournament.pointsForDraw;
    _pointsLoss = widget.tournament.pointsForLoss;

    _useRoulette = widget.tournament.useRoulette;
    _rouletteUnique = widget.tournament.rouletteUnique;
    _rouletteRoundUnique = widget.tournament.rouletteRoundUnique;
    _roulettePool = List.from(widget.tournament.roulettePool);

    final provider = Provider.of<TournamentProvider>(context, listen: false);
    for (final player in provider.activeTeams) {
      if (player.id != null) {
        _playerControllers[player.id!] = TextEditingController(text: player.name);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _playerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a tournament name'),
          backgroundColor: Color(0xFFD71212),
        ),
      );
      return;
    }

    if (_useRoulette && _roulettePool.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Roulette pool cannot be empty when roulette is enabled.'),
          backgroundColor: Color(0xFFD71212),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updatedPlayerNames = <int, String>{};
    for (final entry in _playerControllers.entries) {
      updatedPlayerNames[entry.key] = entry.value.text.trim();
    }

    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final success = await provider.updateTournamentSettings(
      tournamentId: widget.tournament.id!,
      name: name,
      pointsWin: _pointsWin,
      pointsDraw: _pointsDraw,
      pointsLoss: _pointsLoss,
      useRoulette: _useRoulette,
      roulettePool: _roulettePool,
      rouletteUnique: _rouletteUnique,
      rouletteRoundUnique: _rouletteRoundUnique,
      updatedPlayerNames: updatedPlayerNames,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tournament updated successfully!'),
          backgroundColor: Colors.black,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _deleteTournament() {
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
          'Are you sure you want to delete "${widget.tournament.name}"? This action cannot be undone.',
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
              if (widget.tournament.id != null) {
                setState(() => _isDeleting = true);
                final provider = Provider.of<TournamentProvider>(context, listen: false);
                await provider.deleteTournament(widget.tournament.id!);
                if (mounted) {
                  setState(() => _isDeleting = false);
                  // Pop Edit screen and Details screen back to Dashboard
                  Navigator.of(context).popUntil((route) => route.isFirst);
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
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TournamentProvider>(context);
    final players = provider.activeTeams;
    final isRoundRobin = widget.tournament.type == TournamentType.roundRobin;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with back button
            Stack(
              children: [
                const MainAppbar(),
                Positioned(
                  left: 10,
                  top: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            // Scrollable Content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      // Section 1: TOURNAMENT NAME
                      const ShortSectionHeader(title: 'TOURNAMENT NAME'),
                      const Gap(12),
                      CustomTextField(
                        controller: _nameController,
                        text: 'Enter tournament name...',
                      ),
                      const Gap(24),

                      // Section 2: EDIT PLAYERS NAMES
                      if (players.isNotEmpty) ...[
                        const ShortSectionHeader(title: 'PARTICIPANTS'),
                        const Gap(12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: players.map((player) {
                              final controller = _playerControllers[player.id];
                              if (controller == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F1F1),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                        color: Colors.black.withValues(alpha: 0.15),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Gap(12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          style: const TextStyle(
                                            fontFamily: 'RobotoMono',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const Gap(24),
                      ],

                      // Section 3: POINTS RULES (League only)
                      if (isRoundRobin) ...[
                        const ShortSectionHeader(title: 'POINTS SETTINGS'),
                        const Gap(12),
                        PointsSettingsCard(
                          initialWin: _pointsWin,
                          initialDraw: _pointsDraw,
                          initialLoss: _pointsLoss,
                          onChanged: (win, draw, loss) {
                            setState(() {
                              _pointsWin = win;
                              _pointsDraw = draw;
                              _pointsLoss = loss;
                            });
                          },
                        ),
                        const Gap(24),
                      ],

                      // Section 4: TEAM ROULETTE SETTINGS
                      const ShortSectionHeader(title: 'TEAM ROULETTE'),
                      const Gap(12),
                      ToggleSettingTile(
                        title: 'Enable Team Roulette',
                        subtitle: 'Assign random clubs to players',
                        initialValue: _useRoulette,
                        onChanged: (val) {
                          setState(() => _useRoulette = val);
                        },
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _useRoulette
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Column(
                          children: [
                            const Gap(12),
                            ToggleSettingTile(
                              title: 'Unique Teams Only',
                              subtitle: 'Prevent duplicate team assignments',
                              initialValue: _rouletteUnique,
                              onChanged: (val) {
                                setState(() => _rouletteUnique = val);
                              },
                            ),
                            const Gap(12),
                            ToggleSettingTile(
                              title: 'Distinct Teams Across Rounds',
                              subtitle: 'Prevent getting the same team twice',
                              initialValue: _rouletteRoundUnique,
                              onChanged: (val) {
                                setState(() => _rouletteRoundUnique = val);
                              },
                            ),
                            const Gap(12),
                            const ShortSectionHeader(title: 'ROULETTE POOL'),
                            const Gap(12),
                            DynamicInput(
                              tagType: 'Teams',
                              hintText: 'Enter team name (e.g. PSG, RMA)...',
                              initialTags: _roulettePool,
                              onTagsChanged: (tags) {
                                setState(() {
                                  _roulettePool = List.from(tags);
                                });
                              },
                            ),
                            const Gap(12),
                          ],
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),
                      const Gap(24),

                      // Save Button
                      CreateTournamentButton(
                        text: 'SAVE CHANGES',
                        isLoading: _isSaving,
                        onPressed: _isSaving || _isDeleting ? null : _saveSettings,
                      ),
                      const Gap(16),

                      // Delete Tournament Button
                      DeleteTournamentButton(
                        isLoading: _isDeleting,
                        onPressed: _isSaving || _isDeleting ? null : _deleteTournament,
                      ),
                      const Gap(30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
