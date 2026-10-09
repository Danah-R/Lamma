import 'package:flutter/material.dart';
import '../data.dart';
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
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
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
        body: ListView(padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 120), children: [
          TabHeader(l.accountTitle, l.accountSubtitle),
          const SizedBox(height: 12),
          Center(child: Avatar(profile.name, size: 104)),
          const SizedBox(height: 12),
          Center(child: Text(profile.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
          Center(
              child: Text(l.accountAgeSpirit(profile.age),
                  style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w600))),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: () async {
                await go(context, const DesignAvatarPage());
                if (mounted) setState(() {});
              },
              child: Text(l.accountDesignCharacter,
                  style: const TextStyle(color: C.terracotta, fontWeight: FontWeight.w800)),
            ),
          ),
          SectionTitle(l.accountMyInterests),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final i in profile.interests) Pill(ld(context, i), color: C.greenTint),
          ]),
          SectionTitle(l.accountPlacesToVisit),
          LCard(
            child: Text(
                profile.outingTypes.isEmpty
                    ? l.accountNothingPicked
                    : profile.outingTypes.map((t) => ld(context, t)).join('، '),
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (profile.isParent) ...[
            SectionTitle(l.accountParentSection),
            LCard(
              color: C.navy,
              onTap: () => go(context, const ParentControlsPage()),
              child: Row(children: [
                const Icon(Icons.shield_rounded, color: C.mustard),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.accountParentControlsTitle,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                    Text(l.accountParentControlsDesc,
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              ]),
            ),
          ],
          SectionTitle(l.accountAchievements),
          Row(children: [
            _stat('12', l.accountStatDays, C.mustardTint),
            const SizedBox(width: 12),
            _stat('8', l.accountStatGames, C.tealTint),
          ]),
          const SizedBox(height: 14),
          Btn(l.accountAllBadges, color: C.navy, onTap: () => go(context, const BadgesPage())),
        ]),
      );
  }

  Widget _stat(String v, String label, Color c) => Expanded(
        child: LCard(
          color: c,
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(children: [
            Text(v, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: C.inkSoft, fontWeight: FontWeight.w700)),
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
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(l.designCharacterTitle, [
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
        SectionTitle(l.designCharacterSection),
        SizedBox(
          height: 78,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (var i = 0; i < characters.length; i++)
              GestureDetector(
                onTap: () => setState(() => _a = i),
                child: Container(
                  margin: const EdgeInsetsDirectional.only(end: 12),
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
        SectionTitle(l.designOutfitsSection),
        Wrap(spacing: 10, runSpacing: 10, children: [
          Pill(l.commonComingSoon, color: C.beige),
        ]),
      ],
          bottom: Btn(l.designSave, onTap: () {
            profile.avatar = _a;
            final i = members.indexWhere((m) => m.name == profile.name);
            if (i >= 0) {
              final o = members[i];
              members[i] = Member(o.key, o.name, o.role, o.age, characters[_a].$2, o.points);
            }
            Navigator.pop(context);
          }));
  }
}

// ---- 10 badges and achievements
class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Page1(l.badgesTitle, [
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
                    Text(ld(context, b.$1),
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
}
