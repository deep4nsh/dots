import 'dart:math';
import 'package:flutter/material.dart';

class AestheticDotsBackground extends StatefulWidget {
  final int dotCount;
  final Color color;

  const AestheticDotsBackground({
    super.key,
    this.dotCount = 15,
    this.color = Colors.black,
  });

  @override
  State<AestheticDotsBackground> createState() => _AestheticDotsBackgroundState();
}

class _AestheticDotsBackgroundState extends State<AestheticDotsBackground> {
  late List<_DotParams> _dots;

  @override
  void initState() {
    super.initState();
    _generateDots();
  }

  void _generateDots() {
    final random = Random();
    _dots = List.generate(widget.dotCount, (index) {
      return _DotParams(
        x: random.nextDouble(), // 0.0 to 1.0 (relative position)
        y: random.nextDouble(),
        size: random.nextDouble() * 4 + 2, // 2.0 to 6.0
        opacity: random.nextDouble() * 0.08 + 0.02, // 0.02 to 0.10 (very subtle)
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotsPainter(_dots, widget.color),
      child: Container(),
    );
  }
}

class _DotParams {
  final double x;
  final double y;
  final double size;
  final double opacity;

  _DotParams({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });
}

class _DotsPainter extends CustomPainter {
  final List<_DotParams> dots;
  final Color color;

  _DotsPainter(this.dots, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final dot in dots) {
      paint.color = color.withOpacity(dot.opacity);
      canvas.drawCircle(
        Offset(dot.x * size.width, dot.y * size.height),
        dot.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
