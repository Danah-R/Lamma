import 'dart:io';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';

/// The 260px picture slot of "لحظة جديدة": empty prompt with camera/gallery
/// buttons, or the chosen photo with a "change photo" button on top.
class PhotoArea extends StatelessWidget {
  final String? path;
  final VoidCallback onCamera, onGallery, onClear;
  const PhotoArea({
    super.key,
    required this.path,
    required this.onCamera,
    required this.onGallery,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (path != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 260,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(path!),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(color: AC.track),
              ),
              PositionedDirectional(
                top: 12,
                end: 12,
                child: Material(
                  color: const Color(0xB3141B2E),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onClear,
                    child: SizedBox(
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Center(
                          child: Text(
                            l.momentsChangePhoto,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return CustomPaint(
      painter: const _Dashed(color: Color(0xFFD9C6AE), radius: 24),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          color: AC.track,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                size: 28,
                color: AC.brick,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l.momentsSnapPrompt,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AC.ink,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: _Btn(
                    label: l.momentsCamera,
                    icon: Icons.photo_camera_outlined,
                    filled: true,
                    onTap: onCamera,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: _Btn(
                    label: l.momentsGallery,
                    icon: Icons.photo_library_outlined,
                    filled: false,
                    onTap: onGallery,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  const _Btn({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AC.ink;
    return Material(
      color: filled ? AC.navy : AC.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: filled ? BorderSide.none : const BorderSide(color: AC.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 46,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dashed extends CustomPainter {
  final Color color;
  final double radius;
  const _Dashed({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(1),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Dashed old) =>
      old.color != color || old.radius != radius;
}
