import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../moments_controller.dart';
import '../../../widgets/photo_or_painted.dart';
import 'moment_avatar.dart';
import 'moment_scene.dart';

const _ease = Cubic(.2, .8, .2, 1);

/// One family moment: author, picture, caption, likes, comments, composer.
class MomentCard extends StatefulWidget {
  final Moment moment;
  final String? myReaction;
  final ValueChanged<String> onReact;
  final ValueChanged<String> onComment;
  final DateTime Function() clock;
  const MomentCard({
    super.key,
    required this.moment,
    required this.myReaction,
    required this.onReact,
    required this.onComment,
    this.clock = DateTime.now,
  });

  @override
  State<MomentCard> createState() => _MomentCardState();
}

class _MomentCardState extends State<MomentCard> {
  final _draft = TextEditingController();
  bool _open = false;
  int _rainKey = 0;
  String? _rainEmoji; // the reaction that is raining over the picture
  final _countKey = GlobalKey();

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _react(String key) {
    HapticFeedback.lightImpact();
    // choosing a reaction (not taking it back) makes it rain on the picture
    if (widget.myReaction != key && !MediaQuery.disableAnimationsOf(context)) {
      setState(() {
        _rainEmoji = momentReactionEmoji[key];
        _rainKey++;
      });
    }
    widget.onReact(key);
  }

