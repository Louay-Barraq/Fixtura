import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fixtura/l10n/app_localizations.dart';
import 'nav_item.dart';

/// Fixtura's bottom nav bar: four equal buttons in a row — Home,
/// Tournaments, Create, Roulette. Icons are hand-drawn to match the app's
/// own bracket and wheel motifs rather than a generic icon set.
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCreateTap,
  });

  /// 0 = Home, 1 = Tournaments, 2 = Roulette. Create has no "selected"
  /// state since it's an action, not a destination.
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCreateTap;

  static const _barHeight = 76.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                label: l10n?.homeTab ?? 'Home',
                selected: currentIndex == 0,
                painterBuilder: (color) => _HouseIconPainter(color),
                onTap: () => onTap(0),
              ),
              NavItem(
                label: l10n?.tournamentsTab ?? 'Tournaments',
                selected: currentIndex == 1,
                painterBuilder: (color) => _BracketIconPainter(color),
                onTap: () => onTap(1),
              ),
              NavItem(
                label: l10n?.createTab ?? 'Create',
                selected: false,
                alwaysFilled: false,
                painterBuilder: (color) => _PlusIconPainter(color),
                onTap: onCreateTap,
              ),
              NavItem(
                label: l10n?.rouletteTab ?? 'Roulette',
                selected: currentIndex == 2,
                painterBuilder: (color) => _WheelIconPainter(color),
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple house glyph — roof + base, matching the flat line-art style used
/// throughout the app.
class _HouseIconPainter extends CustomPainter {
  _HouseIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width, h = size.height;
    final roof = Path()
      ..moveTo(w * 0.5, h * 0.22)
      ..lineTo(w * 0.24, h * 0.46)
      ..moveTo(w * 0.5, h * 0.22)
      ..lineTo(w * 0.76, h * 0.46);
    canvas.drawPath(roof, paint);

    final base = Rect.fromLTRB(w * 0.30, h * 0.46, w * 0.70, h * 0.76);
    canvas.drawRect(base, paint);

    final doorPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(w * 0.44, h * 0.58, w * 0.56, h * 0.76),
      doorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HouseIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Miniature version of the app's own bracket motif — two short lines
/// converging into one, same visual language as the app icon.
class _BracketIconPainter extends CustomPainter {
  _BracketIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.20, h * 0.28)
      ..lineTo(w * 0.48, h * 0.28)
      ..moveTo(w * 0.20, h * 0.68)
      ..lineTo(w * 0.48, h * 0.68)
      ..moveTo(w * 0.48, h * 0.28)
      ..lineTo(w * 0.48, h * 0.68)
      ..moveTo(w * 0.48, h * 0.48)
      ..lineTo(w * 0.80, h * 0.48);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BracketIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Miniature roulette wheel — circle with spoke lines, echoing the actual
/// wheel widget elsewhere in the app.
class _WheelIconPainter extends CustomPainter {
  _WheelIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.32;
    canvas.drawCircle(center, radius, paint);

    for (final angleDeg in [0.0, 45.0, 90.0, 135.0]) {
      final rad = angleDeg * math.pi / 180;
      final dx = radius * math.cos(rad);
      final dy = radius * math.sin(rad);
      canvas.drawLine(
        Offset(center.dx - dx, center.dy - dy),
        Offset(center.dx + dx, center.dy + dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WheelIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Simple plus glyph for the center Create button.
class _PlusIconPainter extends CustomPainter {
  _PlusIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final w = size.width, h = size.height;
    canvas.drawLine(
      Offset(w * 0.5, h * 0.32),
      Offset(w * 0.5, h * 0.68),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.32, h * 0.5),
      Offset(w * 0.68, h * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlusIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
