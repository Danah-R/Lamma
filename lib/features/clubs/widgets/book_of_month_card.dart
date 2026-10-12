import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../clubs_controller.dart';
import '../motion.dart';

/// "كتاب الشهر": the current book, its cover, and an expandable blurb.
class BookOfMonthCard extends StatefulWidget {
  final Book book;
  final String daysLeftLabel;
  const BookOfMonthCard({
    super.key,
    required this.book,
    required this.daysLeftLabel,
  });

  @override
  State<BookOfMonthCard> createState() => _BookOfMonthCardState();
}

class _BookOfMonthCardState extends State<BookOfMonthCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final book = widget.book;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AC.card,
        border: Border.all(color: AC.border),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookCover(book: book),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AC.salmonTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l.clubsBookOfMonthBadge,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AC.brick,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: AC.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.author} · ${book.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: AC.muted),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AC.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AC.ink,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.daysLeftLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AC.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l.clubsAboutHeading,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AC.ink,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSize(
            duration: clubsMotionDuration(context, 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Text(
              book.about,
              maxLines: _expanded ? null : 2,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                height: 1.75,
                color: AC.textSoft,
              ),
            ),
          ),
          Semantics(
            button: true,
            expanded: _expanded,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? l.clubsReadLess : l.clubsReadMore,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AC.brick,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _expanded ? .5 : 0,
                      duration: clubsMotionDuration(context, 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AC.brick,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  final Book book;
  const _BookCover({required this.book});
  @override
  Widget build(BuildContext context) => Container(
    width: 108,
    height: 158,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: book.coverColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        bottomLeft: Radius.circular(4),
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x405B3A28),
          blurRadius: 20,
          offset: Offset(-6, 10),
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
            width: 8,
            child: ColoredBox(color: Color(0x26000000)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CustomPaint(painter: _SunPainter()),
              ),
              Column(
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
            ],
          ),
        ),
      ],
    ),
  );
}

/// The small gold "compass" sun on the book cover.
class _SunPainter extends CustomPainter {
  const _SunPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 40, sy = size.height / 40;
    final c = Offset(20 * sx, 20 * sy);
    canvas.drawCircle(c, 9 * math.min(sx, sy), Paint()..color = AC.mustard);
    final spoke = Paint()
      ..color = AC.mustard
      ..strokeWidth = 2.4 * math.min(sx, sy)
      ..strokeCap = StrokeCap.round;
    void line(double x1, double y1, double x2, double y2) => canvas.drawLine(
      Offset(x1 * sx, y1 * sy),
      Offset(x2 * sx, y2 * sy),
      spoke,
    );
    line(20, 2, 20, 8);
    line(20, 32, 20, 38);
    line(2, 20, 8, 20);
    line(32, 20, 38, 20);
    line(7, 7, 11, 11);
    line(29, 29, 33, 33);
    line(7, 33, 11, 29);
    line(29, 11, 33, 7);
  }

  @override
  bool shouldRepaint(covariant _SunPainter oldDelegate) => false;
}
