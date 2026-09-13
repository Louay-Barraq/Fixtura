import 'package:flutter/material.dart';

class PlayerStatusTile extends StatelessWidget {
  final String playerName;
  final String teamName;

  const PlayerStatusTile({
    super.key,
    required this.playerName,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player Name
          Expanded(
            child: Text(
              playerName,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 12),

          // Team Badge
          Container(
            width: 130,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.black,
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
            child: Center(
              child: Text(
                teamName,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}