import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../clubs_controller.dart';

/// One candidate book in the horizontal "مقترحات الشهر الجاي" list.
class BookSuggestionTile extends StatelessWidget {
  final Book book;
  final bool voted;
  final VoidCallback onToggleVote;
  const BookSuggestionTile({
    super.key,
    required this.book,
    required this.voted,
    required this.onToggleVote,
  });

  @override
  Widget build(BuildContext context) {
    final votes = book.votes + (voted ? 1 : 0);
    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: book.coverColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                bottomLeft: Radius.circular(3),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              border: voted ? Border.all(color: AC.brick, width: 3) : null,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2E5B3A28),
                  blurRadius: 16,
                  offset: Offset(-4, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    width: 6,
                    child: ColoredBox(color: Color(0x24000000)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            color: book.inkColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: book.subColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AC.track,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    book.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AC.muted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AC.ink,
                ),
              ),
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AC.muted),
              ),
              if (book.about.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  book.about,
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
          const SizedBox(height: 8),
          VoteButton(votes: votes, voted: voted, onTap: onToggleVote),
        ],
      ),
    );
  }
}

/// A heart + count vote toggle, shared by the book and podcast suggestion
/// lists (only the accent color differs between the two clubs).
class VoteButton extends StatelessWidget {
  final int votes;
  final bool voted;
  final Color accent;
  final VoidCallback onTap;
  const VoteButton({
    super.key,
    required this.votes,
    required this.voted,
    this.accent = AC.brick,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      toggled: voted,
      label: l.clubsVotedForCount(votes),
      child: Material(
        color: voted ? accent : AC.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 64),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: voted ? null : Border.all(color: AC.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  voted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 16,
                  color: voted ? Colors.white : accent,
                ),
                const SizedBox(width: 6),
                Text(
                  '$votes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: voted ? Colors.white : AC.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The trailing "اقترح كتاب" tile — same footprint as a book cover.
class SuggestBookTile extends StatelessWidget {
  final VoidCallback onTap;
  const SuggestBookTile({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      width: 132,
      height: 180,
      child: Material(
        color: AC.card,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(3),
          bottomLeft: Radius.circular(3),
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3),
            bottomLeft: Radius.circular(3),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          onTap: onTap,
          child: DottedBorderBox(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AC.salmonTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AC.brick,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.clubsSuggestBook,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AC.brick,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.clubsSuggestBookHint,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AC.muted,
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

/// A dashed-border rectangle, matching the reference's `border: 2px dashed`.
/// [borderRadius]/[color] default to the book cover's asymmetric spine
/// shape; pass a uniform radius and a different [color] to match other
/// dashed "suggest" affordances (e.g. the podcast one).
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Color color;
  const DottedBorderBox({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(3),
      bottomLeft: Radius.circular(3),
      topRight: Radius.circular(10),
      bottomRight: Radius.circular(10),
    ),
    this.color = const Color(0xFFD9C6AE),
  });
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorderPainter(borderRadius, color),
    child: child,
  );
}

class _DashedBorderPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final Color color;
  const _DashedBorderPainter(this.borderRadius, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    final rrect = borderRadius.toRRect(rect);
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      const dash = 6.0, gap = 5.0;
      while (dist < metric.length) {
        final next = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius || oldDelegate.color != color;
}
