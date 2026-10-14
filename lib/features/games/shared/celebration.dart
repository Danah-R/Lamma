import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// What the family games pay out: for winning, and for each right answer.
const winPoints = 20;
const correctPoints = 2;

/// Wraps a result screen: confetti bursts over it once, as soon as it appears.
class WinnerConfetti extends StatefulWidget {
  final Widget child;
  const WinnerConfetti({super.key, required this.child});
  @override
  State<WinnerConfetti> createState() => _WinnerConfettiState();
}

class _WinnerConfettiState extends State<WinnerConfetti> {
  final _c = ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    if (!WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations)
      _c.play();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.topCenter,
    children: [
      widget.child,
      IgnorePointer(
        child: ConfettiWidget(
          confettiController: _c,
          blastDirection: math.pi / 2,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: .06,
          numberOfParticles: 22,
          maxBlastForce: 22,
          minBlastForce: 8,
          gravity: .18,
          shouldLoop: false,
          colors: const [
            Color(0xFF9A4A3E),
            Color(0xFF3E7A75),
            Color(0xFFDEB461),
            Color(0xFFE29079),
            Color(0xFF8FA580),
            Color(0xFF1E2A47),
          ],
        ),
      ),
    ],
  );
}

/// Soft balloons floating in the background of a card (put it behind the card's content).
class BalloonsBackground extends StatelessWidget {
  const BalloonsBackground({super.key});
  @override
  Widget build(BuildContext context) => const Positioned.fill(
    child: IgnorePointer(child: CustomPaint(painter: _BalloonPainter())),
  );
}

class _BalloonPainter extends CustomPainter {
  const _BalloonPainter();
  @override
  void paint(Canvas canvas, Size size) {
    // x (0-1), y (0-1), width, color, tilt (a little lean so no two look the same)
    final balloons = <(double, double, double, Color, double)>[
      (.07, .34, 34, const Color(0xFFFFD166), -.10),
      (.20, .74, 26, const Color(0xFFFF9B80), .08),
      (.36, .22, 22, const Color(0xFFFFFFFF), .12),
      (.64, .80, 24, const Color(0xFFFFFFFF), -.08),
      (.82, .28, 32, const Color(0xFFFF9B80), .10),
      (.94, .68, 26, const Color(0xFFFFD166), -.12),
    ];
    for (final b in balloons) {
      canvas.save();
      canvas.translate(b.$1 * size.width, b.$2 * size.height);
      canvas.rotate(b.$5);
      final w = b.$3, h = b.$3 * 1.28;
      final fill = Paint()..color = b.$4.withValues(alpha: .62);

      // body: round on top, a little narrower toward the bottom (like a real balloon)
      final body = Path()
        ..moveTo(0, h / 2)
        ..cubicTo(-w * .62, h * .28, -w * .62, -h * .5, 0, -h * .5)
        ..cubicTo(w * .62, -h * .5, w * .62, h * .28, 0, h / 2)
        ..close();
      canvas.drawPath(body, fill);

      // a little knot
      final knot = Path()
        ..moveTo(0, h / 2 - 1)
        ..lineTo(-w * .12, h / 2 + w * .16)
        ..lineTo(w * .12, h / 2 + w * .16)
        ..close();
      canvas.drawPath(knot, fill);

      // a loose, wavy string (curves left and right, never a ruler line)
      final y0 = h / 2 + w * .16;
      final string = Path()
        ..moveTo(0, y0)
        ..cubicTo(
          -w * .55,
          y0 + w * .45,
          w * .55,
          y0 + w * .9,
          -w * .1,
          y0 + w * 1.45,
        )
        ..cubicTo(
          -w * .5,
          y0 + w * 1.8,
          w * .35,
          y0 + w * 2.1,
          w * .1,
          y0 + w * 2.5,
        );
      canvas.drawPath(
        string,
        Paint()
          ..color = Colors.white.withValues(alpha: .5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );

      // shine
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(-w * .22, -h * .22),
          width: w * .2,
          height: h * .26,
        ),
        Paint()..color = Colors.white.withValues(alpha: .4),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// "+20" earned for winning: just the number, no box around it.
class PointsBadge extends StatelessWidget {
  final int points;
  const PointsBadge(this.points, {super.key});
  @override
  Widget build(BuildContext context) => Text(
    '+$points',
    style: const TextStyle(
      fontSize: 34,
      height: 1.1,
      fontWeight: FontWeight.w700,
      color: Color(0xFFFFE2A0),
    ),
  );
}
