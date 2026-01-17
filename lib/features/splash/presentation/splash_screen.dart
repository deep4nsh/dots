import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _lineProgress;
  late Animation<double> _textOpacity;
  
  // Animation Sequence Configuration
  static const int _dotCount = 5;
  final List<Offset> _dotPositions = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateDots();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Total animation time
    );

    // 1. Line Drawing Progress (0.0 to 1.0)
    _lineProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // 2. Text "dots" Reveal (Opacity)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
      ),
    );

    // Start Animation
    _mainController.forward().ignore();

    // Navigate to Home after completion
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Wait a gentle moment before switching
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) context.go('/');
        });
      }
    });
  }

  void _generateDots() {
    // Generate random positions for the dots "constellation"
    // We'll keep them somewhat centered but scattered
    for (int i = 0; i < _dotCount; i++) {
      _dotPositions.add(Offset(
        (_random.nextDouble() - 0.5) * 300, // x spread
        (_random.nextDouble() - 0.5) * 400, // y spread
      ));
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Native black transition
      body: Center(
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return CustomPaint(
              painter: _SplashPainter(
                lineProgress: _lineProgress.value,
                dotPositions: _dotPositions,
                textOpacity: _textOpacity.value,
              ),
              size: MediaQuery.of(context).size,
            );
          },
        ),
      ),
    );
  }
}

class _SplashPainter extends CustomPainter {
  final double lineProgress;
  final List<Offset> dotPositions;
  final double textOpacity;

  _SplashPainter({
    required this.lineProgress,
    required this.dotPositions,
    required this.textOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // 0. Calculate Text & Dot Positions FIRST
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 48,
      fontWeight: FontWeight.bold,
      letterSpacing: -2,
      fontFamily: 'Plus Jakarta Sans',
    );
    
    final textSpan = TextSpan(
      text: 'dots',
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Position text exactly in center
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    
    // Calculate final dot position (at baseline of text, slightly after 's')
    // We want it to be the "full stop"
    final dotPosition = Offset(
      textOffset.dx + textPainter.width + 4, // Just after text
      textOffset.dy + textPainter.height / 1.5, // Aligned with baseline roughly
    );

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 1. Draw The "Line" connecting dots
    if (dotPositions.isNotEmpty && lineProgress > 0) {
        Path fullPath = Path();
        fullPath.moveTo(center.dx + dotPositions[0].dx, center.dy + dotPositions[0].dy);
        
        for (int i = 1; i < dotPositions.length; i++) {
           fullPath.lineTo(
             center.dx + dotPositions[i].dx, 
             center.dy + dotPositions[i].dy
           );
        }
        
        // DESTINATION: The final dot position
        fullPath.lineTo(dotPosition.dx, dotPosition.dy);
        
        // Calculate extraction
        final metrics = fullPath.computeMetrics();
        for (final metric in metrics) {
          final extractPath = metric.extractPath(0, metric.length * lineProgress);
          canvas.drawPath(extractPath, paint);
        }

        // Draw dots that have been "passed"
        int dotsToShow = (dotPositions.length * lineProgress).floor();
        for (int i = 0; i < dotsToShow && i < dotPositions.length; i++) {
           canvas.drawCircle(
             center + dotPositions[i], 
             4.0, 
             dotPaint
           );
        }
    }

    // 2. Draw Text "dots"
    if (textOpacity > 0) {
      // Fade in text
      textPainter.text = TextSpan(
        text: 'dots',
        style: textStyle.copyWith(color: Colors.white.withOpacity(textOpacity)),
      );
      textPainter.layout();
      textPainter.paint(canvas, textOffset);

      // 3. The Final Dot "."
      // It appears when the line finishes (lineProgress ~ 1.0) OR text is fully visible
      // We want it to look like the line *becomes* the dot.
      if (lineProgress >= 0.95 || textOpacity > 0.5) {
         canvas.drawCircle(dotPosition, 4.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplashPainter oldDelegate) {
    return oldDelegate.lineProgress != lineProgress || 
           oldDelegate.textOpacity != textOpacity;
  }
}
