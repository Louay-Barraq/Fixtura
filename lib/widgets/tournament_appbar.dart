import 'package:flutter/material.dart';
import 'package:fixtura/widgets/progress_bar_section.dart';

class TournamentAppbar extends StatelessWidget {
  final String tournamentName;
  final int progressValue;
  const TournamentAppbar({
    super.key,
    required this.tournamentName,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: const Color(0xFFFFFCFC),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 40, right: 40),
                  child: Text(
                    tournamentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 36,
                      color: Color(0xFF000000),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: ProgressBarSection(progressValue: progressValue),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 6,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF000000).withValues(alpha: 0.15),
                const Color(0xFF000000).withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}