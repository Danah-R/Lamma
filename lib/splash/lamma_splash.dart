// Lamma — animated splash screen.
//
// All scene geometry is expressed in "scene units": pixel coordinates of the
// original 1245 x 848 family render. The whole scene is drawn inside one
// Transform (translate + uniform scale), so every image, hotspot and painter
// lines up exactly no matter the device size.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Assets
// ---------------------------------------------------------------------------
class _A {
  static const _p = 'assets/splash/';
  static const scene = '${_p}scene.webp';
  static const girl = '${_p}girl.webp';
  static const mother = '${_p}mother.webp';
  static const son = '${_p}son.webp';
  static const sister = '${_p}sister.webp';
  static const fatherBody = '${_p}father_body.webp';
  static const fatherArm = '${_p}father_arm.webp';
  static const dallah = '${_p}dallah.webp';
  static const block = '${_p}block.webp';

  static const all = [
    scene, girl, mother, son, sister,
    fatherBody, fatherArm, dallah, block,
  ];
}

// ---------------------------------------------------------------------------
// Scene geometry (scene units). Boxes are [left, top, width, height].
// ---------------------------------------------------------------------------
class _G {
  static const sceneW = 1245.0;
  static const sceneH = 848.0;

  static const girl = Rect.fromLTWH(587, 184, 154, 202);
  static const mother = Rect.fromLTWH(777, 124, 200, 312);
  static const son = Rect.fromLTWH(247, 305, 239, 330);
  static const sister = Rect.fromLTWH(801, 318, 224, 319);
  static const fatherBody = Rect.fromLTWH(312, 102, 228, 338);
  static const fatherArm = Rect.fromLTWH(449, 209, 91, 145);
  static const dallah = Rect.fromLTWH(494, 332, 105, 129);
  static const blockSize = Size(25, 27);

  // Framing: these scene units fill the screen width, and the scene's
  // vertical centre sits at [centerYFraction] of the screen height.
  static const frameWidth = 1286.0;
  static const frameCenterX = 640.0;
  static const frameCenterY = 485.0;
  static const centerYFraction = 0.526;

  // Father rig.
  static const leanPivot = Offset(440, 440); // base of his seated body
  static const shoulder = Offset(462, 217);
  static const handRest = Offset(510, 330);

  // Dallah rig (the dallah is mirrored: spout points left towards the cups).
  static const dallahGrip = Offset(54, 20); // neck, local to dallah box
  static const dallahSpout = Offset(3, 55); // spout tip, local to dallah box
  static Offset get dallahRestGrip => dallah.topLeft + dallahGrip;
  static const cupMouth = Offset(487, 398);
  static const cupSteam = Offset(481, 352);

  // Blocks.
  static const blockFrom = Offset(622, 322); // the girl's hand
  static const towerTop = Offset(661, 329);
  static const blockStep = 23.0;
  static const blockArc = 34.0;
  static const maxStack = 3;

  // Hotspots.
  static Rect get dallahHotspot => dallah.inflate(14);
  static const blocksHotspotA = Rect.fromLTWH(640, 300, 100, 100);
  static const blocksHotspotB = Rect.fromLTWH(590, 280, 50, 70);
}

// ---------------------------------------------------------------------------
// Palette
// ---------------------------------------------------------------------------
class _C {
  static const red = Color(0xFF8E1B20);
  static const taglineBrown = Color(0xFF5E3C24);
  static const coffee = Color(0xFF5A3214);
  // Floor colours sampled from the render, so the scene melts into the screen.
  static const bgTop = Color(0xFFC18A58);
  static const bgBottom = Color(0xFFD1A982);
}

// ---------------------------------------------------------------------------
// Timeline (milliseconds)
// ---------------------------------------------------------------------------
class _T {
  static const sceneFadeIn = 600;
  static const firstPour = 500;
  static const firstBlock = 1200;
  static const blockEvery = 2300;
  static const logoAt = 4000;
  static const buttonAt = 4600;
  static const fadeDuration = 1000;
  static const pourEvery = 10000;
  static const autoStartDelay = 2000;

  // Pour clip.
  static const pourLength = 4600;
  static const streamOn = 1550;
  static const streamOff = 2650;
  static const streamFade = 200;
}

