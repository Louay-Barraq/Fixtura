import 'dart:math';
import 'package:flutter/material.dart';

class CustomRouletteWheel extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String>? onResult;

  const CustomRouletteWheel({super.key, required this.items, this.onResult});

  @override
  State<CustomRouletteWheel> createState() => _CustomCustomRouletteWheelState();
}

class _CustomCustomRouletteWheelState extends State<CustomRouletteWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Random _random = Random();

  double _startAngle = 0;
  double _currentAngle = 0;
  bool _isSpinning = false;
  double _targetRotation = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.decelerate);

    _controller.addListener(() {
      setState(() {
        _currentAngle = _startAngle + _animation.value * _targetRotation;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isSpinning = false;
        _determineWinner();
      }
    });
  }

  void _spinWheel() {
    if (_isSpinning || widget.items.isEmpty) return;

    _isSpinning = true;
    _startAngle = _currentAngle % (2 * pi);

    final int spinDurationMs = 1000 + _random.nextInt(2001);
    _controller.duration = Duration(milliseconds: spinDurationMs);

    final double extraSpins = (5 + _random.nextInt(4)) * 2 * pi;
    final double randomOffset = _random.nextDouble() * 2 * pi;
    _targetRotation = extraSpins + randomOffset;

    _controller.forward(from: 0.0);
  }

  void _determineWinner() {
    final int totalItems = widget.items.length;
    if (totalItems == 0) return;

    final double sliceAngle = (2 * pi) / totalItems;

    // Normalizing angle into [0, 2π) range
    final double normalizedRotation = _currentAngle % (2 * pi);

    // Fixed 180° offset issue: Top arrow points at -pi/2
    double angleAtPointer = (-pi / 2 - normalizedRotation) % (2 * pi);
    if (angleAtPointer < 0) {
      angleAtPointer += 2 * pi;
    }

    final int selectedIndex =
        (angleAtPointer / sliceAngle).floor() % totalItems;
    final String selectedItem = widget.items[selectedIndex];

    widget.onResult?.call(selectedItem);
    _showWinnerDialog(selectedItem);
  }

  void _showWinnerDialog(String item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SELECTED TEAM',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 22,
                  letterSpacing: 1.2,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD30D15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        // color: const Color(0xFFF1F1F1),
        color: Colors.white,
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
      child: SizedBox(
        width: 260,
        // Extra height just enough for the pointer to sit closer to the
        // wheel without the old icon's built-in glyph padding pushing it
        // away.
        height: 274,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Wheel & Central Interactive GO Button
            Positioned(
              top: 14,
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 0),
                            blurRadius: 4,
                            spreadRadius: 4,
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ],
                      ),
                    ),
                    Transform.rotate(
                      angle: _currentAngle,
                      child: CustomPaint(
                        size: const Size(260, 260),
                        painter: _WheelPainter(items: widget.items),
                      ),
                    ),
                    GestureDetector(
                      onTap: _spinWheel,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD30D15),
                          shape: BoxShape.circle,
                          // border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 0),
                              blurRadius: 4,
                              spreadRadius: 4,
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'GO',
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: 44,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Pointer — hand-drawn triangle instead of Icons.arrow_drop_down,
            // which carries a lot of transparent glyph padding that made it
            // read as much further from the wheel than the box size implied.
            // Overlaps a few pixels onto the wheel's top edge.
            Positioned(
              top: 4,
              child: CustomPaint(
                size: const Size(26, 18),
                painter: _PointerPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFD71212)
        ..style = PaintingStyle.fill,
    );
    // canvas.drawPath(
    //   path,
    //   Paint()
    //     ..color = Colors.black
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 1.5,
    // );
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) => false;
}

class _WheelPainter extends CustomPainter {
  final List<String> items;

  _WheelPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final int totalItems = items.isEmpty ? 1 : items.length;
    final double sweepAngle = (2 * pi) / totalItems;

    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint slicePaint = Paint()
      ..color = Colors.white
      // ..color = Color(0xFFF1F1F1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, slicePaint);

    // Anchor point roughly midway between the center "GO" button and the
    // outer rim, so wrapped text has roughly equal room to grow toward
    // either side without hitting the button or the wheel edge.
    const double goButtonRadius = 45; // 70px button + a little clearance
    final double anchorRadius = (goButtonRadius + radius) / 2;
    final double maxRadialRoom =
        (radius - goButtonRadius) / 2 - 4; // safety margin

    // Tangential space available before overlapping the neighboring
    // slice's text, computed from the chord length at the anchor radius.
    final double rawChordWidth = 2 * anchorRadius * sin(sweepAngle / 2) * 0.85;
    final double maxTextWidth = rawChordWidth.clamp(24.0, radius);

    for (int i = 0; i < totalItems; i++) {
      final double startAngle = i * sweepAngle;

      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * cos(startAngle),
          center.dy + radius * sin(startAngle),
        ),
        borderPaint,
      );

      if (items.isNotEmpty) {
        final double textAngle = startAngle + sweepAngle / 2;

        // Lay out the text, shrinking the font a point at a time if a
        // single unbreakable word still overflows the available width
        // after wrapping (Flutter won't break mid-word on its own).
        double fontSize = 11;
        const double minFontSize = 8;
        late TextPainter textPainter;
        while (true) {
          textPainter = TextPainter(
            text: TextSpan(
              text: items[i],
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1.05,
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: maxTextWidth);

          final bool tooWide = textPainter.width > maxTextWidth + 0.5;
          final bool tooTall = textPainter.height > maxRadialRoom * 2;
          if ((!tooWide && !tooTall) || fontSize <= minFontSize) break;
          fontSize -= 1;
        }

        canvas.save();
        canvas.translate(
          center.dx + anchorRadius * cos(textAngle),
          center.dy + anchorRadius * sin(textAngle),
        );
        canvas.rotate(textAngle + pi / 2);
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      }
    }

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.items != items;
}
