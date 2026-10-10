import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../clubs_controller.dart';

/// "قرأناها قبل": a short history of books the family already finished.
class ReadBeforeList extends StatelessWidget {
  final List<ReadBeforeEntry> entries;
  const ReadBeforeList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.clubsReadBeforeTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AC.ink,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AC.card,
            border: Border.all(color: AC.border),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              for (final e in entries) ...[
                _ReadBeforeRow(entry: e),
                if (e != entries.last)
                  const Divider(height: 1, color: AC.track),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadBeforeRow extends StatelessWidget {
  final ReadBeforeEntry entry;
  const _ReadBeforeRow({required this.entry});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 50,
            decoration: BoxDecoration(
              color: entry.coverColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
                topRight: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AC.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.author} · ${entry.note}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AC.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AC.tealTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              l.clubsScoreOutOf(entry.completed, entry.total),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AC.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
