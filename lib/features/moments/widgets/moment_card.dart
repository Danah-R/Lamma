import 'dart:io';

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
  final bool liked;
  final VoidCallback onLike;
  final ValueChanged<String> onComment;
  final DateTime Function() clock;
  const MomentCard({
    super.key,
    required this.moment,
    required this.liked,
    required this.onLike,
    required this.onComment,
    this.clock = DateTime.now,
  });

  @override
  State<MomentCard> createState() => _MomentCardState();
}

class _MomentCardState extends State<MomentCard>
    with SingleTickerProviderStateMixin {
  final _draft = TextEditingController();
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _popScale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 60),
  ]).animate(CurvedAnimation(parent: _pop, curve: _ease));
  bool _open = false;

  @override
  void dispose() {
    _draft.dispose();
    _pop.dispose();
    super.dispose();
  }

  void _like() {
    HapticFeedback.lightImpact();
    if (!widget.liked && !MediaQuery.disableAnimationsOf(context)) {
      _pop.forward(from: 0);
    }
    widget.onLike();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    widget.onComment(text);
    _draft.clear();
    setState(() => _open = true);
  }

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
    final likers = m.likedBy.length > 3
        ? m.likedBy.sublist(m.likedBy.length - 3)
        : m.likedBy;
    final quick = [l.momentsQuick1, l.momentsQuick2, l.momentsQuick3];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AC.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: m.isNew ? const Color(0xFFE9BFAF) : AC.border,
        ),
        boxShadow: [
          if (m.isNew) const BoxShadow(color: AC.salmonTint, spreadRadius: 3),
        ],
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
                          fontWeight: FontWeight.w800,
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
                        fontWeight: FontWeight.w800,
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
              child: m.imagePath != null && !m.imagePath!.startsWith('assets/')
                  ? Image.file(
                      File(m.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _scene(m),
                    )
                  : PhotoOrPainted(assetPath: m.imagePath, fallback: _scene(m)),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              m.caption,
              style: const TextStyle(fontSize: 16, height: 1.6, color: AC.ink),
            ),
          ),
          const SizedBox(height: 12),
          // reactions
          Row(
            children: [
              _LikePill(
                liked: widget.liked,
                count: m.likedBy.length,
                scale: _popScale,
                label: l.momentsLike,
                onTap: _like,
              ),
              const SizedBox(width: 8),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AC.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: AC.ink,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$n',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AC.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (likers.isNotEmpty)
                SizedBox(
                  width: 28.0 + (likers.length - 1) * 20,
                  height: 28,
                  child: Stack(
                    children: [
                      for (var k = 0; k < likers.length; k++)
                        PositionedDirectional(
                          start: k * 20.0,
                          child: MomentAvatar(
                            member: momentsMember(likers[k]),
                            size: 28,
                            fontSize: 10,
                            ring: AC.card,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
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
                        shape: const StadiumBorder(
                          side: BorderSide(color: AC.border),
                        ),
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
                      height: 44,
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(color: AC.border),
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
                    child: Material(
                      color: can ? AC.brick : const Color(0xFFD9C6AE),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: can ? () => _send(_draft.text) : null,
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          // send arrow auto-mirrors in RTL: points left
                          child: Icon(
                            Icons.send_rounded,
                            size: 18,
                            color: Colors.white,
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

class _LikePill extends StatelessWidget {
  final bool liked;
  final int count;
  final Animation<double> scale;
  final String label;
  final VoidCallback onTap;
  const _LikePill({
    required this.liked,
    required this.count,
    required this.scale,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = liked ? AC.brick : AC.ink;
    return Semantics(
      button: true,
      toggled: liked,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: liked ? AC.salmonTint : AC.card,
        shape: StadiumBorder(
          side: BorderSide(color: liked ? AC.salmonTint : AC.border),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: scale,
                    child: Icon(
                      liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color: fg,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
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
              // CSS "4px 16px 16px 16px": physical top-left is the small one
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorId == momentsMeId ? l.momentsYou : who.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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
