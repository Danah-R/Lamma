import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../backend/backend.dart';
import '../data.dart';
import '../widgets/notification_bell.dart';
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
import '../theme.dart';
import '../features/games/games_controller.dart';
import '../features/outings/outing_controller.dart';
import '../widgets/photo_or_painted.dart';
import '../widgets.dart';
import '../widgets/podcast_listen.dart';
import '../features/clubs/clubs_controller.dart';
import '../features/clubs/clubs_screen.dart';
import '../features/topics/topics_controller.dart';
import '../features/topics/topics_screen.dart';
import '../widgets/topic_deck_card.dart';
import 'activities_colors.dart';
import 'home.dart' show AddEventPage;
import 'activities_data.dart';
import '../features/games/charades/charades_screen.dart';
import '../features/games/seen_jeem/seen_jeem_screen.dart';
import '../features/games/who_am_i/who_am_i_screen.dart';
import 'game_illustrations.dart';
import 'games_data.dart';

// ---- 18 activity box
class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  // space the floating tab bar occupies
  static const _bottomInset = 104.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, _bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ActivitiesHeader(),
            const SizedBox(height: 22),
            Builder(
              builder: (context) {
                // "Tonight's topic" reads from the shared topics controller.
                final topics = context.watch<TopicsController>();
                final tonight = topics.tonightTopics;
                return TopicDeckCard(
                  topics: [for (final t in tonight) t.text],
                  onStart: (text) {
                    final t = tonight.firstWhere((x) => x.text == text);
                    context.read<TopicsController>().openTopic(t.id);
                    go(context, const TopicsScreen());
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            GamesSection(
              onSeeAll: () => go(context, const GamesPage()),
              onRoulette: () => go(context, const RoulettePage()),
              onSinJim: () => goGame(context, const SeenJeemScreen()),
              onCharades: () => goGame(context, const CharadesScreen()),
              onWhoAmI: () => goGame(context, const WhoAmIScreen()),
            ),
            const SizedBox(height: 32),
            ClubsSection(
              onSeeAll: () =>
                  go(context, const ClubsScreen(initialTab: ClubsTab.book)),
              onBookClub: () =>
                  go(context, const ClubsScreen(initialTab: ClubsTab.book)),
              onPodcast: () =>
                  go(context, const ClubsScreen(initialTab: ClubsTab.podcast)),
            ),
            const SizedBox(height: 32),
            const WeekendOutingCard(),
          ],
        ),
      ),
    );
  }
}

class _ActivitiesHeader extends StatelessWidget {
  const _ActivitiesHeader();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.navActivities,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AC.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.activitiesSubtitle,
                style: const TextStyle(fontSize: 15, color: AC.muted),
              ),
            ],
          ),
        ),
        const NotificationBell(),
      ],
    );
  }
}

/// Small active/inactive dot indicator, shared by the topic deck and the
/// weekend-outing slider.
class _DotsRow extends StatelessWidget {
  final int count;
  final int activeIndex;
  const _DotsRow({required this.count, required this.activeIndex});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < count; i++) ...[
        if (i != 0) const SizedBox(width: 5),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: i == activeIndex ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == activeIndex ? AC.brick : AC.dotInactive,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    ],
  );
}

