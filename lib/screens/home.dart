import 'package:flutter/material.dart';
import '../data.dart';
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
import '../theme.dart';
import '../widgets.dart';
import 'account.dart';
import 'activities.dart';
import 'leaderboard.dart';

class HomePage extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const HomePage({super.key, required this.onSwitchTab});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> get _tonight =>
      [n('daughter'), n('brother'), n('dad'), n('mom'), n('girl')];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
        body: ListView(padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 120), children: [
          // header
          Row(children: [
            Avatar(profile.name, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.homeGreeting(profile.name),
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                Text(ld(context, profile.family),
                    style: const TextStyle(fontSize: 13, color: C.inkSoft, fontWeight: FontWeight.w700)),
              ]),
            ),
            BellButton(() => go(context, const NotificationsPage())),
          ]),
          if (rules.phoneFree || rules.punishments.containsKey(profile.name)) ...[
            const SizedBox(height: 14),
            if (rules.phoneFree)
              LCard(
                color: C.mustardTint,
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  const Icon(Icons.phonelink_erase_rounded, color: C.terracotta),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l.homePhoneFreeBanner(ld(context, rules.from), ld(context, rules.to)),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
            if (rules.punishments.containsKey(profile.name)) ...[
              const SizedBox(height: 8),
              LCard(
                color: C.coralTint,
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  const Icon(Icons.gavel_rounded, color: C.terracotta),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l.homePunishmentBanner(ld(context, rules.punishments[profile.name]!)),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
            ],
          ],
          const SizedBox(height: 18),

          // today with the family
          LCard(
            color: C.teal,
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.homeTodayWithFamily,
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(l.homeFamilyNightTime,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Row(children: [
                AvatarStack(_tonight, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l.homeAttendingCount(_tonight.length, members.length),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ]),
              const Divider(color: Colors.white24, height: 28),
              GestureDetector(
                onTap: () => go(context, const BadgesPage()),
                behavior: HitTestBehavior.opaque,
                child: Row(children: [
                  const Icon(Icons.local_fire_department_rounded, color: C.mustardTint, size: 20),
                  const SizedBox(width: 6),
                  Text(l.homeStreak, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 12),
                  const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l.homeInteractions,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
            ]),
          ),

          // calendar
          SectionTitle(l.homeFamilyCalendar, action: l.homeAddEvent, onAction: _addEvent),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var i = 0; i < 3; i++) ...[
              Expanded(child: _day(context, today.add(Duration(days: i)), i == 0)),
              if (i < 2) const SizedBox(width: 10),
            ],
          ]),
          ..._later(context),

          // weekly podcast
          SectionTitle(l.homeWeeklyPodcast),
          LCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const IconBubble(Icons.headphones_rounded, C.terracotta),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.homePodcastTitle,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(l.homePodcastEpisode, style: const TextStyle(color: C.inkSoft)),
                  ]),
                ),
              ]),
              const SizedBox(height: 14),
              const Bar(.5),
              const SizedBox(height: 6),
              Text(l.homePodcastListenedCount,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.inkSoft)),
              const SizedBox(height: 14),
              Btn(l.homeStartListening, icon: Icons.play_arrow_rounded,
                  onTap: () => go(context, const PodcastPage())),
            ]),
          ),

          SectionTitle(l.leaderboardTitle, action: l.homeLeaderboardSeeAll, onAction: () async {
            await go(context, const LeaderboardPage());
            if (mounted) setState(() {});
          }),
          const RankList(limit: 3),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 26),
            child: Text(l.homeMemoriesQuote,
                textAlign: TextAlign.center,
                style: const TextStyle(color: C.terracotta, fontWeight: FontWeight.w800, fontSize: 15)),
          ),

          // activity
          SectionTitle(l.homeFamilyActivity),
          LCard(
            child: Column(children: [
              _Feed(n('girl'), l.homeFeedPhoto(ld(context, n('girl')))),
              const Divider(color: C.beige, height: 22),
              _Feed(n('brother'), l.homeFeedChallenge(ld(context, n('brother')))),
              const Divider(color: C.beige, height: 22),
              _Feed(n('mom'), l.homeFeedPodcast(ld(context, n('mom')))),
            ]),
          ),
          const SizedBox(height: 16),
          Btn(l.homeYourWeekButton,
              color: C.navy, onTap: () => go(context, const WeeklyRecapPage())),
        ]),
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
            child: Row(children: [
              IconBubble(Icons.event_rounded, e.color, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ld(context, e.title), style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text('${localizedDateLabel(context, e.date)} · ${ld(context, e.time)}',
                      style: const TextStyle(color: C.inkSoft, fontSize: 12)),
                ]),
              ),
            ]),
          ),
        ),
    ];
  }

  Widget _day(BuildContext context, DateTime date, bool isToday) {
    final l = AppLocalizations.of(context);
    final n = date.day;
    final dayLabel = ld(context, weekdayName(date));
    final dayEvents = events.where((e) => sameDay(e.date, date)).toList();
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 12, 8, 10),
      decoration: BoxDecoration(
        color: isToday ? C.coralTint : C.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        Text(isToday ? '$dayLabel ${l.homeDayToday}' : dayLabel,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, color: isToday ? C.terracotta : C.inkSoft)),
        const SizedBox(height: 6),
        isToday
            ? CircleAvatar(
                radius: 15,
                backgroundColor: C.terracotta,
                child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))
            : Text('$n', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        if (dayEvents.isEmpty)
          Text(l.homeNoEvents, style: const TextStyle(fontSize: 11, color: C.inkSoft))
        else
          for (final e in dayEvents)
            GestureDetector(
              onTap: () async {
                await go(context, EventDetailsPage(e));
                if (mounted) setState(() {});
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                    color: e.color.withValues(alpha: .28), borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Text(ld(context, e.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  Text(ld(context, e.time), style: const TextStyle(fontSize: 10, color: C.inkSoft)),
                ]),
              ),
            ),
      ]),
    );
  }
}

