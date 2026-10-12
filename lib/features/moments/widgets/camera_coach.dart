import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';

/// shared_preferences key: the camera hint was shown (or dismissed) once.
const kCoachSeenKey = 'moments_coach_seen';

/// First-visit tooltip over the camera button. Bobs up and down 5px.
class CameraCoach extends StatefulWidget {
  final VoidCallback onLater, onNow;
  const CameraCoach({super.key, required this.onLater, required this.onNow});

  @override
  State<CameraCoach> createState() => _CameraCoachState();
}

class _CameraCoachState extends State<CameraCoach>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800), // 1.6s there-and-back
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _bob.stop();
      _bob.value = 0;
    } else if (!_bob.isAnimating) {
      _bob.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _bob,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -5 * Curves.easeInOut.transform(_bob.value)),
        child: child,
      ),
      child: Semantics(
        container: true,
        label: l.momentsCoachLabel,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 270,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: AC.brick,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x595B3A28),
                    blurRadius: 30,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0x2EFFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.momentsSnapPrompt,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l.momentsCoachBody,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: .92),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Button(
                        label: l.momentsCoachLater,
                        onTap: widget.onLater,
                        filled: false,
                      ),
                      _Button(
                        label: l.momentsCoachNow,
                        onTap: widget.onNow,
                        filled: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // arrow pointing down at the button
            const Positioned(
              bottom: -9,
              child: CustomPaint(size: Size(20, 10), painter: _Arrow()),
            ),
          ],
        ),
      ),
    );
  }
}

/// 40px button (as designed) inside a 44px tap area.
class _Button extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  const _Button({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: SizedBox(
      height: 44,
      child: Center(
        widthFactor: 1,
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: filled ? 16 : 14),
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: filled ? null : Border.all(color: const Color(0x73FFFFFF)),
          ),
          // width follows the text (an aligned Container would stretch)
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: filled ? FontWeight.w800 : FontWeight.w700,
                color: filled ? AC.brick : Colors.white,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Arrow extends CustomPainter {
  const _Arrow();
  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close(),
    Paint()..color = AC.brick,
  );

  @override
  bool shouldRepaint(covariant _Arrow old) => false;
}