/// "ألعاب جماعية": section header, the full-width roulette card, and the
/// Sin Jim / Letters-with-Aziz tile grid.
class GamesSection extends StatelessWidget {
  final VoidCallback onSeeAll, onRoulette, onSinJim, onCharades, onWhoAmI;
  const GamesSection({
    super.key,
    required this.onSeeAll,
    required this.onRoulette,
    required this.onSinJim,
    required this.onCharades,
    required this.onWhoAmI,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: l.activitiesGroupGamesTitle,
          action: l.homeLeaderboardSeeAll,
          onAction: onSeeAll,
        ),
        const SizedBox(height: 14),
        _RouletteCard(onTap: onRoulette),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _GameTile(
                image: 'assets/games/sin_jim.png',
                title: l.gamesSinJimTitle,
                onTap: onSinJim,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _GameTile(
                image: 'assets/games/charades.webp',
                title: l.gamesCharadesTitle,
                onTap: onCharades,
              ),
            ),
            const SizedBox(width: 10),
            // no picture for this one yet: its own drawing on a soft background
            Expanded(
              child: _GameTile(
                image: 'assets/games/whoami.jpg',
                title: l.gamesWhoAmITitle,
                onTap: onWhoAmI,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RouletteCard extends StatelessWidget {
  final VoidCallback onTap;
  const _RouletteCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: AC.salmonTint,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const SizedBox(
                width: 86,
                height: 86,
                child: CustomPaint(painter: _MiniWheelPainter()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.activitiesRouletteBadge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AC.brickDeep,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.gamesRouletteTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AC.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.activitiesRouletteCardDesc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: AC.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AC.brick,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A group game shown as just its picture.
class _GameTile extends StatelessWidget {
  final String image, title;
  final VoidCallback onTap;
  const _GameTile({
    required this.image,
    required this.title,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: title,
    child: AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: AC.card,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink.image(image: AssetImage(image), fit: BoxFit.cover),
        ),
      ),
    ),
  );
}

/// Decorative six-slice wheel icon on the roulette card. Purely cosmetic —
/// not the real spinning wheel, see [_WheelPainter] on [RoulettePage].
class _MiniWheelPainter extends CustomPainter {
  const _MiniWheelPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    const colors = [AC.brick, AC.navy, AC.salmon, AC.mustard, AC.teal, AC.sage];
    final seg = 2 * math.pi / colors.length;
    for (var i = 0; i < colors.length; i++) {
      final start = -math.pi / 2 + i * seg;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        seg,
        true,
        Paint()..color = colors[i],
      );
    }
    canvas.drawCircle(
      c,
      r - 1.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(c, r * .18, Paint()..color = AC.background);
    final pointer = Path()
      ..moveTo(c.dx - r * .12, 0)
      ..lineTo(c.dx + r * .12, 0)
      ..lineTo(c.dx, r * .12)
      ..close();
    canvas.drawPath(pointer, Paint()..color = AC.ink);
  }

  @override
  bool shouldRepaint(covariant _MiniWheelPainter oldDelegate) => false;
}

/// "النوادي": book club and podcast club progress cards.
class ClubsSection extends StatelessWidget {
  final VoidCallback onSeeAll, onBookClub, onPodcast;
  const ClubsSection({
    super.key,
    required this.onSeeAll,
    required this.onBookClub,
    required this.onPodcast,
  });
  Future<void> _openEpisode(BuildContext context, String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.soonPageMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final clubs = context.watch<ClubsController>();

    final finishedReaders = clubs.bookMembers
        .where((m) => m.percent >= 100)
        .take(3)
        .toList();
    final myBookDone = clubs.myBookProgress >= 1;
    final allBookDone = clubs.finishedCount == clubs.memberCount;
    final String bookBold, bookRest;
    if (allBookDone) {
      bookBold = l.clubsBookAllDoneBold;
      bookRest = l.clubsBookAllDoneRest(clubs.bookDiscussion.dayName);
    } else if (myBookDone) {
      bookBold = l.clubsBookDoneWaitingBold;
      bookRest = l.clubsBookDoneWaitingRest(
        clubs.memberCount - clubs.finishedCount,
      );
    } else {
      bookBold = l.activitiesClubCatchUpBold;
      bookRest = l.activitiesClubFinishedCount(clubs.finishedCount);
    }

    final String podBold, podRest;
    if (clubs.iHeard) {
      podBold = l.clubsPodcastHeardBold;
      podRest = l.clubsPodcastHeardRest(
        clubs.podDiscussion.dayName,
        clubs.podDiscussion.time,
      );
    } else {
      podBold = l.activitiesPodcastYourTurnBold;
      podRest = l.clubsPodcastYourTurnRest(
        clubs.heardCount,
        clubs.memberCount,
        clubs.podDiscussion.dayName,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: l.activitiesClubsSection,
          action: l.homeLeaderboardSeeAll,
          onAction: onSeeAll,
        ),
        const SizedBox(height: 14),
        ClubCard(
          iconBg: AC.salmonTint,
          iconColor: AC.brick,
          icon: Icons.menu_book_outlined,
          label: l.activitiesBookClubTitle,
          title: clubs.currentBook.title,
          progress: clubs.groupProgress,
          progressColor: AC.brick,
          captionBold: bookBold,
          captionBoldColor: AC.brick,
          captionRest: bookRest,
          peopleNames: [
            for (final m in clubs.bookMembers)
              if (m.percent >= 100) m.name,
          ],
          topRight: _Badge(l.activitiesBookClubDaysLeft(clubs.daysLeft)),
          bottomTrailing: finishedReaders.isEmpty
              ? null
              : _AvatarStack(names: [for (final r in finishedReaders) r.name]),
          onTap: onBookClub,
        ),
        const SizedBox(height: 12),
        ClubCard(
          iconBg: AC.tealTint,
          iconColor: AC.teal,
          icon: Icons.headphones_outlined,
          label: l.clubsPodcastClubLabel(clubs.currentEpisode.host),
          title: clubs.currentEpisode.title,
          progress: clubs.heardCount / clubs.memberCount,
          progressColor: AC.teal,
          captionBold: podBold,
          captionBoldColor: AC.teal,
          captionRest: podRest,
          peopleNames: [
            for (final r in clubs.heardBy) r.name,
            if (clubs.iHeard) profile.name,
          ],
          topRight: _RoundIconButton(
            background: Colors.transparent,
            iconColor: AC.teal,
            icon: Icons.play_arrow_rounded,
            tooltip: l.activitiesPlayPodcastTooltip,
            onTap: () => _openEpisode(context, clubs.currentEpisode.youtubeUrl),
          ),
          onTap: onPodcast,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AC.background,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AC.muted,
      ),
    ),
  );
}

class ClubCard extends StatefulWidget {
  final Color iconBg, iconColor, progressColor, captionBoldColor;
  final IconData icon;
  final String label, title, captionBold, captionRest;
  final double progress;
  final Widget topRight;
  final Widget? bottomTrailing;

  /// The people behind the caption (who finished / who listened): tapping the caption row opens
  /// their list right inside the card.
  final List<String> peopleNames;
  final VoidCallback onTap;
  const ClubCard({
    super.key,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.title,
    required this.progress,
    required this.progressColor,
    required this.captionBold,
    required this.captionBoldColor,
    required this.captionRest,
    required this.topRight,
    this.bottomTrailing,
    this.peopleNames = const [],
    required this.onTap,
  });
  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> {
  bool _open = false;
  @override
  Widget build(BuildContext context) => Material(
    color: AC.card,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(widget.icon, color: widget.iconColor, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.iconColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AC.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                widget.topRight,
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.progress,
                minHeight: 8,
                color: widget.progressColor,
                backgroundColor: AC.track,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.peopleNames.isEmpty
                  ? null
                  : () => setState(() => _open = !_open),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 13, color: AC.muted),
                        children: [
                          TextSpan(
                            text: widget.captionBold,
                            style: TextStyle(
                              color: widget.captionBoldColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: ' $widget.captionRest'),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ?widget.bottomTrailing,
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _open && widget.peopleNames.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: PeopleList(widget.peopleNames),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AvatarStack extends StatelessWidget {
  final List<String> names;
  static const _size = 24.0;
  static const _overlap = 8.0;
  const _AvatarStack({required this.names});
  @override
  Widget build(BuildContext context) {
    final n = names.length;
    return SizedBox(
      width: n == 0 ? 0 : (n - 1) * (_size - _overlap) + _size,
      height: _size,
      child: Stack(
        children: [
          for (var i = 0; i < n; i++)
            PositionedDirectional(
              start: i * (_size - _overlap),
              child: Avatar(names[i], size: _size), // real profile picture
            ),
        ],
      ),
    );
  }
}

/// Generic icon-only round button used for the header bell, the podcast
/// play button, and the weekend-outing prev/next arrows.
class _RoundIconButton extends StatelessWidget {
  final Color background;
  final Color iconColor;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _RoundIconButton({
    required this.background,
    required this.iconColor,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: tooltip,
    child: Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
      ),
    ),
  );
}

/// Filled or outlined pill button (height 48, radius 14) matching the
/// reference design's button style, used across this page's cards.
class _PillButton extends StatelessWidget {
  final String label;
  final Color background, foreground;
  final IconData? icon;
  final VoidCallback? onTap;
  const _PillButton({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final text = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
    final iconWidget = icon == null
        ? null
        : Icon(icon, size: 18, color: foreground);
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: iconWidget == null
                ? [text]
                : [iconWidget, const SizedBox(width: 8), text],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeading({required this.title, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AC.ink,
          ),
        ),
      ),
      if (action != null)
        onAction != null
            ? Semantics(
                button: true,
                child: InkWell(
                  onTap: onAction,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    child: Text(
                      action!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AC.brick,
                      ),
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                child: Text(
                  action!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AC.brick,
                  ),
                ),
              ),
    ],
  );
}

/// "طلعة الويكند": a sliding PageView of candidate places, with prev/next
/// buttons (animateToPage) and swipe, plus a dot indicator below.
class WeekendOutingCard extends StatefulWidget {
  const WeekendOutingCard({super.key});
  @override
  State<WeekendOutingCard> createState() => _WeekendOutingCardState();
}

class _WeekendOutingCardState extends State<WeekendOutingCard> {
  bool _votersOpen =
      false; // the list of who voted is open (the cards grow to fit it)
  late final PageController _pageCtrl = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final n = _places(AppLocalizations.of(context)).length;
    _pageCtrl.animateToPage(
      (_index + delta + n) % n,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleVote(int i) => context.read<OutingController>().toggleVote(i);

  /// The built-in places, then the ones the family suggested.
  List<WeekendPlace> _places(AppLocalizations l) => [
    ...weekendPlaces,
    for (final name in suggestedOutings)
      WeekendPlace(
        name: name,
        tag: l.activitiesSuggestedByFamily,
        baseVotes: 0,
        scene: OutingScene.park,
        sky: AC.sageTint,
        barColor: AC.sage,
        imagePath:
            'assets/images/outings/none.jpg', // no photo: the drawn scene shows
        mapsQuery: name,
      ),
  ];

  /// A small sheet to suggest a new outing; it joins the list for the whole family.
  Future<void> _addOuting() async {
    final l = AppLocalizations.of(context);
    final ctl = TextEditingController();
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          20 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.activitiesAddOuting,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: C.navy,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctl,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (v) => Navigator.pop(ctx, v),
                    decoration: InputDecoration(
                      hintText: l.activitiesOutingName,
                      filled: true,
                      fillColor: C.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, ctl.text),
                  style: FilledButton.styleFrom(
                    backgroundColor: C.brick,
                    minimumSize: const Size(76, 52),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    l.activitiesOutingAdd,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    final v = name?.trim() ?? '';
    if (v.isEmpty || !mounted) return;
    context.read<OutingController>().suggest(v);
    setState(() {
      suggestedOutings = [...suggestedOutings, v];
    });
    if (sharedLive) Backend.addOuting(v);
  }

  /// Opens the add-event page with this outing filled in, so the date, time and details can be chosen
  /// before it goes in the family calendar on the Home page.
  Future<void> _addToCalendar(WeekendPlace place) async {
    await go(
      context,
      AddEventPage(initialName: place.name, initialType: 'Outing'),
    );
    sharedTick.value++; // so the Home page redraws its calendar
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final places = _places(l);
    final n = places.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.activitiesWeekendOutingTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AC.ink,
                ),
              ),
            ),
            _RoundIconButton(
              background: Colors.transparent,
              iconColor: AC.ink,
              icon: Icons.arrow_back_rounded,
              tooltip: l.activitiesPrevPlace,
              onTap: () => _go(-1),
            ),
            const SizedBox(width: 4),
            _RoundIconButton(
              background: Colors.transparent,
              iconColor: AC.brick,
              icon: Icons.arrow_forward_rounded,
              tooltip: l.activitiesNextPlace,
              onTap: () => _go(1),
            ),
            // add an outing
            _RoundIconButton(
              background: Colors.transparent,
              iconColor: AC.ink,
              icon: Icons.add_rounded,
              tooltip: l.activitiesAddOuting,
              onTap: _addOuting,
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: _votersOpen ? 372 + 40.0 * (3).clamp(1, 6) : 372,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: n,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final place = places[i];
              final voted = context.watch<OutingController>().hasVoted(i);
              final votes = place.baseVotes + (voted ? 1 : 0);
              return _PlaceCard(
                place: place,
                votes: votes,
                voted: voted,
                onToggleVote: () => _toggleVote(i),
                onAddToCalendar: () => _addToCalendar(place),
                votersOpen: _votersOpen,
                onToggleVoters: () =>
                    setState(() => _votersOpen = !_votersOpen),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: _DotsRow(count: n, activeIndex: _index),
        ),
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final WeekendPlace place;
  final int votes;
  final bool voted;
  final VoidCallback onToggleVote;
  final VoidCallback onAddToCalendar;
  final bool votersOpen;
  final VoidCallback onToggleVoters;
  const _PlaceCard({
    required this.place,
    required this.votes,
    required this.voted,
    required this.onToggleVote,
    required this.onAddToCalendar,
    required this.votersOpen,
    required this.onToggleVoters,
  });

  /// Opens the place in Google Maps (the app if it is installed, otherwise the website).
  Future<void> _openMaps(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final url = Uri.parse(
      place.mapsUrl ??
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeQueryComponent(place.mapsQuery)}',
    );
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(l.soonPageMessage)));
  }

  /// 2000 -> "2K", 64000 -> "64K" (Google shows rating counts this way).
  String _compactCount(int n) => n >= 1000 ? '${(n / 1000).round()}K' : '$n';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AC.card,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _openMaps(context),
            child: SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PhotoOrPainted(
                    assetPath: place.imagePath,
                    fallback: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: place.sky),
                        CustomPaint(painter: _scenePainterFor(place.scene)),
                      ],
                    ),
                  ),
                  // a map pin: the card opens Google Maps
                  PositionedDirectional(
                    end: 12,
                    top: 12,
                    child: Semantics(
                      label: l.activitiesOpenInMaps,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AC.card,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AC.brick,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AC.card,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        place.tag,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AC.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openMaps(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AC.ink,
                        ),
                      ),
                      // the place's Google Maps rating (stars, and how many people rated it)
                      if (place.rating != null) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF2B01E),
                              size: 18,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AC.ink,
                              ),
                            ),
                            if (place.ratingCount != null)
                              Text(
                                '  (${_compactCount(place.ratingCount!)})',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AC.muted,
                                ),
                              ),
                            Text(
                              '  ·  ${l.activitiesGoogleMapsRating}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AC.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.activitiesWeekendVoteText(votes),
                  style: const TextStyle(fontSize: 14, color: AC.muted),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: (votes / 6).clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      color: place.barColor,
                      backgroundColor: AC.track,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // like (a heart)
                    Expanded(
                      child: voted
                          ? _PillButton(
                              label: l.activitiesWeekendVotedButton,
                              background: AC.salmonTint,
                              foreground: AC.brick,
                              icon: Icons.favorite_rounded,
                              onTap: onToggleVote,
                            )
                          : _PillButton(
                              label: l.activitiesWeekendVoteButton,
                              background: AC.track,
                              foreground: AC.ink,
                              icon: Icons.favorite_border_rounded,
                              onTap: onToggleVote,
                            ),
                    ),
                    const SizedBox(width: 8),
                    // add the outing to the family calendar on Home
                    Expanded(
                      child: _PillButton(
                        label: l.activitiesAddToCalendar,
                        background: AC.brick,
                        foreground: Colors.white,
                        icon: Icons.event_rounded,
                        onTap: onAddToCalendar,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Semantics(
                      label: l.activitiesWhoVotedLabel,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: votes == 0 ? null : onToggleVoters,
                        child: _VotersStack(count: votes, voted: voted),
                      ),
                    ),
                  ],
                ),
                if (votersOpen && votes > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: PeopleList(
                      [
                        if (voted) profile.name,
                        for (final m in members)
                          if (m.name != profile.name) m.name,
                      ].take(votes).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VotersStack extends StatelessWidget {
  final int count;
  final bool voted; // when you voted, you are one of the pictures
  const _VotersStack({required this.count, required this.voted});
  static const _size = 32.0;
  static const _overlap = 10.0;

  @override
  Widget build(BuildContext context) {
    // real family members' pictures, up to two, then "+N" for the rest
    final names = <String>[
      if (voted) profile.name,
      for (final m in members)
        if (m.name != profile.name) m.name,
    ].take(count.clamp(0, 2)).toList();
    final more = (count - names.length).clamp(0, 999);
    final items = [
      for (final n in names) Avatar(n, size: _size),
      if (more > 0) _moreDot(more),
    ];
    return SizedBox(
      width: items.isEmpty
          ? 0
          : (items.length - 1) * (_size - _overlap) + _size,
      height: _size,
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            PositionedDirectional(
              start: i * (_size - _overlap),
              child: items[i],
            ),
        ],
      ),
    );
  }

  Widget _moreDot(int more) => Container(
    width: _size,
    height: _size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AC.track,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Text(
      '+$more',
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AC.ink,
      ),
    ),
  );
}

