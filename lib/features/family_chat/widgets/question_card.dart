import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';

const _ink = Color(0xFF6E5418);

/// "سؤال اليوم": centered card with an "answer" button.
class QuestionCard extends StatelessWidget {
  final String question;
  final bool answered;
  final int answeredCount;
  final VoidCallback onAnswer;
  const QuestionCard({
    super.key,
    required this.question,
    required this.answered,
    required this.answeredCount,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AC.mustardTint,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: _ink,
                ),
                const SizedBox(width: 6),
                Text(
                  l.chatQuestionLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.5,
                color: AC.ink,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    answered
                        ? l.chatQuestionAnswered
                        : l.chatQuestionFamily(answeredCount),
                    style: const TextStyle(fontSize: 12, color: _ink),
                  ),
                ),
                Material(
                  color: AC.navy,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onAnswer,
                    child: SizedBox(
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: Text(
                            l.chatAnswer,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
