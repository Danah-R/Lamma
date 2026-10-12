import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';

/// Message field + send button, with an optional "replying to the question"
/// bar above it.
class ChatComposer extends StatefulWidget {
  final bool replying;
  final String question;
  final VoidCallback onCancelReply;
  final ValueChanged<String> onSend;
  const ChatComposer({
    super.key,
    required this.replying,
    required this.question,
    required this.onCancelReply,
    required this.onSend,
  });

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void didUpdateWidget(covariant ChatComposer old) {
    super.didUpdateWidget(old);
    // "جاوب" was pressed: jump straight into the field
    if (widget.replying && !old.replying) _focus.requestFocus();
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    widget.onSend(t);
    _text.clear();
  }

  Widget _replyArea(AppLocalizations l) {
    final bar = widget.replying
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ReplyBar(
              title: l.chatReplyingTo,
              text: widget.question,
              cancelLabel: l.chatCancelReply,
              onCancel: widget.onCancelReply,
            ),
          )
        : const SizedBox(width: double.infinity);
    if (MediaQuery.disableAnimationsOf(context)) return bar;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.bottomCenter,
      child: bar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _replyArea(l),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: Semantics(
                  textField: true,
                  label: l.chatMessageField,
                  child: TextField(
                    controller: _text,
                    focusNode: _focus,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: const TextStyle(fontSize: 15, color: AC.ink),
                    decoration: InputDecoration(
                      hintText: widget.replying
                          ? l.chatHintReply
                          : l.chatHintWrite,
                      hintStyle: const TextStyle(fontSize: 15, color: AC.muted),
                      filled: true,
                      fillColor: AC.card,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: AC.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: AC.brick,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _text,
              builder: (_, v, _) {
                final can = v.text.trim().isNotEmpty;
                return Semantics(
                  button: true,
                  enabled: can,
                  label: l.chatSend,
                  excludeSemantics: true,
                  child: Material(
                    color: can ? AC.brick : AC.dotInactive,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: can ? _send : null,
                      child: const SizedBox(
                        width: 50,
                        height: 50,
                        // the send arrow mirrors in RTL: points left
                        child: Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ReplyBar extends StatelessWidget {
  final String title, text, cancelLabel;
  final VoidCallback onCancel;
  const _ReplyBar({
    required this.title,
    required this.text,
    required this.cancelLabel,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Container(
      decoration: BoxDecoration(
        color: AC.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AC.border),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 14, 8),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AC.brick,
                          ),
                        ),
                        Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AC.muted),
                        ),
                      ],
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: cancelLabel,
                  excludeSemantics: true,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onCancel,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AC.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: ColoredBox(color: AC.brick),
          ),
        ],
      ),
    ),
  );
}
