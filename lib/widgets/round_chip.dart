import 'package:flutter/material.dart';

class RoundChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const RoundChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 10),
        
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 0,
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 14,
                letterSpacing: 1,
                color: isSelected ? Colors.white : Colors.black,
              ),
              child: const Text('ROUND'),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.white,
                ),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
