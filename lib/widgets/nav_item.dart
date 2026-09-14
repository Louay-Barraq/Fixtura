import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    this.label,
    this.selected = false,
    this.alwaysFilled = false,
    this.size = 44.0,
    required this.painterBuilder,
    required this.onTap,
  });

  final String? label;
  final bool selected;
  final bool alwaysFilled;
  final double size;
  final CustomPainter Function(Color color) painterBuilder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final filled = selected || alwaysFilled;
    final circleColor = filled ? const Color(0xFFD71212) : Colors.white;
    final iconColor = filled ? Colors.white : const Color(0xFFD71212);
    final labelColor = selected ? const Color(0xFFD30D15) : Colors.black;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0,
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ],
            ),
            child: CustomPaint(
              size: Size(size, size),
              painter: painterBuilder(iconColor),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 6),
            Text(
              label!,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 11,
                color: labelColor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
