// Decorative CustomPainter illustrations for the Games page. Each one
// approximates its SVG in design/games_design_reference.html — simple
// straight-line pieces (hexagons, stick figures, motion lines) are drawn
// exactly to the reference's path coordinates; rounded blob shapes (the
// speech-bubble tail, the photo's shoulders, the head-and-shoulders
// silhouette) are simplified to plain rounded rects/arcs since they're
// purely decorative.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'activities_colors.dart';

/// Picks the right illustration painter for a game id and paints it at the
/// given tile size (the reference's viewBox is 78x64).
class GameIllustration extends StatelessWidget {
  final String id;
  const GameIllustration(this.id, {super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _painterFor(id));

  CustomPainter _painterFor(String id) => switch (id) {
    'huroof' => const _HuroofPainter(),
    'seen' => const _SeenPainter(),
    'freeze' => const _FreezePainter(),
    'charades' => const _CharadesPainter(),
    'photo' => const _PhotoPainter(),
    'whoami' => const _WhoAmIPainter(),
    _ => const _HuroofPainter(),
  };
}

/// "حروف مع عزيز": four overlapping hex/diamond cells spelling ح ر و ف.
class _HuroofPainter extends CustomPainter {
  const _HuroofPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 78, sy = size.height / 64;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    Path cell(List<Offset> pts) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final pt in pts.skip(1)) {
        path.lineTo(pt.dx, pt.dy);
      }
      return path..close();
    }

    final cells = [
      (
        [p(20, 2), p(34, 10), p(34, 26), p(20, 34), p(6, 26), p(6, 10)],
        AC.navy,
        'ح',
        p(20, 23).dy,
        Colors.white,
      ),
      (
        [p(50, 2), p(64, 10), p(64, 26), p(50, 34), p(36, 26), p(36, 10)],
        Colors.white,
        'ر',
        p(50, 23).dy,
        AC.navy,
      ),
      (
        [p(35, 28), p(49, 36), p(49, 52), p(35, 60), p(21, 52), p(21, 36)],
        AC.brick,
        'و',
        p(35, 49).dy,
        Colors.white,
      ),
      (
        [p(65, 28), p(79, 36), p(79, 52), p(65, 60), p(51, 52), p(51, 36)],
        Colors.white.withValues(alpha: .7),
        'ف',
        p(65, 49).dy,
        AC.navy,
      ),
    ];

    for (final (pts, color, letter, textY, textColor) in cells) {
      canvas.drawPath(cell(pts), Paint()..color = color);
      final tp = TextPainter(
        text: TextSpan(
          text: letter,
          style: TextStyle(
            color: textColor,
            fontSize: 14 * sy,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, Offset(pts[0].dx - tp.width / 2, textY - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _HuroofPainter oldDelegate) => false;
}

/// "سين جيم": a teal speech bubble with "؟" and a white one with "!".
class _SeenPainter extends CustomPainter {
  const _SeenPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 78, sy = size.height / 64;
    void bubble(
      Rect rect,
      Offset tailTip,
      Color color,
      String mark,
      double markSize,
      Color markColor,
    ) {
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(6 * sx));
      final path = Path()..addRRect(rrect);
      final tail = Path()
        ..moveTo(rect.left + rect.width * .22, rect.bottom - 2 * sy)
        ..lineTo(tailTip.dx, tailTip.dy)
        ..lineTo(rect.left + rect.width * .42, rect.bottom - 2 * sy)
        ..close();
      canvas.drawPath(
        Path.combine(PathOperation.union, path, tail),
        Paint()..color = color,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: mark,
          style: TextStyle(
            color: markColor,
            fontSize: markSize * sy,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(
        canvas,
        Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
      );
    }

    bubble(
      Rect.fromLTWH(0, 6 * sy, 44 * sx, 30 * sy),
      Offset(10 * sx, 42 * sy),
      AC.teal,
      '؟',
      22,
      Colors.white,
    );
    bubble(
      Rect.fromLTWH(34 * sx, 22 * sy, 40 * sx, 30 * sy),
      Offset(68 * sx, 58 * sy),
      Colors.white,
      '!',
      18,
      AC.teal,
    );
  }

  @override
  bool shouldRepaint(covariant _SeenPainter oldDelegate) => false;
}

/// "ثبّت": a frozen stick figure with two snowflakes.
class _FreezePainter extends CustomPainter {
  const _FreezePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 78, sy = size.height / 64;
    Offset p(double x, double y) => Offset(x * sx, y * sy);
    final figure = Paint()
      ..color = AC.freezeFigure
      ..strokeWidth = 6 * sy
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(p(39, 12), 8 * sy, Paint()..color = AC.freezeFigure);
    canvas.drawLine(p(39, 22), p(39, 42), figure);
    canvas.drawLine(p(39, 28), p(23, 18), figure);
    canvas.drawLine(p(39, 28), p(53, 14), figure);
    canvas.drawLine(p(39, 42), p(29, 60), figure);
    canvas.drawLine(p(39, 42), p(51, 58), figure);

    void snowflake(Offset c, double r, double strokeWidth) {
      final paint = Paint()
        ..color = Colors.white
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), paint);
      canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), paint);
      final d = r * .7;
      canvas.drawLine(
        Offset(c.dx - d, c.dy - d),
        Offset(c.dx + d, c.dy + d),
        paint,
      );
      canvas.drawLine(
        Offset(c.dx + d, c.dy - d),
        Offset(c.dx - d, c.dy + d),
        paint,
      );
    }

    snowflake(p(66, 15), 7 * sy, 2.4 * sy);
    snowflake(p(12, 39), 5 * sy, 2 * sy);
  }

  @override
  bool shouldRepaint(covariant _FreezePainter oldDelegate) => false;
}