// Pour keyframes: [time, ...values]. Interpolated with smoothstep.
const _handKeys = <List<double>>[
  [0, 510, 330],
  [500, 540, 352],
  [750, 535, 340],
  [1500, 506, 305],
  [2700, 505, 308],
  [3500, 535, 340],
  [3950, 540, 352],
  [4600, 510, 330],
];
const _leanKeys = <List<double>>[
  [0, 0],
  [500, 7],
  [1500, 2],
  [2700, 2],
  [3950, 7],
  [4600, 0],
];
// [time, gripX, gripY, angleDeg]
const _dallahKeys = <List<double>>[
  [0, 548, 352, 0],
  [500, 548, 352, 0],
  [750, 543, 340, 0],
  [1500, 517, 305, -35],
  [2700, 516, 308, -40],
  [3500, 543, 340, 0],
  [3950, 548, 352, 0],
  [4600, 548, 352, 0],
];

double _smooth(double x) => x * x * (3 - 2 * x);

List<double> _interp(List<List<double>> keys, double t) {
  if (t <= keys.first[0]) return keys.first.sublist(1);
  for (var i = 1; i < keys.length; i++) {
    if (t <= keys[i][0]) {
      final a = keys[i - 1], b = keys[i];
      final u = _smooth((t - a[0]) / (b[0] - a[0]));
      return List<double>.generate(a.length - 1, (j) => a[j + 1] + (b[j + 1] - a[j + 1]) * u);
    }
  }
  return keys.last.sublist(1);
}

double _rad(double deg) => deg * math.pi / 180;

Offset _rotateAround(Offset p, Offset c, double deg) {
  final r = _rad(deg), x = p.dx - c.dx, y = p.dy - c.dy;
  return Offset(c.dx + x * math.cos(r) - y * math.sin(r), c.dy + x * math.sin(r) + y * math.cos(r));
}

/// Everything the scene needs for one frame of the pour.
class _PourPose {
  _PourPose(double t) {
    lean = _interp(_leanKeys, t)[0];
    final h = _interp(_handKeys, t);
    hand = Offset(h[0], h[1]);
    final d = _interp(_dallahKeys, t);
    grip = Offset(d[0], d[1]);
    angle = d[2];

    final r = _rad(angle);
    final l = _G.dallahSpout - _G.dallahGrip;
    spout = grip + Offset(l.dx * math.cos(r) - l.dy * math.sin(r), l.dx * math.sin(r) + l.dy * math.cos(r));

    if (t < _T.streamOn || t > _T.streamOff + _T.streamFade) {
      stream = 0;
    } else if (t < _T.streamOn + _T.streamFade) {
      stream = (t - _T.streamOn) / _T.streamFade;
    } else if (t > _T.streamOff) {
      stream = 1 - (t - _T.streamOff) / _T.streamFade;
    } else {
      stream = 1;
    }
  }

  late final double lean;
  late final Offset hand;
  late final Offset grip;
  late final double angle;
  late final Offset spout;
  late final double stream;

  Matrix4 bodyMatrix() {
    final p = _G.leanPivot - _G.fatherBody.topLeft;
    return Matrix4.identity()
      ..translateByDouble(p.dx, p.dy, 0.0, 1.0)
      ..rotateZ(_rad(lean))
      ..translateByDouble(-p.dx, -p.dy, 0.0, 1.0);
  }

  /// Two-point IK: the arm pivots at the (leaning) shoulder and stretches
  /// along its own axis so the hand lands exactly on [hand].
  Matrix4 armMatrix() {
    final box = _G.fatherArm.topLeft;
    final s = _rotateAround(_G.shoulder, _G.leanPivot, lean);
    final rest = _G.handRest - _G.shoulder;
    final restAngle = math.atan2(rest.dy, rest.dx);
    final v = hand - s;
    final angleNow = math.atan2(v.dy, v.dx);
    final stretch = v.distance / rest.distance;
    return Matrix4.identity()
      ..translateByDouble(s.dx - box.dx, s.dy - box.dy, 0.0, 1.0)
      ..rotateZ(angleNow)
      ..scaleByDouble(stretch, 1.0, 1.0, 1.0)
      ..rotateZ(-restAngle)
      ..translateByDouble(box.dx - _G.shoulder.dx, box.dy - _G.shoulder.dy, 0.0, 1.0);
  }

