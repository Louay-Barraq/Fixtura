import 'package:flutter/material.dart';

enum TournamentTab { fixtures, standings, roulette }

class TournamentTabBar extends StatefulWidget {
  final bool isRouletteEnabled;
  final TournamentTab initialTab;
  final ValueChanged<TournamentTab> onTabSelected;

  const TournamentTabBar({
    super.key,
    required this.isRouletteEnabled,
    this.initialTab = TournamentTab.fixtures,
    required this.onTabSelected,
  });

  @override
  State<TournamentTabBar> createState() => _TournamentTabBarState();
}

class _TournamentTabBarState extends State<TournamentTabBar> {
  late TournamentTab currentTab;

  @override
  void initState() {
    super.initState();
    currentTab = widget.initialTab;
  }

  void _selectTab(TournamentTab tab) {
    setState(() {
      currentTab = tab;
    });
    widget.onTabSelected(tab);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 2,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ],
      ),
      child: widget.isRouletteEnabled
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: FIXTURES & STANDINGS
                Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        label: 'FIXTURES',
                        tab: TournamentTab.fixtures,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTabButton(
                        label: 'STANDINGS',
                        tab: TournamentTab.standings,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Bottom Center: ROULETTE (80% width)
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: _buildTabButton(
                    label: 'ROULETTE',
                    tab: TournamentTab.roulette,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                // Horizontal Row: FIXTURES & STANDINGS only
                Expanded(
                  child: _buildTabButton(
                    label: 'FIXTURES',
                    tab: TournamentTab.fixtures,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                    label: 'STANDINGS',
                    tab: TournamentTab.standings,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required TournamentTab tab,
  }) {
    final bool isSelected = currentTab == tab;

    return GestureDetector(
      onTap: () => _selectTab(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 2,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.1,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}