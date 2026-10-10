import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../screens/activities_colors.dart';
import 'clubs_controller.dart';
import 'motion.dart';
import 'widgets/book_of_month_card.dart';
import 'widgets/book_suggestion_tile.dart';
import 'widgets/discussion_date_card.dart';
import 'widgets/discussion_questions_card.dart';
import 'widgets/episode_card.dart';
import 'widgets/family_progress_card.dart';
import 'widgets/podcast_heard_card.dart';
import 'widgets/podcast_suggestion_row.dart';
import 'widgets/progress_sheet.dart';
import 'widgets/read_before_list.dart';
import 'widgets/suggest_sheet.dart';

enum ClubsTab { book, podcast }

/// The "النوادي" screen: book club and podcast club in one tabbed page.
/// Opened from the clubs section on the Activities page (the "see all"
/// link, or either club card), landing on whichever tab matches.
class ClubsScreen extends StatefulWidget {
  final ClubsTab initialTab;
  const ClubsScreen({super.key, this.initialTab = ClubsTab.book});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  late ClubsTab _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _ClubsHeader(onBack: () => Navigator.of(context).pop()),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 104),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ClubsTabBar(
                      value: _tab,
                      onChanged: (t) => setState(() => _tab = t),
                    ),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: KeyedSubtree(
                        key: ValueKey(_tab),
                        child: _tab == ClubsTab.book
                            ? const _BookTab()
                            : const _PodcastTab(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookTab extends StatefulWidget {
  const _BookTab();
  @override
  State<_BookTab> createState() => _BookTabState();
}

class _BookTabState extends State<_BookTab> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _suggestBook(ClubsController clubs) async {
    final l = AppLocalizations.of(context);
    final result = await SuggestSheet.show(context, SuggestType.book);
    if (result == null || !mounted) return;
    clubs.addBookSuggestion(
      title: result.title,
      author: result.by.isEmpty ? l.clubsYourSuggestion : result.by,
      category: result.category,
      about: result.about,
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.clubsSuggestionAdded)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (MediaQuery.of(context).disableAnimations) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _logProgress(ClubsController clubs) async {
    final totalPages = clubs.currentBook.totalPages;
    final result = await ProgressSheet.show(
      context,
      bookTitle: clubs.currentBook.title,
      totalPages: totalPages,
      initialPage: (clubs.myBookProgress * totalPages).round(),
    );
    if (result == null) return;
    clubs.updateMyProgress(totalPages == 0 ? 1 : result / totalPages);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final clubs = context.watch<ClubsController>();
    final myDone = clubs.myBookProgress >= 1;
    final allFinished = clubs.finishedCount == clubs.memberCount;
    final String progressBold, progressRest;
    if (allFinished) {
      progressBold = l.clubsBookAllDoneBold;
      progressRest = l.clubsBookAllDoneRest(clubs.bookDiscussion.dayName);
    } else if (myDone) {
      progressBold = l.clubsBookDoneWaitingBold;
      progressRest = l.clubsBookDoneWaitingRest(
        clubs.memberCount - clubs.finishedCount,
      );
    } else {
      progressBold = l.clubsCatchUpBold;
      progressRest = l.clubsPagesLeft(clubs.myPagesLeft);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookOfMonthCard(
          book: clubs.currentBook,
          daysLeftLabel: l.activitiesBookClubDaysLeft(clubs.daysLeft),
        ),
        const SizedBox(height: 16),
        FamilyProgressCard(
          title: l.clubsFamilyProgressTitle,
          readers: clubs.bookMembers,
          captionBold: progressBold,
          captionRest: progressRest,
          onLogProgress: () => _logProgress(clubs),
        ),
        const SizedBox(height: 16),
        DiscussionDateCard(
          day: clubs.bookDiscussion.dayName,
          date: clubs.bookDiscussion.dayNumber,
          time: clubs.bookDiscussion.time,
          dayColor: AC.brick,
          reminderOn: clubs.bookDiscussion.reminderOn,
          onToggleReminder: clubs.toggleBookReminder,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                l.clubsNextMonthSuggestions,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AC.ink,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              clubs.bookVotes.isEmpty
                  ? l.clubsNotVotedYet
                  : l.clubsVotedForCount(clubs.bookVotes.length),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AC.muted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l.clubsVoteForMoreHint,
          style: const TextStyle(fontSize: 14, color: AC.muted),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < clubs.bookSuggestions.length; i++) ...[
                if (i != 0) const SizedBox(width: 12),
                BookSuggestionTile(
                  book: clubs.bookSuggestions[i],
                  voted: clubs.bookVotes.contains(i),
                  onToggleVote: () => clubs.toggleBookVote(i),
                ),
              ],
              const SizedBox(width: 12),
              SuggestBookTile(onTap: () => _suggestBook(clubs)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ReadBeforeList(entries: clubs.readBefore),
      ],
    );
  }
}

class _PodcastTab extends StatefulWidget {
  const _PodcastTab();
  @override
  State<_PodcastTab> createState() => _PodcastTabState();
}

class _PodcastTabState extends State<_PodcastTab> {
  Future<void> _suggestPodcast(ClubsController clubs) async {
    final l = AppLocalizations.of(context);
    final result = await SuggestSheet.show(context, SuggestType.podcast);
    if (result == null || !mounted) return;
    final parts = [
      result.category,
      if (result.by.isNotEmpty) result.by,
      l.clubsYourSuggestion,
    ];
    clubs.addPodSuggestion(
      title: result.title,
      note: parts.join(' · '),
      about: result.about,
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.clubsSuggestionAdded)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final clubs = context.watch<ClubsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EpisodeCard(episode: clubs.currentEpisode),
        const SizedBox(height: 16),
        PodcastHeardCard(
          heardBy: clubs.heardBy,
          iHeard: clubs.iHeard,
          total: clubs.memberCount,
          onToggleHeard: clubs.toggleHeard,
        ),
        const SizedBox(height: 16),
        DiscussionQuestionsCard(
          questions: clubs.questions,
          onAdd: clubs.addDiscussionQuestion,
        ),
        const SizedBox(height: 16),
        DiscussionDateCard(
          day: clubs.podDiscussion.dayName,
          date: clubs.podDiscussion.dayNumber,
          time: clubs.podDiscussion.time,
          dayColor: AC.teal,
          reminderOn: clubs.podDiscussion.reminderOn,
          onToggleReminder: clubs.togglePodReminder,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                l.clubsNextWeekSuggestions,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AC.ink,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              clubs.podVotes.isEmpty
                  ? l.clubsNotVotedYet
                  : l.clubsVotedForCount(clubs.podVotes.length),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AC.muted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l.clubsVoteForMorePodcastHint,
          style: const TextStyle(fontSize: 14, color: AC.muted),
        ),
        const SizedBox(height: 12),
        PodcastSuggestionList(
          items: clubs.podSuggestions,
          voted: clubs.podVotes,
          onToggleVote: clubs.togglePodVote,
        ),
        const SizedBox(height: 12),
        SuggestPodcastButton(onTap: () => _suggestPodcast(clubs)),
      ],
    );
  }
}

class _ClubsHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _ClubsHeader({required this.onBack});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Tooltip(
          message: MaterialLocalizations.of(context).backButtonTooltip,
          child: Semantics(
            button: true,
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
                l.activitiesClubsSection,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: AC.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.clubsSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: AC.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClubsTabBar extends StatelessWidget {
  final ClubsTab value;
  final ValueChanged<ClubsTab> onChanged;
  const _ClubsTabBar({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AC.track,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ClubsTab(
              label: l.activitiesBookClubTitle,
              icon: Icons.menu_book_outlined,
              selected: value == ClubsTab.book,
              onTap: () => onChanged(ClubsTab.book),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ClubsTab(
              label: l.activitiesPodcastClubTitle,
              icon: Icons.headphones_outlined,
              selected: value == ClubsTab.podcast,
              onTap: () => onChanged(ClubsTab.podcast),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubsTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ClubsTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: clubsMotionDuration(context, 200),
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AC.card : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AC.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? AC.ink : AC.muted),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: selected ? AC.ink : AC.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
