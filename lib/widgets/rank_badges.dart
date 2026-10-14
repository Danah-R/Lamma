import 'package:flutter/material.dart';

/// Hand-drawn leaderboard marks (no stock icons): a crown for first place and a
/// ribbon medal for the top three, in gold, silver and bronze.
class Crown extends StatelessWidget {
  final double width;
  const Crown({super.key, this.width = 28});
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, width * .72),
    painter: const _CrownPainter(),
  );
}

class _CrownPainter extends CustomPainter {
  const _CrownPainter();
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final body = Path()
      ..moveTo(w * .06, h * .92)
      ..lineTo(0, h * .26)
      ..lineTo(w * .26, h * .52)
      ..lineTo(w * .5, 0)
      ..lineTo(w * .74, h * .52)
      ..lineTo(w, h * .26)
      ..lineTo(w * .94, h * .92)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE08A), Color(0xFFE0A526)],
        ).createShader(Offset.zero & s),
    );
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = w * .05
        ..color = const Color(0xFFB9791A),
    );
    // band along the bottom
    final band = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * .05, h * .8, w * .9, h * .2),
      Radius.circular(h * .08),
    );
    canvas.drawRRect(band, Paint()..color = const Color(0xFFD99A1E));
    // jewels on the points
    for (final p in [
      Offset(w * .5, h * .12),
      Offset(w * .02, h * .26),
      Offset(w * .98, h * .26),
    ]) {
      canvas.drawCircle(p, w * .055, Paint()..color = const Color(0xFFB4412F));
    }
    canvas.drawCircle(
      Offset(w * .5, h * .9),
      w * .05,
      Paint()..color = const Color(0xFFFFF3C4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// A ribbon medal with the place number on it. [place] 1 = gold, 2 = silver, 3 = bronze.
class RankMedal extends StatelessWidget {
  final int place;
  final double size;
  const RankMedal(this.place, {super.key, this.size = 32});

  static const _tones = <int, (Color, Color, Color, Color)>{
    // light, dark, rim, number
    1: (
      Color(0xFFFFE08A),
      Color(0xFFE0A526),
      Color(0xFFB9791A),
      Color(0xFF7A4B0B),
    ),
    2: (
      Color(0xFFF4F6F8),
      Color(0xFFA9B2BC),
      Color(0xFF7D8791),
      Color(0xFF4A535C),
    ),
    3: (
      Color(0xFFF2C29B),
      Color(0xFFC1743A),
      Color(0xFF8F5124),
      Color(0xFF5C3010),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final t = _tones[place]!;
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(size, size * 1.15),
            painter: _MedalPainter(t.$1, t.$2, t.$3),
          ),
          // centered on the disc (its middle is at 75% of the width from the top)
          Positioned(
            top: size * .75 - size * .3,
            left: 0,
            right: 0,
            height: size * .6,
            child: Center(
              child: Text(
                '$place',
                style: TextStyle(
                  fontSize: size * .42,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: t.$4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalPainter extends CustomPainter {
  final Color light, dark, rim;
  const _MedalPainter(this.light, this.dark, this.rim);
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    // ribbon tails behind the disc
    final left = Path()
      ..moveTo(w * .22, 0)
      ..lineTo(w * .46, 0)
      ..lineTo(w * .56, w * .55)
      ..lineTo(w * .34, w * .5)
      ..lineTo(w * .26, w * .62)
      ..close();
    final right = Path()
      ..moveTo(w * .78, 0)
      ..lineTo(w * .54, 0)
      ..lineTo(w * .44, w * .55)
      ..lineTo(w * .66, w * .5)
      ..lineTo(w * .74, w * .62)
      ..close();
    canvas.drawPath(left, Paint()..color = const Color(0xFFB4412F));
    canvas.drawPath(right, Paint()..color = const Color(0xFF8E3225));
    // the disc
    final c = Offset(w / 2, s.height - w * .4);
    final r = w * .4;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, dark],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .06
        ..color = rim,
    );
    canvas.drawCircle(
      c,
      r * .72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .02
        ..color = rim.withValues(alpha: .45),
    );
  }

  @override
  bool shouldRepaint(covariant _MedalPainter old) =>
      old.light != light || old.dark != dark;
}
