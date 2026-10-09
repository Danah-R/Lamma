import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data.dart';
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
import '../theme.dart';
import '../widgets.dart';

// ---- 18 activities menu
class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
      body: ListView(padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 120), children: [
        TabHeader(l.activitiesTitle, l.activitiesSubtitle),
        const SizedBox(height: 12),
        item(l.activitiesGroupGamesTitle, l.activitiesGroupGamesDesc, Icons.casino_rounded, C.terracotta, const GamesPage()),
        item(l.activitiesBookClubTitle, l.activitiesBookClubDesc, Icons.menu_book_rounded, C.teal, const BookClubPage()),
        item(l.activitiesPodcastClubTitle, l.activitiesPodcastDesc, Icons.headphones_rounded, C.coral, const PodcastPage()),
        item(l.activitiesTalkTopicsTitle, l.activitiesTalkTopicsDesc, Icons.forum_rounded, C.green, const TalkTopicsPage()),
        item(l.activitiesOutingsTitle, l.activitiesOutingsDesc, Icons.explore_rounded, C.mustard, const OutingsPage()),
      ]),
    );
  }
}

// ---- 19 games
class GamesPage extends StatelessWidget {
  const GamesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
              Btn(l.gamesStartPlaying, color: C.navy, onTap: () => go(context, page)),
            ]),
          ),
        );
    return Page1(l.gamesTitle, [
      LCard(
        color: C.navy,
        onTap: () => go(context, const RoulettePage()),
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          const Icon(Icons.casino_rounded, color: C.mustard, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.gamesRouletteTitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              Text(l.gamesRouletteDesc, style: const TextStyle(color: Colors.white70)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      game(l.gamesAzizTitle, l.gamesAzizDesc, l.gamesTimeRange5to10, const AzizPage()),
      game(l.gamesSinJimTitle, l.gamesSinJimDesc, l.gamesTimeRange10to15, const SinJimPage()),
      game(l.gamesThabbitTitle, l.gamesThabbitDesc, l.gamesTime5min, _SoonPage(l.gamesThabbitTitle)),
      game(l.gamesShiddahTitle, l.gamesShiddahDesc, l.gamesTime10min, _SoonPage(l.gamesShiddahTitle)),
    ]);
  }
}

class _SoonPage extends StatelessWidget {
  final String name;
  const _SoonPage(this.name);
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(name, [
        const SizedBox(height: 80),
        const Center(child: Icon(Icons.construction_rounded, size: 56, color: C.sand)),
        const SizedBox(height: 14),
        Center(child: Text(l.soonPageMessage, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
      ]);
  }
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
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(l.gamesAzizTitle, [
        LCard(
          color: C.terracotta,
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Text(ld(context, azizQuestions[_i]),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.35)),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Btn(l.azizNext, onTap: _next)),
          const SizedBox(width: 12),
          Expanded(child: Btn(l.azizSkip, outlined: true, color: C.inkSoft, onTap: _next)),
        ]),
      ]);
  }
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
    final l = AppLocalizations.of(context);
    final who = members[(_i + 1) % members.length];
    return Page1(l.gamesSinJimTitle, [
      LCard(
        padding: const EdgeInsets.all(22),
        child: Column(children: [
          Text(l.sinJimAnswerOnBehalf, style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Avatar(who.name, size: 76),
          const SizedBox(height: 8),
          Text(ld(context, who.name), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 18),
          Text('${l.sinJimQPrefix} ${ld(context, sinJimQuestions[_i % sinJimQuestions.length])}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.4)),
        ]),
      ),
      const SizedBox(height: 14),
      Btn(l.sinJimEveryoneAnswered, onTap: () => setState(() {
            _i++;
            _answered++;
          })),
      const SizedBox(height: 10),
      Center(
          child: Text(l.sinJimAnswersRecorded(_answered),
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
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final direction = Directionality.of(context);
    final displayItems = _items.map((e) => ld(context, e)).toList();
    return Page1(l.gamesRouletteTitle, [
        Wrap(spacing: 8, children: [
          for (final m in _modes.keys)
            Choice(ld(context, m), _mode == m, () {
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
                          painter: _WheelPainter(displayItems, _colors, direction)),
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
                      ? l.rouletteResultStarts(ld(context, _items[_result!]))
                      : ld(context, _items[_result!]),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: C.terracotta)),
        ),
      ], bottom: Btn(l.rouletteSpin, icon: Icons.casino_rounded, onTap: () {
        if (!_ctrl.isAnimating) _spin();
      }));
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> items;
  final List<Color> colors;
  final TextDirection textDirection;
  _WheelPainter(this.items, this.colors, this.textDirection);
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
        textDirection: textDirection,
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
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(l.activitiesBookClubTitle, [
        LCard(
          child: Row(children: [
            Container(
              width: 74,
              height: 100,
              decoration: BoxDecoration(color: C.terracotta, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.bookClubCurrentBook, style: const TextStyle(color: C.inkSoft, fontSize: 12, fontWeight: FontWeight.w700)),
                Text(l.activitiesBookClubDesc,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(l.bookClubReadingStatus,
                    style: const TextStyle(color: C.inkSoft, fontSize: 12)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const Bar(.5),
        const SizedBox(height: 14),
        Btn(l.bookClubJoinDiscussion, onTap: () {}),
        SectionTitle(l.discussionQuestionsHeading),
        for (final q in [l.bookClubQ1, l.bookClubQ2])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LCard(child: Text(q, style: const TextStyle(fontWeight: FontWeight.w700))),
          ),
      ]);
  }
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
    final l = AppLocalizations.of(context);
    final count = 3 + (_listened ? 1 : 0);
    return Page1(l.activitiesPodcastClubTitle, [
      LCard(
        color: C.navy,
        padding: const EdgeInsets.all(22),
        child: Column(children: [
          Text(l.podcastThisWeekEpisode, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(l.homePodcastTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(l.podcastDuration, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => setState(() => _listened = true),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: C.terracotta,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12)),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l.homeStartListening, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      LCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(l.podcastListenedLabel, style: const TextStyle(fontWeight: FontWeight.w800))),
            Text(l.podcastListenedFraction(count), style: const TextStyle(fontWeight: FontWeight.w900, color: C.terracotta)),
          ]),
          const SizedBox(height: 10),
          Bar(count / 6),
          const SizedBox(height: 10),
          Text(l.podcastNextGathering,
              style: const TextStyle(color: C.inkSoft, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
      SectionTitle(l.discussionQuestionsHeading),
      for (final q in [l.podcastQ1, l.podcastQ2])
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
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(l.activitiesTalkTopicsTitle, [
        LCard(
          color: C.terracotta,
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Text(ld(context, topics[_i]),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, height: 1.35)),
          ),
        ),
        const SizedBox(height: 14),
        Btn(l.talkTopicsGiveMeTopic, icon: Icons.shuffle_rounded, color: C.navy,
            onTap: () => setState(() => _i = (_i + 1) % topics.length)),
        SectionTitle(l.talkTopicsTrendingNow),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in [l.talkTopicsTrend1, l.talkTopicsTrend2])
            ActionChip(
              label: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
              backgroundColor: C.card,
              side: const BorderSide(color: C.sand),
              onPressed: () {},
            ),
        ]),
      ]);
  }
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
    final l = AppLocalizations.of(context);
    final list = places.where((p) => _f == 'All' || p.type == _f).toList();
    return Page1(l.activitiesOutingsTitle, [
      SizedBox(
        height: 44,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (final f in ['All', 'Restaurants', 'Cafés', 'Nature', 'Entertainment'])
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Choice(f == 'All' ? l.outingsFilterAll : ld(context, f), _f == f, () => setState(() => _f = f)),
            ),
        ]),
      ),
      const SizedBox(height: 14),
      Container(
        height: 130,
        decoration: BoxDecoration(color: C.tealTint, borderRadius: BorderRadius.circular(24)),
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.map_rounded, color: C.teal, size: 34),
          const SizedBox(height: 6),
          Text(l.outingsPlacesMap, style: const TextStyle(color: C.teal, fontWeight: FontWeight.w800)),
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
                  Text(ld(context, p.name), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(ld(context, p.why), style: const TextStyle(color: C.inkSoft, fontSize: 12)),
                ]),
              ),
            ]),
          ),
        ),
      const SizedBox(height: 6),
      Btn(l.outingsOurOutings, outlined: true, color: C.navy, onTap: () => go(context, const OurOutingsPage())),
    ]);
  }
}

// ---- 27 suggested place
class SuggestPlacePage extends StatelessWidget {
  final Place p;
  const SuggestPlacePage(this.p, {super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(l.suggestPlaceTitle, [
        LCard(
          color: C.terracotta,
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Center(
              child: Text(ld(context, p.name),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 12),
        LCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.suggestPlaceWhyHeading, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(ld(context, p.why), style: const TextStyle(color: C.inkSoft, height: 1.4)),
          ]),
        ),
      ],
          bottom: Btn(l.suggestPlaceAdd, icon: Icons.add_rounded, onTap: () {
            if (!ourOutings.contains(p)) ourOutings.add(p);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(l.suggestPlaceAddedSnackbar)));
          }));
  }
}

// ---- our outings
class OurOutingsPage extends StatelessWidget {
  const OurOutingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(l.outingsOurOutings, [
        if (ourOutings.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
                child: Text(l.ourOutingsEmpty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w600, height: 1.5))),
          ),
        for (final p in ourOutings)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LCard(
              child: Row(children: [
                IconBubble(p.icon, p.color),
                const SizedBox(width: 14),
                Expanded(child: Text(ld(context, p.name), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
              ]),
            ),
          ),
      ]);
  }
}