CustomPainter _scenePainterFor(OutingScene scene) => switch (scene) {
  OutingScene.park => const _ParkScenePainter(),
  OutingScene.wadi => const _WadiScenePainter(),
  OutingScene.city => const _CityScenePainter(),
};

/// Hills/trees/sun scene for the park place. Purely cosmetic, approximating
/// the reference illustration.
class _ParkScenePainter extends CustomPainter {
  const _ParkScenePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final backHill = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * .62)
      ..quadraticBezierTo(w * .17, h * .4, w * .34, h * .58)
      ..quadraticBezierTo(w * .5, h * .72, w * .69, h * .52)
      ..quadraticBezierTo(w * .85, h * .36, w, h * .56)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(backHill, Paint()..color = AC.sageLight);

    final frontHill = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * .78)
      ..quadraticBezierTo(w * .26, h * .62, w * .51, h * .76)
      ..quadraticBezierTo(w * .75, h * .9, w, h * .72)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(frontHill, Paint()..color = AC.sage);

    void tree(double cx, double cyRatio, double r) {
      final cy = h * cyRatio;
      canvas.drawLine(
        Offset(cx, cy + r * .4),
        Offset(cx, cy + r * 1.5),
        Paint()
          ..color = AC.textSoft
          ..strokeWidth = 4,
      );
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = AC.treeGreen);
    }

    tree(w * .2, .45, w * .05);
    tree(w * .8, .4, w * .06);
    canvas.drawCircle(
      Offset(w * .5, h * .22),
      w * .035,
      Paint()..color = AC.mustard,
    );
  }

  @override
  bool shouldRepaint(covariant _ParkScenePainter oldDelegate) => false;
}

