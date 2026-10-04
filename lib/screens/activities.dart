import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

// ---- 18 activities menu
class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});
  @override
  Widget build(BuildContext context) {
    Widget item(String t, String s, IconData i, Color c, Widget page) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LCard(
            onTap: () => go(context, page),
            child: Row(children: [
              IconBubble(i, c, size: 50),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  Text(s, style: const TextStyle(color: C.inkSoft)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: C.inkSoft),
            ]),
          ),
        );
    return Scaffold(
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 120), children: [
        const TabHeader('Activities', 'What can we do together?'),
        const SizedBox(height: 12),
        item('Group games', 'Roulette, Sin Jim and more', Icons.casino_rounded, C.terracotta, const GamesPage()),
        item('Book club', 'A Thousand Splendid Suns', Icons.menu_book_rounded, C.teal, const BookClubPage()),
        item('Podcast club', 'Episode 12 · 3 of 6 listened', Icons.headphones_rounded, C.coral, const PodcastPage()),
        item('Talk topics', 'Conversation starters', Icons.forum_rounded, C.green, const TalkTopicsPage()),
        item('Outings', 'Places that suit the whole family', Icons.explore_rounded, C.mustard, const OutingsPage()),
      ]),
    );
  }
}

// ---- 19 games
class GamesPage extends StatelessWidget {
  const GamesPage({super.key});
  @override
  Widget build(BuildContext context) {
    Widget game(String t, String s, String time, Widget page) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
                Text(time, style: const TextStyle(color: C.inkSoft, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 2),
              Text(s, style: const TextStyle(color: C.inkSoft)),
              const SizedBox(height: 12),
              Btn('Start playing', color: C.navy, onTap: () => go(context, page)),
            ]),
          ),
        );
    return Page1('Games', [
      LCard(
        color: C.navy,
        onTap: () => go(context, const RoulettePage()),
        padding: const EdgeInsets.all(20),
        child: const Row(children: [
          Icon(Icons.casino_rounded, color: C.mustard, size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Roulette', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              Text('Who starts? Who takes the challenge?', style: TextStyle(color: Colors.white70)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      game('Talks with Aziz', 'Funny and surprising questions', '5–10 min', const AzizPage()),
      game('Sin Jim', 'Answer on behalf of someone', '10–15 min', const SinJimPage()),
      game('Thabbit', 'Hold the pose!', '5 min', const _SoonPage('Thabbit')),
      game('Shiddah', 'Fast-paced card game', '10 min', const _SoonPage('Shiddah')),
    ]);
  }
}

class _SoonPage extends StatelessWidget {
  final String name;
  const _SoonPage(this.name);
  @override
  Widget build(BuildContext context) => Page1(name, [
        const SizedBox(height: 80),
        const Center(child: Icon(Icons.construction_rounded, size: 56, color: C.sand)),
        const SizedBox(height: 14),
        const Center(child: Text('Coming soon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
      ]);
}

// ---- 20 Talks with Aziz
class AzizPage extends StatefulWidget {
  const AzizPage({super.key});
  @override
  State<AzizPage> createState() => _AzizPageState();
}

class _AzizPageState extends State<AzizPage> {
  int _i = 0;
  void _next() => setState(() => _i = (_i + 1) % azizQuestions.length);
  @override
  Widget build(BuildContext context) => Page1('Talks with Aziz', [
        LCard(
          color: C.terracotta,
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Text(azizQuestions[_i],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.35)),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Btn('Next', onTap: _next)),
          const SizedBox(width: 12),
          Expanded(child: Btn('Skip', outlined: true, color: C.inkSoft, onTap: _next)),
        ]),
      ]);
}

// ---- 21 Sin Jim
class SinJimPage extends StatefulWidget {
  const SinJimPage({super.key});
  @override
  State<SinJimPage> createState() => _SinJimPageState();
}

class _SinJimPageState extends State<SinJimPage> {
  int _i = 0;
  int _answered = 0;
  @override
  Widget build(BuildContext context) {
    final who = members[(_i + 1) % members.length];
    return Page1('Sin Jim', [
      LCard(
        padding: const EdgeInsets.all(22),
        child: Column(children: [
          const Text('Answer on behalf of', style: TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Avatar(who.name, size: 76),
          const SizedBox(height: 8),
          Text(who.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 18),
          Text('Q: ${sinJimQuestions[_i % sinJimQuestions.length]}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.4)),
        ]),
      ),
      const SizedBox(height: 14),
      Btn('Everyone answered', onTap: () => setState(() {
            _i++;
            _answered++;
          })),
      const SizedBox(height: 10),
      Center(
          child: Text('$_answered answers recorded',
              style: const TextStyle(color: C.inkSoft, fontSize: 12, fontWeight: FontWeight.w600))),
    ]);
  }
}

// ---- 22 roulette
class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key});
  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> with SingleTickerProviderStateMixin {
  static final _modes = <String, List<String>>{
    'Who starts?': [for (final m in members) m.name],
    'Challenge': ['Tell a joke', 'Sing a line', 'Imitate someone', 'Dance 10 sec', 'Tell a secret', 'Draw in 10 sec'],
    'Decision': ['Stay home', 'Go out', 'Cook', 'Order food', 'Watch a movie', 'Play games'],
  };
  static const _colors = [C.terracotta, C.navy, C.coral, C.mustard, C.teal, C.green];

  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));
  String _mode = 'Who starts?';
  double _from = 0, _to = 0;
  int? _result;
  final _rng = math.Random();

  List<String> get _items => _modes[_mode]!;

  void _spin() {
    final n = _items.length;
    final seg = 2 * math.pi / n;
    final pick = _rng.nextInt(n);
    // rotate so the picked segment's center ends under the top pointer
    final target = (2 * math.pi - (pick + .5) * seg) % (2 * math.pi);
    _from = _to % (2 * math.pi);
    _to = _from + 5 * 2 * math.pi + ((target - _from) % (2 * math.pi));
    _result = null;
    _ctrl.forward(from: 0).whenComplete(() => setState(() => _result = pick));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Page1('Roulette', [
        Wrap(spacing: 8, children: [
          for (final m in _modes.keys)
            Choice(m, _mode == m, () {
              if (_ctrl.isAnimating) return;
              setState(() {
                _mode = m;
                _result = null;
                _from = _to = 0;
              });
            }),
        ]),
        const SizedBox(height: 18),
        Center(
          child: SizedBox(
            width: 280,
            height: 300,
            child: Stack(alignment: Alignment.bottomCenter, children: [
              Positioned(
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, _) {
                    final t = Curves.easeOutCubic.transform(_ctrl.value);
                    return Transform.rotate(
                      angle: _ctrl.isAnimating || _ctrl.isCompleted ? _from + (_to - _from) * t : _to,
                      child: CustomPaint(
                          size: const Size(280, 280),
                          painter: _WheelPainter(_items, _colors)),
                    );
                  },
                ),
              ),
              const Positioned(
                  top: 0, child: Icon(Icons.arrow_drop_down_rounded, size: 48, color: C.ink)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
              _result == null
                  ? ' '
                  : _mode == 'Who starts?'
                      ? '${_items[_result!]} starts!'
                      : _items[_result!],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: C.terracotta)),
        ),
      ], bottom: Btn('Spin the wheel', icon: Icons.casino_rounded, onTap: () {
        if (!_ctrl.isAnimating) _spin();
      }));
}

