import 'package:flutter/material.dart';

class FormatOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final CustomPainter Function(Color color)? customPainter;
  final bool isSelected;
  final VoidCallback onTap;

  const FormatOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.customPainter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isSelected ? Colors.white : const Color(0xFFD71212);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        width: 160,
        height: 115,
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              spreadRadius: 2,
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD71212) : const Color(0xFFF1F1F1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : const Color(0xFFD71212),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: customPainter != null
                    ? CustomPaint(
                        size: const Size(22, 22),
                        painter: customPainter!(accentColor),
                      )
                    : Icon(
                        icon ?? Icons.star,
                        size: 20,
                        color: accentColor,
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 18,
                color: isSelected ? Colors.white : Colors.black,
                letterSpacing: 1,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 10,
                color: isSelected ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}