/// Desert canyon + palm-tree scene for the wadi place. Approximated.
class _WadiScenePainter extends CustomPainter {
  const _WadiScenePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawCircle(
      Offset(w * .74, h * .26),
      w * .04,
      Paint()..color = AC.salmon,
    );

    final leftCliff = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * .3)
      ..lineTo(w * .2, h * .36)
      ..lineTo(w * .31, h * .56)
      ..lineTo(w * .37, h)
      ..close();
    canvas.drawPath(leftCliff, Paint()..color = AC.wadiBar);

    final rightCliff = Path()
      ..moveTo(w, h)
      ..lineTo(w, h * .28)
      ..lineTo(w * .8, h * .4)
      ..lineTo(w * .69, h * .58)
      ..lineTo(w * .63, h)
      ..close();
    canvas.drawPath(rightCliff, Paint()..color = AC.wadiBar);

    final ground = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * .6)
      ..quadraticBezierTo(w * .3, h * .68, w * .6, h * .78)
      ..quadraticBezierTo(w * .8, h * .84, w, h * .6)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(ground, Paint()..color = AC.wadiDune);

    final water = Path()
      ..moveTo(w * .17, h)
      ..quadraticBezierTo(w * .42, h * .82, w * .5, h * .9)
      ..quadraticBezierTo(w * .65, h * 1.0, w * .86, h)
      ..close();
    canvas.drawPath(water, Paint()..color = AC.wadiWater);

    final trunkX = w * .46;
    canvas.drawLine(
      Offset(trunkX, h * .5),
      Offset(trunkX, h * .82),
      Paint()
        ..color = AC.textSoft
        ..strokeWidth = 4,
    );
    final frond = Paint()
      ..color = AC.treeGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final top = Offset(trunkX, h * .5);
    canvas.drawPath(
      Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(
          top.dx - w * .08,
          top.dy - h * .08,
          top.dx - w * .14,
          top.dy - h * .02,
        ),
      frond,
    );
    canvas.drawPath(
      Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(
          top.dx + w * .08,
          top.dy - h * .1,
          top.dx + w * .16,
          top.dy - h * .02,
        ),
      frond,
    );
    canvas.drawPath(
      Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(
          top.dx - w * .06,
          top.dy - h * .16,
          top.dx - w * .1,
          top.dy - h * .18,
        ),
      frond,
    );
    canvas.drawPath(
      Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(
          top.dx + w * .06,
          top.dy - h * .16,
          top.dx + w * .12,
          top.dy - h * .18,
        ),
      frond,
    );
  }

  @override
  bool shouldRepaint(covariant _WadiScenePainter oldDelegate) => false;
}

