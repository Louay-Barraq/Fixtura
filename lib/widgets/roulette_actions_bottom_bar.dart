import 'package:flutter/material.dart';

class RouletteActionsBottomBar extends StatelessWidget {
  final VoidCallback? onAutoDraftAllRounds;
  final VoidCallback? onAutoDraftThisRound;
  final VoidCallback? onResetThisRound;
  final VoidCallback? onResetAllRounds;

  const RouletteActionsBottomBar({
    super.key,
    this.onAutoDraftAllRounds,
    this.onAutoDraftThisRound,
    this.onResetThisRound,
    this.onResetAllRounds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      boxShadow: [
        BoxShadow(
          offset: Offset(0, -1),
          blurRadius: 4,
          spreadRadius: 0,
          color: Color(0xFF000000).withValues(alpha: 0.25),
        ),
        ],
      ),
      
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section Title
          const Text(
            'ACTIONS',
            style: TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: 18,
              letterSpacing: 1,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 4),

          // 4 Action Buttons Row
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  labelLine1: 'AUTO DRAFT',
                  labelLine2: 'ALL ROUNDS',
                  backgroundColor: const Color(0xFF303030),
                  onTap: onAutoDraftAllRounds,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  labelLine1: 'AUTO DRAFT',
                  labelLine2: 'THIS ROUND',
                  backgroundColor: const Color(0xFF303030),
                  onTap: onAutoDraftThisRound,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  labelLine1: 'RESET',
                  labelLine2: 'THIS ROUND',
                  backgroundColor: const Color(0xFFD71212),
                  onTap: onResetThisRound,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  labelLine1: 'RESET ALL',
                  labelLine2: 'ROUNDS',
                  backgroundColor: const Color(0xFFD71212),
                  onTap: onResetAllRounds,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String labelLine1,
    required String labelLine2,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                labelLine1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 12,
                  height: 1,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
              Text(
                labelLine2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 12,
                  height: 1,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}