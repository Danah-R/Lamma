import 'package:flutter/material.dart';

import '../moments_controller.dart';

/// Placeholder "photo" for the sample moments: a flat scene (sky, sun,
/// ground, two accent shapes) drawn to cover its box, like BoxFit.cover.
class MomentScenePainter extends CustomPainter {
  final MomentScene scene;
  const MomentScenePainter(this.scene);

  // The scenes are drawn on a 300x200 canvas, scaled to cover.
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300 > size.height / 200
        ? size.width / 300
        : size.height / 200;
    canvas.save();
    canvas.translate((size.width - 300 * s) / 2, (size.height - 200 * s) / 2);
    canvas.scale(s);
    canvas.clipRect(const Rect.fromLTWH(0, 0, 300, 200));
    Paint p(int c) => Paint()..color = Color(c);
    switch (scene) {
      case MomentScene.park:
        canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 200), p(0xFFE1E9D8));
        canvas.drawCircle(const Offset(235, 52), 22, p(0xFFDEB461));
        canvas.drawPath(_hill(132, 120, 102), p(0xFF8FA580));
        canvas.drawCircle(const Offset(72, 112), 28, p(0xFF6E8A60));
        canvas.drawCircle(const Offset(230, 100), 34, p(0xFF6E8A60));
        canvas.drawRect(const Rect.fromLTWH(68, 134, 8, 46), p(0xFF5A4A44));
        canvas.drawRect(const Rect.fromLTWH(226, 128, 8, 52), p(0xFF5A4A44));
      case MomentScene.coffee:
        canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 200), p(0xFFF5E7C4));
        canvas.drawRect(const Rect.fromLTWH(0, 150, 300, 50), p(0xFF9A4A3E));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(128, 74, 66, 74),
            const Radius.circular(18),
          ),
          p(0xFFC9963F),
        );
        canvas.drawRect(const Rect.fromLTWH(206, 122, 24, 26), p(0xFFFFFFFF));
        canvas.drawRect(const Rect.fromLTWH(240, 122, 24, 26), p(0xFFFFFFFF));
        canvas.drawRect(const Rect.fromLTWH(0, 160, 300, 5), p(0xFFFFFFFF));
      case MomentScene.dinner:
        canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 200), p(0xFFF1E8DA));
        canvas.drawCircle(const Offset(150, 110), 66, p(0xFFFFFFFF));
        canvas.drawRect(const Rect.fromLTWH(0, 172, 300, 28), p(0xFFE5D7C3));
        canvas.drawPath(
          Path()
            ..moveTo(96, 124)
            ..quadraticBezierTo(150, 64, 204, 124)
            ..close(),
          p(0xFFDEB461),
        );
        canvas.drawOval(const Rect.fromLTWH(126, 88, 48, 22), p(0xFF9A4A3E));
      case MomentScene.desert:
        canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 200), p(0xFFF6DDD3));
        canvas.drawCircle(const Offset(150, 118), 42, p(0xFFE29079));
        canvas.drawPath(_hill(140, 128, 112), p(0xFFC49A6C));
        canvas.drawPath(_hill(166, 160, 146), p(0xFFD9B98C));
        canvas.drawPath(
          Path()
            ..moveTo(236, 150)
            ..lineTo(258, 118)
            ..lineTo(280, 150)
            ..close(),
          p(0xFF5A4A44),
        );
    }
    canvas.restore();
  }

  Path _hill(double left, double right, double mid) => Path()
    ..moveTo(0, 200)
    ..lineTo(0, left)
    ..quadraticBezierTo(150, mid, 300, right)
    ..lineTo(300, 200)
    ..close();

  @override
  bool shouldRepaint(covariant MomentScenePainter old) => old.scene != scene;
}
