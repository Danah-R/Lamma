import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/backend.dart';
import '../data.dart';
import '../features/moments/widgets/camera_coach.dart'
    show CoachSession, kCoachSeenKey;
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
  // space the floating tab bar occupies
  static const _bottomInset = 104.0;

  static const _outingIcons = <String, IconData>{
    'Nature': Icons.park_outlined,
    'Restaurants': Icons.restaurant_outlined,
    'Cafés': Icons.local_cafe_outlined,
    'Entertainment': Icons.sports_esports_outlined,
  };

  Future<void> _designCharacter() async {
    await go(context, const DesignAvatarPage());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, _bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight - 8 - _bottomInset),
            child: IntrinsicHeight(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TabHeader(l.accountTitle, l.accountSubtitle),
                const SizedBox(height: 20),

                // who you are: photo beside the name, not stacked and centered
                Row(children: [
                  GestureDetector(onTap: _designCharacter, child: Avatar(profile.name, size: 96)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(profile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -.3)),
                      const SizedBox(height: 2),
                      Text(l.accountAgeSpirit(profile.age),
                          style: TextStyle(fontSize: 15, color: C.ink.withValues(alpha: .7))),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _designCharacter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Flexible(
                              child: Text(l.accountDesignCharacter,
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w600, color: C.brick)),
                            ),
                            const SizedBox(width: 4),
                            // Material arrows mirror themselves in right-to-left
                            const Icon(Icons.arrow_forward_rounded, size: 16, color: C.brick),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ]),
                const SizedBox(height: 36),
                const _FlexGap(),

                // interests: set as a line of text rather than a bag of tags
                SectionLabel(l.accountMyInterests),
                const SizedBox(height: 10),
                Wrap(spacing: 22, runSpacing: 6, children: [
                  for (final i in profile.interests)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      // a small sage dot: the interests' color
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.sage, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(ld(context, i), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
                    ]),
                ]),
                const SizedBox(height: 36),

                // places: each saved category, with its own mark
                SectionLabel(l.accountPlacesToVisit),
                const SizedBox(height: 12),
                if (profile.outingTypes.isEmpty)
                  Text(l.accountNothingPicked, style: const TextStyle(fontSize: 15, color: C.inkSoft))
                else
                  Wrap(spacing: 24, runSpacing: 12, children: [
                    for (final t in profile.outingTypes)
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_outingIcons[t] ?? Icons.place_outlined,
                            size: 20, color: C.ink.withValues(alpha: .8)),
                        const SizedBox(width: 8),
                        Text(ld(context, t), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ]),
                  ]),
                const SizedBox(height: 36),
                const _FlexGap(),

                if (profile.isParent) ...[
                  SectionLabel(l.accountParentSection),
                  const Divider(height: 20, color: C.line),
                  _LinkRow(
                    icon: Icons.shield_outlined,
                    title: l.accountParentControlsTitle,
                    detail: l.accountParentControlsDesc,
                    onTap: () => go(context, const ParentControlsPage()),
                  ),
                  const Divider(height: 20, color: C.line),
                  const SizedBox(height: 24),
                ],

                // the family's join code, so people can invite each other
                if (profile.memberId != null) ...[
                  SectionLabel(l.accountFamilyCode),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: profile.familyCode));
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(l.accountFamilyCodeCopied)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.ltr, // a code always reads left to right
                            child: Text(profile.familyCode,
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                          ),
                        ),
                        const Icon(Icons.copy_rounded, size: 20, color: C.inkSoft),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // show the camera hint again (it comes back on the moments page)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final msg = l.accountResetCoachDone;
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove(kCoachSeenKey);
                      } catch (_) {}
                      CoachSession.reset();
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text(msg)));
                    },
                    child: Text(l.accountResetCoach,
                        style: const TextStyle(color: C.inkSoft, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),

                // achievements: numbers sit in the page, not in cards
                SectionLabel(l.accountAchievements),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _Stat('12', l.accountStatDays, C.brick),
                  const SizedBox(width: 44),
                  _Stat('8', l.accountStatGames, C.teal),
                ]),
                const Divider(height: 28, color: C.line),
                _LinkRow(
                  badge: C.yellow,
                  icon: Icons.emoji_events_rounded,
                  title: l.accountAllBadges,
                  onTap: () => go(context, const BadgesPage()),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Breathing room that grows on taller phones, but only up to a limit, so
/// sections stay related instead of drifting apart.
class _FlexGap extends StatelessWidget {
  const _FlexGap();
  @override
  Widget build(BuildContext context) => Flexible(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 40),
          child: const SizedBox.expand(),
        ),
      );
}

class _Stat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500, height: 1.1, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 13, color: C.inkSoft)),
      ]);
}

/// A plain tappable row: optional icon, title, optional detail, arrow.
class _LinkRow extends StatelessWidget {
  final IconData? icon;
  final Color? badge; // when set, the icon sits on a filled disc of this color
  final String title;
  final String? detail;
  final VoidCallback onTap;
  const _LinkRow({this.icon, this.badge, required this.title, this.detail, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          if (icon != null) ...[
            if (badge != null)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: badge, shape: BoxShape.circle),
                child: Icon(icon, size: 18, color: C.ink),
              )
            else
              Icon(icon, size: 22, color: C.ink.withValues(alpha: .8)),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              if (detail != null) ...[
                const SizedBox(height: 2),
                Text(detail!, style: TextStyle(fontSize: 14, color: C.ink.withValues(alpha: .7))),
              ],
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: C.inkSoft),
        ]),
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
                      border: Border.all(color: _a == i ? C.brick : Colors.transparent, width: 3)),
                  child: ClipOval(
                      child: Image.asset(characters[i].$2, fit: BoxFit.cover, alignment: Alignment.topCenter)),
                ),
              ),
          ]),
        ),
        SectionTitle(l.designOutfitsSection),
        Wrap(spacing: 10, runSpacing: 10, children: [
          Pill(l.commonComingSoon, color: C.line),
        ]),
      ],
          bottom: Btn(l.designSave, onTap: () {
            profile.avatar = _a;
            final i = members.indexWhere((m) => m.id != null ? m.id == profile.memberId : m.name == profile.name);
            if (i >= 0) {
              final o = members[i];
              members[i] = Member(o.key, o.name, o.role, o.age, characters[_a].$2, o.points, id: o.id, parent: o.parent);
            }
            if (Backend.enabled && profile.memberId != null) {
              Backend.updateMyProfile({'avatar': _a}).catchError((Object e) => debugPrint('Saving avatar failed: $e'));
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
                        color: b == badges.first ? C.yellow : b.$3, size: 30),
                    const SizedBox(height: 8),
                    Text(ld(context, b.$1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: b == badges.first ? Colors.white : C.ink)),
                  ]),
                ),
              ),
          ],
        ),
      ]);
  }
}
