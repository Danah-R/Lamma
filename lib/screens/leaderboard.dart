import 'package:flutter/material.dart';
import '../data.dart';
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
import '../theme.dart';
import '../widgets.dart';

List<Member> get ranked => [...members]..sort((a, b) => b.points.compareTo(a.points));

/// The kid in first place: parents don't compete for the reward.
Member? get leader {
  for (final m in ranked) {
    if (!m.isParent) return m;
  }
  return null;
}

/// Plain ranked list: 1, 2, 3... with name and points.
class RankList extends StatelessWidget {
  final int? limit;
  const RankList({super.key, this.limit});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final list = limit == null ? ranked : ranked.take(limit!).toList();
    return Column(children: [
      for (var i = 0; i < list.length; i++) ...[
        if (i > 0) const Divider(height: 1, color: C.beige),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            SizedBox(
                width: 30,
                child: Text('${i + 1}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: C.terracotta))),
            Avatar(list[i].name, size: 34),
            const SizedBox(width: 12),
            Expanded(
                child: Text(ld(context, list[i].name), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
            Text(l.leaderboardPts(list[i].points), style: const TextStyle(fontWeight: FontWeight.w800)),
          ]),
        ),
      ],
    ]);
  }
}

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});
  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(l.leaderboardTitle, [
        LCard(
          color: C.mustardTint,
          child: Row(children: [
            const Icon(Icons.emoji_events_rounded, color: C.terracotta, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.leaderboardCycleReward(ld(context, rules.cycle)),
                    style: const TextStyle(color: C.inkSoft, fontSize: 12, fontWeight: FontWeight.w700)),
                Text(ld(context, rules.reward), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ]),
            ),
          ]),
        ),
        if (rules.lastWinner != null) ...[
          const SizedBox(height: 10),
          LCard(
            child: Row(children: [
              const Icon(Icons.celebration_rounded, color: C.teal),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(l.leaderboardLastWinner(ld(context, rules.lastWinner!), ld(context, rules.lastReward!)),
                      style: const TextStyle(fontWeight: FontWeight.w700))),
            ]),
          ),
        ],
        SectionTitle(l.leaderboardRanking),
        const RankList(),
        if (profile.isParent) ...[
          const SizedBox(height: 20),
          Btn(l.accountParentControlsTitle, icon: Icons.shield_rounded, color: C.navy, onTap: () async {
            await go(context, const ParentControlsPage());
            if (mounted) setState(() {});
          }),
        ],
      ]);
  }
}

// ---- parent-only controls
class ParentControlsPage extends StatefulWidget {
  const ParentControlsPage({super.key});
  @override
  State<ParentControlsPage> createState() => _ParentControlsPageState();
}

