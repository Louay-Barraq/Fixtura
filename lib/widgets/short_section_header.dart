import 'package:flutter/material.dart';

class ShortSectionHeader extends StatelessWidget {
  final String title;
  const ShortSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 290,
      decoration: BoxDecoration(
        color: Color(0xFF000000),
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
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 16,
            letterSpacing: 3,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
