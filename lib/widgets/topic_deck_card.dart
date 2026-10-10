import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/topics/topics_data.dart';
import '../l10n/app_localizations.dart';

/// كرت "سالفة الليلة": رزمة كروت، الأمامي يطير لما تغيّر الموضوع.
/// التالي: زر "غيّرها" أو سحب الكرت لليسار.
/// السابق: زر السهم اليمين أو سحب الكرت لليمين.
class TopicDeckCard extends StatefulWidget {
  final List<String> topics;
  final ValueChanged<String>? onStart; // زر "يلا نسولف"

  // ---- النسخة الغنية (شاشة المواضيع). كلها اختيارية، وبدونها يبقى الشكل
  // الأصلي لصندوق الأنشطة بدون أي تغيير.
  final List<Topic>? items;
  final TopicCategory Function(String categoryId)? categoryOf;
  final bool Function(String topicId)? isSaved;
  final bool Function(String topicId)? isDiscussed;
  final ValueChanged<String>? onToggleSave;
  final ValueChanged<String>? onTalk;
  final int? index;
  final VoidCallback? onNext, onPrev;

  const TopicDeckCard({super.key, required this.topics, this.onStart})
    : items = null,
      categoryOf = null,
      isSaved = null,
      isDiscussed = null,
      onToggleSave = null,
      onTalk = null,
      index = null,
      onNext = null,
      onPrev = null;

  /// رزمة المواضيع الكاملة: فئات، حفظ، "سولفنا فيه".
  TopicDeckCard.rich({
    super.key,
    required List<Topic> this.items,
    required TopicCategory Function(String categoryId) this.categoryOf,
    required bool Function(String topicId) this.isSaved,
    required bool Function(String topicId) this.isDiscussed,
    required ValueChanged<String> this.onToggleSave,
    required ValueChanged<String> this.onTalk,
    required int this.index,
    this.onNext,
    this.onPrev,
  }) : topics = [for (final t in items) t.text],
       onStart = null;

  @override
  State<TopicDeckCard> createState() => _TopicDeckCardState();
}

class _Pose {
  final double dy, angle, scale, shadow;
  final Color color, border;
  const _Pose(
    this.dy,
    this.angle,
    this.scale,
    this.color,
    this.border,
    this.shadow,
  );

  static _Pose lerp(_Pose a, _Pose b, double t) => _Pose(
    a.dy + (b.dy - a.dy) * t,
    a.angle + (b.angle - a.angle) * t,
    a.scale + (b.scale - a.scale) * t,
    Color.lerp(a.color, b.color, t)!,
    Color.lerp(a.border, b.border, t)!,
    a.shadow + (b.shadow - a.shadow) * t,
  );
}

class _C {
  static const bg = Color(0xFFFBF4EA);
  static const border = Color(0xFFEADFCF);
  static const ink = Color(0xFF2B211E);
  static const brick = Color(0xFF9A4A3E);
  static const salmon = Color(0xFFE29079);
  static const mustard = Color(0xFFDEB461);
  static const quote = Color(0xFFF6DDD3);
  static const dotOff = Color(0xFFE5D7C3);
  static const navy = Color(0xFF1E2A47);
  static const doneBg = Color(0xFFD6E7E4);
  static const doneInk = Color(0xFF2F6662);
}

const double _deg = math.pi / 180;
const _pose0 = _Pose(0, 0, 1, Colors.white, _C.border, 1);