class _ParentControlsPageState extends State<ParentControlsPage> {
  String? _who;
  final _custom = TextEditingController(text: rules.punishment);
  final _customReward = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    _customReward.dispose();
    super.dispose();
  }

  List<Member> get _kids => members.where((m) => !m.isParent).toList();

  Future<void> _pickTime(bool from) async {
    final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 20, minute: 0));
    if (t == null || !mounted) return;
    setState(() => from ? rules.from = t.format(context) : rules.to = t.format(context));
  }

  void _apply(AppLocalizations l) {
    final who = _who!;
    final v = rules.consequence == 'points'
        ? Violation(who, 'Lost points', '-${rules.penalty} pts', 'Just now')
        : Violation(who, 'Punishment', rules.punishment, 'Just now');
    if (rules.consequence == 'points') {
      addPoints(who, -rules.penalty);
    } else {
      rules.punishments[who] = rules.punishment;
    }
    rules.violations.insert(0, v);
    setState(() => _who = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.parentControlsViolationSnackbar(
            ld(context, who), ld(context, v.kind).toLowerCase(), ld(context, v.detail)))));
  }

  void _giveReward(AppLocalizations l) {
    final w = leader;
    if (w == null) return;
    rules.lastWinner = w.name;
    rules.lastReward = rules.reward;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.leaderboardRewardSnackbar(ld(context, w.name), ld(context, rules.reward)))));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final points = rules.consequence == 'points';
    return Page1(l.accountParentControlsTitle, [
      // phone-free time
      LCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.phonelink_erase_rounded, color: C.terracotta),
            const SizedBox(width: 12),
            Expanded(
                child: Text(l.parentControlsPhoneFreeTime, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
            Switch(
                value: rules.phoneFree,
                activeThumbColor: Colors.white,
                activeTrackColor: C.teal,
                onChanged: (v) => setState(() => rules.phoneFree = v)),
          ]),
          if (rules.phoneFree) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _timeBox(l.parentControlsFrom, ld(context, rules.from), () => _pickTime(true))),
              const SizedBox(width: 10),
              Expanded(child: _timeBox(l.parentControlsUntil, ld(context, rules.to), () => _pickTime(false))),
            ]),
            const SizedBox(height: 16),
            Text(l.parentControlsIfPhoneUsed, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              Choice(l.parentControlsLosePointsChoice, points, () => setState(() => rules.consequence = 'points')),
              Choice(ld(context, 'Punishment'), !points, () => setState(() => rules.consequence = 'punishment')),
            ]),
            const SizedBox(height: 14),
            if (points)
              Row(children: [
                Expanded(child: Text(l.parentControlsPointsLost, style: const TextStyle(fontWeight: FontWeight.w700))),
                IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: C.beige, foregroundColor: C.ink),
                    onPressed: () => setState(() => rules.penalty = (rules.penalty - 5).clamp(5, 50)),
                    icon: const Icon(Icons.remove_rounded)),
                SizedBox(
                    width: 48,
                    child: Text('-${rules.penalty}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: C.beige, foregroundColor: C.ink),
                    onPressed: () => setState(() => rules.penalty = (rules.penalty + 5).clamp(5, 50)),
                    icon: const Icon(Icons.add_rounded)),
              ])
            else ...[
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final p in punishmentOptions)
                  Choice(ld(context, p), rules.punishment == p, () => setState(() {
                        rules.punishment = p;
                        _custom.text = p;
                      })),
              ]),
              const SizedBox(height: 10),
              TextField(
                controller: _custom,
                onChanged: (v) => rules.punishment = v.trim().isEmpty ? punishmentOptions.first : v.trim(),
                decoration: InputDecoration(hintText: l.parentControlsOrWriteOwn),
              ),
            ],
          ],
        ]),
      ),

      // record a violation
      SectionTitle(l.parentControlsRecordViolation),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final k in _kids) Choice(ld(context, k.name), _who == k.name, () => setState(() => _who = k.name)),
      ]),
      const SizedBox(height: 12),
      Btn(points ? l.parentControlsTakeAwayPoints(rules.penalty) : l.parentControlsGivePunishment,
          icon: Icons.phone_disabled_rounded,
          enabled: _who != null && rules.phoneFree,
          onTap: () => _apply(l)),

      // log
      if (rules.violations.isNotEmpty) ...[
        SectionTitle(l.parentControlsRecent),
        for (final v in rules.violations.take(6))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LCard(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Avatar(v.who, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${ld(context, v.who)} · ${ld(context, v.kind)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('${ld(context, v.detail)} · ${ld(context, v.when)}', style: const TextStyle(color: C.inkSoft, fontSize: 12)),
                  ]),
                ),
                if (v.kind == 'Punishment' && !v.done)
                  TextButton(
                      onPressed: () => setState(() {
                            v.done = true;
                            rules.punishments.remove(v.who);
                          }),
                      child: Text(l.parentControlsDone, style: const TextStyle(color: C.teal, fontWeight: FontWeight.w800)))
                else if (v.done)
                  const Icon(Icons.check_circle_rounded, color: C.green),
              ]),
            ),
          ),
      ],

      // rewards
      SectionTitle(l.parentControlsLeaderboardReward),
      Text(l.parentControlsWinningCycle, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        for (final c in ['Weekly', 'Monthly'])
          Choice(ld(context, c), rules.cycle == c, () => setState(() => rules.cycle = c)),
      ]),
      const SizedBox(height: 16),
      Text(l.parentControlsRewardForWinner, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final r in rewardOptions)
          Choice(ld(context, r), rules.reward == r, () => setState(() => rules.reward = r), color: C.teal),
      ]),
      const SizedBox(height: 10),
      TextField(
        controller: _customReward,
        onChanged: (v) {
          if (v.trim().isNotEmpty) setState(() => rules.reward = v.trim());
        },
        decoration: InputDecoration(hintText: l.parentControlsOrWriteOwnReward),
      ),
      const SizedBox(height: 14),
      Btn(leader == null ? l.leaderboardNoWinnerYet : l.leaderboardRewardNow(ld(context, leader!.name)),
          icon: Icons.emoji_events_rounded, color: C.teal, enabled: leader != null, onTap: () => _giveReward(l)),
    ]);
  }

  Widget _timeBox(String label, String value, VoidCallback onTap) => LCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: C.inkSoft, fontSize: 12, fontWeight: FontWeight.w700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ]),
      );
}
