import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../clubs_controller.dart';
import 'book_suggestion_tile.dart';

/// "مقترحات الأسبوع الجاي": a white card listing each candidate podcast,
/// one row per item with a divider between rows.
class PodcastSuggestionList extends StatelessWidget {
  final List<PodcastSuggestion> items;
  final Set<int> voted;
  final void Function(int) onToggleVote;
  const PodcastSuggestionList({
    super.key,
    required this.items,
    required this.voted,
    required this.onToggleVote,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AC.card,
      border: Border.all(color: AC.border),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _PodcastRow(
            item: items[i],
            voted: voted.contains(i),
            onToggleVote: () => onToggleVote(i),
          ),
          if (i != items.length - 1) const Divider(height: 1, color: AC.track),
        ],
      ],
    ),
  );
}

class _PodcastRow extends StatelessWidget {
  final PodcastSuggestion item;
  final bool voted;
  final VoidCallback onToggleVote;
  const _PodcastRow({
    required this.item,
    required this.voted,
    required this.onToggleVote,
  });

  Future<void> _open(BuildContext context) async {
    final url = item.url;
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final votes = item.votes + (voted ? 1 : 0);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.url == null ? null : () => _open(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.iconColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
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
                      item.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AC.muted),
                    ),
                    if (item.about.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.about,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AC.textSoft,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              VoteButton(
                votes: votes,
                voted: voted,
                accent: AC.teal,
                onTap: onToggleVote,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-width dashed "اقترح بودكاست" button under the suggestions card.
class SuggestPodcastButton extends StatelessWidget {
  final VoidCallback onTap;
  const SuggestPodcastButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Material(
        color: AC.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: DottedBorderBox(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFB9D3CF),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 18, color: AC.tealDeep),
                  const SizedBox(width: 8),
                  Text(
                    l.clubsSuggestPodcastHeading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AC.tealDeep,
                    ),
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
