import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../topics_data.dart';

const _doneInk = Color(0xFF2F6662);
const _maxShown = 4;

/// "سولفنا فيها": the last four topics the family talked about.
class DiscussedSection extends StatelessWidget {
  /// Newest first; only the latest four are shown.
  final List<Topic> topics;
  final int totalCount;
  const DiscussedSection({
    super.key,
    required this.topics,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              l.topicsDoneTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AC.ink,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l.topicsDoneCount(totalCount),
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 13, color: AC.muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: Duration(milliseconds: reduce ? 0 : 250),
          child: topics.isEmpty
              ? const _EmptyBox(key: ValueKey('empty'))
              : _DiscussedCard(key: const ValueKey('card'), topics: topics),
        ),
      ],
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorder(color: AC.dotInactive, radius: 22),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Text(
        AppLocalizations.of(context).topicsDoneEmpty,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, height: 1.6, color: AC.muted),
      ),
    ),
  );
}

class _DashedBorder extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorder({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(1),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorder old) =>
      old.color != color || old.radius != radius;
}

/// White card holding an [AnimatedList]: a topic marked as discussed slides
/// in on top, and the fifth one drops off the bottom.
class _DiscussedCard extends StatefulWidget {
  final List<Topic> topics;
  const _DiscussedCard({super.key, required this.topics});
  @override
  State<_DiscussedCard> createState() => _DiscussedCardState();
}

class _DiscussedCardState extends State<_DiscussedCard> {
  final _listKey = GlobalKey<AnimatedListState>();
  late List<Topic> _shown = widget.topics.take(_maxShown).toList();

  @override
  void didUpdateWidget(covariant _DiscussedCard old) {
    super.didUpdateWidget(old);
    final next = widget.topics.take(_maxShown).toList();
    if (next.isNotEmpty &&
        !_shown.any((t) => t.id == next.first.id) &&
        _listKey.currentState != null) {
      _shown.insert(0, next.first);
      _listKey.currentState!.insertItem(
        0,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 350),
      );
      if (_shown.length > _maxShown) {
        final removed = _shown.removeLast();
        _listKey.currentState!.removeItem(
          _maxShown,
          (context, anim) => _Row(topic: removed, first: false),
          duration: Duration.zero,
        );
      }
    } else if (!_sameIds(_shown, next)) {
      setState(() => _shown = next);
    }
  }

  bool _sameIds(List<Topic> a, List<Topic> b) =>
      a.length == b.length &&
      [for (final t in a) t.id].join(',') ==
          [for (final t in b) t.id].join(',');

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: AC.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AC.border),
    ),
    child: AnimatedList(
      key: _listKey,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      initialItemCount: _shown.length,
      itemBuilder: (context, i, anim) {
        if (i >= _shown.length) return const SizedBox.shrink();
        return SizeTransition(
          sizeFactor: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          child: FadeTransition(
            opacity: anim,
            child: _Row(topic: _shown[i], first: i == 0),
          ),
        );
      },
    ),
  );
}

class _Row extends StatelessWidget {
  final Topic topic;
  final bool first;
  const _Row({required this.topic, required this.first});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      border: first ? null : const Border(top: BorderSide(color: AC.track)),
    ),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AC.tealTint,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 14, color: _doneInk),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            topic.text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AC.ink,
            ),
          ),
        ),
      ],
    ),
  );
}
