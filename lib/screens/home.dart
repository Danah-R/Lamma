import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'account.dart';
import 'activities.dart';

class HomePage extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const HomePage({super.key, required this.onSwitchTab});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _tonight = ['Noura', 'Mohammed', 'Abdullah', 'Amina', 'Sarah'];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 120), children: [
          // header
          Row(children: [
            Avatar(profile.name, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Good evening, ${profile.name}',
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                Text(profile.family,
                    style: const TextStyle(fontSize: 13, color: C.inkSoft, fontWeight: FontWeight.w700)),
              ]),
            ),
            BellButton(() => go(context, const NotificationsPage())),
          ]),
          const SizedBox(height: 18),

          // today with the family
          LCard(
            color: C.terracotta,
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Today with the family',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Family night · 8:00 PM',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Row(children: [
                const AvatarStack(_tonight, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('${_tonight.length} of ${members.length} attending',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ]),
              const Divider(color: Colors.white24, height: 28),
              GestureDetector(
                onTap: () => go(context, const BadgesPage()),
                behavior: HitTestBehavior.opaque,
                child: const Row(children: [
                  Icon(Icons.local_fire_department_rounded, color: C.mustardTint, size: 20),
                  SizedBox(width: 6),
                  Text('7 day streak', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  SizedBox(width: 12),
                  Icon(Icons.chat_bubble_outline_rounded, color: Colors.white70, size: 18),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text('12 interactions this week',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
            ]),
          ),

          // calendar
          SectionTitle('Family calendar', action: '+ Add event', onAction: _addEvent),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final d in calendarDays) ...[
              Expanded(child: _day(d.$1, d.$2)),
              if (d != calendarDays.last) const SizedBox(width: 10),
            ],
          ]),

          // weekly podcast
          const SectionTitle('Weekly podcast'),
          LCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const IconBubble(Icons.headphones_rounded, C.terracotta),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('What makes us laugh together?',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text('Episode 12 · 32 min', style: TextStyle(color: C.inkSoft)),
                  ]),
                ),
              ]),
              const SizedBox(height: 14),
              const Bar(.5),
              const SizedBox(height: 6),
              const Text('3 of 6 listened',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.inkSoft)),
              const SizedBox(height: 14),
              Btn('Start listening', icon: Icons.play_arrow_rounded,
                  onTap: () => go(context, const PodcastPage())),
            ]),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 26),
            child: Text('The best memories start with a simple question',
                textAlign: TextAlign.center,
                style: TextStyle(color: C.terracotta, fontWeight: FontWeight.w800, fontSize: 15)),
          ),

          // activity
          const SectionTitle('Family activity'),
          const LCard(
            child: Column(children: [
              _Feed('Sarah', 'Sarah shared a photo'),
              Divider(color: C.beige, height: 22),
              _Feed('Mohammed', "Mohammed finished today's challenge"),
              Divider(color: C.beige, height: 22),
              _Feed('Amina', 'Amina listened to the weekly podcast'),
            ]),
          ),
          const SizedBox(height: 16),
          Btn('Your week in Lamma',
              color: C.navy, onTap: () => go(context, const WeeklyRecapPage())),
        ]),
      );

  Future<void> _addEvent() async {
    await go(context, const AddEventPage());
    if (mounted) setState(() {});
  }

  Widget _day(int n, String label) {
    final today = n == 12;
    final dayEvents = events.where((e) => e.day == n).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      decoration: BoxDecoration(
        color: today ? C.coralTint : C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: today ? C.coral : C.beige, width: 1.5),
      ),
      child: Column(children: [
        Text(today ? '$label · Today' : label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, color: today ? C.terracotta : C.inkSoft)),
        const SizedBox(height: 6),
        today
            ? CircleAvatar(
                radius: 15,
                backgroundColor: C.terracotta,
                child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))
            : Text('$n', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        if (dayEvents.isEmpty)
          const Text('No events', style: TextStyle(fontSize: 11, color: C.inkSoft))
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
                  Text(e.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  Text(e.time, style: const TextStyle(fontSize: 10, color: C.inkSoft)),
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
    final e = widget.e;
    final me = e.going.contains(profile.name);
    final day = calendarDays.firstWhere((d) => d.$1 == e.day, orElse: () => (e.day, '')).$2;
    return Page1('Event details', [
      const SizedBox(height: 10),
      Center(child: IconBubble(Icons.event_rounded, e.color, size: 72)),
      const SizedBox(height: 16),
      Center(child: Text(e.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900))),
      const SizedBox(height: 6),
      Center(
          child: Text('$day ${e.day} · ${e.time}',
              style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700))),
      const SizedBox(height: 8),
      Center(child: Pill(e.type, color: e.color.withValues(alpha: .25))),
      const SizedBox(height: 24),
      Center(child: AvatarStack(e.going, size: 46)),
      const SizedBox(height: 8),
      Center(
          child: Text('${e.going.length} of the family are coming',
              style: const TextStyle(fontWeight: FontWeight.w700))),
    ],
        bottom: Btn(me ? "You're in" : "I'm coming",
            icon: me ? Icons.check_rounded : null,
            color: me ? C.green : C.terracotta,
            onTap: () => setState(() => me ? e.going.remove(profile.name) : e.going.add(profile.name))));
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
  int _day = 12;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Page1('New event', [
        const Text('Event type', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in eventTypes) Choice(t, _type == t, () => setState(() => _type = t)),
        ]),
        const SizedBox(height: 18),
        Field('Name', hint: 'Event name...', controller: _name, onChanged: (_) => setState(() {})),
        const Text('Day', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final d in calendarDays)
            Choice('${d.$2} ${d.$1}', _day == d.$1, () => setState(() => _day = d.$1)),
        ]),
        const SizedBox(height: 18),
        const Text('Time', style: TextStyle(fontWeight: FontWeight.w700)),
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
          bottom: Btn('Add to calendar', enabled: _name.text.trim().isNotEmpty, onTap: () {
            events.add(Ev(_name.text.trim(), _day, _time.format(context), _type,
                [C.teal, C.mustard, C.coral, C.green][eventTypes.indexOf(_type) % 4], [profile.name]));
            Navigator.pop(context);
          }));
}