/// "ولا كلمة": a gold zipper-mouth face with motion lines.
class _CharadesPainter extends CustomPainter {
  const _CharadesPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 78, sy = size.height / 64;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    canvas.drawCircle(
      p(39, 32),
      24 * math.min(sx, sy),
      Paint()..color = AC.mustard,
    );
    canvas.drawCircle(p(31, 27), 3 * sy, Paint()..color = AC.navy);
    canvas.drawCircle(p(47, 27), 3 * sy, Paint()..color = AC.navy);

    final line = Paint()
      ..color = AC.navy
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(27, 40), p(51, 40), line..strokeWidth = 3 * sy);
    for (final x in [30.0, 35.0, 40.0, 45.0]) {
      canvas.drawLine(p(x, 37), p(x, 43), line..strokeWidth = 2 * sy);
    }

    final motion = Paint()
      ..color = AC.mustardTint
      ..strokeWidth = 2.4 * sy
      ..strokeCap = StrokeCap.round;
    for (final seg in [
      [p(4, 20), p(10, 23)],
      [p(2, 32), p(9, 32)],
      [p(4, 44), p(10, 41)],
      [p(74, 20), p(68, 23)],
      [p(76, 32), p(69, 32)],
      [p(74, 44), p(68, 41)],
    ]) {
      canvas.drawLine(seg[0], seg[1], motion);
    }
  }

  @override
  bool shouldRepaint(covariant _CharadesPainter oldDelegate) => false;
}

/// "مين في الصورة؟": a tilted polaroid with a "؟" badge.
class _PhotoPainter extends CustomPainter {
  const _PhotoPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 78, sy = size.height / 64;
    final s = math.min(sx, sy);

    canvas.save();
    canvas.translate(39 * sx, 32 * sy);
    canvas.rotate(-6 * math.pi / 180);
    canvas.translate(-39 * sx, -32 * sy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(16 * sx, 4 * sy, 44 * sx, 54 * sy),
        Radius.circular(4 * s),
      ),
      Paint()..color = Colors.white,
    );
    final photoRect = Rect.fromLTWH(20 * sx, 8 * sy, 36 * sx, 34 * sy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(photoRect, Radius.circular(2 * s)),
      Paint()..color = AC.salmon,
    );
    canvas.drawCircle(
      Offset(38 * sx, 21 * sy),
      6 * s,
      Paint()..color = Colors.white.withValues(alpha: .85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(26 * sx, 34 * sy, 24 * sx, 10 * sy),
        Radius.circular(8 * s),
      ),
      Paint()..color = Colors.white.withValues(alpha: .85),
    );
    canvas.restore();

    canvas.drawCircle(
      Offset(62 * sx, 14 * sy),
      11 * s,
      Paint()..color = AC.brick,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '؟',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16 * s,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, Offset(62 * sx - tp.width / 2, 14 * sy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PhotoPainter oldDelegate) => false;
}

/// "مين أنا؟": a navy head-and-shoulders silhouette with a card on top.
class _WhoAmIPainter extends CustomPainter {
  const _WhoAmIPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 78, sy = size.height / 64;
    final s = math.min(sx, sy);
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(19 * sx, 48 * sy, 40 * sx, 16 * sy),
        Radius.circular(10 * s),
      ),
      Paint()..color = AC.navy,
    );
    canvas.drawCircle(p(39, 40), 20 * s, Paint()..color = AC.navy);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(25 * sx, 4 * sy, 28 * sx, 22 * sy),
        Radius.circular(4 * s),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(25 * sx, 4 * sy, 28 * sx, 22 * sy),
        Radius.circular(4 * s),
      ),
      Paint()
        ..color = AC.brick
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * s,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '؟',
        style: TextStyle(
          color: AC.brick,
          fontSize: 15 * s,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, Offset(39 * sx - tp.width / 2, 15 * sy - tp.height / 2));

    canvas.drawCircle(p(32, 40), 2.5 * s, Paint()..color = Colors.white);
    canvas.drawCircle(p(46, 40), 2.5 * s, Paint()..color = Colors.white);
    final smile = Path()
      ..moveTo(p(33, 48).dx, p(33, 48).dy)
      ..quadraticBezierTo(
        p(39, 52).dx,
        p(39, 52).dy,
        p(45, 48).dx,
        p(45, 48).dy,
      );
    canvas.drawPath(
      smile,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * s
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WhoAmIPainter oldDelegate) => false;
}

/// The 6-slice roulette wheel used by the "تonight's game" hero card.
/// Order clockwise from the top matches the reference exactly.
class RouletteHeroWheelPainter extends CustomPainter {
  const RouletteHeroWheelPainter();
  static const colors = [
    AC.brick,
    AC.mustard,
    AC.salmon,
    AC.gamesTeal,
    AC.sage,
    AC.mustardTint,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final seg = 2 * math.pi / colors.length;
    for (var i = 0; i < colors.length; i++) {
      final start = -math.pi / 2 + i * seg;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        seg,
        true,
        Paint()..color = colors[i],
      );
    }
    final divider = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
    for (var i = 0; i < colors.length; i++) {
      final a = -math.pi / 2 + i * seg;
      canvas.drawLine(
        c,
        Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a)),
        divider,
      );
    }
    canvas.drawCircle(
      c,
      r - 1,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(c, r * .086, Paint()..color = AC.background);
    canvas.drawCircle(c, r * .033, Paint()..color = AC.brick);
  }

  @override
  bool shouldRepaint(covariant RouletteHeroWheelPainter oldDelegate) => false;
}
