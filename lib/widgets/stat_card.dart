import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(top: 10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: const Color(0xFFD71212), width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 2,
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Label Badge (Red if selected, Black if unselected)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 6),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD71212) : Colors.black,
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
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),

            // Numeric Value
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
