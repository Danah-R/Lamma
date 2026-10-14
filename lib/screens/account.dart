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
                          children: [
                            GestureDetector(
                              onTap: _editAccount,
                              child: Avatar(profile.name, size: 96),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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

                  // interests: set as a line of text rather than a bag of tags
                  SectionLabel(l.accountMyInterests),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 22,
                    runSpacing: 6,
                    children: [
                      for (final i in profile.interests)
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
                            Text(
                              ld(context, i),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // my topics: the ones I added that the family has not talked about yet
                  Builder(
                    builder: (context) {
                      final topics = context.watch<TopicsController>();
                      final mine = topics.myPendingTopics;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(l.accountMyTopics),
                          const SizedBox(height: 4),
                          Text(
                            l.accountMyTopicsHint,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: C.inkSoft,
                            ),
                          ),
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
                          const SizedBox(height: 22),
                        ],
                      );
                    },
                  ),

                  // places: each saved category, with its own mark
                  SectionLabel(l.accountPlacesToVisit),
                  const SizedBox(height: 12),
                  if (profile.outingTypes.isEmpty)
                    Text(
                      l.accountNothingPicked,
                      style: const TextStyle(fontSize: 15, color: C.inkSoft),
                    )
                  else
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        for (final t in profile.outingTypes)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _outingIcons[t] ?? Icons.place_outlined,
                                size: 20,
                                color: C.ink.withValues(alpha: .8),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ld(context, t),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  const SizedBox(height: 22),
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
                        Clipboard.setData(
                          ClipboardData(text: profile.familyCode),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.accountFamilyCodeCopied)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Directionality(
                                textDirection: TextDirection
                                    .ltr, // a code always reads left to right
                                child: Text(
                                  profile.familyCode,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.copy_rounded,
                              size: 20,
                              color: C.inkSoft,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // achievements: numbers sit in the page, not in cards
                  SectionLabel(l.accountAchievements),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Stat('12', l.accountStatDays, C.brick),
                      _Stat('8', l.accountStatGames, C.teal),
                      // pictures (moments) I shared, and the points I have collected
                      _Stat('$_pictures', l.accountStatPictures, C.navy),
                      _Stat('$_points', l.accountStatPoints, C.yellow),
                    ],
                  ),
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
                    child: Container(
                      width: 58,
                      height: 58,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: C.peachTint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Image.asset(
                        badgeImages[b.$1]!,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, _, _) =>
                            Icon(b.$2, size: 24, color: b.$3),
                      ),
                    ),
                  )
                : Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !b.$4
                          ? C.line
                          : (b == badges.first
                                ? C.yellow
                                : b.$3.withValues(alpha: .14)),
                    ),
                    child: Icon(
                      b.$4 ? b.$2 : Icons.lock_rounded,
                      size: 15,
                      color: !b.$4
                          ? C.inkSoft
                          : (b == badges.first ? C.ink : b.$3),
                    ),
                  ),
          ),
      ],
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
    width: 92,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.1,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: C.inkSoft)),
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
              child: LCard(
                color: b == badges.first ? C.navy : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (badgeImages[b.$1] != null)
                      Container(
                        width: 84,
                        height: 84,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: C.peachTint,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          badgeImages[b.$1]!,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, _, _) =>
                              Icon(b.$2, size: 24, color: b.$3),
                        ),
                      )
                    else
                      Icon(
                        b.$4 ? b.$2 : Icons.lock_rounded,
                        color: b == badges.first ? C.yellow : b.$3,
                        size: 30,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      ld(context, b.$1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: b == badges.first ? Colors.white : C.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ]);
  }
}