class _Feed extends StatelessWidget {
  final String who, text;
  const _Feed(this.who, this.text);
  @override
  Widget build(BuildContext context) => Row(children: [
        Avatar(who, size: 38),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]);
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
    return Page1(l.eventDetailsTitle, [
      const SizedBox(height: 10),
      Center(child: IconBubble(Icons.event_rounded, e.color, size: 72)),
      const SizedBox(height: 16),
      Center(child: Text(ld(context, e.title), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900))),
      const SizedBox(height: 6),
      Center(
          child: Text('${localizedDateLabel(context, e.date)} · ${ld(context, e.time)}',
              style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700))),
      const SizedBox(height: 8),
      Center(child: Pill(ld(context, e.type), color: e.color.withValues(alpha: .25))),
      const SizedBox(height: 24),
      Center(child: AvatarStack(e.going, size: 46)),
      const SizedBox(height: 8),
      Center(
          child: Text(l.eventDetailsGoingCount(e.going.length),
              style: const TextStyle(fontWeight: FontWeight.w700))),
    ],
        bottom: Btn(me ? l.eventDetailsImIn : l.eventDetailsImComing,
            icon: me ? Icons.check_rounded : null,
            color: me ? C.green : C.terracotta,
            onTap: () => setState(() {
              if (me) {
                e.going.remove(profile.name);
                addPoints(profile.name, -5);
              } else {
                e.going.add(profile.name);
                addPoints(profile.name, 5);
              }
            })));
  }
}

// ---- 08 add event
class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});
  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  String _type = eventTypes.first;
  DateTime _date = DateTime(today.year, today.month, today.day);
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(l.addEventTitle, [
        Text(l.addEventTypeLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in eventTypes) Choice(ld(context, t), _type == t, () => setState(() => _type = t)),
        ]),
        const SizedBox(height: 18),
        Field(l.addEventNameLabel, hint: l.addEventNameHint, controller: _name, onChanged: (_) => setState(() {})),
        Text(l.addEventDateLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        LCard(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(today.year, today.month, today.day),
              lastDate: DateTime(today.year + 2, today.month, today.day),
            );
            if (d != null) setState(() => _date = d);
          },
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded, color: C.inkSoft),
            const SizedBox(width: 12),
            Expanded(child: Text(localizedDateLabel(context, _date), style: const TextStyle(fontWeight: FontWeight.w800))),
            const Icon(Icons.expand_more_rounded, color: C.inkSoft),
          ]),
        ),
        const SizedBox(height: 18),
        Text(l.addEventTimeLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        LCard(
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: _time);
            if (t != null) setState(() => _time = t);
          },
          child: Row(children: [
            const Icon(Icons.schedule_rounded, color: C.inkSoft),
            const SizedBox(width: 12),
            Text(_time.format(context), style: const TextStyle(fontWeight: FontWeight.w800)),
          ]),
        ),
      ],
          bottom: Btn(l.addEventSubmit, enabled: _name.text.trim().isNotEmpty, onTap: () {
            events.add(Ev(_name.text.trim(), _date, _time.format(context), _type,
                [C.teal, C.mustard, C.coral, C.green][eventTypes.indexOf(_type) % 4], [profile.name]));
            Navigator.pop(context);
          }));
  }
}

// ---- 11 notifications
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget n2(IconData i, Color c, String t) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LCard(
              child: Row(children: [
            IconBubble(i, c, size: 40),
            const SizedBox(width: 12),
            Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700))),
          ])),
        );
    return Page1(l.notificationsTitle, [
      n2(Icons.headphones_rounded, C.terracotta, l.notifEpisodeReady),
      n2(Icons.camera_alt_rounded, C.teal, l.notifMomentShared(ld(context, n('girl')))),
      n2(Icons.favorite_rounded, C.mustard, l.notifBadgeEarned),
      const SizedBox(height: 12),
      Center(
          child: Text(l.notifEmpty,
              style: const TextStyle(color: C.inkSoft, fontSize: 12, fontWeight: FontWeight.w600))),
    ]);
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
            child: Column(children: [
              Icon(i, color: c),
              const SizedBox(height: 8),
              Text(v, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700)),
            ]),
          ),
        );
    return Page1(l.recapTitle, [
      LCard(
        color: C.navy,
        padding: const EdgeInsets.symmetric(vertical: 26),
        child: Center(
            child: Text(l.recapHeroTitle,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))),
      ),
      const SizedBox(height: 12),
      Row(children: [
        tile('12', l.recapChats, Icons.chat_bubble_rounded, C.teal),
        const SizedBox(width: 12),
        tile('24', l.recapPhotos, Icons.camera_alt_rounded, C.terracotta),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        tile('6', l.recapActiveDays, Icons.local_fire_department_rounded, C.mustard),
        const SizedBox(width: 12),
        tile('3/6', l.recapListened, Icons.headphones_rounded, C.coral),
      ]),
      const SizedBox(height: 12),
      LCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.recapMostShared, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            AvatarStack([for (final m in members.take(4)) m.name], size: 38),
            const SizedBox(width: 10),
            Expanded(
                child: Text(l.recapEveryonePlayed, style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w600))),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      Btn(l.recapSeeBadges, outlined: true, onTap: () => go(context, const BadgesPage())),
    ]);
  }
}
