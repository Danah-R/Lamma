import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../clubs_controller.dart';

/// "وين وصلت العائلة؟": each reader's progress bar, plus a nudge to log
/// your own progress.
class FamilyProgressCard extends StatelessWidget {
  final String title;
  final List<ClubReader> readers;
  final String captionBold;
  final String captionRest;
  final VoidCallback onLogProgress;
  const FamilyProgressCard({
    super.key,
    required this.title,
    required this.readers,
    required this.captionBold,
    required this.captionRest,
    required this.onLogProgress,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final done = readers.where((r) => r.percent == 100).length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AC.card,
        border: Border.all(color: AC.border),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AC.ink,
                  ),
                ),
              ),
              Text(
                l.clubsFinishedCount(done, readers.length),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AC.brick,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final r in readers) ...[
            _ReaderRow(reader: r),
            if (r != readers.last) const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AC.salmonTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 14, color: AC.textSoft),
                      children: [
                        TextSpan(
                          text: captionBold,
                          style: const TextStyle(
                            color: AC.brickDeep,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(text: ' $captionRest'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: onLogProgress,
                    style: FilledButton.styleFrom(
                      backgroundColor: AC.brick,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l.clubsLogProgress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderRow extends StatelessWidget {
  final ClubReader reader;
  const _ReaderRow({required this.reader});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final done = reader.percent == 100;
    final barColor = done ? AC.teal : AC.brick;
    final needsDarkText =
        reader.color == AC.mustard ||
        reader.color == AC.sage ||
        reader.color == AC.salmon;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: reader.color,
            shape: BoxShape.circle,
            boxShadow: reader.isMe
                ? const [
                    BoxShadow(color: AC.brick, spreadRadius: 4),
                    BoxShadow(color: Colors.white, spreadRadius: 2),
                  ]
                : null,
          ),
          child: Text(
            reader.initial,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: needsDarkText ? AC.ink : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 52,
          child: Text(
            reader.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AC.ink,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: reader.percent / 100,
              minHeight: 8,
              color: barColor,
              backgroundColor: AC.track,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          child: Text(
            done ? l.clubsDoneLabel : '${reader.percent}%',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: done ? AC.teal : AC.muted,
            ),
          ),
        ),
      ],
    );
  }
}
