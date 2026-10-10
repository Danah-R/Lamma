import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';

/// Navy "جلسة النقاش" card: a date chip, the time, and a "ذكّرني" toggle.
/// Parameterized by day/date/time/color so the podcast tab can reuse it.
/// The reminder flag is owned by the caller (the clubs controller), so it
/// stays in sync with the rest of the discussion state.
class DiscussionDateCard extends StatelessWidget {
  final String day;
  final String date;
  final String time;
  final Color dayColor;
  final bool reminderOn;
  final VoidCallback onToggleReminder;
  const DiscussionDateCard({
    super.key,
    required this.day,
    required this.date,
    required this.time,
    required this.dayColor,
    required this.reminderOn,
    required this.onToggleReminder,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AC.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AC.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: dayColor,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: AC.navy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.clubsDiscussionSession,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AC.heroDescText),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            toggled: reminderOn,
            child: Material(
              color: reminderOn ? AC.mustard : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onToggleReminder,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: reminderOn
                        ? null
                        : Border.all(color: AC.reminderBorder),
                  ),
                  child: Text(
                    reminderOn ? l.clubsRemindMeOn : l.clubsRemindMe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: reminderOn ? AC.navy : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
