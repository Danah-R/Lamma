import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../screens/activities_colors.dart';
import '../theme.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/notifications/notifications_controller.dart';
import '../features/notifications/widgets/notification_panel.dart';

const _scrim = Color(0x2E1E2A47); // navy at 18%
const _panelWidth = 336.0;
const _panelMaxHeight = 470.0;

/// The bell in a screen header: shows the unread count, and opens the
/// floating notifications box right under it.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  final _token = Object();
  late final NotificationsController _c;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _scale = TweenSequence<double>(
    [
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 60),
    ],
  ).animate(CurvedAnimation(parent: _pulse, curve: const Cubic(.2, .8, .2, 1)));
  StreamSubscription<Object>? _sub;
  OverlayEntry? _entry;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _c = context.read<NotificationsController>();
    _c.addListener(_onChange);
    _sub = _c.onNew.listen((_) {
      if (_active && mounted && !MediaQuery.disableAnimationsOf(context)) {
        _pulse.forward(from: 0);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hidden tabs keep their bell in the tree: only the visible one counts.
    final active = TickerMode.valuesOf(context).enabled;
    if (active == _active) return;
    _active = active;
    if (active) {
      _c.bellShown(_token);
    } else {
      _removeEntry();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _c.bellHidden(_token),
      );
    }
  }

  @override
  void dispose() {
    _c.removeListener(_onChange);
    _sub?.cancel();
    _removeEntry();
    _c.bellHidden(_token);
    _pulse.dispose();
    super.dispose();
  }

  void _removeEntry() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }

  void _onChange() {
    if (!mounted) return;
    if (_c.panelOpen && _active && _entry == null) {
      _insertEntry();
    } else if (!_c.panelOpen && _entry != null) {
      _removeEntry();
    }
    setState(() {});
  }

  void _insertEntry() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final bellLeft = box.localToGlobal(Offset.zero).dx;
    final bellSize = box.size;
    final screenW = MediaQuery.sizeOf(context).width;
    final width = _panelWidth.clamp(0.0, screenW - 24);
    _entry = OverlayEntry(
      builder: (ctx) => _PanelLayer(
        link: _link,
        width: width,
        bellLeft: bellLeft,
        bellSize: bellSize,
        controller: _c,
        onSeeAll: () {
          _c.closePanel();
          openNotificationsScreen(context);
        },
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final open = _c.panelOpen && _entry != null;
    final count = _c.unreadCount;
    final label = count > 0 ? l.notifBellLabel(count) : l.notifBellLabelNone;
    // Danah's bell, as designed (the old BellButton): a filled icon button
    // (peach tint, navy icon) with a small brick dot at its top corner. The
    // dot shows while there is something unread; pressing opens the box.
    return CompositedTransformTarget(
      link: _link,
      child: Semantics(
        button: true,
        expanded: open,
        label: label,
        excludeSemantics: true,
        child: Stack(
          children: [
            IconButton.filled(
              onPressed: _c.togglePanel,
              style: IconButton.styleFrom(
                backgroundColor: C.peachTint,
                foregroundColor: C.navy,
              ),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            if (count > 0)
              PositionedDirectional(
                top: 8,
                end: 10,
                child: IgnorePointer(
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: C.brick,
                        shape: BoxShape.circle,
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
}

/// Scrim + the box itself, following the bell.
class _PanelLayer extends StatefulWidget {
  final LayerLink link;
  final double width, bellLeft;
  final Size bellSize;
  final NotificationsController controller;
  final VoidCallback onSeeAll;
  const _PanelLayer({
    required this.link,
    required this.width,
    required this.bellLeft,
    required this.bellSize,
    required this.controller,
    required this.onSeeAll,
  });

  @override
  State<_PanelLayer> createState() => _PanelLayerState();
}

class _PanelLayerState extends State<_PanelLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    _in.forward();
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    // panel's left edge sits 12px from the screen; the arrow points at the bell
    const edge = 12.0;
    final arrowLeft = (widget.bellLeft + widget.bellSize.width / 2 - edge - 7).clamp(
      16.0,
      widget.width - 30,
    );
    final curved = CurvedAnimation(
      parent: _in,
      curve: const Cubic(.2, .8, .2, 1),
    );
    final panel = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: _panelMaxHeight),
          decoration: BoxDecoration(
            color: AC.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AC.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x401E2A47),
                blurRadius: 44,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: NotificationPanel(
              controller: widget.controller,
              onSeeAll: widget.onSeeAll,
              onOpen: (n) {
                widget.controller.closePanel();
                widget.controller.open(n);
              },
            ),
          ),
        ),
        Positioned(
          top: -7,
          left: arrowLeft,
          child: Transform.rotate(
            angle: .785398,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AC.card,
                border: Border(
                  top: BorderSide(color: AC.border),
                  left: BorderSide(color: AC.border),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              button: true,
              label: l.notifClosePanel,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.controller.closePanel,
                child: const ColoredBox(color: _scrim),
              ),
            ),
          ),
          CompositedTransformFollower(
            link: widget.link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topLeft,
            followerAnchor: Alignment.topLeft,
            offset: Offset(edge - widget.bellLeft, widget.bellSize.height + 8),
            child: Align(
              alignment: Alignment.topLeft,
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: reduce
                      ? const AlwaysStoppedAnimation(1.0)
                      : Tween(begin: .96, end: 1.0).animate(curved),
                  alignment: FractionalOffset(
                    (arrowLeft + 7) / widget.width,
                    0,
                  ),
                  child: SizedBox(width: widget.width, child: panel),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