  /// A small pop-up under the reactions count: who reacted, and with what. Tap anywhere to close it.
  void _showReactors() {
    final m = widget.moment;
    final box = _countKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || m.likedBy.isEmpty) return;
    final origin = box.localToGlobal(Offset.zero);
    final screen = MediaQuery.sizeOf(context);
    const w = 230.0;
    final left = (origin.dx + box.size.width / 2 - w / 2).clamp(
      12.0,
      screen.width - w - 12,
    );
    final l = AppLocalizations.of(context);
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (ctx, _, _) => Stack(
        children: [
          Positioned(
            top: origin.dy + box.size.height + 6,
            left: left,
            width: w,
            child: Material(
              color: AC.card,
              elevation: 8,
              shadowColor: const Color(0x33000000),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final id in m.likedBy)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            MomentAvatar(
                              member: momentsMember(id),
                              size: 28,
                              fontSize: 10,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                id == momentsMeId
                                    ? l.momentsYou
                                    : momentsMember(id).name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AC.ink,
                                ),
                              ),
                            ),
                            Text(
                              momentReactionEmoji[m.reactionOf(id) ?? 'heart']!,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(
            begin: .9,
            end: 1.0,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
    );
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    widget.onComment(text);
    _draft.clear();
    setState(() => _open = true);
  }

  String _reactionLabel(AppLocalizations l, String k) => switch (k) {
    'heart' => l.momentsReactHeart,
    'laugh' => l.momentsReactLaugh,
    'thumbs' => l.momentsReactThumbs,
    'cry' => l.momentsReactCry,
    _ => l.momentsReactLove,
  };

  String _timeLabel(AppLocalizations l) {
    final t = widget.moment.createdAt;
    final now = widget.clock();
    if (now.difference(t).inSeconds.abs() < 60) return l.momentsNow;
    final today = DateTime(now.year, now.month, now.day);
    final days = today.difference(DateTime(t.year, t.month, t.day)).inDays;
    final day = days <= 0
        ? l.momentsToday
        : days == 1
        ? l.momentsYesterday
        : '${t.day}/${t.month}';
    final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final mm = t.minute.toString().padLeft(2, '0');
    final time = '$h12:$mm ${t.hour >= 12 ? l.momentsPm : l.momentsAm}';
    return l.momentsDayTime(day, time);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final m = widget.moment;
    final author = momentsMember(m.authorId);
    final mine = m.authorId == momentsMeId;
    final withNames = [for (final id in m.withIds) momentsMember(id).name];
    final n = m.comments.length;
    final hidden = n - 2;
    final shown = _open || hidden <= 0 ? m.comments : m.comments.sublist(n - 2);
    final firstShown = n - shown.length;
    final quick = [l.momentsQuick1, l.momentsQuick2, l.momentsQuick3];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AC.card,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // author
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                MomentAvatar(member: author, size: 42),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: mine ? l.momentsYou : author.name,
                          children: [
                            if (withNames.isNotEmpty)
                              TextSpan(
                                text: l.momentsWith(
                                  withNames.join(l.momentsAnd),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AC.muted,
                                ),
                              ),
                          ],
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AC.ink,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _timeLabel(l),
                        style: const TextStyle(fontSize: 12, color: AC.muted),
                      ),
                    ],
                  ),
                ),
                if (m.isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AC.brick,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l.momentsNew,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // picture
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 280,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  m.imagePath != null && !m.imagePath!.startsWith('assets/')
                      ? Image.file(
                          File(m.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _scene(m),
                        )
                      : PhotoOrPainted(
                          assetPath: m.imagePath,
                          fallback: _scene(m),
                          // the meal photo is tall: keep the food in view
                          alignment: m.scene == MomentScene.dinner
                              ? const Alignment(0, -.7)
                              : Alignment.center,
                        ),
                  if (_rainEmoji != null)
                    IgnorePointer(
                      child: _EmojiRain(
                        key: ValueKey(_rainKey),
                        emoji: _rainEmoji!,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          // reactions close together, and plain counts: a number and its little icon
          Row(
            children: [
              SizedBox(
                width: 34.0 * (momentReactions.length - 1) + 44,
                height: 44,
                child: Stack(
                  children: [
                    for (var i = 0; i < momentReactions.length; i++)
                      PositionedDirectional(
                        start: i * 34.0,
                        child: _ReactionButton(
                          emoji: momentReactionEmoji[momentReactions[i]]!,
                          selected: widget.myReaction == momentReactions[i],
                          label: _reactionLabel(l, momentReactions[i]),
                          onTap: () => _react(momentReactions[i]),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        key: _countKey,
                        behavior: HitTestBehavior.opaque,
                        onTap: _showReactors,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${m.likedBy.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AC.muted,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.add_reaction_outlined,
                                size: 18,
                                color: AC.muted,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$n',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AC.muted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                        color: AC.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              m.caption,
              style: const TextStyle(fontSize: 16, height: 1.6, color: AC.ink),
            ),
          ),
          const SizedBox(height: 12),
          // comments
          if (n > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hidden > 0)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: InkWell(
                      onTap: () => setState(() => _open = !_open),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: SizedBox(
                          height: 44,
                          child: Center(
                            child: Text(
                              _open
                                  ? l.momentsHideComments
                                  : hidden == 1
                                  ? l.momentsSeeSecond
                                  : l.momentsSeeAll(n),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AC.muted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                for (var k = 0; k < shown.length; k++) ...[
                  if (k > 0 || hidden > 0) const SizedBox(height: 8),
                  _CommentTile(
                    key: ValueKey('${m.id}-${firstShown + k}'),
                    comment: shown[k],
                    clock: widget.clock,
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          // quick replies
          SizedBox(
            height: 44,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: false),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: quick.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                // 44px tap area around the 36px pill
                itemBuilder: (_, i) => InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => _send(quick[i]),
                  child: Center(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: AC.card,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        quick[i],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AC.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // composer
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _draft,
            builder: (_, v, _) {
              final can = v.text.trim().isNotEmpty;
              return Row(
                children: [
                  MomentAvatar(member: momentsMember(momentsMeId), size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _draft,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _send,
                        scrollPadding: const EdgeInsets.only(bottom: 180),
                        style: const TextStyle(fontSize: 14, color: AC.ink),
                        decoration: InputDecoration(
                          hintText: mine
                              ? l.momentsReplyHint
                              : l.momentsCommentHint(author.name),
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: AC.muted,
                          ),
                          filled: true,
                          fillColor: AC.background,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(
                              color: AC.brick,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: l.momentsSend,
                    excludeSemantics: true,
                    // the round button is as tall as the text box (36); the tap area stays 44
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: can ? () => _send(_draft.text) : null,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: can ? AC.brick : const Color(0xFFD9C6AE),
                              shape: BoxShape.circle,
                            ),
                            // send arrow auto-mirrors in RTL: points left
                            child: const Icon(
                              Icons.send_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _scene(Moment m) =>
    CustomPaint(painter: MomentScenePainter(m.scene), size: Size.infinite);

class _ReactionButton extends StatelessWidget {
  final String emoji, label;
  final bool selected;
  final VoidCallback onTap;
  const _ReactionButton({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    toggled: selected,
    label: label,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Opacity(
            opacity: selected ? 1 : .6,
            child: Text(emoji, style: TextStyle(fontSize: selected ? 26 : 24)),
          ),
        ),
      ),
    ),
  );
}

/// The chosen reaction raining down over the picture: drops all over it, a little uneven on purpose
/// (their places, sizes, starts and speeds are slightly different), so it never looks too neat.
class _EmojiRain extends StatefulWidget {
  final String emoji;
  const _EmojiRain({super.key, required this.emoji});
  @override
  State<_EmojiRain> createState() => _EmojiRainState();
}

class _EmojiRainState extends State<_EmojiRain>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..forward();

  // x (0-1), start (0-1), speed (share of the time one fall takes), size
  static final _drops = () {
    final r = math.Random(11);
    const columns = 10;
    return [
      for (var i = 0; i < columns; i++)
        (
          ((i + .5) / columns + (r.nextDouble() - .5) * .12).clamp(0.02, 0.98),
          r.nextDouble() * .5,
          .38 + r.nextDouble() * .17,
          26.0,
        ),
    ];
  }();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          for (final d in _drops)
            () {
              final t = ((_c.value - d.$2) / d.$3).clamp(0.0, 1.0);
              if (t <= 0 || t >= 1) return const SizedBox.shrink();
              return Positioned(
                left: d.$1 * (box.maxWidth - d.$4),
                top: -d.$4 + t * (box.maxHeight + d.$4),
                child: Opacity(
                  opacity: t > .85 ? (1 - t) / .15 : 1,
                  child: Text(
                    widget.emoji,
                    style: TextStyle(
                      fontSize: d.$4,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              );
            }(),
        ],
      ),
    ),
  );
}

class _CommentTile extends StatelessWidget {
  final MomentComment comment;
  final DateTime Function() clock;
  const _CommentTile({super.key, required this.comment, required this.clock});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final who = momentsMember(comment.authorId);
    final fresh = clock().difference(comment.createdAt).inSeconds.abs() < 2;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final tile = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: MomentAvatar(member: who, size: 30),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: const BoxDecoration(
              color: AC.background,
              // the small corner is the one next to the avatar (top right in Arabic, top left in English)
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(4),
                topEnd: Radius.circular(16),
                bottomEnd: Radius.circular(16),
                bottomStart: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorId == momentsMeId ? l.momentsYou : who.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: who.nameColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  comment.text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AC.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    if (!fresh) return tile;
    // new comment: fade + slide down into place
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: reduce ? 150 : 500),
      curve: _ease,
      child: tile,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, reduce ? 0 : -14 * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}
