import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data.dart';
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
import '../theme.dart';
import '../widgets.dart';
import '../features/clubs/clubs_controller.dart';
import '../features/clubs/clubs_screen.dart';
import '../features/topics/topics_controller.dart';
import '../features/topics/topics_screen.dart';
import '../widgets/topic_deck_card.dart';
import 'activities_colors.dart';
import 'activities_data.dart';
import '../features/games/charades/charades_screen.dart';
import '../features/games/seen_jeem/seen_jeem_screen.dart';
import '../features/games/who_am_i/who_am_i_screen.dart';
import 'game_illustrations.dart';
import 'games_data.dart';
import 'home.dart';

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
            _ActivitiesHeader(
              onBell: () => go(context, const NotificationsPage()),
            ),
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
  final VoidCallback onBell;
  const _ActivitiesHeader({required this.onBell});
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
                  fontWeight: FontWeight.w800,
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
        _RoundIconButton(
          background: AC.card,
          iconColor: AC.ink,
          borderColor: AC.border,
          icon: Icons.notifications_none_rounded,
          tooltip: l.notificationsTitle,
          onTap: onBell,
        ),
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
  final VoidCallback onSeeAll, onRoulette, onSinJim, onCharades;
  const GamesSection({
    super.key,
    required this.onSeeAll,
    required this.onRoulette,
    required this.onSinJim,
    required this.onCharades,
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
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _GameTile(
                  background: AC.tealTint,
                  iconBg: AC.teal,
                  iconChild: const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  title: l.gamesSinJimTitle,
                  desc: l.activitiesSinJimCardDesc,
                  descColor: AC.sinJimDesc,
                  onTap: onSinJim,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GameTile(
                  background: AC.mustardTint,
                  iconBg: AC.navy,
                  iconChild: const SizedBox(
                    width: 32,
                    height: 26,
                    child: FittedBox(
                      child: SizedBox(
                        width: 78,
                        height: 64,
                        child: GameIllustration('charades'),
                      ),
                    ),
                  ),
                  title: l.gamesCharadesTitle,
                  desc: l.gamesCharadesDesc,
                  descColor: AC.lettersDesc,
                  onTap: onCharades,
                ),
              ),
            ],
          ),
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
                        fontWeight: FontWeight.w800,
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
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AC.brick,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final Color background, iconBg, descColor;
  final Widget iconChild;
  final String title, desc;
  final VoidCallback onTap;
  const _GameTile({
    required this.background,
    required this.iconBg,
    required this.iconChild,
    required this.title,
    required this.desc,
    required this.descColor,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: background,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: iconChild,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AC.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, height: 1.3, color: descColor),
            ),
          ],
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
          topRight: _Badge(l.activitiesBookClubDaysLeft(clubs.daysLeft)),
          bottomTrailing: finishedReaders.isEmpty
              ? null
              : _AvatarStack(
                  colors: [for (final r in finishedReaders) r.color],
                  initials: [for (final r in finishedReaders) r.initial],
                ),
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
          topRight: _RoundIconButton(
            background: AC.teal,
            iconColor: Colors.white,
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

class ClubCard extends StatelessWidget {
  final Color iconBg, iconColor, progressColor, captionBoldColor;
  final IconData icon;
  final String label, title, captionBold, captionRest;
  final double progress;
  final Widget topRight;
  final Widget? bottomTrailing;
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
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: AC.card,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AC.border),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AC.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                topRight,
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: progressColor,
                backgroundColor: AC.track,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 13, color: AC.muted),
                      children: [
                        TextSpan(
                          text: captionBold,
                          style: TextStyle(
                            color: captionBoldColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(text: ' $captionRest'),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ?bottomTrailing,
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _AvatarStack extends StatelessWidget {
  final List<Color> colors;
  final List<String> initials;
  static const _size = 24.0;
  static const _overlap = 8.0;
  const _AvatarStack({required this.colors, required this.initials});
  @override
  Widget build(BuildContext context) {
    final n = initials.length;
    return SizedBox(
      width: n == 0 ? 0 : (n - 1) * (_size - _overlap) + _size,
      height: _size,
      child: Stack(
        children: [
          for (var i = 0; i < n; i++)
            PositionedDirectional(
              start: i * (_size - _overlap),
              child: Container(
                width: _size,
                height: _size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  initials[i],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
  final Color? borderColor;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _RoundIconButton({
    required this.background,
    required this.iconColor,
    this.borderColor,
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
        shape: CircleBorder(
          side: borderColor != null
              ? BorderSide(color: borderColor!)
              : BorderSide.none,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: iconColor, size: 20),
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
  final Color? borderColor;
  final IconData? icon;
  final VoidCallback? onTap;
  const _PillButton({
    required this.label,
    required this.background,
    required this.foreground,
    this.borderColor,
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
          fontWeight: FontWeight.w800,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
          ),
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
            fontWeight: FontWeight.w800,
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
  late final PageController _pageCtrl = PageController();
  int _index = 0;
  final Set<int> _voted = {};

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final n = weekendPlaces.length;
    _pageCtrl.animateToPage(
      (_index + delta + n) % n,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleVote(int i) => setState(() {
    if (!_voted.add(i)) _voted.remove(i);
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final n = weekendPlaces.length;
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
                  fontWeight: FontWeight.w800,
                  color: AC.ink,
                ),
              ),
            ),
            _RoundIconButton(
              background: AC.card,
              iconColor: AC.ink,
              borderColor: AC.border,
              icon: Icons.arrow_back_rounded,
              tooltip: l.activitiesPrevPlace,
              onTap: () => _go(-1),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 56,
              child: Text(
                l.activitiesPlaceCounter(_index + 1, n),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AC.muted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _RoundIconButton(
              background: AC.brick,
              iconColor: Colors.white,
              icon: Icons.arrow_forward_rounded,
              tooltip: l.activitiesNextPlace,
              onTap: () => _go(1),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 326,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: n,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final place = weekendPlaces[i];
              final voted = _voted.contains(i);
              final votes = place.baseVotes + (voted ? 1 : 0);
              return _PlaceCard(
                place: place,
                votes: votes,
                voted: voted,
                onToggleVote: () => _toggleVote(i),
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
  const _PlaceCard({
    required this.place,
    required this.votes,
    required this.voted,
    required this.onToggleVote,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AC.card,
        border: Border.all(color: AC.border),
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 140,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: place.sky),
                CustomPaint(painter: _scenePainterFor(place.scene)),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AC.ink,
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
                    Expanded(
                      child: voted
                          ? _PillButton(
                              label: l.activitiesWeekendVotedButton,
                              background: AC.sageTint,
                              foreground: AC.votedText,
                              borderColor: AC.treeGreen,
                              icon: Icons.check_rounded,
                              onTap: onToggleVote,
                            )
                          : _PillButton(
                              label: l.activitiesWeekendVoteButton,
                              background: AC.brick,
                              foreground: Colors.white,
                              onTap: onToggleVote,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Semantics(
                      label: l.activitiesWhoVotedLabel,
                      child: _VotersStack(count: votes),
                    ),
                  ],
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
  const _VotersStack({required this.count});
  static const _size = 32.0;
  static const _overlap = 10.0;

  @override
  Widget build(BuildContext context) {
    final more = (count - 2).clamp(0, 999);
    final items = [_dot(AC.brick, 'م'), _dot(AC.navy, 'س'), _moreDot(more)];
    return SizedBox(
      width: (items.length - 1) * (_size - _overlap) + _size,
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

  Widget _dot(Color color, String initial) => Container(
    width: _size,
    height: _size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Text(
      initial,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

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
        fontWeight: FontWeight.w800,
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
                              fontWeight: FontWeight.w800,
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
                              mainAxisExtent: 236,
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
              shape: const CircleBorder(side: BorderSide(color: AC.border)),
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
                  fontWeight: FontWeight.w800,
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
                                  fontWeight: FontWeight.w800,
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
                            fontWeight: FontWeight.w800,
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
                                  fontWeight: FontWeight.w800,
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
            border: Border.all(color: selected ? AC.navy : AC.border),
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
                  height: 96,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: game.art,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
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
                                fontWeight: FontWeight.w800,
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
                    fontWeight: FontWeight.w800,
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
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
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
              fontWeight: FontWeight.w900,
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
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 18),
            Text(
              '${l.sinJimQPrefix} ${ld(context, sinJimQuestions[_i % sinJimQuestions.length])}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
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
  static const _colors = [
    C.coral,
    C.navy,
    C.mustard,
    C.teal,
    C.terracotta,
    C.green,
  ];

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
                              fontWeight: FontWeight.w900,
                              color: C.terracotta,
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

const _wheelFontFallback = [
  'SF Arabic',
  'Geeza Pro',
  'Noto Sans Arabic',
  'Roboto',
];

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
            fontWeight: FontWeight.w800,
            fontFamilyFallback: _wheelFontFallback,
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
          fontWeight: FontWeight.w800,
          fontFamilyFallback: _wheelFontFallback,
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
    canvas.drawCircle(c, 16, Paint()..color = C.cream);
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
              color: C.cream,
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
                        fontWeight: FontWeight.w900,
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
                        fontWeight: FontWeight.w900,
                        color: C.ink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Btn(
                  l.rouletteGotIt,
                  color: C.terracotta,
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
                color: C.terracotta,
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
                      fontWeight: FontWeight.w900,
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
  bool _listened = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final count = 3 + (_listened ? 1 : 0);
    return Page1(l.activitiesPodcastClubTitle, [
      LCard(
        color: C.navy,
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Text(
              l.podcastThisWeekEpisode,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l.homePodcastTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              l.podcastDuration,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => setState(() {
                if (!_listened) addPoints(profile.name, 15);
                _listened = true;
              }),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: C.terracotta,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                l.homeStartListening,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      LCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.podcastListenedLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  l.podcastListenedFraction(count),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: C.terracotta,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Bar(count / 6),
            const SizedBox(height: 10),
            Text(
              l.podcastNextGathering,
              style: const TextStyle(
                color: C.inkSoft,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      SectionTitle(l.discussionQuestionsHeading),
      for (final q in [l.podcastQ1, l.podcastQ2])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LCard(
            child: Text(q, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
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
                  fontWeight: FontWeight.w800,
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
                          fontWeight: FontWeight.w800,
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
                fontWeight: FontWeight.w900,
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
                style: const TextStyle(fontWeight: FontWeight.w900),
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
                      fontWeight: FontWeight.w800,
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
