import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../family_chat_controller.dart';
import 'chat_avatar.dart';
import 'message_row.dart' show chatTimeLabel;

/// A poll message: one vote each, tap again to take it back.
class PollCard extends StatelessWidget {
  final ChatMessage message;
  final FamilyChatController chat;
  const PollCard({super.key, required this.message, required this.chat});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final who = chatMember(message.authorId);
    final total = chat.totalVotes;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ChatAvatar(member: who),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            width: 272,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AC.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AC.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        who.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: who.nameColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9DEEA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bar_chart_rounded,
                            size: 12,
                            color: AC.navy,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l.chatPollBadge,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AC.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: AC.ink,
                  ),
                ),
                for (final o in chat.pollOptions) ...[
                  const SizedBox(height: 8),
                  _Option(
                    option: o,
                    votes: chat.votesFor(o),
                    fraction: chat.votesFor(o) / total,
                    on: chat.myVote == o.id,
                    animate: !reduce,
                    onTap: () => chat.vote(o.id),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l.chatVotes(total),
                      style: const TextStyle(fontSize: 11, color: AC.muted),
                    ),
                    Text(
                      chatTimeLabel(l, message.createdAt, chat.now),
                      style: const TextStyle(fontSize: 11, color: AC.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  final PollOption option;
  final int votes;
  final double fraction;
  final bool on, animate;
  final VoidCallback onTap;
  const _Option({
    required this.option,
    required this.votes,
    required this.fraction,
    required this.on,
    required this.animate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: on,
    child: Material(
      color: AC.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: on ? AC.brick : AC.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Stack(
            children: [
              // fills from the right edge
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedFractionallySizedBox(
                    duration: Duration(milliseconds: animate ? 300 : 0),
                    widthFactor: fraction,
                    heightFactor: 1,
                    child: ColoredBox(color: on ? AC.salmonTint : AC.track),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AC.ink,
                              ),
                            ),
                          ),
                          if (on) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: AC.brick,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '$votes',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AC.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
