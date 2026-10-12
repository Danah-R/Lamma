import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../screens/activities_colors.dart';
import 'family_chat_controller.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_header.dart';
import 'widgets/date_chip.dart';
import 'widgets/message_row.dart';
import 'widgets/poll_card.dart';
import 'widgets/question_card.dart';
import 'widgets/typing_indicator.dart';

/// "لمّه": the family chat. Text only; photos live in the moments screen.
class FamilyChatScreen extends StatefulWidget {
  const FamilyChatScreen({super.key});

  // space the floating bottom bar occupies
  static const bottomInset = 104.0;

  @override
  State<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends State<FamilyChatScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom() {
    // the list is reversed: the newest message is at offset 0
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _scroll.jumpTo(0);
      } else {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final chat = context.watch<FamilyChatController>();
    final msgs = chat.messages;
    // newest first (the list is reversed): typing, messages…, question, date
    final count = msgs.length + 3;
    return Scaffold(
      backgroundColor: AC.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ChatHeader(
              title: l.navLamma,
              subtitle: l.chatSubtitle(chat.onlineCount),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(scrollbars: false),
                child: ListView.separated(
                  controller: _scroll,
                  reverse: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  itemCount: count,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    if (i == 0) return TypingIndicator(who: chat.typing);
                    if (i == count - 1) return DateChip(l.chatToday);
                    if (i == count - 2) {
                      return QuestionCard(
                        question: chat.question,
                        answered: chat.answered,
                        answeredCount: 4,
                        onAnswer: chat.replyToQuestion,
                      );
                    }
                    final m = msgs[msgs.length - i];
                    return m.kind == ChatKind.poll
                        ? PollCard(key: ValueKey(m.id), message: m, chat: chat)
                        : MessageRow(
                            key: ValueKey(m.id),
                            message: m,
                            now: chat.now,
                          );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                8,
                14,
                FamilyChatScreen.bottomInset,
              ),
              child: ChatComposer(
                replying: chat.replyingToQuestion,
                question: chat.question,
                onCancelReply: chat.cancelReply,
                onSend: (t) {
                  chat.send(t);
                  _toBottom();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
