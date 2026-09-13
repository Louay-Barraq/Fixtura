import 'package:flutter/material.dart';

class StandingRowTile extends StatelessWidget {
  final int rank;
  final String playerName;
  final String? teamName;
  final int goalDifference;
  final int points;

  const StandingRowTile({
    super.key,
    required this.rank,
    required this.playerName,
    this.teamName,
    required this.goalDifference,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final String gdString =
        goalDifference > 0 ? '+$goalDifference' : '$goalDifference';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 2,
            color: Color(0xFF000000).withValues(alpha: 0.25),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          SizedBox(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 30),

          // Player & Team Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  playerName,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                // if (teamName != null && teamName!.isNotEmpty) ...[
                //   const SizedBox(height: 2),
                //   Text(
                //     teamName!,
                //     style: TextStyle(
                //       fontFamily: 'RobotoMono',
                //       fontSize: 10,
                //       color: Colors.grey[700],
                //     ),
                //   ),
                // ],
              ],
            ),
          ),

          // Goal Difference (GD)
          SizedBox(
            width: 100,
            child: Text(
              gdString,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),

          // Points Badge (PTS)
          Container(
            width: 54,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$points',
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}