  Matrix4 dallahMatrix() {
    final move = grip - _G.dallahRestGrip;
    return Matrix4.identity()
      ..translateByDouble(move.dx + _G.dallahGrip.dx, move.dy + _G.dallahGrip.dy, 0.0, 1.0)
      ..rotateZ(_rad(angle))
      ..translateByDouble(-_G.dallahGrip.dx, -_G.dallahGrip.dy, 0.0, 1.0);
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------
class LammaSplash extends StatefulWidget {
  const LammaSplash({super.key, this.onStart});

  /// Called when the user taps "يالله حيهم!".
  final VoidCallback? onStart;

  @override
  State<LammaSplash> createState() => _LammaSplashState();
}

class _LammaSplashState extends State<LammaSplash> with TickerProviderStateMixin {
  late final AnimationController _pour =
      AnimationController(vsync: this, duration: const Duration(milliseconds: _T.pourLength));
  late final AnimationController _steam =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  late final AnimationController _girlRock =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final List<AnimationController> _breath = [3200, 3500, 3800]
      .map((ms) => AnimationController(vsync: this, duration: Duration(milliseconds: ms)))
      .toList();

  final List<_FlyingBlock> _blocks = [];
  final List<Timer> _timers = [];

  bool _ready = false;
  bool _showScene = false;
  bool _showLogo = false;
  bool _steamOn = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _pour.addListener(() {
      final t = _pour.value * _T.pourLength;
      if (!_steamOn && t >= _T.streamOff && mounted) {
        setState(() => _steamOn = true);
        _steam.repeat();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    Future.wait(_A.all.map((a) => precacheImage(AssetImage(a), context))).whenComplete(() {
      if (!mounted) return;
      setState(() => _ready = true);
      _run();
    });
  }

  void _after(int ms, VoidCallback fn) => _timers.add(Timer(Duration(milliseconds: ms), () {
        if (mounted) fn();
      }));

  void _run() {
    if (MediaQuery.of(context).disableAnimations) {
      setState(() {
        _showScene = true;
        _showLogo = true;
      });
      _after(_T.autoStartDelay, () => widget.onStart?.call());
      return;
    }
    setState(() => _showScene = true);
    for (var i = 0; i < _breath.length; i++) {
      _breath[i].value = i / _breath.length;
      _breath[i].repeat(reverse: true);
    }
    _after(_T.firstPour, _startPour);
    _after(_T.firstBlock, () {
      _placeBlock();
      _timers.add(Timer.periodic(const Duration(milliseconds: _T.blockEvery), (_) {
        if (mounted) _placeBlock();
      }));
    });
    _after(_T.logoAt, () => setState(() => _showLogo = true));
    // Auto-continue a couple seconds after where the button used to appear —
    // no button is shown; the splash advances on its own.
    _after(_T.buttonAt + _T.autoStartDelay, () => widget.onStart?.call());
    _after(_T.pourEvery, () {
      _startPour();
      _timers.add(Timer.periodic(const Duration(milliseconds: _T.pourEvery), (_) {
        if (mounted) _startPour();
      }));
    });
  }

  void _startPour() {
    if (_pour.isAnimating) return;
    _pour.forward(from: 0);
  }

  void _placeBlock() {
    final standing = _blocks.where((b) => !b.toppling).toList();
    if (standing.length >= _G.maxStack) {
      _topple(standing);
      return;
    }
    _girlRock.forward(from: 0);
    final level = standing.length;
    final target = Offset(_G.towerTop.dx, _G.towerTop.dy - level * _G.blockStep) - _G.blockFrom;
    final block = _FlyingBlock(
      controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1000)),
      target: target,
      tilt: level.isOdd ? -5 : 4,
      index: level,
    );
    setState(() => _blocks.add(block));
    block.controller.forward();
  }

  void _topple(List<_FlyingBlock> stack) {
    for (final b in stack) {
      b.toppling = true;
      b.topple = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
      b.topple!.forward().whenComplete(() {
        if (!mounted) return;
        setState(() => _blocks.remove(b));
        b.dispose();
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    for (final b in _blocks) {
      b.dispose();
    }
    _pour.dispose();
    _steam.dispose();
    _girlRock.dispose();
    for (final c in _breath) {
      c.dispose();
    }
    super.dispose();
  }

  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bgBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.bgTop, _C.bgTop, _C.bgBottom, _C.bgBottom],
            stops: [0.0, 0.35, 0.66, 1.0],
          ),
        ),
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth, h = c.maxHeight;
          final k = w / _G.frameWidth;
          final ox = w / 2 - _G.frameCenterX * k;
          final oy = h * _G.centerYFraction - _G.frameCenterY * k;
          final pad = MediaQuery.of(context).padding;

          return Stack(
            children: [
              if (_ready)
                Positioned(
                  left: 0,
                  top: 0,
                  child: AnimatedOpacity(
                    opacity: _showScene ? 1 : 0,
                    duration: const Duration(milliseconds: _T.sceneFadeIn),
                    curve: Curves.easeOut,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translateByDouble(ox, oy, 0.0, 1.0)
                        ..scaleByDouble(k, k, 1.0, 1.0),
                      child: SizedBox(
                        width: _G.sceneW,
                        height: _G.sceneH,
                        child: _buildScene(),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                top: pad.top + h * 0.06,
                child: AnimatedOpacity(
                  opacity: _showLogo ? 1 : 0,
                  duration: const Duration(milliseconds: _T.fadeDuration),
                  curve: Curves.easeInOut,
                  child: const _Logo(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _breathing(String asset, Rect box, AnimationController c) => Positioned.fromRect(
        rect: box,
        child: AnimatedBuilder(
          animation: c,
          builder: (_, child) {
            final e = Curves.easeInOut.transform(c.value);
            return Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.diagonal3Values(1 + 0.004 * e, 1 + 0.012 * e, 1),
              child: child,
            );
          },
          child: Image.asset(asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
        ),
      );

  Widget _buildScene() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The family render (father and dallah removed; they are animated).
        Positioned.fill(child: Image.asset(_A.scene, fit: BoxFit.fill, filterQuality: FilterQuality.medium)),

        // Girl — rocks a little each time she places a block.
        Positioned.fromRect(
          rect: _G.girl,
          child: AnimatedBuilder(
            animation: _girlRock,
            builder: (_, child) {
              final s = math.sin(math.pi * Curves.easeInOut.transform(_girlRock.value));
              return Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..translateByDouble(0.0, 1.0 * s, 0.0, 1.0)
                  ..rotateZ(_rad(1.6 * s)),
                child: child,
              );
            },
            child: Image.asset(_A.girl, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
          ),
        ),
        _breathing(_A.mother, _G.mother, _breath[0]),

        // Father (body + arm) and the dallah, all driven by the pour clip.
        AnimatedBuilder(
          animation: _pour,
          builder: (_, _) {
            final pose = _PourPose(_pour.value * _T.pourLength);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fromRect(
                  rect: _G.fatherBody,
                  child: Transform(
                    transform: pose.bodyMatrix(),
                    child: Image.asset(_A.fatherBody, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
                  ),
                ),
                Positioned.fromRect(
                  rect: _G.fatherArm,
                  child: Transform(
                    transform: pose.armMatrix(),
                    child: Image.asset(_A.fatherArm, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
                  ),
                ),
                Positioned.fromRect(
                  rect: _G.dallah,
                  child: Transform(
                    transform: pose.dallahMatrix(),
                    child: Image.asset(_A.dallah, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _StreamPainter(from: pose.spout, to: _G.cupMouth, opacity: pose.stream)),
                  ),
                ),
              ],
            );
          },
        ),

        _breathing(_A.son, _G.son, _breath[1]),
        _breathing(_A.sister, _G.sister, _breath[2]),

        // Blocks the girl places on her tower.
        ..._blocks.map((b) => Positioned(
              left: _G.blockFrom.dx,
              top: _G.blockFrom.dy,
              width: _G.blockSize.width,
              height: _G.blockSize.height,
              child: AnimatedBuilder(
                animation: Listenable.merge([b.controller, if (b.topple != null) b.topple!]),
                builder: (_, child) {
                  final f = b.frame();
                  return Opacity(
                    opacity: f.opacity,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translateByDouble(f.offset.dx, f.offset.dy, 0.0, 1.0)
                        ..rotateZ(_rad(f.rotation)),
                      child: child,
                    ),
                  );
                },
                child: Image.asset(_A.block, fit: BoxFit.fill),
              ),
            )),

        // Steam rising from the poured cup.
        if (_steamOn)
          Positioned(
            left: _G.cupSteam.dx - 20,
            top: _G.cupSteam.dy - 80,
            width: 60,
            height: 130,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _steam,
                builder: (_, _) => CustomPaint(painter: _SteamPainter(_steam.value)),
              ),
            ),
          ),

        // Tap targets.
        _hotspot(_G.dallahHotspot, 'صب القهوة', _startPour),
        _hotspot(_G.blocksHotspotA, 'العب بالمكعبات', _placeBlock),
        _hotspot(_G.blocksHotspotB, 'العب بالمكعبات', _placeBlock),
      ],
    );
  }

  Widget _hotspot(Rect r, String label, VoidCallback onTap) => Positioned.fromRect(
        rect: r,
        child: Semantics(
          button: true,
          label: label,
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap),
        ),
      );
}

// ---------------------------------------------------------------------------
// Blocks
// ---------------------------------------------------------------------------
class _BlockFrame {
  const _BlockFrame(this.offset, this.rotation, this.opacity);
  final Offset offset;
  final double rotation;
  final double opacity;
}

class _FlyingBlock {
  _FlyingBlock({required this.controller, required this.target, required this.tilt, required this.index});

  final AnimationController controller;
  final Offset target;
  final double tilt;
  final int index;
  AnimationController? topple;
  bool toppling = false;

  static const _flight = Cubic(0.45, 0, 0.25, 1);
  static const _fall = Cubic(0.5, 0, 0.75, 0);

  _BlockFrame frame() {
    final v = controller.value;
    Offset pos;
    double rot;
    double op = 1;
    if (v <= 0.7) {
      final u = _flight.transform((v / 0.7).clamp(0.0, 1.0));
      pos = Offset(target.dx * u, target.dy * u - math.sin(math.pi * u) * _G.blockArc);
      rot = tilt * u;
      op = u < 0.15 ? u / 0.15 : 1;
    } else {
      final w = Curves.easeOut.transform(((v - 0.7) / 0.3).clamp(0.0, 1.0));
      pos = Offset(target.dx, target.dy - 3 * math.sin(math.pi * w));
      rot = tilt * (1 - w);
    }
    final t = topple;
    if (t != null) {
      final u = _fall.transform(t.value.clamp(0.0, 1.0));
      final i = index.toDouble();
      pos += Offset((30 + i * 22) * u, (44 + i * 16) * u);
      rot = rot + (90 + i * 40) * u;
      op = t.value < 0.65 ? 1 : 1 - (t.value - 0.65) / 0.35;
    }
    return _BlockFrame(pos, rot, op.clamp(0.0, 1.0).toDouble());
  }

  void dispose() {
    controller.dispose();
    topple?.dispose();
  }
}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------
class _StreamPainter extends CustomPainter {
  _StreamPainter({required this.from, required this.to, required this.opacity});
  final Offset from;
  final Offset to;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final mid = Offset((from.dx + to.dx) / 2 - 2, (from.dy + to.dy) / 2);
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = _C.coffee.withValues(alpha: opacity.clamp(0.0, 1.0).toDouble())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_StreamPainter old) => old.from != from || old.opacity != opacity;
}

class _SteamPainter extends CustomPainter {
  _SteamPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // Origin of the wisps inside this 60 x 130 box.
    const origin = Offset(20, 80);
    const xs = [0.0, 9.0, -7.0];
    for (var i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1.0;
      final a = p < 0.25 ? p / 0.25 * 0.85 : 0.85 * (1 - (p - 0.25) / 0.75);
      final w = 12 * (1 + 0.8 * p);
      final c = origin + Offset(xs[i] + 8 * p + 6, -60 * p + 18);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: w, height: 36), const Radius.circular(10)),
        Paint()
          ..color = Colors.white.withValues(alpha: a * 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(_SteamPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Logo + button
// ---------------------------------------------------------------------------
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'لمّه',
            style: GoogleFonts.tajawal(fontSize: 72, fontWeight: FontWeight.w800, color: _C.red, height: 1),
          ),
          const SizedBox(height: 10),
          Text(
            'يلا نتلمّ',
            style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w500, color: _C.taglineBrown),
          ),
        ],
      ),
    );
  }
}
