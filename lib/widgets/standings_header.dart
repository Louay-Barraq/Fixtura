import 'package:flutter/material.dart';

class StandingsHeader extends StatelessWidget {
  const StandingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
            color: Color(0xFF000000).withValues(alpha: 0.25),
          ),
        ],
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              'RANK',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'PLAYER',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              'GD',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 54,
            child: Text(
              'PTS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}