import 'package:flutter/material.dart';

import '../../../screens/activities_colors.dart';

/// A ring that expands and fades around [child] every 1.6s while [active]
/// (and animations are allowed). Starts/stops its ticker, so nothing runs
/// when there's no pulse.
class SharePulse extends StatefulWidget {
  final bool active;
  final double size;
  final Widget child;
  const SharePulse({
    super.key,
    required this.active,
    required this.size,
    required this.child,
  });

  @override
  State<SharePulse> createState() => _SharePulseState();
}

class _SharePulseState extends State<SharePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  bool get _run => widget.active && !MediaQuery.disableAnimationsOf(context);

  void _sync() {
    if (_run) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant SharePulse old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: [
      if (_run)
        AnimatedBuilder(
          animation: _c,
          builder: (_, _) {
            // ping: 0 -> 70% grows 0..16px and fades from .75; then rests
            final u = (_c.value / .7).clamp(0.0, 1.0);
            return IgnorePointer(
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _c.value >= .7
                      ? null
                      : [
                          BoxShadow(
                            color: AC.salmon.withValues(alpha: .75 * (1 - u)),
                            spreadRadius: 16 * u,
                          ),
                        ],
                ),
              ),
            );
          },
        ),
      widget.child,
    ],
  );
}
