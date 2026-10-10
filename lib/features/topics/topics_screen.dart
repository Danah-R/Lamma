import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../screens/activities_colors.dart';
import '../../widgets/topic_deck_card.dart';
import 'topics_controller.dart';
import 'widgets/category_chips.dart';
import 'widgets/discussed_section.dart';
import 'widgets/suggest_card.dart';
import 'widgets/trending_section.dart';

/// "مواضيع للحديث": categories + deck, trending, suggest and history.
class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  // space the floating tab bar occupies
  static const bottomInset = 104.0;

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToDeck() {
    if (!_scroll.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(0);
    } else {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.watch<TopicsController>();
    final reduce = MediaQuery.disableAnimationsOf(context);
    final discussed = [
      for (final id in c.discussedIds.take(4))
        if (c.byId(id) != null) c.byId(id)!,
    ];
    return Scaffold(
      backgroundColor: AC.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.only(
            top: 8,
            bottom: TopicsScreen.bottomInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Header(
                  title: l.activitiesTalkTopicsTitle,
                  subtitle: l.topicsSubtitle,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(height: 20),
              CategoryChips(
                categories: c.categories,
                selected: c.selectedCategory,
                onSelect: c.selectCategory,
              ),
              // 4 (chips bottom padding) + 18 (deck section top) in the design
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // New category: the deck restarts from its first topic, faded in.
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: reduce ? 120 : 250),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...previous, ?current],
                  ),
                  child: TopicDeckCard.rich(
                    key: ValueKey(c.selectedCategory ?? 'all'),
                    items: c.visibleTopics,
                    categoryOf: c.category,
                    isSaved: c.isSaved,
                    isDiscussed: c.isDiscussed,
                    onToggleSave: c.toggleSave,
                    onTalk: c.markDiscussed,
                    index: c.currentIndex,
                    onNext: c.next,
                    onPrev: c.prev,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              TrendingSection(
                topics: c.trendingTopics,
                categoryOf: c.category,
                onOpen: (id) {
                  c.openTopic(id);
                  _scrollToDeck();
                },
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SuggestCard(
                  onAdd: (text) {
                    c.addMyTopic(text);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text(l.topicsAddedSnack)),
                      );
                    _scrollToDeck();
                  },
                ),
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DiscussedSection(
                  topics: discussed,
                  totalCount: c.discussedIds.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback onBack;
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final back = MaterialLocalizations.of(context).backButtonTooltip;
    return Row(
      children: [
        Tooltip(
          message: back,
          excludeFromSemantics: true,
          child: Semantics(
            button: true,
            label: back,
            excludeSemantics: true,
            child: Material(
              color: AC.card,
              shape: const CircleBorder(side: BorderSide(color: AC.border)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    // RTL page: back points right.
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: AC.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AC.ink,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: AC.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