class _WheelPainter extends CustomPainter {
  final List<String> items;
  final List<Color> colors;
  _WheelPainter(this.items, this.colors);
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final seg = 2 * math.pi / items.length;
    for (var i = 0; i < items.length; i++) {
      final start = -math.pi / 2 + i * seg;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, seg, true,
          Paint()..color = colors[i % colors.length]);
      final mid = start + seg / 2;
      final tp = TextPainter(
        text: TextSpan(
            text: items[i],
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: r * .55);
      canvas.save();
      canvas.translate(c.dx + math.cos(mid) * r * .62, c.dy + math.sin(mid) * r * .62);
      canvas.rotate(mid + math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
    canvas.drawCircle(c, 16, Paint()..color = C.cream);
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.items != items;
}

// ---- 23 book club
class BookClubPage extends StatelessWidget {
  const BookClubPage({super.key});
  @override
  Widget build(BuildContext context) => Page1('Book club', [
        LCard(
          child: Row(children: [
            Container(
              width: 74,
              height: 100,
              decoration: BoxDecoration(color: C.terracotta, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current book', style: TextStyle(color: C.inkSoft, fontSize: 12, fontWeight: FontWeight.w700)),
                Text('A Thousand Splendid Suns',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                SizedBox(height: 2),
                Text('3 of 6 reading · discussion on Thursday',
                    style: TextStyle(color: C.inkSoft, fontSize: 12)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const Bar(.5),
        const SizedBox(height: 14),
        Btn('Join the discussion', onTap: () {}),
        const SectionTitle('Discussion questions'),
        for (final q in ['Which character are you closest to?', 'If the ending changed, what would it be?'])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LCard(child: Text(q, style: const TextStyle(fontWeight: FontWeight.w700))),
          ),
      ]);
}

// ---- 09 podcast club / weekly podcast
class PodcastPage extends StatefulWidget {
  const PodcastPage({super.key});
  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  bool _listened = false;
  @override
  Widget build(BuildContext context) {
    final count = 3 + (_listened ? 1 : 0);
    return Page1('Podcast club', [
      LCard(
        color: C.navy,
        padding: const EdgeInsets.all(22),
        child: Column(children: [
          const Text("This week's episode", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('What makes us laugh together?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const Text('32 min', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => setState(() => _listened = true),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: C.terracotta,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12)),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start listening', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      LCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Listened', style: TextStyle(fontWeight: FontWeight.w800))),
            Text('$count/6', style: const TextStyle(fontWeight: FontWeight.w900, color: C.terracotta)),
          ]),
          const SizedBox(height: 10),
          Bar(count / 6),
          const SizedBox(height: 10),
          const Text('Next gathering: Friday after dinner. We will all talk about it.',
              style: TextStyle(color: C.inkSoft, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
      const SectionTitle('Discussion questions'),
      for (final q in ['When did we last laugh until we cried?', 'Who in the family tells the best jokes?'])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LCard(child: Text(q, style: const TextStyle(fontWeight: FontWeight.w700))),
        ),
    ]);
  }
}

// ---- 24/25 talk topics
class TalkTopicsPage extends StatefulWidget {
  const TalkTopicsPage({super.key});
  @override
  State<TalkTopicsPage> createState() => _TalkTopicsPageState();
}

class _TalkTopicsPageState extends State<TalkTopicsPage> {
  int _i = 0;
  @override
  Widget build(BuildContext context) => Page1('Talk topics', [
        LCard(
          color: C.terracotta,
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Text(topics[_i],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, height: 1.35)),
          ),
        ),
        const SizedBox(height: 14),
        Btn('Give me a topic', icon: Icons.shuffle_rounded, color: C.navy,
            onTap: () => setState(() => _i = (_i + 1) % topics.length)),
        const SectionTitle('Trending now'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in ['Best Ramadan memory', "Mom's favorite dish"])
            ActionChip(
              label: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
              backgroundColor: C.card,
              side: const BorderSide(color: C.sand),
              onPressed: () {},
            ),
        ]),
      ]);
}

// ---- 26 outings
class OutingsPage extends StatefulWidget {
  const OutingsPage({super.key});
  @override
  State<OutingsPage> createState() => _OutingsPageState();
}

class _OutingsPageState extends State<OutingsPage> {
  String _f = 'All';
  @override
  Widget build(BuildContext context) {
    final list = places.where((p) => _f == 'All' || p.type == _f).toList();
    return Page1('Outings', [
      SizedBox(
        height: 44,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (final f in ['All', 'Restaurants', 'Cafés', 'Nature', 'Entertainment'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Choice(f, _f == f, () => setState(() => _f = f)),
            ),
        ]),
      ),
      const SizedBox(height: 14),
      Container(
        height: 130,
        decoration: BoxDecoration(color: C.tealTint, borderRadius: BorderRadius.circular(24)),
        child: const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.map_rounded, color: C.teal, size: 34),
          SizedBox(height: 6),
          Text('Places map', style: TextStyle(color: C.teal, fontWeight: FontWeight.w800)),
        ])),
      ),
      const SizedBox(height: 14),
      for (final p in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LCard(
            onTap: () => go(context, SuggestPlacePage(p)),
            child: Row(children: [
              IconBubble(p.icon, p.color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(p.why, style: const TextStyle(color: C.inkSoft, fontSize: 12)),
                ]),
              ),
            ]),
          ),
        ),
      const SizedBox(height: 6),
      Btn('Our outings', outlined: true, color: C.navy, onTap: () => go(context, const OurOutingsPage())),
    ]);
  }
}

// ---- 27 suggested place
class SuggestPlacePage extends StatelessWidget {
  final Place p;
  const SuggestPlacePage(this.p, {super.key});
  @override
  Widget build(BuildContext context) => Page1('Suggestion for the family', [
        LCard(
          color: C.terracotta,
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Center(
              child: Text(p.name,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 12),
        LCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Why we suggested it', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(p.why, style: const TextStyle(color: C.inkSoft, height: 1.4)),
          ]),
        ),
      ],
          bottom: Btn('Add to "Our outings"', icon: Icons.add_rounded, onTap: () {
            if (!ourOutings.contains(p)) ourOutings.add(p);
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Added to Our outings')));
          }));
}

// ---- our outings
class OurOutingsPage extends StatelessWidget {
  const OurOutingsPage({super.key});
  @override
  Widget build(BuildContext context) => Page1('Our outings', [
        if (ourOutings.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(
                child: Text('Nothing here yet.\nAdd a place from Outings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: C.inkSoft, fontWeight: FontWeight.w600, height: 1.5))),
          ),
        for (final p in ourOutings)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LCard(
              child: Row(children: [
                IconBubble(p.icon, p.color),
                const SizedBox(width: 14),
                Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
              ]),
            ),
          ),
      ]);
}
