import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../screens/activities_colors.dart';
import 'notification_model.dart';
import 'notifications_controller.dart';
import 'widgets/notification_visuals.dart';

/// Opens the full notifications screen above everything, including the
/// bottom bar.
Future<void> openNotificationsScreen(BuildContext context) => Navigator.of(
  context,
  rootNavigator: true,
).push(MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()));

const _heroInk = Color(0xFF6E5418);
const _readBorder = Color(0xFFF3EADF);
const _newBg = Color(0xFFFFF7F0);
const _newBorder = Color(0xFFF3E2D6);
const _dot = Color(0xFFC9806D);

class _TypeStyle {
  final String Function(AppLocalizations) tag;
  final Color color, tint, ink;
  final IconData icon;
  const _TypeStyle(this.tag, this.color, this.tint, this.ink, this.icon);
}

final _styles = <NotificationType, _TypeStyle>{
  NotificationType.event: _TypeStyle(
    (l) => l.notifsTagEvent,
    const Color(0xFF8C6A24),
    AC.mustardTint,
    _heroInk,
    Icons.event_outlined,
  ),
  NotificationType.moment: _TypeStyle(
    (l) => l.notifsTagMoment,
    AC.brick,
    AC.salmonTint,
    AC.brickDeep,
    Icons.photo_camera_outlined,
  ),
  NotificationType.comment: _TypeStyle(
    (l) => l.notifsTagComment,
    AC.navy,
    const Color(0xFFD9DEEA),
    AC.navy,
    Icons.chat_bubble_outline_rounded,
  ),
  NotificationType.chat: _TypeStyle(
    (l) => l.notifsTagChat,
    AC.navy,
    const Color(0xFFD9DEEA),
    AC.navy,
    Icons.forum_outlined,
  ),
  NotificationType.game: _TypeStyle(
    (l) => l.notifsTagGame,
    AC.teal,
    AC.tealTint,
    AC.tealDeep,
    Icons.sports_esports_outlined,
  ),
  NotificationType.club: _TypeStyle(
    (l) => l.notifsTagClub,
    AC.teal,
    AC.tealTint,
    AC.tealDeep,
    Icons.menu_book_outlined,
  ),
  NotificationType.survey: _TypeStyle(
    (l) => l.notifsTagSurvey,
    AC.brick,
    AC.salmonTint,
    AC.brickDeep,
    Icons.favorite_border_rounded,
  ),
  NotificationType.vote: _TypeStyle(
    (l) => l.notifsTagVote,
    AC.treeGreen,
    AC.sageTint,
    AC.votedText,
    Icons.bar_chart_rounded,
  ),
};

enum _Group { today, yesterday, earlier }

_Group _groupOf(DateTime t, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final days = today.difference(DateTime(t.year, t.month, t.day)).inDays;
  return days <= 0
      ? _Group.today
      : days == 1
      ? _Group.yesterday
      : _Group.earlier;
}

