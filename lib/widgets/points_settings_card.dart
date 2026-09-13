import 'package:flutter/material.dart';
import '/widgets/square_button.dart';

class PointsSettingsCard extends StatefulWidget {
  final int initialWin;
  final int initialDraw;
  final int initialLoss;
  final Function(int win, int draw, int loss)? onChanged;

  const PointsSettingsCard({
    super.key,
    this.initialWin = 3,
    this.initialDraw = 1,
    this.initialLoss = 0,
    this.onChanged,
  });

  @override
  State<PointsSettingsCard> createState() => _PointsSettingsCardState();
}

class _PointsSettingsCardState extends State<PointsSettingsCard> {
  late int winPoints;
  late int drawPoints;
  late int lossPoints;

  @override
  void initState() {
    super.initState();
    winPoints = widget.initialWin;
    drawPoints = widget.initialDraw;
    lossPoints = widget.initialLoss;
  }

  void _notifyChange() {
    widget.onChanged?.call(winPoints, drawPoints, lossPoints);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 2,
            color: Color(0xFF000000).withValues(alpha: 0.25),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Title
          // const Text(
          //   'Points',
          //   style: TextStyle(
          //     fontFamily: 'RobotoMono',
          //     fontSize: 20,
          //     fontWeight: FontWeight.w400,
          //     color: Colors.black,
          //   ),
          // ),
          // const SizedBox(height: 20),

          // Counters Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPointCounter(
                label: 'Win Pts',
                value: winPoints,
                onDecrement: () {
                  if (winPoints > 0) {
                    setState(() => winPoints--);
                    _notifyChange();
                  }
                },
                onIncrement: () {
                  setState(() => winPoints++);
                  _notifyChange();
                },
              ),
              _buildPointCounter(
                label: 'Draw Pts',
                value: drawPoints,
                onDecrement: () {
                  if (drawPoints > 0) {
                    setState(() => drawPoints--);
                    _notifyChange();
                  }
                },
                onIncrement: () {
                  setState(() => drawPoints++);
                  _notifyChange();
                },
              ),
              _buildPointCounter(
                label: 'Loss Pts',
                value: lossPoints,
                onDecrement: () {
                  if (lossPoints > 0) {
                    setState(() => lossPoints--);
                    _notifyChange();
                  }
                },
                onIncrement: () {
                  setState(() => lossPoints++);
                  _notifyChange();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointCounter({
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Column(
      children: [
        // Category Label
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 16,
            color: Colors.black,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Decrement (-) Number Increment (+) Row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SquareButton(icon: Icons.remove, onTap: onDecrement),
            SizedBox(
              width: 36,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            SquareButton(icon: Icons.add, onTap: onIncrement),
          ],
        ),
      ],
    );
  }
}
