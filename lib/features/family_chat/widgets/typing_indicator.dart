import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../family_chat_controller.dart';
import 'chat_avatar.dart';

/// "عبدالله يكتب": a small bubble with three bouncing dots. With reduced
/// motion the dots stay still.
class TypingIndicator extends StatefulWidget {
  final ChatMember who;
  const TypingIndicator({super.key, required this.who});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // 0..1 bounce for dot [i]: up at 40% of its (delayed) cycle
  double _lift(int i) {
    final t = (_c.value - i * .125) % 1.0;
    if (t < .4) return t / .4;
    if (t < .8) return 1 - (t - .4) / .4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ChatAvatar(member: widget.who),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AC.card,
            border: Border.all(color: AC.border),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, _) => Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Padding(
                          padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                          child: Transform.translate(
                            offset: Offset(0, -4 * _lift(i)),
                            child: Opacity(
                              opacity: .45 + .55 * _lift(i),
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: AC.muted,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l.chatTyping(widget.who.name),
                style: const TextStyle(fontSize: 12, color: AC.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
