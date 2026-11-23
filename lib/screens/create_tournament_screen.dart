import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:fixtura/l10n/app_localizations.dart';
import '../providers/tournament_provider.dart';
import '../models/tournament.dart';
import '../logic/tournament_rules.dart';
import '../widgets/app_back_button.dart';
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
  int _groupCount = 2;
  int _qualifiersPerGroup = 2;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int _leagueRounds(int players) {
    final effectiveTeams = players.isOdd ? players + 1 : players;
    return _legs * (effectiveTeams - 1);
  }

  int _bracketRounds(int entrants) {
    var rounds = 0;
    var powerOfTwo = 1;
    while (powerOfTwo < entrants) {
      powerOfTwo <<= 1;
      rounds++;
    }
    return rounds;
  }

  int _estimatedRoundCount() {
    final participantCount = _playerNames.length;
    switch (_type) {
      case TournamentType.roundRobin:
        return _leagueRounds(participantCount);
      case TournamentType.knockout:
        return _bracketRounds(participantCount);
      case TournamentType.groupsKnockout:
        // The biggest group sets the number of group rounds
        final biggestGroup = (participantCount / _groupCount).ceil();
        return _leagueRounds(biggestGroup) + _bracketRounds(_groupCount * _qualifiersPerGroup);
    }
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.pleaseEnterTournamentName,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD71212),
        ),
      );
      return;
    }

    if (_playerNames.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.atLeastTwoPlayersRequired,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD71212),
        ),
      );
      return;
    }

    if (_type == TournamentType.groupsKnockout) {
      final needed = minPlayersForGroups(_groupCount, _qualifiersPerGroup);
      if (_playerNames.length < needed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.groupsNeedMorePlayers(needed, _groupCount),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFD71212),
          ),
        );
        return;
      }
    }

    if (_useRoulette) {
      if (_teamNames.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.teamPoolEmptyError,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFD71212),
          ),
        );
        return;
      }
      if (_rouletteRoundUnique && _teamNames.length < _estimatedRoundCount()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.rouletteDistinctNeedsMore(_estimatedRoundCount(), _teamNames.length),
              style: const TextStyle(color: Colors.white),
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
              l10n.rouletteUniqueNeedsMore(_playerNames.length, _teamNames.length),
              style: const TextStyle(color: Colors.white),
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
      groupCount: _groupCount,
      qualifiersPerGroup: _qualifiersPerGroup,
    );

    if (tournamentId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tournamentCreatedSuccess, style: const TextStyle(color: Colors.white)),
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
        SnackBar(
          content: Text(
            l10n.failedToCreateTournament,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD71212),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top App Bar with back button navigation
            Stack(
              children: [
                const MainAppbar(),
                const AppBackButton(),
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
                      ShortSectionHeader(title: l10n.tournamentName),
                      const Gap(12),
                      CustomTextField(
                        controller: _nameController,
                        text: l10n.tournamentNameHint,
                      ),
                      const Gap(24),

                      // Section 2: FORMAT
                      ShortSectionHeader(title: l10n.format),
                      const Gap(12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: FormatOptionCard(
                                width: null,
                                title: l10n.league,
                                subtitle: l10n.roundRobin,
                                icon: Icons.leaderboard_rounded,
                                isSelected: _type == TournamentType.roundRobin,
                                onTap: () => setState(
                                  () => _type = TournamentType.roundRobin,
                                ),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: FormatOptionCard(
                                width: null,
                                title: l10n.brackets,
                                subtitle: l10n.knockout,
                                customPainter: (color) => _BracketFormatIconPainter(color),
                                isSelected: _type == TournamentType.knockout,
                                onTap: () =>
                                    setState(() => _type = TournamentType.knockout),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: FormatOptionCard(
                                width: null,
                                title: l10n.groups,
                                subtitle: l10n.groupsPlusKnockout,
                                icon: Icons.grid_view_rounded,
                                isSelected: _type == TournamentType.groupsKnockout,
                                onTap: () => setState(
                                  () => _type = TournamentType.groupsKnockout,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(24),

                      // Section 3: LEAGUE SETTINGS (Smooth Animated Transition)
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _type != TournamentType.knockout
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Column(
                          children: [
                            if (_type == TournamentType.groupsKnockout) ...[
                              ShortSectionHeader(title: l10n.groupSettings),
                              const Gap(12),
                              DropdownTile(
                                key: const ValueKey('groupCount'),
                                title: l10n.numberOfGroups,
                                subtitle: l10n.numberOfGroupsSubtitle,
                                initialValue: '$_groupCount',
                                options: [for (final g in groupCountOptions) '$g'],
                                onChanged: (val) {
                                  if (val != null) setState(() => _groupCount = int.parse(val));
                                },
                              ),
                              const Gap(16),
                              DropdownTile(
                                key: const ValueKey('qualifiers'),
                                title: l10n.qualifiersPerGroup,
                                subtitle: l10n.qualifiersPerGroupSubtitle,
                                initialValue: '$_qualifiersPerGroup',
                                options: [for (final q in qualifierOptions) '$q'],
                                onChanged: (val) {
                                  if (val != null) setState(() => _qualifiersPerGroup = int.parse(val));
                                },
                              ),
                              const Gap(24),
                            ],
                            ShortSectionHeader(title: l10n.leagueSettings),
                            const Gap(12),
                            DropdownTile(
                              key: const ValueKey('legs'),
                              title: l10n.legs,
                              subtitle: l10n.legsSubtitle,
                              initialValue: _legs == 1
                                  ? l10n.singleLeg
                                  : l10n.doubleLeg,
                              options: [
                                l10n.singleLeg,
                                l10n.doubleLeg,
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _legs = (val == l10n.singleLeg) ? 1 : 2;
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
                      ShortSectionHeader(title: l10n.teamRoulette),
                      const Gap(12),
                      ToggleSettingTile(
                        title: l10n.enableTeamRoulette,
                        subtitle: l10n.enableRouletteSubtitle,
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
                              title: l10n.uniqueTeamsOnly,
                              subtitle: l10n.uniqueTeamsSubtitle,
                              initialValue: _rouletteUnique,
                              onChanged: (val) {
                                setState(() => _rouletteUnique = val);
                              },
                            ),
                            const Gap(12),
                            ToggleSettingTile(
                              title: l10n.distinctTeamsAcrossRounds,
                              subtitle: l10n.distinctTeamsSubtitle,
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
                      ShortSectionHeader(title: l10n.managePlayers),
                      const Gap(12),
                      DynamicInput(
                        tagType: 'Players',
                        hintText: l10n.playerHint,
                        onTagsChanged: (players) {
                          setState(() {
                            _playerNames = List.from(players);
                          });
                        },
                      ),
                      const Gap(24),

                      // Section 6: MANAGE TEAMS
                      ShortSectionHeader(title: l10n.manageTeams),
                      const Gap(12),
                      DynamicInput(
                        tagType: 'Teams',
                        hintText: l10n.teamHint,
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
