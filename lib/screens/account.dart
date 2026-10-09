import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'leaderboard.dart';

// ---- 28/29 profile
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 120), children: [
          const TabHeader('Account', 'Your Lamma profile'),
          const SizedBox(height: 12),
          Center(child: Avatar(profile.name, size: 104)),
          const SizedBox(height: 12),
          Center(child: Text(profile.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
          Center(
              child: Text('${profile.age} years · Lamma spirit',
                  style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w600))),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: () async {
                await go(context, const DesignAvatarPage());
                if (mounted) setState(() {});
              },
              child: const Text('Design your character',
                  style: TextStyle(color: C.terracotta, fontWeight: FontWeight.w800)),
            ),
          ),
          const SectionTitle('My interests'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final i in profile.interests) Pill(i, color: C.greenTint),
          ]),
          const SectionTitle('Places I\'d like to visit'),
          LCard(
            child: Text(
                profile.outingTypes.isEmpty ? 'Nothing picked yet' : profile.outingTypes.join(', '),
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (profile.isParent) ...[
            const SectionTitle('Parent'),
            LCard(
              color: C.navy,
              onTap: () => go(context, const ParentControlsPage()),
              child: const Row(children: [
                Icon(Icons.shield_rounded, color: C.mustard),
                SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Parent controls',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('Phone-free time, consequences, rewards',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white70),
              ]),
            ),
          ],
          const SectionTitle('Achievements'),
          Row(children: [
            _stat('12', 'Days', C.mustardTint),
            const SizedBox(width: 12),
            _stat('8', 'Games', C.tealTint),
          ]),
          const SizedBox(height: 14),
          Btn('All badges and achievements', color: C.navy, onTap: () => go(context, const BadgesPage())),
        ]),
      );

  Widget _stat(String v, String l, Color c) => Expanded(
        child: LCard(
          color: c,
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(children: [
            Text(v, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            Text(l, style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

// ---- 30 design your character
class DesignAvatarPage extends StatefulWidget {
  const DesignAvatarPage({super.key});
  @override
  State<DesignAvatarPage> createState() => _DesignAvatarPageState();
}

class _DesignAvatarPageState extends State<DesignAvatarPage> {
  int _a = profile.avatar;
  @override
  Widget build(BuildContext context) => Page1('My character', [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 5)),
            child: ClipOval(
                child: Image.asset(characters[_a].$2, fit: BoxFit.cover, alignment: Alignment.topCenter)),
          ),
        ),
        const SectionTitle('Character'),
        SizedBox(
          height: 78,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (var i = 0; i < characters.length; i++)
              GestureDetector(
                onTap: () => setState(() => _a = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(3),
                  width: 74,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _a == i ? C.terracotta : Colors.transparent, width: 3)),
                  child: ClipOval(
                      child: Image.asset(characters[i].$2, fit: BoxFit.cover, alignment: Alignment.topCenter)),
                ),
              ),
          ]),
        ),
        const SectionTitle('Outfits'),
        const Wrap(spacing: 10, runSpacing: 10, children: [
          Pill('Coming soon', color: C.beige),
        ]),
      ],
          bottom: Btn('Save', onTap: () {
            profile.avatar = _a;
            final i = members.indexWhere((m) => m.name == profile.name);
            if (i >= 0) {
              final o = members[i];
              members[i] = Member(o.key, o.name, o.role, o.age, characters[_a].$2, o.points);
            }
            Navigator.pop(context);
          }));
}

// ---- 10 badges and achievements
class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});
  @override
  Widget build(BuildContext context) => Page1('Badges and achievements', [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            for (final b in badges)
              Opacity(
                opacity: b.$4 ? 1 : .45,
                child: LCard(
                  color: b == badges.first ? C.navy : null,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(b.$4 ? b.$2 : Icons.lock_rounded,
                        color: b == badges.first ? C.mustard : b.$3, size: 30),
                    const SizedBox(height: 8),
                    Text(b.$1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: b == badges.first ? Colors.white : C.ink)),
                  ]),
                ),
              ),
          ],
        ),
      ]);
}