class _TopicDeckCardState extends State<TopicDeckCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  )..addStatusListener(_onStatus);

  int _index = 0;
  int _dir = 0; // 1 = التالي، -1 = السابق، 0 = واقف
  double _dx = 0; // مقدار السحب

  bool get _rich => widget.items != null;
  double get _cardH => _rich ? 318 : 262;

  int get _n => widget.topics.length;
  int _at(int k) => ((k % _n) + _n) % _n;

  TopicCategory _catOf(int k) =>
      widget.categoryOf!(widget.items![_at(k)].categoryId);

  // الكرت اللي ورا الأمامي: لون فئته (الأول) ثم الـ tint (الثاني).
  _Pose _p1(int k) {
    final c = _rich ? _catOf(k).color : _C.salmon;
    return _Pose(8, 2.5 * _deg, .98, c, c, 0);
  }

  _Pose _p2(int k) {
    final c = _rich ? _catOf(k).tint : _C.mustard;
    return _Pose(14, -3 * _deg, .96, c, c, 0);
  }

  @override
  void initState() {
    super.initState();
    if (_rich) _index = _clampIndex(widget.index ?? 0);
  }

  int _clampIndex(int i) => _n == 0 ? 0 : i.clamp(0, _n - 1);

  @override
  void didUpdateWidget(covariant TopicDeckCard old) {
    super.didUpdateWidget(old);
    if (_rich && !_busy && _dir == 0) {
      final target = _clampIndex(widget.index ?? _index);
      if (target != _index) _index = target;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    _ctrl.duration = Duration(milliseconds: reduce ? 180 : 550);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus s) {
    if (s != AnimationStatus.completed) return;
    final dir = _dir;
    setState(() {
      _index = _at(_index + _dir);
      _dir = 0;
    });
    _ctrl.value = 0;
    if (dir == 1) widget.onNext?.call();
    if (dir == -1) widget.onPrev?.call();
  }

  bool get _busy => _ctrl.isAnimating;

  bool get _fadeOnly => _rich && MediaQuery.disableAnimationsOf(context);

  // Reduced motion: no flying card, just a short cross-fade to the next one.
  void _jump(int d) {
    setState(() => _index = _at(_index + d));
    if (d > 0) widget.onNext?.call();
    if (d < 0) widget.onPrev?.call();
  }

  void _next({double from = 0}) {
    if (_busy || _n < 2) return;
    if (_fadeOnly) return _jump(1);
    HapticFeedback.selectionClick();
    setState(() {
      _dir = 1;
      _dx = 0;
    });
    _ctrl.forward(from: from);
  }

  void _prev() {
    if (_busy || _n < 2) return;
    if (_fadeOnly) return _jump(-1);
    HapticFeedback.selectionClick();
    setState(() {
      _dir = -1;
      _dx = 0;
    });
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_n == 0) return SizedBox(height: _cardH + 18);
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (d) {
            if (_busy) return;
            setState(() => _dx += d.delta.dx);
          },
          onHorizontalDragEnd: (d) {
            if (_busy) return;
            final v = d.velocity.pixelsPerSecond.dx;
            if (_dx < -w * .22 || v < -600) {
              _next(from: (-_dx / (1.2 * w)).clamp(0.0, .9));
            } else if (_dx > w * .22 || v > 600) {
              _prev();
            } else {
              setState(() => _dx = 0);
            }
          },
          child: SizedBox(
            height: _cardH + 18,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) =>
                  Stack(clipBehavior: Clip.none, children: _layers(w)),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _layers(double w) {
    final i = _index;
    var t = _ctrl.value;
    var mode = _dir;

    if (_fadeOnly) {
      return [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: KeyedSubtree(
              key: ValueKey(i),
              child: Stack(
                children: [_card(i, _pose0, content: 1, interactive: true)],
              ),
            ),
          ),
        ),
      ];
    }

    if (mode == 0 && _dx < 0) {
      mode = 1;
      t = (-_dx / (1.2 * w)).clamp(0.0, 1.0);
    }

    if (mode == 1) {
      return [
        if (_n > 3) _card(_at(i + 3), _p2(i + 3), opacity: t),
        _card(_at(i + 2), _Pose.lerp(_p2(i + 2), _p1(i + 2), t)),
        _card(
          _at(i + 1),
          _Pose.lerp(_p1(i + 1), _pose0, t),
          content: ((t - .4) / .6).clamp(0.0, 1.0),
        ),
        _card(
          i,
          _pose0,
          dx: -1.2 * w * t,
          extraAngle: -14 * _deg * t,
          opacity: 1 - t,
          content: 1,
        ),
      ];
    }

    if (mode == -1) {
      return [
        _card(_at(i + 2), _p2(i + 2), opacity: 1 - t),
        _card(_at(i + 1), _Pose.lerp(_p1(i + 1), _p2(i + 1), t)),
        _card(
          i,
          _Pose.lerp(_pose0, _p1(i), t),
          content: (1 - t * 2).clamp(0.0, 1.0),
        ),
        _card(
          _at(i - 1),
          _pose0,
          dx: -1.2 * w * (1 - t),
          extraAngle: -14 * _deg * (1 - t),
          opacity: t,
          content: 1,
        ),
      ];
    }

    return [
      _card(_at(i + 2), _p2(i + 2)),
      _card(_at(i + 1), _p1(i + 1)),
      _card(
        i,
        _pose0,
        dx: _dx,
        extraAngle: _dx / w * .15,
        content: 1,
        interactive: true,
      ),
    ];
  }

  Widget _card(
    int k,
    _Pose p, {
    double dx = 0,
    double extraAngle = 0,
    double opacity = 1,
    double content = 0,
    bool interactive = false,
  }) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: _cardH,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(dx, p.dy),
          child: Transform.rotate(
            angle: p.angle + extraAngle,
            child: Transform.scale(
              scale: p.scale,
              child: IgnorePointer(
                ignoring: !interactive,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: p.color,
                    borderRadius: BorderRadius.circular(_rich ? 28 : 26),
                    border: Border.all(color: p.border),
                    boxShadow: [
                      if (p.shadow > 0)
                        BoxShadow(
                          color: const Color(
                            0xFF5B3A28,
                          ).withValues(alpha: (_rich ? .12 : .10) * p.shadow),
                          blurRadius: _rich ? 28 : 24,
                          offset: Offset(0, _rich ? 12 : 10),
                        ),
                    ],
                  ),
                  child: content > 0
                      ? Opacity(opacity: content, child: _content(k))
                      : const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(int k) {
    if (_rich) return _richContent(k);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 10, 6),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.coffee_outlined, size: 18, color: _C.brick),
                  SizedBox(width: 8),
                  Text(
                    'سالفة الليلة',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _C.brick,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Semantics(
              label: 'موضوع ${k + 1} من $_n',
              child: Row(
                children: List.generate(_n, (j) {
                  final on = j == k;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: on ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: on ? _C.brick : _C.dotOff,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                top: -6,
                child: Icon(
                  Icons.format_quote_rounded,
                  size: 48,
                  color: _C.quote,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 4),
                child: Text(
                  widget.topics[k],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.55,
                    color: _C.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _squareButton(
              label: 'الموضوع السابق',
              onTap: _prev,
              icon: const Directionality(
                textDirection: TextDirection.ltr,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: _C.ink,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () => widget.onStart?.call(widget.topics[k]),
                  style: FilledButton.styleFrom(
                    backgroundColor: _C.brick,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'يلا نسولف',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => _next(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _C.bg,
                  foregroundColor: _C.ink,
                  side: const BorderSide(color: _C.border),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'غيّرها',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: _C.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _richContent(int k) {
    final l = AppLocalizations.of(context);
    final topic = widget.items![k];
    final cat = widget.categoryOf!(topic.categoryId);
    final saved = widget.isSaved!(topic.id);
    final done = widget.isDiscussed!(topic.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cat.tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                cat.label(l),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: cat.ink,
                ),
              ),
            ),
            const Spacer(),
            Semantics(
              button: true,
              toggled: saved,
              label: l.topicsSave,
              excludeSemantics: true,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(side: BorderSide(color: _C.border)),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onToggleSave!(topic.id);
                  },
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 20,
                      color: _C.brick,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                top: -2,
                child: SizedBox(
                  width: 44,
                  height: 34,
                  child: CustomPaint(painter: _QuotePainter()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 4),
                child: Text(
                  topic.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.55,
                    color: _C.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 24,
          child: Row(
            children: [
              Text(
                l.topicsCountOf(k + 1, _n),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B5D55),
                ),
              ),
              const Spacer(),
              if (done)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _C.doneBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: _C.doneInk,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        l.topicsDiscussedBadge,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _C.doneInk,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            // RTL: first child sits on the right.
            Semantics(
              button: true,
              label: l.topicsPrev,
              excludeSemantics: true,
              child: Material(
                color: _C.bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: _C.border),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _prev,
                  child: const SizedBox(
                    width: 52,
                    height: 52,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: _C.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Material(
                color: done ? _C.doneBg : _C.brick,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: done
                      ? const BorderSide(color: Color(0xFFB9D3CF))
                      : BorderSide.none,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => widget.onTalk!(topic.id),
                  child: SizedBox(
                    height: 52,
                    child: Center(
                      child: Text(
                        done
                            ? '${l.topicsDiscussedButton} ✓'
                            : l.topicsLetsTalk,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: done ? _C.doneInk : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: _C.navy,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _next(),
                child: SizedBox(
                  height: 52,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shuffle_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l.topicsShuffle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _squareButton({
    required String label,
    required VoidCallback onTap,
    required Widget icon,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: _C.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _C.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(width: 48, height: 48, child: Center(child: icon)),
        ),
      ),
    );
  }
}

/// The two-piece quote mark from the design (44x34 viewBox).
class _QuotePainter extends CustomPainter {
  const _QuotePainter();
  @override
  void paint(Canvas canvas, Size size) {
    Path half(double x) => Path()
      ..moveTo(x, 34)
      ..lineTo(x, 20)
      ..relativeCubicTo(0, -11, 6, -18, 17, -20)
      ..relativeLineTo(2, 5)
      ..relativeCubicTo(-6, 2, -9, 6, -9, 11)
      ..relativeLineTo(8, 0)
      ..relativeLineTo(0, 18)
      ..close();
    canvas.drawPath(half(0), Paint()..color = _C.quote);
    canvas.drawPath(half(24), Paint()..color = _C.quote);
  }

  @override
  bool shouldRepaint(covariant _QuotePainter old) => false;
}
