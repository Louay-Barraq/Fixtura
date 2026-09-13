import 'package:flutter/material.dart';
import 'package:fixtura/widgets/standing_row_tile.dart';
import 'package:fixtura/widgets/standings_header.dart';

class StandingEntry {
  final int rank;
  final String playerName;
  final String? teamName;
  final int goalDifference;
  final int points;

  const StandingEntry({
    required this.rank,
    required this.playerName,
    this.teamName,
    required this.goalDifference,
    required this.points,
  });
}

class StandingsTable extends StatelessWidget {
  final List<StandingEntry> entries;

  const StandingsTable({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Standings Table Header
          const StandingsHeader(),
          const SizedBox(height: 12),

          // Dynamic Standings Row List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return StandingRowTile(
                rank: entry.rank,
                playerName: entry.playerName,
                teamName: entry.teamName,
                goalDifference: entry.goalDifference,
                points: entry.points,
              );
            },
          ),
        ],
      ),
    );
  }
}
