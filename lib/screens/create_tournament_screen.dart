import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../providers/tournament_provider.dart';
import '../models/tournament.dart';
import '../widgets/main_appbar.dart';
import '../widgets/short_section_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/format_option_card.dart';
import '../widgets/dropdown_tile.dart';
import '../widgets/points_settings_card.dart';
import '../widgets/toggle_setting_tile.dart';
import '../widgets/dynamic_input.dart';
import '../widgets/create_tournament_button.dart';
import 'tournament_details_screen.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  TournamentType _type = TournamentType.roundRobin;
  int _legs = 1; // 1 = Single, 2 = Double
  int _pointsWin = 3;
  int _pointsDraw = 1;
  int _pointsLoss = 0;

  List<String> _playerNames = [];
  List<String> _teamNames = [];
  bool _useRoulette = false;
  bool _rouletteUnique = true;
  bool _rouletteRoundUnique = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int _estimatedRoundCount() {
    final participantCount = _playerNames.length;
    if (_type == TournamentType.roundRobin) {
      final effectiveTeams = participantCount.isOdd
          ? participantCount + 1
          : participantCount;
      return _legs * (effectiveTeams - 1);
    }
    var rounds = 0;
    var powerOfTwo = 1;
    while (powerOfTwo < participantCount) {
      powerOfTwo <<= 1;
      rounds++;
    }
    return rounds;
  }

  Future<void> _submitForm() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a tournament name',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFFD71212),
        ),
      );
      return;
    }

    if (_playerNames.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You need at least 2 players in MANAGE PLAYERS to create a tournament.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFFD71212),
        ),
      );
      return;
    }

    if (_useRoulette) {
      if (_teamNames.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The team pool (MANAGE TEAMS) cannot be empty when Team Roulette is enabled.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFFD71212),
          ),
        );
        return;
      }
      if (_rouletteRoundUnique && _teamNames.length < _estimatedRoundCount()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You need at least ${_estimatedRoundCount()} teams in MANAGE TEAMS to keep assignments distinct across all rounds (you have ${_teamNames.length}).',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFD71212),
          ),
        );
        return;
      }
      if (_rouletteUnique && _teamNames.length < _playerNames.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You need at least ${_playerNames.length} teams in MANAGE TEAMS to ensure unique assignments per player (you have ${_teamNames.length}).',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFD71212),
          ),
        );
        return;
      }
    }

    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final tournamentId = await provider.createTournament(
      name: name,
      type: _type,
      legs: _legs,
      teamNames:
          _playerNames, // Players are the tournament participants (John, David, etc.)
      pointsWin: _pointsWin,
      pointsDraw: _pointsDraw,
      pointsLoss: _pointsLoss,
      useRoulette: _useRoulette,
      roulettePool: _useRoulette
          ? _teamNames
          : (_teamNames.isNotEmpty
                ? _teamNames
                : []), // Teams used (PSG, RMA, etc.)
      rouletteUnique: _useRoulette ? _rouletteUnique : true,
      rouletteRoundUnique: _useRoulette ? _rouletteRoundUnique : true,
    );

    if (tournamentId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tournament created successfully!', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.black,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TournamentDetailsScreen(tournamentId: tournamentId),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to create tournament.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFFD71212),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top App Bar with back button navigation
            Stack(
              children: [
                const MainAppbar(),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  start: 10,
                  top: 10,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: 0,
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Transform.flip(
                        flipX: Directionality.of(context) == TextDirection.rtl,
                        child: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            // Scrollable Form Content
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

                      // Section 2: FORMAT
                      const ShortSectionHeader(title: 'FORMAT'),
                      const Gap(12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FormatOptionCard(
                            title: 'League',
                            subtitle: 'Round-Robin',
                            icon: Icons.leaderboard_rounded,
                            isSelected: _type == TournamentType.roundRobin,
                            onTap: () => setState(
                              () => _type = TournamentType.roundRobin,
                            ),
                          ),
                          const Gap(16),
                          FormatOptionCard(
                            title: 'BRACKETS',
                            subtitle: 'Knockout',
                            customPainter: (color) => _BracketFormatIconPainter(color),
                            isSelected: _type == TournamentType.knockout,
                            onTap: () =>
                                setState(() => _type = TournamentType.knockout),
                          ),
                        ],
                      ),
                      const Gap(24),

                      // Section 3: LEAGUE SETTINGS (Smooth Animated Transition)
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _type == TournamentType.roundRobin
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Column(
                          children: [
                            const ShortSectionHeader(title: 'LEAGUE SETTINGS'),
                            const Gap(12),
                            DropdownTile(
                              title: 'Legs',
                              subtitle: 'Number of matches per pair',
                              initialValue: _legs == 1
                                  ? '1 LEG (SINGLE)'
                                  : '2 LEGS (DOUBLE)',
                              options: const [
                                '1 LEG (SINGLE)',
                                '2 LEGS (DOUBLE)',
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _legs = val.contains('1') ? 1 : 2;
                                  });
                                }
                              },
                            ),
                            const Gap(16),
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
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),

                      // Section 4: TEAM ROULETTE
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
                          ],
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),
                      const Gap(12),

                      // Section 5: MANAGE PLAYERS
                      const ShortSectionHeader(title: 'MANAGE PLAYERS'),
                      const Gap(12),
                      DynamicInput(
                        tagType: 'Players',
                        hintText: 'Enter player name (e.g. John, David)...',
                        onTagsChanged: (players) {
                          setState(() {
                            _playerNames = List.from(players);
                          });
                        },
                      ),
                      const Gap(24),

                      // Section 6: MANAGE TEAMS
                      const ShortSectionHeader(title: 'MANAGE TEAMS'),
                      const Gap(12),
                      DynamicInput(
                        tagType: 'Teams',
                        hintText: 'Enter team name (e.g. PSG, RMA, FCB)...',
                        onTagsChanged: (teams) {
                          setState(() {
                            _teamNames = List.from(teams);
                          });
                        },
                      ),
                      const Gap(32),

                      // Submit Action Button (Right aligned, #D71212)
                      Consumer<TournamentProvider>(
                        builder: (context, provider, child) {
                          return CreateTournamentButton(
                            isLoading: provider.isLoading,
                            onPressed: _submitForm,
                          );
                        },
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

class _BracketFormatIconPainter extends CustomPainter {
  final Color color;
  _BracketFormatIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Bracket lines: two inputs converging into a single match line
    final path = Path()
      ..moveTo(w * 0.18, h * 0.24)
      ..lineTo(w * 0.50, h * 0.24)
      ..moveTo(w * 0.18, h * 0.76)
      ..lineTo(w * 0.50, h * 0.76)
      ..moveTo(w * 0.50, h * 0.24)
      ..lineTo(w * 0.50, h * 0.76)
      ..moveTo(w * 0.50, h * 0.50)
      ..lineTo(w * 0.84, h * 0.50);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BracketFormatIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
