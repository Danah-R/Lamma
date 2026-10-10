import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../topics_data.dart';

/// "رائج الحين": horizontally scrolling cards, each opens its topic.
class TrendingSection extends StatelessWidget {
  final List<Topic> topics;
  final TopicCategory Function(String categoryId) categoryOf;
  final ValueChanged<String> onOpen;
  const TrendingSection({
    super.key,
    required this.topics,
    required this.categoryOf,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l.topicsTrendingTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AC.ink,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.topicsTrendingSub,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 13, color: AC.muted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < topics.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  _TrendingCard(
                    topic: topics[i],
                    category: categoryOf(topics[i].categoryId),
                    onTap: () => onOpen(topics[i].id),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final Topic topic;
  final TopicCategory category;
  final VoidCallback onTap;
  const _TrendingCard({
    required this.topic,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      child: SizedBox(
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // white card with the 1px border; the 5px category bar covers
              // the top edge (CSS border-top: 5px).
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AC.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AC.border),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 5,
                child: ColoredBox(color: category.color),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 150),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 19, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: category.tint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category.label(l),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: category.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Text(
                              topic.text,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                fontWeight: FontWeight.w800,
                                color: AC.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                l.topicsTalkAboutIt,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AC.brick,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // RTL page: forward points left.
                              const Directionality(
                                textDirection: TextDirection.ltr,
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 14,
                                  color: AC.brick,
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
            ],
          ),
        ),
      ),
    );
  }
}