/// Night skyline + crescent moon scene for the city place. Approximated.
class _CityScenePainter extends CustomPainter {
  const _CityScenePainter();
  static const _heights = [.64, .5, .64, .4, .6, .32, .44];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    for (final p in [
      Offset(w * .34, h * .17),
      Offset(w * .6, h * .13),
      Offset(w * .86, h * .21),
    ]) {
      canvas.drawCircle(p, 1.6, Paint()..color = AC.mustardTint);
    }
    canvas.drawCircle(
      Offset(w * .17, h * .24),
      w * .034,
      Paint()..color = AC.mustardTint,
    );
    canvas.drawCircle(
      Offset(w * .19, h * .21),
      w * .034,
      Paint()..color = AC.navy,
    );

    final cols = _heights.length;
    final colW = w / cols;
    final buildingPaint = Paint()..color = AC.citySkyline;
    final windowPaint = Paint()..color = AC.mustard;
    for (var i = 0; i < cols; i++) {
      final bh = h * (1 - _heights[i]);
      final rect = Rect.fromLTWH(i * colW, h - bh, colW - 2, bh);
      canvas.drawRect(rect, buildingPaint);
      canvas.drawRect(
        Rect.fromLTWH(rect.left + colW * .3, rect.top + 10, 4, 4),
        windowPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(rect.left + colW * .6, rect.top + 22, 4, 4),
        windowPaint,
      );
    }

    final lights = Path()
      ..moveTo(0, h * .84)
      ..quadraticBezierTo(w * .5, h * .72, w, h * .78);
    final dashPaint = Paint()..color = AC.mustard;
    for (final metric in lights.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final tangent = metric.getTangentForOffset(dist);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 1.2, dashPaint);
        }
        dist += 10;
      }
    }

    canvas.drawRect(
      Rect.fromLTWH(0, h * .88, w, h * .12),
      Paint()..color = AC.cityForeground,
    );
  }

  @override
  bool shouldRepaint(covariant _CityScenePainter oldDelegate) => false;
}

// ---- 19 games
class GamesPage extends StatefulWidget {
  const GamesPage({super.key});
  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  String _filter = 'all';

