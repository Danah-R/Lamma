import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data.dart';
import '../features/survey/survey_controller.dart';
import '../features/topics/topics_controller.dart';
import '../features/topics/topics_screen.dart';
import '../features/survey/survey_screen.dart';
import '../features/moments/moments_controller.dart'
    show MomentsController, momentsMeId;
import '../l10n/app_localizations.dart';
import '../l10n/data_localizations.dart';
import '../theme.dart';
import '../widgets.dart';
import 'edit_account.dart';
import 'leaderboard.dart';

// ---- 28/29 profile
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SharedRefresh<AccountPage> {
  bool _showFamily = false;

  // space the floating tab bar occupies
  static const _bottomInset = 104.0;

  static const _outingIcons = <String, IconData>{
    'Nature': Icons.park_outlined,
    'Restaurants': Icons.restaurant_outlined,
    'Cafés': Icons.local_cafe_outlined,
    'Entertainment': Icons.sports_esports_outlined,
  };

  Future<void> _editAccount() async {
    await go(context, const EditAccountPage());
    if (mounted) setState(() {});
  }

  /// The family's name for "member of the ... family" (the word "family" itself is dropped from it).
  String get _familyName {
    var n = profile.family.trim();
    n = n
        .replaceAll(RegExp(r'\s*family\s*$', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^(عائلة|العائلة)\s+'), '')
        .trim();
    return n.isEmpty ? profile.family : n;
  }

  int get _pictures => context
      .watch<MomentsController>()
      .moments
      .where((m) => m.authorId == momentsMeId)
      .length;

  int get _points =>
      members
          .where(
            (m) => profile.memberId != null
                ? m.id == profile.memberId
                : m.name == profile.name,
          )
          .firstOrNull
          ?.points ??
      0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(
            20,
            8,
            20,
            _bottomInset,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: box.maxHeight - 8 - _bottomInset,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The picture is at the very top; "Edit your account" is on the same level, in the
                  // top-left corner (physical left, the same in Arabic and English).
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // level with the name (both start below the "Edit your account" link)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: GestureDetector(
                                onTap: _editAccount,
                                child: Avatar(profile.name, size: 96),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // starts below the "Edit your account" link, so the two never overlap
                                  const SizedBox(height: 40),
                                  Text(
                                    profile.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // "member of the ... family": the family's name without a repeated "family"
                                  Text(
                                    l.accountMemberOfFamily(_familyName),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: C.ink.withValues(alpha: .7),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l.accountAgeSpirit(profile.age),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: C.ink.withValues(alpha: .7),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const _BadgeStrip(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          child: InkWell(
                            onTap: _editAccount,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: C.brick,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l.accountEditAccount,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: C.brick,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // this month's survey: waits here until it is answered
                  Builder(
                    builder: (context) {
                      final survey = context.watch<SurveyController>();
                      if (survey.done) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: C.teal,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l.surveyDoneCard,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: C.inkSoft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: LCard(
                          color: C.peachTint,
                          onTap: () => go(context, const SurveyScreen()),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.favorite_border_rounded,
                                color: C.brick,
                                size: 28,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.surveyCardTitle,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l.surveyCardDesc,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: C.inkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: C.inkSoft,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  const _FlexGap(),

                  // interests and favorite outings, side by side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.accountMyInterests,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: .3,
                                color: C.inkSoft,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (final i in profile.interests)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    // a small sage dot: the interests' color
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: C.sage,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        ld(context, i),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.accountPlacesToVisit,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: .3,
                                color: C.inkSoft,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (profile.outingTypes.isEmpty)
                              Text(
                                l.accountNothingPicked,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: C.inkSoft,
                                ),
                              )
                            else
                              for (final t in profile.outingTypes)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _outingIcons[t] ?? Icons.place_outlined,
                                        size: 18,
                                        color: C.ink.withValues(alpha: .8),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          ld(context, t),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // achievements: numbers sit in the page, not in cards
                  SectionLabel(l.accountAchievements),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _Stat('12', l.accountStatDays, C.brick)),
                      const SizedBox(width: 8),
                      Expanded(child: _Stat('8', l.accountStatGames, C.teal)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Stat(
                          '$_pictures',
                          l.accountStatPictures,
                          C.navy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Stat('$_points', l.accountStatPoints, C.yellow),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // my topics: the ones I added that the family has not talked about yet
                  Builder(
                    builder: (context) {
                      final topics = context.watch<TopicsController>();
                      final mine = topics.myPendingTopics;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(l.accountMyTopics),
                          const SizedBox(height: 10),
                          if (mine.isEmpty)
                            Text(
                              l.accountMyTopicsEmpty,
                              style: const TextStyle(
                                fontSize: 15,
                                color: C.inkSoft,
                              ),
                            )
                          else
                            for (final t in mine)
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  context.read<TopicsController>().openTopic(
                                    t.id,
                                  );
                                  go(context, const TopicsScreen());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.forum_outlined,
                                        size: 18,
                                        color: C.teal,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          t.text,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          const SizedBox(height: 0),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 14),

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
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 28),
                  // everyone in the family: tap to show or hide the list, right here
                  SectionLabel(l.accountFamilyMembers),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _showFamily = !_showFamily),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          AvatarStack([
                            for (final m in members) m.name,
                          ], size: 34),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _showFamily
                                  ? l.accountHideFamily
                                  : l.accountShowFamily(members.length),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: C.brick,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: !_showFamily
                        ? const SizedBox(width: double.infinity)
                        : Column(
                            children: [
                              for (final m in members)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Avatar(m.name, size: 44),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ld(context, m.name),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              ld(context, m.role),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: C.inkSoft,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (m.isParent)
                                        const Icon(
                                          Icons.shield_outlined,
                                          size: 18,
                                          color: C.inkSoft,
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 28),

                  // the family's join code at the bottom of the page: tap it to copy and share it
                  ...[
                    SectionLabel(l.accountFamilyCode),
                    const SizedBox(height: 8),
                    // the code sits on the right, in a light-red pill; tap it to copy
                    Align(
                      alignment: Alignment.centerRight,
                      child: Material(
                        color: C.brickTint,
                        shape: const StadiumBorder(),
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: profile.familyCode),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l.accountFamilyCodeCopied),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Directionality(
                              textDirection: TextDirection
                                  .ltr, // a code always reads left to right
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    profile.familyCode,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: C.brick,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.copy_rounded,
                                    size: 15,
                                    color: C.brick,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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
      constraints: const BoxConstraints(maxHeight: 12),
      child: const SizedBox.expand(),
    ),
  );
}

/// All badges in one tight row, icons only. Earned ones are colored, locked ones are
/// faded; long-press shows a name. Tapping opens the full list.
class _BadgeStrip extends StatelessWidget {
  const _BadgeStrip();
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () => go(context, const BadgesPage()),
    child: Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final b in badges)
          Tooltip(
            message: ld(context, b.$1),
            child: badgeImages[b.$1] != null
                // badges with their own picture: all of it, on a soft background
                ? Opacity(
                    opacity: b.$4 ? 1 : .45,
                    child: _BadgePicture(badge: b, size: 36),
                  )
                : Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !b.$4 ? C.line : C.yellow,
                    ),
                    child: Icon(
                      b.$4 ? b.$2 : Icons.lock_rounded,
                      size: 18,
                      color: !b.$4 ? C.inkSoft : C.ink,
                    ),
                  ),
          ),
      ],
    ),
  );
}

/// A badge's own picture as a circle (the picture already has its background and room around it,
/// so it is shown whole); if it cannot be loaded the badge's icon shows instead.
class _BadgePicture extends StatelessWidget {
  final (String, IconData, Color, bool) badge;
  final double size;
  const _BadgePicture({required this.badge, required this.size});
  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(
      badgeImages[badge.$1]!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        color: C.yellow,
        child: Icon(badge.$2, size: size * .5, color: C.ink),
      ),
    ),
  );
}

/// A small container: one number with its label.
class _Stat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      // text starts on the right in Arabic (the left in English), as it did before
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            height: 1.15,
            color: color,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: C.inkSoft),
          ),
        ),
      ],
    ),
  );
}

/// A plain tappable row: optional icon, title, optional detail, arrow.
class _LinkRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? detail;
  final VoidCallback onTap;
  const _LinkRow({
    this.icon,
    required this.title,
    this.detail,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 22, color: C.ink.withValues(alpha: .8)),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (detail != null) ...[
                const SizedBox(height: 2),
                Text(
                  detail!,
                  style: TextStyle(
                    fontSize: 14,
                    color: C.ink.withValues(alpha: .7),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: C.inkSoft),
      ],
    ),
  );
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
        childAspectRatio: 1.05,
        children: [
          for (final b in badges)
            Opacity(
              opacity: b.$4 ? 1 : .45,
              // no box behind a badge: just the picture and its name
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (badgeImages[b.$1] != null)
                    _BadgePicture(badge: b, size: 68)
                  else
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: C.yellow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        b.$4 ? b.$2 : Icons.lock_rounded,
                        color: C.ink,
                        size: 36,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    ld(context, b.$1),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, color: C.ink),
                  ),
                ],
              ),
            ),
        ],
      ),
    ]);
  }
}
