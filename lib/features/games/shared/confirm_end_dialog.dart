import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import 'motion.dart';

/// Asks the player to confirm ending a game/turn. Resolves to true when they
/// choose to end, false when they keep playing.
Future<bool> showConfirmEnd(
  BuildContext context, {
  required String title,
  required String message,
  bool showTimerPaused = false,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: title,
    barrierColor: AC.navy.withValues(alpha: .55),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, _, _) => _ConfirmEndCard(
      title: title,
      message: message,
      showTimerPaused: showTimerPaused,
    ),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      if (reduceMotion(ctx)) {
        return FadeTransition(opacity: curved, child: child);
      }
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
  return result ?? false;
}

class _ConfirmEndCard extends StatelessWidget {
  final String title, message;
  final bool showTimerPaused;
  const _ConfirmEndCard({
    required this.title,
    required this.message,
    required this.showTimerPaused,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Semantics(
              scopesRoute: true,
              explicitChildNodes: true,
              label: title,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AC.salmonTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 26,
                      color: AC.brick,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AC.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AC.muted,
                    ),
                  ),
                  if (showTimerPaused) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AC.track,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l.confirmEndTimerPaused,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AC.muted,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  // RTL: first child sits on the right.
                  Row(
                    children: [
                      Expanded(
                        child: _DialogButton(
                          label: l.confirmEndYes,
                          background: Colors.white,
                          foreground: AC.brick,
                          border: const Color(0xFFE9BFAF),
                          onTap: () => Navigator.of(context).pop(true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DialogButton(
                          label: l.confirmEndKeepPlaying,
                          background: AC.navy,
                          foreground: Colors.white,
                          onTap: () => Navigator.of(context).pop(false),
                        ),
                      ),
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

class _DialogButton extends StatelessWidget {
  final String label;
  final Color background, foreground;
  final Color? border;
  final VoidCallback onTap;
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: border == null ? BorderSide.none : BorderSide(color: border!),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
      ),
    ),
  );
}
