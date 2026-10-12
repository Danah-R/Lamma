import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../family_chat_controller.dart';
import 'chat_avatar.dart';

const _questionInk = Color(0xFF6E5418);
const _gold = AC.mustard;
const _navyMuted = Color(0xFFC9CFDD);
const _ease = Cubic(.2, .8, .2, 1);

/// "الحين" for a message sent in the last minute, else "8:15 ص".
String chatTimeLabel(AppLocalizations l, DateTime t, DateTime now) {
  if (now.difference(t).inSeconds.abs() < 60) return l.chatNow;
  final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final mm = t.minute.toString().padLeft(2, '0');
  return '$h12:$mm ${t.hour >= 12 ? l.chatPm : l.chatAm}';
}

/// One text bubble (plain or an answer to the daily question). Mine are on
/// the far side in navy; everyone else's are white with a colored name.
class MessageRow extends StatelessWidget {
  final ChatMessage message;
  final DateTime now;
  const MessageRow({super.key, required this.message, required this.now});

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, c) => _content(context, c.maxWidth));

  Widget _content(BuildContext context, double rowWidth) {
    final l = AppLocalizations.of(context);
    final m = message;
    final mine = m.authorId == chatMeId;
    final who = chatMember(m.authorId);
    final fresh = now.difference(m.createdAt).inSeconds.abs() < 2;
    final reduce = MediaQuery.disableAnimationsOf(context);

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: rowWidth * .76, // max-width 76% of the row
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 9, 13, 7),
        decoration: BoxDecoration(
          color: mine ? AC.navy : AC.card,
          border: mine ? null : Border.all(color: AC.border),
          // physical corners, as in the design
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 6 : 18),
            bottomRight: Radius.circular(mine ? 18 : 6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!mine) ...[
              Text(
                who.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: who.nameColor,
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (m.kind == ChatKind.reply) ...[
              _Quote(
                label: l.chatQuestionLabel,
                text: m.quote ?? '',
                mine: mine,
              ),
              const SizedBox(height: 4),
            ],
            Text(
              m.text,
              style: TextStyle(
                fontSize: 16,
                height: 1.55,
                color: mine ? Colors.white : AC.ink,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                chatTimeLabel(l, m.createdAt, now),
                style: TextStyle(
                  fontSize: 11,
                  color: mine ? _navyMuted : AC.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!mine) ...[ChatAvatar(member: who), const SizedBox(width: 8)],
        Flexible(child: bubble),
      ],
    );
    if (!fresh) return row;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: reduce ? 150 : 400),
      curve: _ease,
      child: row,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, reduce ? 0 : 14 * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}

/// The quoted question inside an answer: a 3px bar on the right edge, a
/// label, and the question cut to one line.
class _Quote extends StatelessWidget {
  final String label, text;
  final bool mine;
  const _Quote({required this.label, required this.text, required this.mine});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      color: mine ? const Color(0x1FFFFFFF) : AC.background,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 11, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: mine ? AC.mustardTint : _questionInk,
                  ),
                ),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: mine ? _navyMuted : AC.muted,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 3,
            child: ColoredBox(color: _gold),
          ),
        ],
      ),
    ),
  );
}
