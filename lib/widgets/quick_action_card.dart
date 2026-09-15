import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 1,
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Transform.flip(
                flipX: Directionality.of(context) == TextDirection.rtl,
                child: const Icon(
                  Icons.arrow_circle_right_outlined,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
