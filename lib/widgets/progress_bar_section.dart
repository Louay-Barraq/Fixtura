import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProgressBarSection extends StatelessWidget {
  final int progressValue;
  const ProgressBarSection({super.key, required this.progressValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            Text(
              '$progressValue %',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                color: Color(0xFFD71212),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Gap(4),
        // Progress Bar
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progressValue / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFFD71212),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