// ---- 11 notifications
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    Widget n(IconData i, Color c, String t) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LCard(
              child: Row(children: [
            IconBubble(i, c, size: 40),
            const SizedBox(width: 12),
            Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700))),
          ])),
        );
    return Page1('Notifications', [
      n(Icons.headphones_rounded, C.terracotta, "This week's episode is ready"),
      n(Icons.camera_alt_rounded, C.teal, 'Sarah shared a moment'),
      n(Icons.favorite_rounded, C.mustard, 'You earned the Lamma spirit badge'),
      const SizedBox(height: 12),
      const Center(
          child: Text("That's all for now",
              style: TextStyle(color: C.inkSoft, fontSize: 12, fontWeight: FontWeight.w600))),
    ]);
  }
}

// ---- 32 weekly recap
class WeeklyRecapPage extends StatelessWidget {
  const WeeklyRecapPage({super.key});
  @override
  Widget build(BuildContext context) {
    Widget tile(String v, String l, IconData i, Color c) => Expanded(
          child: LCard(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(children: [
              Icon(i, color: c),
              const SizedBox(height: 8),
              Text(v, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              Text(l, style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700)),
            ]),
          ),
        );
    return Page1('Your week', [
      LCard(
        color: C.navy,
        padding: const EdgeInsets.symmetric(vertical: 26),
        child: const Center(
            child: Text('Your week in Lamma',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))),
      ),
      const SizedBox(height: 12),
      Row(children: [
        tile('12', 'Chats', Icons.chat_bubble_rounded, C.teal),
        const SizedBox(width: 12),
        tile('24', 'Photos', Icons.camera_alt_rounded, C.terracotta),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        tile('6', 'Active days', Icons.local_fire_department_rounded, C.mustard),
        const SizedBox(width: 12),
        tile('3/6', 'Listened', Icons.headphones_rounded, C.coral),
      ]),
      const SizedBox(height: 12),
      LCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Most shared: Talks with Aziz', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            AvatarStack([for (final m in members.take(4)) m.name], size: 38),
            const SizedBox(width: 10),
            const Expanded(
                child: Text('Everyone played it', style: TextStyle(color: C.inkSoft, fontWeight: FontWeight.w600))),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      Btn('See badges', outlined: true, onTap: () => go(context, const BadgesPage())),
    ]);
  }
}
