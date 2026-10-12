import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../notification_model.dart';
import '../notifications_controller.dart';
import 'notification_visuals.dart';

/// Drops in from the top when a notification arrives while the app is open,
/// stays 3.5 seconds, then leaves. Tap: open the box under the bell. Swipe
/// up: dismiss. Place inside a [Stack] that covers the whole screen.
class NotificationBannerHost extends StatefulWidget {
  const NotificationBannerHost({super.key});

  @override
  State<NotificationBannerHost> createState() => _NotificationBannerHostState();
}

class _NotificationBannerHostState extends State<NotificationBannerHost> {
  late final NotificationsController _c;
  StreamSubscription<AppNotification>? _sub;
  Timer? _timer;
  AppNotification? _n;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _c = context.read<NotificationsController>();
    _c.addListener(_onChange);
    _sub = _c.onNew.listen(_arrive);
  }

  @override
  void dispose() {
    _c.removeListener(_onChange);
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _onChange() {
    if (_c.panelOpen && _show) _hide();
  }

  void _arrive(AppNotification n) {
    if (!mounted || _c.panelOpen) return;
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _n = n;
      _show = true;
    });
    _timer = Timer(const Duration(milliseconds: 3500), _hide);
  }

  void _hide() {
    _timer?.cancel();
    if (mounted && _show) setState(() => _show = false);
  }

  void _tap() {
    final n = _n;
    _hide();
    if (n == null) return;
    // no bell on this screen: go straight to what it is about
    if (_c.hasActiveBell) {
      _c.openPanel();
    } else {
      _c.open(n);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = _n;
    if (n == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final banner = GestureDetector(
      onVerticalDragUpdate: (d) {
        if (d.delta.dy < -4) _hide();
      },
      child: Material(
        color: AC.navy,
        borderRadius: BorderRadius.circular(20),
        elevation: 12,
        shadowColor: const Color(0x591E2A47),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _tap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                NotificationAvatar(n: n, size: 40, ring: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.notifBannerKicker,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFC9CFDD),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text.rich(
                        notificationSpan(
                          n,
                          color: Colors.white,
                          size: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 4,
      left: 12,
      right: 12,
      child: IgnorePointer(
        ignoring: !_show,
        child: ExcludeSemantics(
          excluding: !_show,
          child: AnimatedSlide(
            duration: Duration(milliseconds: reduce ? 0 : 350),
            curve: const Cubic(.2, .8, .2, 1),
            offset: _show || reduce ? Offset.zero : const Offset(0, -1.6),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: reduce ? 150 : 250),
              opacity: _show ? 1 : 0,
              child: Semantics(liveRegion: true, child: banner),
            ),
          ),
        ),
      ),
    );
  }
}
