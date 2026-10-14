import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../backend/backend.dart';
import '../data.dart';
import '../features/clubs/clubs_controller.dart';
import '../features/topics/topics_controller.dart';
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/notification_bell.dart';
import 'account.dart';
import 'activities.dart';
import 'leaderboard.dart';

class HomePage extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const HomePage({super.key, required this.onSwitchTab});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SharedRefresh<HomePage> {
  Timer? _clock;
  static const _weekKey = 'week_points_base';
  int _weekBase = 0;
  bool _weekReady = false;

  /// The week we are in (counted from Saturday, like the family week).
  String get _thisWeek {
    final d = DateTime.now();
    final start = DateTime(
      d.year,
      d.month,
      d.day,
    ).subtract(Duration(days: (d.weekday + 1) % 7));
    return '${start.year}-${start.month}-${start.day}';
  }

  int get _myPoints =>
      members
          .where(
            (m) => profile.memberId != null
                ? m.id == profile.memberId
                : m.name == profile.name,
          )
          .firstOrNull
          ?.points ??
      0;

  /// Points earned since the week started (the total, minus what I had at the start of the week).
  int get _weekPoints =>
      _weekReady ? (_myPoints - _weekBase).clamp(0, 99999) : 0;

  Future<void> _loadWeek() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_weekKey)?.split('|');
      if (saved != null && saved.length == 2 && saved[0] == _thisWeek) {
        _weekBase = int.tryParse(saved[1]) ?? _myPoints;
      } else {
        // a new week: today's total is where this week starts
        _weekBase = _myPoints;
        await prefs.setString(_weekKey, '$_thisWeek|$_weekBase');
      }
    } catch (_) {
      _weekBase = _myPoints;
    }
    if (mounted) setState(() => _weekReady = true);
  }

  @override
  void initState() {
    super.initState();
    rules.tick(DateTime.now());
    _loadWeek();
    // re-check the phone-free window twice a minute: it appears when the time starts
    // and the switch turns off when the time is up
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (rules.tick(DateTime.now()) && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  /// the day whose list of plans is open under the strip
  DateTime? _openDay;

  int _minutes(String t) {
    final m = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)?',
      caseSensitive: false,
    ).firstMatch(t);
    if (m == null) return 0;
    var h = int.parse(m[1]!) % 12;
    if (m[3] == null) h = int.parse(m[1]!);
    if (m[3]?.toUpperCase() == 'PM') h += 12;
    return h * 60 + int.parse(m[2]!);
  }

  /// The picture on the big card: the dallah and finjan, on the app's brick red, for every kind of plan.
  ({String asset, bool dark})? _heroArt(Ev? e) =>
      e == null ? null : (asset: 'assets/home/dallah.png', dark: true);

  /// The plan closest to now: today's, otherwise the soonest coming one.
  Ev? _nextEvent() {
    final start = DateTime(today.year, today.month, today.day);
    final up =
        events
            .where(
              (e) => !DateTime(
                e.date.year,
                e.date.month,
                e.date.day,
              ).isBefore(start),
            )
            .toList()
          ..sort((a, b) {
            final c = DateTime(
              a.date.year,
              a.date.month,
              a.date.day,
            ).compareTo(DateTime(b.date.year, b.date.month, b.date.day));
            return c != 0 ? c : _minutes(a.time).compareTo(_minutes(b.time));
          });
    return up.isEmpty ? null : up.first;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 120),
        children: [
          // header
          Row(
            children: [
              Avatar(profile.name, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.homeGreeting(profile.name),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: C.navy,
                  ),
                ),
              ),
              // streak: just a flame with the number
              GestureDetector(
                onTap: () => go(context, const BadgesPage()),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    children: const [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: C.yellow,
                        size: 26,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '7',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: C.navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const NotificationBell(),
            ],
          ),
          if (rules.isActiveAt(DateTime.now()) ||
              rules.punishments.containsKey(profile.name)) ...[
            const SizedBox(height: 14),
            if (rules.isActiveAt(DateTime.now()))
              LCard(
                color: C.yellowTint,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.phonelink_erase_rounded,
                          color: C.brick,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l.homePhoneFreeBanner(
                              rules.from.format(context),
                              rules.to.format(context),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    // kids are warned what happens if they leave the app to use their phone
                    if (!profile.isParent) ...[
                      const SizedBox(height: 8),
                      Text(
                        rules.consequence == 'points'
                            ? l.homePhoneFreeWarningPoints(rules.penalty)
                            : l.homePhoneFreeWarningPunishment(
                                ld(context, rules.punishment),
                              ),
                        style: const TextStyle(
                          color: Color(0xFFC0392B),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            if (rules.punishments.containsKey(profile.name)) ...[
              const SizedBox(height: 8),
              LCard(
                color: C.peachTint,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.gavel_rounded, color: C.brick),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.homePunishmentBanner(
                          ld(context, rules.punishments[profile.name]!),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 18),

          // today: the closest upcoming plan, on a picture that matches what it is
          Builder(
            builder: (context) {
              final next = _nextEvent();
              final art = _heroArt(next);
              final dark = art == null || art.dark; // light text on the dark pictures, dark text on the sand one
              final fg = dark ? Colors.white : C.ink;
              final fgSoft = dark
                  ? Colors.white70
                  : C.ink.withValues(alpha: .7);
              final line = dark ? Colors.white24 : C.ink.withValues(alpha: .15);
              final body = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.homeTodayTitle,
                            style: TextStyle(
                              color: fgSoft,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (next == null)
                            Text(
                              l.homeNoPlans,
                              style: TextStyle(
                                color: fg,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          else ...[
                            GestureDetector(
                              onTap: () async {
                                await go(context, EventDetailsPage(next));
                                if (mounted) setState(() {});
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ld(context, next.title),
                                    style: TextStyle(
                                      color: fg,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    sameDay(next.date, today)
                                        ? ld(context, next.time)
                                        : '${localizedDateLabel(context, next.date)} · ${ld(context, next.time)}',
                                    style: TextStyle(
                                      color: fgSoft,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            PeopleExpand(
                              names: next.going,
                              color: fgSoft,
                              header: Row(
                                children: [
                                  AvatarStack(next.going, size: 36),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      l.homeAttendingCount(
                                        next.going.length,
                                        members.length,
                                      ),
                                      style: TextStyle(
                                        color: fg,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: line, height: 1),
                  const SizedBox(height: 14),
                  GestureDetector(
                    // the points I earned this week; tap to see the leaderboard
                    onTap: () async {
                      await go(context, const LeaderboardPage());
                      if (mounted) setState(() {});
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: fgSoft,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l.homePointsThisWeek(_weekPoints),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fg,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              if (art == null) {
                return LCard(
                  color: C.teal,
                  padding: const EdgeInsets.all(18),
                  child: body,
                );
              }
              // the app's brick red, with the dallah and finjan picture on the left (the text is on the right)
              return ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ColoredBox(
                  color: C.brick,
                  child: Stack(
                    children: [
                      Padding(padding: const EdgeInsets.all(18), child: body),
                    ],
                  ),
                ),
              );
            },
          ),

          // calendar
          SectionTitle(
            l.homeFamilyCalendar,
            action: l.homeAddEvent,
            onAction: _addEvent,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < 3; i++) ...[
                Expanded(
                  child: _day(context, today.add(Duration(days: i)), i == 0),
                ),
                if (i < 2) const SizedBox(width: 10),
              ],
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _openDay == null
                ? const SizedBox(width: double.infinity)
                : _dayList(context, _openDay!),
          ),
          ..._later(context),

          // weekly podcast
          SectionTitle(l.homeWeeklyPodcast),
          LCard(
            padding: const EdgeInsets.all(18),
            onTap: () => go(context, const PodcastPage()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/podcast/channels/fahem.jpg',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.homePodcastTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.homePodcastEpisode,
                            style: const TextStyle(
                              color: C.inkSoft,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: C.inkSoft,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Bar(.5),
                const SizedBox(height: 8),
                // tap to see who listened, right here
                Builder(
                  builder: (context) {
                    final clubs = context.watch<ClubsController>();
                    return PeopleExpand(
                      names: [
                        for (final r in clubs.heardBy) r.name,
                        if (clubs.iHeard) profile.name,
                      ],
                      header: Row(
                        children: [
                          AvatarStack([
                            for (final r in clubs.heardBy) r.name,
                            if (clubs.iHeard) profile.name,
                          ], size: 26),
                          const SizedBox(width: 8),
                          Text(
                            l.homePodcastListenedCount,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: C.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const _TopicAdder(),

          SectionTitle(
            l.leaderboardTitle,
            action: l.homeLeaderboardSeeAll,
            onAction: () async {
              await go(context, const LeaderboardPage());
              if (mounted) setState(() {});
            },
          ),
          const RankList(limit: 3),
        ],
      ),
    );
  }

  Future<void> _addEvent() async {
    await go(context, const AddEventPage());
    if (mounted) setState(() {});
  }

  /// Events further out than the 3-day strip, so nothing added is ever hidden.
  List<Widget> _later(BuildContext context) {
    final cutoff = DateTime(today.year, today.month, today.day + 3);
    final later = events.where((e) => !e.date.isBefore(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (later.isEmpty) return [];
    return [
      const SizedBox(height: 14),
      for (final e in later)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: LCard(
            padding: const EdgeInsets.all(12),
            onTap: () async {
              await go(context, EventDetailsPage(e));
              if (mounted) setState(() {});
            },
            child: Row(
              children: [
                IconBubble(Icons.event_rounded, e.color, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ld(context, e.title),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${localizedDateLabel(context, e.date)} · ${ld(context, e.time)}',
                        style: const TextStyle(color: C.inkSoft, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  /// The plans of one day, opened under the strip.
  Widget _dayList(BuildContext context, DateTime day) {
    final list = events.where((e) => sameDay(e.date, day)).toList()
      ..sort((a, b) => _minutes(a.time).compareTo(_minutes(b.time)));
    if (list.isEmpty) return const SizedBox(width: double.infinity);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: LCard(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizedDateLabel(context, day),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: C.navy,
              ),
            ),
            const SizedBox(height: 4),
            for (final e in list)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await go(context, EventDetailsPage(e));
                  if (mounted) setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: e.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ld(context, e.title),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${ld(context, e.type)} · ${ld(context, e.time)}',
                              style: const TextStyle(
                                color: C.inkSoft,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: C.inkSoft),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _day(BuildContext context, DateTime date, bool isToday) {
    final l = AppLocalizations.of(context);
    final n = date.day;
    final dayLabel = ld(context, weekdayName(date));
    final dayEvents = events.where((e) => sameDay(e.date, date)).toList();
    final open = _openDay != null && sameDay(_openDay!, date);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: dayEvents.isEmpty
          ? null
          : () => setState(() => _openDay = open ? null : date),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 12, 8, 10),
        decoration: BoxDecoration(
          color: isToday ? C.peachTint : C.card,
          borderRadius: BorderRadius.circular(20),
          border: open ? Border.all(color: C.brick, width: 1.5) : null,
        ),
        child: Column(
          children: [
            Text(
              isToday
                  ? l.homeTodayTitle
                  : (sameDay(date, today.add(const Duration(days: 1)))
                        ? l.homeTomorrow
                        : dayLabel),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isToday ? C.brick : C.inkSoft,
              ),
            ),
            const SizedBox(height: 6),
            isToday
                ? CircleAvatar(
                    radius: 15,
                    backgroundColor: C.brick,
                    child: Text(
                      '$n',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : Text(
                    '$n',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            const SizedBox(height: 10),
            // one dot per plan, in the plan's color
            if (dayEvents.isEmpty)
              Text(
                l.homeNoEvents,
                style: const TextStyle(fontSize: 11, color: C.inkSoft),
              )
            else
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final e in dayEvents)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: e.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---- 07 event details
class EventDetailsPage extends StatefulWidget {
  final Ev e;
  const EventDetailsPage(this.e, {super.key});
  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final e = widget.e;
    final me = e.going.contains(profile.name);
    return Page1(
      l.eventDetailsTitle,
      [
        const SizedBox(height: 10),
        Center(child: IconBubble(Icons.event_rounded, e.color, size: 72)),
        const SizedBox(height: 16),
        Center(
          child: Text(
            ld(context, e.title),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            '${localizedDateLabel(context, e.date)} · ${ld(context, e.time)}',
            style: const TextStyle(
              color: C.inkSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Pill(
            ld(context, e.type),
            color: e.color.withValues(alpha: .25),
          ),
        ),
        const SizedBox(height: 24),
        // tap the pictures to see who is coming, right here
        PeopleExpand(
          names: e.going,
          header: Column(
            children: [
              Center(child: AvatarStack(e.going, size: 46)),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  l.eventDetailsGoingCount(e.going.length),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
      bottom: Btn(
        me ? l.eventDetailsImIn : l.eventDetailsImComing,
        icon: me ? Icons.check_rounded : null,
        color: me ? C.teal : C.brick,
        onTap: () {
          // the race is per event; with the database connected it is shared by the family
          final key = 'event:${e.id ?? '${e.title}|${e.date}'}';
          setState(() {
            if (me) {
              e.going.remove(profile.name);
            } else {
              e.going.add(profile.name);
            }
          });
          if (e.id != null) Backend.setGoing(e.id!, !me);
          if (me) {
            revokeFirst(key, profile.name);
          } else {
            pointsToast(context, claimFirst(key, profile.name));
          }
        },
      ),
    );
  }
}

// ---- 08 add event
class AddEventPage extends StatefulWidget {
  /// Filled in when the page is opened for something specific (an outing from the suggestions).
  final String? initialName;
  final String? initialType;
  const AddEventPage({super.key, this.initialName, this.initialType});
  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  late String _type = eventTypes.contains(widget.initialType)
      ? widget.initialType!
      : eventTypes.first;
  DateTime _date = DateTime(today.year, today.month, today.day);
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);
  late final _name = TextEditingController(text: widget.initialName ?? '');
  bool _calOpen = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(
      l.addEventTitle,
      [
        Text(
          l.addEventTypeLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in eventTypes)
              Choice(
                ld(context, t),
                _type == t,
                () => setState(() => _type = t),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Field(
          l.addEventNameLabel,
          hint: l.addEventNameHint,
          controller: _name,
          onChanged: (_) => setState(() {}),
        ),
        Text(
          l.addEventDateLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        LCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => setState(() => _calOpen = !_calOpen),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: C.brick),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizedDateLabel(context, _date),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _calOpen ? .5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.expand_more_rounded,
                          color: C.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _calOpen
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                        child: _InlineCalendar(
                          selected: _date,
                          first: DateTime(today.year, today.month, today.day),
                          last: DateTime(
                            today.year + 2,
                            today.month,
                            today.day,
                          ),
                          onPick: (d) => setState(() {
                            _date = d;
                            _calOpen = false;
                          }),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l.addEventTimeLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        LCard(
          onTap: () async {
            final t = await showTimePicker(
              context: context,
              initialTime: _time,
            );
            if (t != null) setState(() => _time = t);
          },
          child: Row(
            children: [
              const Icon(Icons.schedule_rounded, color: C.inkSoft),
              const SizedBox(width: 12),
              Text(
                _time.format(context),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
      bottom: Btn(
        l.addEventSubmit,
        enabled: _name.text.trim().isNotEmpty,
        onTap: () {
          final title = _name.text.trim();
          final time = _time.format(context);
          if (sharedLive) {
            Backend.addEvent(
              title,
              _date,
              time,
              _type,
            ); // shared; the list refreshes itself
          }
          events.add(
            Ev(
              title,
              _date,
              time,
              _type,
              [C.teal, C.yellow, C.peach, C.sage][eventTypes.indexOf(_type) %
                  4],
              [profile.name],
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Under the weekly podcast: a box to add a topic the family should talk about. It goes to tonight's
/// topics, to "our topics" in the topics screen, and to "my topics" on the profile.
class _TopicAdder extends StatefulWidget {
  const _TopicAdder();
  @override
  State<_TopicAdder> createState() => _TopicAdderState();
}

class _TopicAdderState extends State<_TopicAdder> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _add() {
    final text = _ctl.text.trim();
    if (text.isEmpty) return;
    final l = AppLocalizations.of(context);
    context.read<TopicsController>().addMyTopic(text, select: false);
    _ctl.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.homeAddTopicAdded)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.homeAddTopicTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      l.homeAddTopicDesc,
                      style: const TextStyle(color: C.inkSoft, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctl,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _add(),
                  decoration: InputDecoration(
                    hintText: l.homeAddTopicHint,
                    filled: true,
                    fillColor: C.cream,
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
                onPressed: _add,
                style: FilledButton.styleFrom(
                  backgroundColor: C.brick,
                  minimumSize: const Size(76, 52),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  l.homeAddTopicButton,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A month grid that opens inside the page (no pop-up): arrows move between months,
/// tapping a day picks it. Styled with the app's own colors.
class _InlineCalendar extends StatefulWidget {
  final DateTime selected, first, last;
  final ValueChanged<DateTime> onPick;
  const _InlineCalendar({
    required this.selected,
    required this.first,
    required this.last,
    required this.onPick,
  });
  @override
  State<_InlineCalendar> createState() => _InlineCalendarState();
}

class _InlineCalendarState extends State<_InlineCalendar> {
  late DateTime _month = DateTime(widget.selected.year, widget.selected.month);

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final m = MaterialLocalizations.of(context);
    final canPrev = DateTime(
      _month.year,
      _month.month,
    ).isAfter(DateTime(widget.first.year, widget.first.month));
    final canNext = DateTime(
      _month.year,
      _month.month + 1,
    ).isBefore(DateTime(widget.last.year, widget.last.month + 1));
    final lead =
        (DateTime(_month.year, _month.month).weekday % 7 -
            m.firstDayOfWeekIndex +
            7) %
        7;
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final rows = ((lead + days) / 7).ceil();
    final firstDay = DateTime(
      widget.first.year,
      widget.first.month,
      widget.first.day,
    );
    final lastDay = DateTime(
      widget.last.year,
      widget.last.month,
      widget.last.day,
    );
    return Column(
      children: [
        const Divider(height: 1, color: C.line),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: canPrev
                  ? () => setState(
                      () => _month = DateTime(_month.year, _month.month - 1),
                    )
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
              color: C.navy,
            ),
            Expanded(
              child: Text(
                m.formatMonthYear(_month),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: C.navy,
                ),
              ),
            ),
            IconButton(
              onPressed: canNext
                  ? () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1),
                    )
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
              color: C.navy,
            ),
          ],
        ),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    m.narrowWeekdays[(m.firstDayOfWeekIndex + i) % 7],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: C.inkSoft,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final day = r * 7 + c - lead + 1;
                      if (day < 1 || day > days)
                        return const SizedBox(height: 40);
                      final d = DateTime(_month.year, _month.month, day);
                      final ok = !d.isBefore(firstDay) && !d.isAfter(lastDay);
                      final sel = _same(d, widget.selected);
                      final isToday = _same(d, firstDay);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: ok ? () => widget.onPick(d) : null,
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          child: Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: sel ? C.brick : null,
                              border: !sel && isToday
                                  ? Border.all(color: C.brick, width: 1.5)
                                  : null,
                            ),
                            child: Text(
                              m.formatDecimal(day),
                              style: TextStyle(
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: sel
                                    ? Colors.white
                                    : (ok ? C.ink : C.line),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// ---- 32 weekly recap
class WeeklyRecapPage extends StatelessWidget {
  const WeeklyRecapPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget tile(String v, String label, IconData i, Color c) => Expanded(
      child: LCard(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(i, color: c),
            const SizedBox(height: 8),
            Text(
              v,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: const TextStyle(
                color: C.inkSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
    return Page1(l.recapTitle, [
      LCard(
        color: C.navy,
        padding: const EdgeInsets.symmetric(vertical: 26),
        child: Center(
          child: Text(
            l.recapHeroTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          tile('12', l.recapChats, Icons.chat_bubble_rounded, C.teal),
          const SizedBox(width: 12),
          tile('24', l.recapPhotos, Icons.camera_alt_rounded, C.navy),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          tile(
            '6',
            l.recapActiveDays,
            Icons.local_fire_department_rounded,
            C.brick,
          ),
          const SizedBox(width: 12),
          tile('3/6', l.recapListened, Icons.headphones_rounded, C.teal),
        ],
      ),
      const SizedBox(height: 12),
      LCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.recapMostShared,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                AvatarStack([
                  for (final m in members.take(4)) m.name,
                ], size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.recapEveryonePlayed,
                    style: const TextStyle(
                      color: C.inkSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Btn(
        l.recapSeeBadges,
        outlined: true,
        onTap: () => go(context, const BadgesPage()),
      ),
    ]);
  }
}