/// "الإشعارات": everything, grouped by day. Reads the same controller as
/// the bell box, so reading in one place updates the other.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.watch<NotificationsController>();
    final now = DateTime.now();
    final unread = c.unreadCount;
    final byGroup = {
      for (final g in _Group.values)
        g: [
          for (final n in c.items)
            if (_groupOf(n.createdAt, now) == g) n,
        ],
    };
    final senders = <String>{};
    final heroFor = <AppNotification>[];
    for (final n in c.items) {
      if (!n.isRead && n.actorId != null && senders.add(n.actorId!)) {
        heroFor.add(n);
      }
    }
    String groupTitle(_Group g) => switch (g) {
      _Group.today => l.notifsGroupToday,
      _Group.yesterday => l.notifsGroupYesterday,
      _Group.earlier => l.notifsGroupEarlier,
    };
    return Scaffold(
      backgroundColor: AC.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: l.notifsBack,
                    excludeSemantics: true,
                    child: Material(
                      color: AC.card,
                      shape: const CircleBorder(
                        side: BorderSide(color: AC.border),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          // RTL page: back points right
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.notifsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AC.ink,
                      ),
                    ),
                  ),
                  if (unread > 0)
                    Material(
                      color: AC.card,
                      shape: const StadiumBorder(
                        side: BorderSide(color: AC.border),
                      ),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: c.markAllRead,
                        child: SizedBox(
                          height: 44,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.done_all_rounded,
                                  size: 16,
                                  color: AC.brick,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l.notifReadAll,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AC.brick,
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
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(scrollbars: false),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    _Hero(unread: unread, senders: heroFor),
                    for (final g in _Group.values)
                      if (byGroup[g]!.isNotEmpty) ...[
                        _GroupHeader(
                          title: groupTitle(g),
                          count: l.notifsGroupCount(byGroup[g]!.length),
                        ),
                        for (final n in byGroup[g]!) ...[
                          const SizedBox(height: 8),
                          _Card(
                            key: ValueKey(n.id),
                            n: n,
                            onTap: () {
                              // go there first (it switches tabs under this
                              // screen), then reveal it by closing the screen
                              c.open(n);
                              Navigator.of(context).maybePop();
                            },
                          ),
                        ],
                      ],
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

class _Hero extends StatelessWidget {
  final int unread;
  final List<AppNotification> senders;
  const _Hero({required this.unread, required this.senders});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final shown = senders.take(3).toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AC.mustardTint,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unread > 0 ? l.notifsHeroKickerNew : l.notifsHeroKickerRead,
                  style: const TextStyle(fontSize: 13, color: _heroInk),
                ),
                const SizedBox(height: 2),
                Text(
                  l.notifsHeroTitle(unread),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AC.ink,
                  ),
                ),
              ],
            ),
          ),
          if (unread > 0 && shown.isNotEmpty)
            SizedBox(
              width: 36.0 + (shown.length - 1) * 26,
              height: 36,
              child: Stack(
                children: [
                  for (var k = 0; k < shown.length; k++)
                    PositionedDirectional(
                      start: k * 26.0,
                      child: NotificationAvatar(
                        n: shown[k],
                        size: 36,
                        ring: AC.mustardTint,
                      ),
                    ),
                ],
              ),
            ),
          if (unread == 0)
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, size: 22, color: AC.teal),
            ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String title, count;
  const _GroupHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 14, 4, 2),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AC.textSoft,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: SizedBox(height: 1, child: ColoredBox(color: AC.dotInactive)),
        ),
        const SizedBox(width: 10),
        Text(count, style: const TextStyle(fontSize: 12, color: AC.muted)),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  final AppNotification n;
  final VoidCallback onTap;
  const _Card({super.key, required this.n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final st = _styles[n.type]!;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final fade = Duration(milliseconds: reduce ? 0 : 300);
    final unread = !n.isRead;
    final person = n.actorId != null;
    return Semantics(
      button: true,
      label: unread ? l.notifsNewPrefix(n.text) : n.text,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AnimatedContainer(
            duration: fade,
            padding: const EdgeInsets.fromLTRB(28, 12, 14, 12),
            decoration: BoxDecoration(
              color: unread ? _newBg : AC.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: unread ? _newBorder : _readBorder),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (person)
                            NotificationAvatar(n: n, size: 44)
                          else
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: st.tint,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(st.icon, size: 24, color: st.ink),
                            ),
                          if (person)
                            Positioned(
                              bottom: -2,
                              left: -2,
                              child: Opacity(
                                opacity: .9,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: st.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AC.card,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    st.icon,
                                    size: 9,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            notificationSpan(
                              n,
                              color: AC.ink,
                              size: 15,
                              leadWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: st.tint,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  st.tag(l),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: st.ink,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 12,
                                    color: AC.muted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    notificationTimeLabel(
                                      l,
                                      n.createdAt,
                                      detailed: true,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AC.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (n.thumbnail != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: NotificationThumbView(
                          thumb: n.thumbnail!,
                          size: 50,
                          radius: 12,
                        ),
                      ),
                  ],
                ),
                // physical left, as in the design
                Positioned(
                  left: -16,
                  child: AnimatedOpacity(
                    duration: fade,
                    opacity: unread ? 1 : 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _dot,
                        shape: BoxShape.circle,
                      ),
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