  void _openGame(GameInfo game) {
    if (game.isSoon) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.gamesSoonSnack)));
      return;
    }
    // Games open full-screen on the root navigator: no bottom nav bar.
    context.read<GamesController>().start(game.title);
    switch (game.id) {
      case 'whoami':
        goGame(context, const WhoAmIScreen());
      case 'seen':
        goGame(context, const SeenJeemScreen());
      case 'charades':
        goGame(context, const CharadesScreen());
      default:
        // Placeholder until each game is built.
        goGame(context, _GamePlaceholderPage(game.title));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = buildGamesList(l);
    final games = _filter == 'all'
        ? all
        : all.where((g) => g.tags.contains(_filter)).toList();

    return Scaffold(
      backgroundColor: AC.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _GamesHeader(onBack: () => Navigator.of(context).pop()),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 104),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RouletteHeroCard(
                      onTap: () => go(context, const RoulettePage()),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            l.gamesAllGamesTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AC.ink,
                            ),
                          ),
                        ),
                        Text(
                          l.gamesCountText(games.length),
                          style: const TextStyle(fontSize: 13, color: AC.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GameFilterChips(
                      value: _filter,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: MediaQuery.disableAnimationsOf(context)
                            ? child
                            : ScaleTransition(
                                scale: Tween<double>(begin: .96, end: 1)
                                    .animate(
                                      CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                child: child,
                              ),
                      ),
                      child: GridView.builder(
                        key: ValueKey(_filter),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              mainAxisExtent: 252,
                            ),
                        itemCount: games.length,
                        itemBuilder: (context, i) {
                          final game = games[i];
                          return GameTile(
                            game: game,
                            onTap: () => _openGame(game),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _GamesHeader({required this.onBack});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Tooltip(
          message: MaterialLocalizations.of(context).backButtonTooltip,
          excludeFromSemantics: true,
          child: Semantics(
            button: true,
            label: MaterialLocalizations.of(context).backButtonTooltip,
            excludeSemantics: true,
            child: Material(
              color: AC.card,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: AC.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.gamesTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AC.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.gamesPageSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: AC.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "لعبة الليلة": the roulette hero card, with the wheel poking out of the
/// bottom-left corner — a fixed, physical-left decorative anchor, so it
/// does not flip with the ambient RTL direction.
class RouletteHeroCard extends StatelessWidget {
  final VoidCallback onTap;
  const RouletteHeroCard({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.gamesTileSemanticsLabel(
        l.gamesRouletteTitle,
        l.gamesRouletteHeroDesc,
      ),
      child: Material(
        color: AC.navy,
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 210),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  left: -70,
                  bottom: -70,
                  child: _HeroBackdropCircle(),
                ),
                Positioned(
                  left: -57,
                  bottom: -57,
                  child: Transform.rotate(
                    angle: -18 * math.pi / 180,
                    child: const SizedBox(
                      width: 210,
                      height: 210,
                      child: CustomPaint(painter: RouletteHeroWheelPainter()),
                    ),
                  ),
                ),
                Positioned(
                  left: 110,
                  bottom: 112,
                  child: Transform.rotate(
                    angle: 45 * math.pi / 180,
                    child: const CustomPaint(
                      size: Size(22, 20),
                      painter: _HeroArrowPainter(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 196),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AC.mustard.withValues(alpha: .14),
                            border: Border.all(
                              color: AC.mustard.withValues(alpha: .35),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: AC.mustard,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l.gamesTonightBadge,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AC.mustard,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.gamesRouletteTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          l.gamesRouletteHeroDesc,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AC.heroDescText,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AC.brick,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AC.brick.withValues(alpha: .35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l.gamesSpinItButton,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Directionality(
                                textDirection: TextDirection.ltr,
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _HeroBackdropCircle extends StatelessWidget {
  const _HeroBackdropCircle();
  @override
  Widget build(BuildContext context) => Container(
    width: 236,
    height: 236,
    decoration: const BoxDecoration(color: AC.navy2, shape: BoxShape.circle),
  );
}

class _HeroArrowPainter extends CustomPainter {
  const _HeroArrowPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(1, 1)
      ..lineTo(21, 1)
      ..lineTo(11, 19)
      ..close();
    canvas.drawPath(path, Paint()..color = AC.background);
    canvas.drawPath(
      path,
      Paint()
        ..color = AC.navy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroArrowPainter oldDelegate) => false;
}

/// "الكل" / "حركية" / "تحدي" / "عائلية".
class GameFilterChips extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const GameFilterChips({
    super.key,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final chips = [
      ('all', l.gamesFilterAll),
      ('move', l.gamesFilterMove),
      ('challenge', l.gamesFilterChallenge),
      ('family', l.gamesFilterFamily),
    ];
    return Semantics(
      container: true,
      label: l.gamesFilterGroupLabel,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final (id, label) in chips) ...[
              if (id != 'all') const SizedBox(width: 8),
              _FilterChip(
                label: label,
                selected: value == id,
                onTap: () => onChanged(id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AC.navy : AC.card,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AC.ink,
            ),
          ),
        ),
      ),
    ),
  );
}

/// One game card in the "كل الألعاب" grid.
class GameTile extends StatelessWidget {
  final GameInfo game;
  final VoidCallback onTap;
  const GameTile({super.key, required this.game, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final descColor = game.dark ? AC.charadesDesc : AC.textSoft;
    final playBg = game.dark ? AC.mustard : AC.brick;
    final playFg = game.dark ? AC.navy : Colors.white;
    return Semantics(
      button: true,
      label: l.gamesTileSemanticsLabel(game.title, game.time),
      child: Material(
        color: game.bg,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: game.image != null ? 108 : 96,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: game.art,
                    borderRadius: BorderRadius.circular(16),
                    image: game.image == null
                        ? null
                        : DecorationImage(
                            image: AssetImage(game.image!),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: Stack(
                    children: [
                      if (game.image == null)
                        Center(
                          child: FittedBox(
                            child: SizedBox(
                              width: 78,
                              height: 64,
                              child: GameIllustration(game.id),
                            ),
                          ),
                        ),
                      if (game.isSoon)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AC.ink,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l.gamesSoonBadge,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  game.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: game.dark ? Colors.white : AC.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  game.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, height: 1.4, color: descColor),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: playBg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Transform.flip(
                          flipX: true,
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: playFg,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GamePlaceholderPage extends StatelessWidget {
  final String name;
  const _GamePlaceholderPage(this.name);
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AC.background,
    appBar: AppBar(
      backgroundColor: AC.background,
      elevation: 0,
      foregroundColor: AC.ink,
    ),
    body: Center(
      child: Text(
        name,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      ),
    ),
  );
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
        color: C.teal,
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Text(
            ld(context, azizQuestions[_i]),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(child: Btn(l.azizNext, onTap: _next)),
          const SizedBox(width: 12),
          Expanded(
            child: Btn(
              l.azizSkip,
              outlined: true,
              color: C.inkSoft,
              onTap: _next,
            ),
          ),
        ],
      ),
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
        child: Column(
          children: [
            Text(
              l.sinJimAnswerOnBehalf,
              style: const TextStyle(
                color: C.inkSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Avatar(who.name, size: 76),
            const SizedBox(height: 8),
            Text(
              ld(context, who.name),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 18),
            Text(
              '${l.sinJimQPrefix} ${ld(context, sinJimQuestions[_i % sinJimQuestions.length])}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Btn(
        l.sinJimEveryoneAnswered,
        onTap: () => setState(() {
          _i++;
          _answered++;
        }),
      ),
      const SizedBox(height: 10),
      Center(
        child: Text(
          l.sinJimAnswersRecorded(_answered),
          style: const TextStyle(
            color: C.inkSoft,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ]);
  }
}

// ---- 22 roulette
class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key});
  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage>
    with SingleTickerProviderStateMixin {
  static final _modes = <String, List<String>>{
    'Who starts?': [for (final m in members) m.name],
    'Challenge': [
      'Tell a joke',
      'Sing a line',
      'Imitate someone',
      'Dance 10 sec',
      'Tell a secret',
      'Draw in 10 sec',
    ],
    'Decision': [
      'Stay home',
      'Go out',
      'Cook',
      'Order food',
      'Watch a movie',
      'Play games',
    ],
  };
  static const _colors = [C.peach, C.navy, C.yellow, C.teal, C.brick, C.sage];

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
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
    _ctrl.forward(from: 0).whenComplete(() {
      setState(() => _result = pick);
      _showWinnerDialog(pick);
    });
  }

  void _showWinnerDialog(int pick) {
    final name = ld(context, _items[pick]);
    final color = _colors[pick % _colors.length];
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 550),
      pageBuilder: (_, _, _) =>
          _WinnerDialog(name: name, color: color, wheelColors: _colors),
      transitionBuilder: (_, anim, _, child) => ScaleTransition(
        scale: Tween<double>(
          begin: 0.5,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.elasticOut)),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final displayItems = _items.map((e) => ld(context, e)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l.gamesRouletteTitle)),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 20),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final m in _modes.keys)
                  Choice(ld(context, m), _mode == m, () {
                    if (_ctrl.isAnimating) return;
                    setState(() {
                      _mode = m;
                      _result = null;
                      _from = _to = 0;
                    });
                  }),
              ],
            ),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wheelSize = math.min(
                      constraints.maxWidth * .85,
                      340.0,
                    );
                    return SizedBox(
                      width: wheelSize,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: wheelSize,
                            height: wheelSize + 40,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Positioned(
                                  bottom: 0,
                                  child: AnimatedBuilder(
                                    animation: _ctrl,
                                    builder: (_, _) {
                                      final t = Curves.easeOutCubic.transform(
                                        _ctrl.value,
                                      );
                                      return Transform.rotate(
                                        angle:
                                            _ctrl.isAnimating ||
                                                _ctrl.isCompleted
                                            ? _from + (_to - _from) * t
                                            : _to,
                                        child: CustomPaint(
                                          size: Size(wheelSize, wheelSize),
                                          painter: _WheelPainter(
                                            displayItems,
                                            _colors,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  child: Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 48,
                                    color: C.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          AnimatedBuilder(
                            animation: _ctrl,
                            builder: (_, _) => Btn(
                              l.rouletteSpin,
                              icon: Icons.casino_rounded,
                              enabled: !_ctrl.isAnimating,
                              onTap: () {
                                if (!_ctrl.isAnimating) _spin();
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _result == null
                                ? ' '
                                : _mode == 'Who starts?'
                                ? l.rouletteResultStarts(
                                    ld(context, _items[_result!]),
                                  )
                                : ld(context, _items[_result!]),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: C.brick,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> items;
  final List<Color> colors;
  _WheelPainter(this.items, this.colors);

  TextPainter _layoutFitted(
    String text,
    double maxLength,
    double maxThickness,
  ) {
    for (var size = 20.0; size > 10.0; size -= 1.0) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: size,
            fontWeight: FontWeight.w700,
            fontFamily: kFontFamily,
            shadows: const [
              Shadow(
                color: Colors.black38,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.rtl,
        maxLines: 1,
      )..layout();
      if (tp.width <= maxLength && tp.height <= maxThickness) return tp;
    }
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: kFontFamily,
          shadows: [
            Shadow(color: Colors.black38, blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.rtl,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxLength);
    return tp;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final seg = 2 * math.pi / items.length;
    final innerR = r * .42;
    final outerR = r - 10;
    final maxLength = outerR - innerR;
    final midR = (innerR + outerR) / 2;
    final maxThickness = 2 * midR * math.sin(seg / 2) * .82;
    for (var i = 0; i < items.length; i++) {
      final start = -math.pi / 2 + i * seg;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        seg,
        true,
        Paint()..color = colors[i % colors.length],
      );
      var mid = start + seg / 2;
      // keep text upright: flip radial direction on the wheel's left half
      final normalized = mid % (2 * math.pi);
      final flip = normalized > math.pi / 2 && normalized < 3 * math.pi / 2;
      final tp = _layoutFitted(items[i], maxLength, maxThickness);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(flip ? mid + math.pi : mid);
      final start_ = flip ? -(innerR + tp.width) : innerR;
      tp.paint(canvas, Offset(start_, -tp.height / 2));
      canvas.restore();
    }
    canvas.drawCircle(c, 16, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.items != items;
}

class _WinnerDialog extends StatefulWidget {
  final String name;
  final Color color;
  final List<Color> wheelColors;
  const _WinnerDialog({
    required this.name,
    required this.color,
    required this.wheelColors,
  });
  @override
  State<_WinnerDialog> createState() => _WinnerDialogState();
}

class _WinnerDialogState extends State<_WinnerDialog>
    with TickerProviderStateMixin {
  late final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 2),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final AnimationController _name = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _confetti.play();
    _name.forward();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _pulse.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: .92, end: 1.08).animate(
                    CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.name.isEmpty ? '' : widget.name.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, .3),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(parent: _name, curve: Curves.easeOut),
                      ),
                  child: FadeTransition(
                    opacity: _name,
                    child: Text(
                      '${widget.name} 🎉',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: C.ink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Btn(
                  l.rouletteGotIt,
                  color: C.brick,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 24,
            minBlastForce: 6,
            maxBlastForce: 16,
            gravity: 0.25,
            shouldLoop: false,
            colors: widget.wheelColors,
          ),
        ],
      ),
    );
  }
}

// ---- 23 book club
class BookClubPage extends StatelessWidget {
  const BookClubPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(l.activitiesBookClubTitle, [
      LCard(
        child: Row(
          children: [
            Container(
              width: 74,
              height: 100,
              decoration: BoxDecoration(
                color: C.brick,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.bookClubCurrentBook,
                    style: const TextStyle(
                      color: C.inkSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l.activitiesBookClubDesc,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.bookClubReadingStatus,
                    style: const TextStyle(color: C.inkSoft, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const Bar(.5),
      const SizedBox(height: 14),
      Btn(l.bookClubJoinDiscussion, onTap: () {}),
      SectionTitle(l.discussionQuestionsHeading),
      for (final q in [l.bookClubQ1, l.bookClubQ2])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LCard(
            child: Text(q, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
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
  bool _showListeners = false;
  final _question = TextEditingController();
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));

  @override
  void dispose() {
    _confetti.dispose();
    _question.dispose();
    super.dispose();
  }

  /// Asks where to listen, then opens that app.
  Future<void> _chooseApp(ClubsController clubs) => chooseListenApp(
    context,
    youtubeUrl: clubs.currentEpisode.youtubeUrl,
    appleUrl: clubs.currentEpisode.appleUrl ?? fahemAppleUrl,
  );

  void _addQuestion(ClubsController clubs) {
    if (_question.text.trim().isEmpty) return;
    clubs.addDiscussionQuestion(_question.text);
    _question.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final clubs = context.watch<ClubsController>();
    final heard = clubs.iHeard;
    final listeners = [
      for (final r in clubs.heardBy) r.name,
      if (heard) profile.name,
    ];
    return Page1(l.podcastPageTitle, [
      // the episode's cover, then its real title and length underneath
      // tapping the cover works like "Start listening": it asks where to listen
      Semantics(
        button: true,
        label: l.homeStartListening,
        child: GestureDetector(
          onTap: () => _chooseApp(clubs),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/podcast/episode_thumbnail.jpg',
                    fit: BoxFit.cover,
                  ),
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      Text(
        l.podcastFullTitle,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: C.navy,
          height: 1.35,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        l.podcastDuration,
        style: const TextStyle(
          fontSize: 13,
          color: C.inkSoft,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 18),

      // one button; it asks where to listen
      StartListeningButton(onPressed: () => _chooseApp(clubs)),
      const SizedBox(height: 22),

      // finished listening: confetti bursts around the button
      Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (!heard)
            Btn(
              l.podcastFinishedButton,
              icon: Icons.check_rounded,
              onTap: () {
                pointsToast(context, clubs.markHeard(true));
                _confetti.play();
              },
            )
          else
            // tapping it again undoes it, in case it was pressed by accident
            LCard(
              color: C.tealTint,
              onTap: () {
                clubs.markHeard(false);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l.podcastNotListened)));
              },
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: C.teal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.podcastFinishedDone,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 40,
            minBlastForce: 8,
            maxBlastForce: 24,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [
              C.brick,
              C.teal,
              C.yellow,
              C.peach,
              C.sage,
              C.navy,
              C.lavender,
            ],
          ),
        ],
      ),
      const SizedBox(height: 22),

      // the members who listened: tap to open the list right here
      LCard(
        onTap: () => setState(() => _showListeners = !_showListeners),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.podcastListenedMembers,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  l.podcastListenedFraction(clubs.heardCount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: C.brick,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (listeners.isEmpty)
              const Text('—', style: TextStyle(color: C.inkSoft))
            else
              AvatarStack(listeners, size: 40),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: !_showListeners || listeners.isEmpty
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          for (final name in listeners)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Avatar(name, size: 32),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ld(context, name),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: C.teal,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      SectionTitle(l.discussionQuestionsHeading),
      for (final q in [
        l.podcastQ1,
        l.podcastQ2,
        ...clubs.questions.skip(ClubsController.defaultQuestionCount),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LCard(
            child: Text(q, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      // add your own
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _question,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addQuestion(clubs),
              decoration: InputDecoration(
                hintText: l.podcastAddQuestionHint,
                filled: true,
                fillColor: C.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: () => _addQuestion(clubs),
            style: FilledButton.styleFrom(
              backgroundColor: C.brick,
              minimumSize: const Size(64, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              l.podcastAddQuestionButton,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
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
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (final f in [
              'All',
              'Restaurants',
              'Cafés',
              'Nature',
              'Entertainment',
            ])
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Choice(
                  f == 'All' ? l.outingsFilterAll : ld(context, f),
                  _f == f,
                  () => setState(() => _f = f),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        height: 130,
        decoration: BoxDecoration(
          color: C.tealTint,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_rounded, color: C.teal, size: 34),
              const SizedBox(height: 6),
              Text(
                l.outingsPlacesMap,
                style: const TextStyle(
                  color: C.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      for (final p in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LCard(
            onTap: () => go(context, SuggestPlacePage(p)),
            child: Row(
              children: [
                IconBubble(p.icon, p.color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ld(context, p.name),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ld(context, p.why),
                        style: const TextStyle(color: C.inkSoft, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 6),
      Btn(
        l.outingsOurOutings,
        outlined: true,
        color: C.navy,
        onTap: () => go(context, const OurOutingsPage()),
      ),
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
    return Page1(
      l.suggestPlaceTitle,
      [
        LCard(
          color: C.teal,
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Center(
            child: Text(
              ld(context, p.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        LCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.suggestPlaceWhyHeading,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                ld(context, p.why),
                style: const TextStyle(color: C.inkSoft, height: 1.4),
              ),
            ],
          ),
        ),
      ],
      bottom: Btn(
        l.suggestPlaceAdd,
        icon: Icons.add_rounded,
        onTap: () {
          if (!ourOutings.contains(p)) ourOutings.add(p);
          context.read<OutingController>().suggest(ld(context, p.name));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.suggestPlaceAddedSnackbar)));
        },
      ),
    );
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
            child: Text(
              l.ourOutingsEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: C.inkSoft,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ),
      for (final p in ourOutings)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LCard(
            child: Row(
              children: [
                IconBubble(p.icon, p.color),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    ld(context, p.name),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ]);
  }
}
