import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class RouletteWheel extends StatefulWidget {
  final List<String> options;
  final Function(String selectedOption) onResult;
  final double size;

  const RouletteWheel({
    super.key,
    required this.options,
    required this.onResult,
    this.size = 280.0,
  });

  @override
  State<RouletteWheel> createState() => _RouletteWheelState();
}

class _RouletteWheelState extends State<RouletteWheel> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _currentAngle = 0.0;
  bool _isSpinning = false;

  final List<Color> _segmentColors = [
    const Color(0xFFFF3B30), // Neon Red
    const Color(0xFFFF9500), // Neon Orange
    const Color(0xFFFFCC00), // Neon Yellow
    const Color(0xFF34C759), // Neon Green
    const Color(0xFF007AFF), // Neon Blue
    const Color(0xFF5856D6), // Neon Purple
    const Color(0xFFAF52DE), // Light Neon Purple
    const Color(0xFFFF2D55), // Pink Accent
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    );

    _animationController.addListener(() {
      setState(() {
        _currentAngle = _animation.value;
      });
      // Simple virtual tick effect
      if (_isSpinning && Random().nextDouble() < 0.1) {
        HapticFeedback.lightImpact();
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning || widget.options.isEmpty) return;

    setState(() {
      _isSpinning = true;
    });

    // Spin multiple full rotations + a random slice
    final random = Random();
    final double extraRotations = (2 + random.nextInt(2)) * 2 * pi;
    final double targetAngle = extraRotations + random.nextDouble() * 2 * pi;

    _animationController.reset();
    _animation = Tween<double>(
      begin: _currentAngle % (2 * pi),
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    ));

    _animationController.forward();
  }

  void _onSpinComplete() {
    setState(() {
      _isSpinning = false;
      _currentAngle = _currentAngle % (2 * pi);
    });

    // Calculate selected option
    // The selector is at the top of the wheel (angle: -pi / 2)
    // We adjust the angle to see which option lands at the top.
    final segmentAngle = (2 * pi) / widget.options.length;
    
    // Normalized angle of rotation
    final double normalizedAngle = (2 * pi) - (_currentAngle % (2 * pi));
    
    // Subtract 90 degrees because the selector is at the top (12 o'clock)
    // while segment 0 starts at 3 o'clock.
    final double relativeAngle = (normalizedAngle - (pi / 2) + (2 * pi)) % (2 * pi);
    
    int index = (relativeAngle / segmentAngle).floor();
    if (index >= widget.options.length) {
      index = 0;
    }

    widget.onResult(widget.options[index]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) {
      return Center(
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surface,
            border: Border.all(color: AppTheme.divider, width: 2),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Add options to spin!',
            style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glowing ring
            Container(
              width: widget.size + 24,
              height: widget.size + 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(_isSpinning ? 0.35 : 0.15),
                    blurRadius: _isSpinning ? 30 : 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            
            // Outer Border Ring
            Container(
              width: widget.size + 8,
              height: widget.size + 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceLight,
              ),
            ),

            // Rotating Wheel
            GestureDetector(
              onTap: _isSpinning ? null : _spin,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Transform.rotate(
                  angle: _currentAngle,
                  child: CustomPaint(
                    painter: RoulettePainter(
                      options: widget.options,
                      colors: _segmentColors,
                    ),
                  ),
                ),
              ),
            ),

            // Top Pointer (static, points to winning slice)
            Positioned(
              top: 0,
              child: CustomPaint(
                size: const Size(20, 24),
                painter: TrianglePainter(),
              ),
            ),

            // Center Pin Button
            GestureDetector(
              onTap: _isSpinning ? null : _spin,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.background,
                  border: Border.all(color: AppTheme.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _isSpinning ? 'SPIN' : 'GO!',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RoulettePainter extends CustomPainter {
  final List<String> options;
  final List<Color> colors;

  RoulettePainter({required this.options, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double segmentAngle = (2 * pi) / options.length;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final borderPaint = Paint()
      ..color = AppTheme.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < options.length; i++) {
      // Draw slice
      paint.color = colors[i % colors.length];
      final double startAngle = i * segmentAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw segment line
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Draw label text
      canvas.save();
      
      // Calculate text placement angle (middle of slice)
      final double textAngle = startAngle + segmentAngle / 2;
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textAngle);

      final textSpan = TextSpan(
        text: _truncateText(options[i], 12),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 4.0,
              color: Colors.black54,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: radius - 40);
      
      // Position text along the radius towards outer edge
      final textOffset = Offset(radius - textPainter.width - 20, -textPainter.height / 2);
      textPainter.paint(canvas, textOffset);
      
      canvas.restore();
    }
  }

  String _truncateText(String text, int limit) {
    if (text.length <= limit) return text;
    return '${text.substring(0, limit - 1)}..';
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Indicator pointer pointing down from the top edge
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    // Draw shadow underneath pointer
    canvas.drawPath(
      path.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black38
        ..style = PaintingStyle.fill,
    );

    // Draw main pointer
    canvas.drawPath(path, paint);

    // Accent line
    final accentPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
