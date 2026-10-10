// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lamma';

  @override
  String get navHome => 'Home';

  @override
  String get navLamma => 'Lamma';

  @override
  String get navActivities => 'Activity Box';

  @override
  String get navAccount => 'Account';

  @override
  String get navShare => 'Share';

  @override
  String get commonComments => 'Comments';

  @override
  String get commonWriteCommentHint => 'Write a comment...';

  @override
  String get commonShareAction => 'Share';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String homeGreeting(String name) {
    return 'Good evening, $name';
  }

  @override
  String get homeTodayWithFamily => 'Today with the family';

  @override
  String get homeFamilyNightTime => 'Family night · 8:00 PM';

  @override
  String homeAttendingCount(int attending, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      attending,
      locale: localeName,
      other: '$attending of $total attending',
      one: '1 of $total attending',
      zero: 'None of $total attending',
    );
    return '$_temp0';
  }

  @override
  String get homeStreak => '7 day streak';

  @override
  String get homeInteractions => '12 interactions this week';

  @override
  String get homeFamilyCalendar => 'Family calendar';

  @override
  String get homeAddEvent => '+ Add event';

  @override
  String get homeWeeklyPodcast => 'Weekly podcast';

  @override
  String get homePodcastTitle => 'What makes us laugh together?';

  @override
  String get homePodcastEpisode => 'Episode 12 · 32 min';

  @override
  String get homePodcastListenedCount => '3 of 6 listened';

  @override
  String get homeStartListening => 'Start listening';

  @override
  String get homeMemoriesQuote =>
      'The best memories start with a simple question';

  @override
  String get homeFamilyActivity => 'Family activity';

  @override
  String get homeFeedSarahPhoto => 'Sarah shared a photo';

  @override
  String get homeFeedMohammedChallenge =>
      'Mohammed finished today\'s challenge';

  @override
  String get homeFeedAminaPodcast => 'Amina listened to the weekly podcast';

  @override
  String homeFeedPhoto(String name) {
    return '$name shared a photo';
  }

  @override
  String homeFeedChallenge(String name) {
    return '$name finished today\'s challenge';
  }

  @override
  String homeFeedPodcast(String name) {
    return '$name listened to the weekly podcast';
  }

  @override
  String homePhoneFreeBanner(String from, String to) {
    return 'Phone-free time · $from – $to';
  }

  @override
  String homePunishmentBanner(String detail) {
    return 'Your punishment: $detail';
  }

  @override
  String get homeLeaderboardSeeAll => 'See all';

  @override
  String notifMomentShared(String name) {
    return '$name shared a moment';
  }

  @override
  String get addEventDateLabel => 'Date';

  @override
  String get homeYourWeekButton => 'Your week in Lamma';

  @override
  String get homeDayToday => '· Today';

  @override
  String get homeNoEvents => 'No events';

  @override
  String get eventDetailsTitle => 'Event details';

  @override
  String eventDetailsDateLine(String day, int dayNum, String time) {
    return '$day $dayNum · $time';
  }

  @override
  String eventDetailsGoingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of the family are coming',
      one: '1 of the family is coming',
      zero: 'None of the family are coming',
    );
    return '$_temp0';
  }

  @override
  String get eventDetailsImIn => 'You\'re in';

  @override
  String get eventDetailsImComing => 'I\'m coming';

  @override
  String get addEventTitle => 'New event';

  @override
  String get addEventTypeLabel => 'Event type';

  @override
  String get addEventNameLabel => 'Name';

  @override
  String get addEventNameHint => 'Event name...';

  @override
  String get addEventDayLabel => 'Day';

  @override
  String get addEventTimeLabel => 'Time';

  @override
  String get addEventSubmit => 'Add to calendar';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notifEpisodeReady => 'This week\'s episode is ready';

  @override
  String get notifSarahMoment => 'Sarah shared a moment';

  @override
  String get notifBadgeEarned => 'You earned the Lamma spirit badge';

  @override
  String get notifEmpty => 'That\'s all for now';

  @override
  String get recapTitle => 'Your week';

  @override
  String get recapHeroTitle => 'Your week in Lamma';

  @override
  String get recapChats => 'Chats';

  @override
  String get recapPhotos => 'Photos';

  @override
  String get recapActiveDays => 'Active days';

  @override
  String get recapListened => 'Listened';

  @override
  String get recapMostShared => 'Most shared: Talks with Aziz';

  @override
  String get recapEveryonePlayed => 'Everyone played it';

  @override
  String get recapSeeBadges => 'See badges';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSubtitle => 'Your Lamma profile';

  @override
  String accountAgeSpirit(int age) {
    return '$age years · Lamma spirit';
  }

  @override
  String get accountDesignCharacter => 'Design your character';

  @override
  String get accountMyInterests => 'My interests';

  @override
  String get accountPlacesToVisit => 'Places I\'d like to visit';

  @override
  String get accountNothingPicked => 'Nothing picked yet';

  @override
  String get accountParentSection => 'Parent';

  @override
  String get accountParentControlsTitle => 'Parent controls';

  @override
  String get accountParentControlsDesc =>
      'Phone-free time, consequences, rewards';

  @override
  String get accountAchievements => 'Achievements';

  @override
  String get accountStatDays => 'Days';

  @override
  String get accountStatGames => 'Games';

  @override
  String get accountAllBadges => 'All badges and achievements';

  @override
  String get designCharacterTitle => 'My character';

  @override
  String get designCharacterSection => 'Character';

  @override
  String get designOutfitsSection => 'Outfits';

  @override
  String get designSave => 'Save';

  @override
  String get badgesTitle => 'Badges and achievements';

  @override
  String get lammaSubtitle => 'Let\'s chat';

  @override
  String get lammaFamilyTalk => 'Family talk';

  @override
  String get lammaOpenFamilyChat => 'Open family chat';

  @override
  String get lammaMomentsOfOurDay => 'Moments of our day';

  @override
  String get lammaShareMomentAction => '+ Share moment';

  @override
  String get momentTitle => 'Moment';

  @override
  String get shareMomentTitle => 'Share a moment';

  @override
  String get shareMomentPhotoHint => 'Take or choose a photo';

  @override
  String get shareMomentTextHint => 'What\'s on your mind? (a word or two)';

  @override
  String get shareMomentTagCafe => 'At the café';

  @override
  String get shareMomentTagWalking => 'Walking';

  @override
  String get shareMomentTagCooking => 'Cooking';

  @override
  String get shareMomentSubmit => 'Share with family';

  @override
  String get shareMomentFallbackCaption => 'A moment';

  @override
  String get familyChatTitle => 'Family chat';

  @override
  String get familyChatInputHint => 'Write a message...';

  @override
  String get activitiesTitle => 'Activities';

  @override
  String get activitiesSubtitle => 'What should we do together today?';

  @override
  String get activitiesGroupGamesTitle => 'Group games';

  @override
  String get activitiesGroupGamesDesc => 'Roulette, Sin Jim and more';

  @override
  String get activitiesBookClubTitle => 'Book club';

  @override
  String get activitiesBookClubDesc => 'A Thousand Splendid Suns';

  @override
  String get activitiesPodcastClubTitle => 'Podcast club';

  @override
  String get activitiesPodcastDesc => 'Episode 12 · 3 of 6 listened';

  @override
  String get activitiesTalkTopicsTitle => 'Talk topics';

  @override
  String get activitiesTalkTopicsDesc => 'Conversation starters';

  @override
  String get activitiesOutingsTitle => 'Outings';

  @override
  String get activitiesOutingsDesc => 'Places that suit the whole family';

  @override
  String get activitiesNewTopic => 'New topic';

  @override
  String get activitiesClubsSection => 'Clubs';

  @override
  String get clubsSubtitle =>
      'Reading and listening together, then talking about it';

  @override
  String get clubsDiscussionSession => 'Discussion session';

  @override
  String get clubsRemindMe => 'Remind me';

  @override
  String get clubsRemindMeOn => 'We\'ll remind you';

  @override
  String get clubsBookOfMonthBadge => 'Book of the month';

  @override
  String get clubsAboutHeading => 'About';

  @override
  String get clubsReadMore => 'Read more';

  @override
  String get clubsReadLess => 'Less';

  @override
  String clubsFinishedCount(int done, int total) {
    return '$done of $total finished';
  }

  @override
  String get clubsCatchUpBold => 'Catch up!';

  @override
  String get clubsLogProgress => 'Log your progress';

  @override
  String clubsLogProgressSheetTitle(String title) {
    return 'How far are you in $title?';
  }

  @override
  String clubsPageOfTotal(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get clubsMarkAsFinished => 'Mark as finished';

  @override
  String get clubsSaveButton => 'Save';

  @override
  String get clubsMyDoneWaitingRest => 'Waiting for the discussion';

  @override
  String get clubsDoneLabel => 'Done';

  @override
  String clubsPagesLeft(int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages pages left for you',
      one: '1 page left for you',
    );
    return '$_temp0';
  }

  @override
  String get clubsFamilyProgressTitle => 'How far has the family gotten?';

  @override
  String get clubsThursday => 'Thursday';

  @override
  String get clubsBookDiscussionTime => 'After dinner · 9:00 PM';

  @override
  String get clubsNextMonthSuggestions => 'Next month\'s suggestions';

  @override
  String get clubsNotVotedYet => 'Haven\'t voted yet';

  @override
  String clubsVotedForCount(int count) {
    return 'Voted for $count';
  }

  @override
  String get clubsVoteForMoreHint =>
      'Vote for more than one book — the most-voted becomes the book of the month';

  @override
  String get clubsSuggestBook => 'Suggest a book';

  @override
  String get clubsSuggestBookHint => 'Didn\'t find what you had in mind?';

  @override
  String get clubsReadBeforeTitle => 'We\'ve read before';

  @override
  String clubsScoreOutOf(int completed, int total) {
    return '$completed of $total';
  }

  @override
  String get clubsSuggestPodcastHeading => 'Suggest a podcast';

  @override
  String get clubsSuggestFormSubtitle =>
      'It\'ll reach the family and join the suggestions';

  @override
  String get clubsClose => 'Close';

  @override
  String get clubsBookNameLabel => 'Book name';

  @override
  String get clubsBookNameHint => 'e.g. I Missed a Prayer';

  @override
  String get clubsBookAuthorLabel => 'Author (optional)';

  @override
  String get clubsBookAuthorHint => 'Author\'s name';

  @override
  String get clubsPodcastNameLabel => 'Podcast or episode name';

  @override
  String get clubsPodcastNameHint => 'e.g. How relationships succeed';

  @override
  String get clubsPodcastHostLabel => 'Host or channel (optional)';

  @override
  String get clubsPodcastHostHint => 'e.g. Yasser Al-Huzaimi';

  @override
  String get clubsCategoryLabel => 'Category';

  @override
  String get clubsAboutShort => 'Short blurb';

  @override
  String get clubsBookAboutHint =>
      'What\'s the book about? Why does it suit the family?';

  @override
  String get clubsPodcastAboutHint =>
      'What\'s the episode about? Why\'s it worth hearing together?';

  @override
  String get clubsAddToSuggestions => 'Add to suggestions';

  @override
  String get clubsCancel => 'Cancel';

  @override
  String get clubsSuggestionAdded => 'Your suggestion was added';

  @override
  String get clubsYourSuggestion => 'Your suggestion';

  @override
  String get clubsCatNovel => 'Novel';

  @override
  String get clubsCatBiographyHistory => 'Biography and history';

  @override
  String get clubsCatLiteratureEssays => 'Literature and essays';

  @override
  String get clubsCatSelfDev => 'Self-development';

  @override
  String get clubsCatFaith => 'Faith';

  @override
  String get clubsCatManners => 'Manners and conduct';

  @override
  String get clubsCatRelationships => 'Relationships';

  @override
  String get clubsCatCulture => 'Culture';

  @override
  String get clubsCatStories => 'Stories';

  @override
  String get clubsCatReligion => 'Religion';

  @override
  String get clubsCatParenting => 'Parenting';

  @override
  String get clubsCatOther => 'Other';

  @override
  String get clubsCustomCategoryHint => 'Type your category';

  @override
  String get clubsEpisodeOfWeekBadge => 'Episode of the week';

  @override
  String get clubsAboutEpisodeHeading => 'About the episode';

  @override
  String get clubsApplePodcasts => 'Apple Podcasts';

  @override
  String get clubsYoutube => 'YouTube';

  @override
  String get clubsWhoHeardTitle => 'Who\'s heard it?';

  @override
  String get clubsHeardButton => 'I heard it';

  @override
  String get clubsHeardButtonOn => 'I heard it ✓';

  @override
  String get clubsHalfFamilyFinished => 'Half the family finished it';

  @override
  String get clubsWhatToDiscussTitle => 'What should we discuss?';

  @override
  String get clubsWhoHeardAvatarsLabel => 'Who\'s heard it';

  @override
  String get clubsPodcastDiscussionTime => 'Over coffee · 5:00 PM';

  @override
  String get clubsNextWeekSuggestions => 'Next week\'s suggestions';

  @override
  String get clubsVoteForMorePodcastHint => 'Vote for more than one podcast';

  @override
  String get clubsAddDiscussionPoint => 'Add a discussion point';

  @override
  String get clubsAddQuestionHint => 'Type your question here';

  @override
  String get activitiesBookClubCount => '3 of 6 reading';

  @override
  String get activitiesPodcastClubDetail =>
      'Episode 12 · What makes us laugh together?';

  @override
  String get activitiesGroupGamesDescFull =>
      'Roulette, Talks with Aziz and Sin Jim';

  @override
  String get activitiesSpinRoulette => 'Spin the roulette';

  @override
  String get activitiesTonightTopicBadge => 'Tonight\'s topic';

  @override
  String activitiesTopicCounter(int index, int total) {
    return 'Topic $index of $total';
  }

  @override
  String get activitiesChatNow => 'Let\'s chat';

  @override
  String get activitiesChangeTopic => 'Change it';

  @override
  String get activitiesPrevTopic => 'Previous topic';

  @override
  String get activitiesRouletteBadge => 'Whose turn tonight?';

  @override
  String get activitiesRouletteCardDesc =>
      'Who starts, a challenge, or a family decision';

  @override
  String get activitiesSinJimCardDesc =>
      'Questions about each other — who knows best?';

  @override
  String get activitiesLettersAzizTitle => 'Letters with Aziz';

  @override
  String get activitiesLettersAzizDesc =>
      'Two teams compete, each answer starts with a letter';

  @override
  String activitiesBookClubDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get activitiesClubCatchUpBold => 'Catch up!';

  @override
  String activitiesClubFinishedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count finished before you',
      one: '1 finished before you',
      zero: 'No one finished yet',
    );
    return '$_temp0';
  }

  @override
  String activitiesPodcastEpisodeLabel(int episode) {
    return 'Podcast club · Episode $episode';
  }

  @override
  String get activitiesPodcastCardQuestion => 'What makes us laugh together?';

  @override
  String get activitiesPodcastYourTurnBold => 'Your turn to listen!';

  @override
  String get activitiesPodcastHalfDone =>
      'Half the family finished it — discussion on Thursday';

  @override
  String clubsPodcastClubLabel(String host) {
    return 'Podcast club · $host';
  }

  @override
  String get clubsBookDoneWaitingBold => 'Done!';

  @override
  String clubsBookDoneWaitingRest(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining left to finish the club',
      one: '1 left to finish the club',
    );
    return '$_temp0';
  }

  @override
  String get clubsBookAllDoneBold => 'Everyone\'s done!';

  @override
  String clubsBookAllDoneRest(String day) {
    return 'See you $day';
  }

  @override
  String clubsPodcastYourTurnRest(int heard, int total, String day) {
    return '$heard of $total listened, discussion $day';
  }

  @override
  String get clubsPodcastHeardBold => 'Listened ✓';

  @override
  String clubsPodcastHeardRest(String day, String time) {
    return 'See you $day $time';
  }

  @override
  String get activitiesPlayPodcastTooltip => 'Play';

  @override
  String get activitiesWeekendOutingTitle => 'Weekend outing';

  @override
  String get activitiesPrevPlace => 'Previous place';

  @override
  String get activitiesNextPlace => 'Next place';

  @override
  String activitiesPlaceCounter(int index, int total) {
    return '$index of $total';
  }

  @override
  String activitiesWeekendVoteText(int votes) {
    String _temp0 = intl.Intl.pluralLogic(
      votes,
      locale: localeName,
      other: '$votes of 6 want to go Friday',
      one: '1 of 6 wants to go Friday',
    );
    return '$_temp0';
  }

  @override
  String get activitiesWeekendVoteButton => 'I\'m in';

  @override
  String get activitiesWeekendVotedButton => 'You\'re in';

  @override
  String get activitiesWhoVotedLabel => 'Who voted';

  @override
  String get gamesTitle => 'Games';

  @override
  String get gamesPageSubtitle => 'Pick tonight\'s game';

  @override
  String get gamesRouletteTitle => 'Roulette';

  @override
  String get gamesRouletteDesc => 'Who starts? Who takes the challenge?';

  @override
  String get gamesTonightBadge => 'Tonight\'s game';

  @override
  String get gamesRouletteHeroDesc =>
      'Who starts, a challenge, or a decision.. the wheel decides';

  @override
  String get gamesSpinItButton => 'Spin it';

  @override
  String get gamesAzizTitle => 'Letters with Aziz';

  @override
  String get gamesAzizDesc => 'Two teams, each answer starts with a letter';

  @override
  String get gamesSinJimTitle => 'Sin Jim';

  @override
  String get gamesSinJimDesc => 'Answer on behalf of someone';

  @override
  String get gamesThabbitTitle => 'Thabbit';

  @override
  String get gamesThabbitDesc => 'Hold the pose!';

  @override
  String get gamesCharadesTitle => 'No Talking';

  @override
  String get gamesCharadesDesc => 'Act out the word without speaking';

  @override
  String get gamesPhotoTitle => 'Who\'s in the Photo?';

  @override
  String get gamesPhotoDesc => 'Family childhood photos, guess who';

  @override
  String get gamesWhoAmITitle => 'Who Am I?';

  @override
  String get gamesWhoAmIDesc => 'Phone on your forehead, everyone hints';

  @override
  String get gamesShiddahTitle => 'Shiddah';

  @override
  String get gamesShiddahDesc => 'Fast-paced card game';

  @override
  String get gamesTimeRange5to10 => '5–10 min';

  @override
  String get gamesTimeRange10to15 => '10–15 min';

  @override
  String get gamesTime5min => '5 min';

  @override
  String get gamesTime10min => '10 min';

  @override
  String get gamesStartPlaying => 'Start playing';

  @override
  String get gamesAllGamesTitle => 'All games';

  @override
  String gamesCountText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
    );
    return '$_temp0';
  }

  @override
  String get gamesFilterGroupLabel => 'Game type';

  @override
  String get gamesFilterAll => 'All';

  @override
  String get gamesFilterMove => 'Active';

  @override
  String get gamesFilterChallenge => 'Challenge';

  @override
  String get gamesFilterFamily => 'Family';

  @override
  String get gamesSoonBadge => 'Soon';

  @override
  String get gamesSoonSnack => 'Coming soon! We\'re getting it ready';

  @override
  String gamesTileSemanticsLabel(String title, String time) {
    return '$title, $time';
  }

  @override
  String get confirmEndYes => 'Yes, end it';

  @override
  String get confirmEndKeepPlaying => 'Keep playing';

  @override
  String get confirmEndTimerPaused => 'Timer paused until you decide';

  @override
  String get whoAmIBadge => 'One player + everyone hints';

  @override
  String get whoAmIHeroDesc => 'Phone on your forehead, everyone hints';

  @override
  String get whoAmIHow1 => 'Phone on your forehead';

  @override
  String get whoAmIHow2 => 'Hints without the word';

  @override
  String get whoAmIHow3 => 'Guess before time\'s up';

  @override
  String get whoAmIChooseCategory => 'Pick a category';

  @override
  String get whoAmICatAnimals => 'Animals';

  @override
  String get whoAmICatFood => 'Food';

  @override
  String get whoAmICatJobs => 'Jobs';

  @override
  String get whoAmICatPlaces => 'Places';

  @override
  String whoAmIWordsCount(int count) {
    return '$count words';
  }

  @override
  String get whoAmIRoundTime => 'Round length';

  @override
  String whoAmISeconds(int n) {
    return '${n}s';
  }

  @override
  String get whoAmIStart => 'Let\'s go';

  @override
  String get whoAmITime => 'Time';

  @override
  String get whoAmIScoreLabel => 'Score';

  @override
  String whoAmIWordNo(int n) {
    return 'Word $n';
  }

  @override
  String get whoAmIFlashCorrect => 'Got it! +1';

  @override
  String get whoAmIFlashSkip => 'Skipped';

  @override
  String get whoAmISkip => 'Skip';

  @override
  String get whoAmIGotIt => 'Got it!';

  @override
  String whoAmITimeLeft(int n) {
    return '$n seconds left';
  }

  @override
  String get whoAmIEndRound => 'End round';

  @override
  String get whoAmIEndTitle => 'End the round?';

  @override
  String get whoAmIEndMessage =>
      'You\'ll go to the results with what you\'ve got so far.';

  @override
  String get whoAmITimesUp => 'Time\'s up!';

  @override
  String get whoAmIVerdictTop => 'Guessing legend!';

  @override
  String get whoAmIVerdictGood => 'Great job!';

  @override
  String get whoAmIVerdictLow => 'Better luck next time!';

  @override
  String get whoAmIKnew => 'Got it';

  @override
  String get whoAmISkipped => 'Skipped';

  @override
  String get whoAmIRoundWords => 'Round words';

  @override
  String get whoAmIAgain => 'Another round';

  @override
  String get whoAmIBackToGames => 'Games';

  @override
  String get charadesSetupDesc =>
      'Act the word out for your team without speaking';

  @override
  String get charadesTeamLabelA => 'First team name';

  @override
  String get charadesTeamLabelB => 'Second team name';

  @override
  String get charadesDefaultTeamA => 'Falcons';

  @override
  String get charadesDefaultTeamB => 'Stars';

  @override
  String get charadesFallbackTeamA => 'Team 1';

  @override
  String get charadesFallbackTeamB => 'Team 2';

  @override
  String charadesMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
      zero: 'Nobody',
    );
    return '$_temp0';
  }

  @override
  String get charadesWhoWithWho => 'Who\'s with who?';

  @override
  String get charadesTapToPick => 'Tap each person to pick their team';

  @override
  String charadesPlayerTeamGroup(String name) {
    return '$name\'s team';
  }

  @override
  String get charadesRounds => 'Rounds';

  @override
  String charadesRoundsOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rounds',
      one: '1 round',
    );
    return '$_temp0';
  }

  @override
  String get charadesStart => 'Let\'s go';

  @override
  String get charadesNeedMembers => 'Each team needs at least one player';

  @override
  String charadesRoundOf(int n, int total) {
    return 'Round $n of $total';
  }

  @override
  String get charadesEndGame => 'End game';

  @override
  String get charadesTeamTurn => 'Team turn:';

  @override
  String get charadesActorThisTime => 'Acting this time';

  @override
  String charadesPassPhone(String name) {
    return 'Pass the phone to $name; everyone else, don\'t look';
  }

  @override
  String charadesImReady(String name) {
    return 'I\'m $name, ready';
  }

  @override
  String charadesActing(String name) {
    return '$name is acting';
  }

  @override
  String charadesSecondsShort(int n) {
    return '${n}s';
  }

  @override
  String get charadesActIt => 'Act it out!';

  @override
  String get charadesTapToReveal => 'Tap to see the word';

  @override
  String get charadesNoTalking => 'No talking or pointing at letters';

  @override
  String get charadesSkip => 'Skip';

  @override
  String get charadesCorrect => 'Got it! +1';

  @override
  String get charadesEndTurn => 'End turn';

  @override
  String get charadesEndTurnTitle => 'End the turn?';

  @override
  String charadesEndTurnMessage(String team) {
    return 'The turn passes to $team.';
  }

  @override
  String get charadesEndGameTitle => 'End the game?';

  @override
  String get charadesEndGameMessage =>
      'We\'ll count the points so far and pick the winner.';

  @override
  String get charadesWinnerTeam => 'Winning team';

  @override
  String get charadesTie => 'It\'s a tie!';

  @override
  String get charadesEveryoneWon => 'Everyone wins';

  @override
  String get charadesPlayerPoints => 'Points per player';

  @override
  String get charadesStarPlayer => 'Star player';

  @override
  String get charadesBackToGames => 'Games';

  @override
  String get charadesNewGame => 'New game';

  @override
  String get seenDesc =>
      'Answer on behalf of someone and see who knows the family best';

  @override
  String get seenWhoPlays => 'Who\'s playing?';

  @override
  String seenPlayersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players',
      one: '1 player',
    );
    return '$_temp0';
  }

  @override
  String get seenPickAtLeast3 => 'pick at least 3';

  @override
  String get seenQuestionCount => 'Number of questions';

  @override
  String seenQuestionsOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String get seenStart => 'Let\'s go';

  @override
  String seenQuestionNo(int n, int total) {
    return 'Question $n of $total';
  }

  @override
  String get seenAbout => 'Question about';

  @override
  String get seenAnswersAloud => 'answers out loud';

  @override
  String seenIsAnswerRight(String name) {
    return '$name, is the answer right?';
  }

  @override
  String get seenWrong => 'Wrong';

  @override
  String get seenRight => 'Right! +1';

  @override
  String get seenEndTitle => 'End the game?';

  @override
  String get seenEndMessage =>
      'We\'ll rank everyone on the questions answered so far.';

  @override
  String get seenWinnerLabel => 'Knows the family best';

  @override
  String seenPointsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String get seenBackToGames => 'Games';

  @override
  String get seenPlayAgain => 'Play again';

  @override
  String get seenCloseLabel => 'End';

  @override
  String get topicsSubtitle => 'Start a conversation, the rest is up to you';

  @override
  String get topicsGroupLabel => 'Topic type';

  @override
  String get topicsAll => 'All';

  @override
  String get topicsCatMemories => 'Memories';

  @override
  String get topicsCatDreams => 'Dreams & travel';

  @override
  String get topicsCatFood => 'Food';

  @override
  String get topicsCatFun => 'Laughs';

  @override
  String get topicsCatWyr => 'Would you rather';

  @override
  String get topicsCatMine => 'Our topics';

  @override
  String get topicsSave => 'Save topic';

  @override
  String topicsCountOf(int n, int total) {
    return '$n of $total';
  }

  @override
  String get topicsDiscussedBadge => 'We talked about it';

  @override
  String get topicsLetsTalk => 'Let\'s talk';

  @override
  String get topicsDiscussedButton => 'We talked about it';

  @override
  String get topicsPrev => 'Previous topic';

  @override
  String get topicsShuffle => 'Change it';

  @override
  String get topicsTrendingTitle => 'Trending now';

  @override
  String get topicsTrendingSub => 'Most talked about this week';

  @override
  String get topicsTalkAboutIt => 'Let\'s talk about it';

  @override
  String get topicsSuggestTitle => 'Got a topic in mind?';

  @override
  String get topicsSuggestSub => 'Write it and it joins your family\'s topics';

  @override
  String get topicsSuggestHint => 'e.g. What was your first salary?';

  @override
  String get topicsSuggestFieldLabel => 'Your topic';

  @override
  String get topicsAdd => 'Add';

  @override
  String get topicsAddedSnack => 'Your topic was added';

  @override
  String get topicsDoneTitle => 'We talked about these';

  @override
  String topicsDoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count topics',
      one: '1 topic',
      zero: 'No topics yet',
    );
    return '$_temp0';
  }

  @override
  String get topicsDoneEmpty =>
      'When you tap \"Let\'s talk\" on a topic,\nit\'s saved here so you remember what you talked about';

  @override
  String get soonPageMessage => 'Coming soon';

  @override
  String get azizNext => 'Next';

  @override
  String get azizSkip => 'Skip';

  @override
  String get sinJimAnswerOnBehalf => 'Answer on behalf of';

  @override
  String get sinJimQPrefix => 'Q:';

  @override
  String get sinJimEveryoneAnswered => 'Everyone answered';

  @override
  String sinJimAnswersRecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answers recorded',
      one: '1 answer recorded',
      zero: 'No answers recorded',
    );
    return '$_temp0';
  }

  @override
  String get rouletteModeWhoStarts => 'Who starts?';

  @override
  String get rouletteModeChallenge => 'Challenge';

  @override
  String get rouletteModeDecision => 'Decision';

  @override
  String get rouletteChallengeJoke => 'Tell a joke';

  @override
  String get rouletteChallengeSing => 'Sing a line';

  @override
  String get rouletteChallengeImitate => 'Imitate someone';

  @override
  String get rouletteChallengeDance => 'Dance 10 sec';

  @override
  String get rouletteChallengeSecret => 'Tell a secret';

  @override
  String get rouletteChallengeDraw => 'Draw in 10 sec';

  @override
  String get rouletteDecisionStayHome => 'Stay home';

  @override
  String get rouletteDecisionGoOut => 'Go out';

  @override
  String get rouletteDecisionCook => 'Cook';

  @override
  String get rouletteDecisionOrderFood => 'Order food';

  @override
  String get rouletteDecisionMovie => 'Watch a movie';

  @override
  String get rouletteDecisionGames => 'Play games';

  @override
  String rouletteResultStarts(String name) {
    return '$name starts!';
  }

  @override
  String get rouletteSpin => 'Spin the wheel';

  @override
  String get rouletteGotIt => 'Got it';

  @override
  String get bookClubCurrentBook => 'Current book';

  @override
  String get bookClubReadingStatus => '3 of 6 reading · discussion on Thursday';

  @override
  String get bookClubJoinDiscussion => 'Join the discussion';

  @override
  String get discussionQuestionsHeading => 'Discussion questions';

  @override
  String get bookClubQ1 => 'Which character are you closest to?';

  @override
  String get bookClubQ2 => 'If the ending changed, what would it be?';

  @override
  String get podcastThisWeekEpisode => 'This week\'s episode';

  @override
  String get podcastDuration => '32 min';

  @override
  String get podcastListenedLabel => 'Listened';

  @override
  String podcastListenedFraction(int count) {
    return '$count/6';
  }

  @override
  String get podcastNextGathering =>
      'Next gathering: Friday after dinner. We will all talk about it.';

  @override
  String get podcastQ1 => 'When did we last laugh until we cried?';

  @override
  String get podcastQ2 => 'Who in the family tells the best jokes?';

  @override
  String get talkTopicsGiveMeTopic => 'Give me a topic';

  @override
  String get talkTopicsTrendingNow => 'Trending now';

  @override
  String get talkTopicsTrend1 => 'Best Ramadan memory';

  @override
  String get talkTopicsTrend2 => 'Mom\'s favorite dish';

  @override
  String get outingsFilterAll => 'All';

  @override
  String get outingsPlacesMap => 'Places map';

  @override
  String get outingsOurOutings => 'Our outings';

  @override
  String get suggestPlaceTitle => 'Suggestion for the family';

  @override
  String get suggestPlaceWhyHeading => 'Why we suggested it';

  @override
  String get suggestPlaceAdd => 'Add to \"Our outings\"';

  @override
  String get suggestPlaceAddedSnackbar => 'Added to Our outings';

  @override
  String get ourOutingsEmpty => 'Nothing here yet.\nAdd a place from Outings.';

  @override
  String get onboardingSplashLogo => 'Lamma';

  @override
  String get onboardingSplashTagline => 'Let\'s gather';

  @override
  String get onboardingSplashStart => 'Start';

  @override
  String get onboardingAboutTitle => 'Let\'s get to know you';

  @override
  String get onboardingAboutSubtitle => 'A few quick questions';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingInterestsTitle => 'What do you like?';

  @override
  String get onboardingInterestsSubtitle => 'Pick what suits your experience';

  @override
  String get onboardingSignupTitle => 'Welcome!';

  @override
  String get onboardingSignupSubtitle => 'We\'ll text you a verification code';

  @override
  String get onboardingCreateAccount => 'Create account';

  @override
  String get onboardingFamilyTitle => 'Your family';

  @override
  String get onboardingFamilySubtitle => 'Create a family space or join one';

  @override
  String get onboardingCharacterTitle => 'Pick your character';

  @override
  String get onboardingCharacterSubtitle =>
      'You can change it any time in Account';

  @override
  String get onboardingLetsGo => 'Let\'s go';

  @override
  String get onboardingNameLabel => 'Your name';

  @override
  String get onboardingNameHint => 'Name';

  @override
  String get onboardingAgeLabel => 'Age';

  @override
  String get onboardingAgeHint => 'Your age';

  @override
  String get onboardingRoleQuestion => 'I\'m the family\'s...';

  @override
  String get roleMomLabel => 'Mom';

  @override
  String get roleDadLabel => 'Dad';

  @override
  String get roleDaughterLabel => 'Daughter';

  @override
  String get roleSonLabel => 'Son';

  @override
  String get onboardingJobQuestion => 'What do you do?';

  @override
  String get onboardingJobWork => 'I work';

  @override
  String get onboardingJobStudent => 'I\'m a student';

  @override
  String get onboardingJobHome => 'I stay at home';

  @override
  String get onboardingThingsYouLove => 'Things you love';

  @override
  String get onboardingTypeOfOutings => 'Type of outings';

  @override
  String get onboardingIPrefer => 'I prefer...';

  @override
  String get onboardingPreferGames => 'Games';

  @override
  String get onboardingPreferDiscussions => 'Discussions';

  @override
  String get onboardingPhoneHint => '05 ••• ••• ••';

  @override
  String get onboardingSigninInstead => 'Already have an account? Sign in';

  @override
  String get onboardingStartFamily => 'Start a family';

  @override
  String get onboardingFamilyNameHint => 'e.g. Al-Otaibi family';

  @override
  String get onboardingCreate => 'Create';

  @override
  String get onboardingHaveInviteCode => 'Have an invite code?';

  @override
  String get onboardingInviteCodeHint => 'LAMMA-48';

  @override
  String get onboardingJoin => 'Join';

  @override
  String get dataCharacterSister => 'Sister';

  @override
  String get dataCharacterBigBrother => 'Big brother';

  @override
  String get dataCharacterFather => 'Father';

  @override
  String get dataCharacterMother => 'Mother';

  @override
  String get dataCharacterLittleGirl => 'Little girl';

  @override
  String get dataCharacterSon => 'Son';

  @override
  String get dataMemberNoura => 'Noura';

  @override
  String get dataMemberMohammed => 'Mohammed';

  @override
  String get dataMemberAbdullah => 'Abdullah';

  @override
  String get dataMemberAmina => 'Amina';

  @override
  String get dataMemberSarah => 'Sarah';

  @override
  String get dataMemberYousef => 'Yousef';

  @override
  String get dataEventTypeGathering => 'Gathering';

  @override
  String get dataEventTypeOuting => 'Outing';

  @override
  String get dataEventTypeDinner => 'Dinner';

  @override
  String get dataEventTypeGames => 'Games';

  @override
  String get dataEventTypeTrip => 'Trip';

  @override
  String get dataEventTypeMovie => 'Movie';

  @override
  String get dataEventTypeOccasion => 'Occasion';

  @override
  String get dataDaySat => 'Sat';

  @override
  String get dataDaySun => 'Sun';

  @override
  String get dataDayMon => 'Mon';

  @override
  String get dataWeekdayMon => 'Mon';

  @override
  String get dataWeekdayTue => 'Tue';

  @override
  String get dataWeekdayWed => 'Wed';

  @override
  String get dataWeekdayThu => 'Thu';

  @override
  String get dataWeekdayFri => 'Fri';

  @override
  String get dataWeekdaySat => 'Sat';

  @override
  String get dataWeekdaySun => 'Sun';

  @override
  String get dataMonthJan => 'Jan';

  @override
  String get dataMonthFeb => 'Feb';

  @override
  String get dataMonthMar => 'Mar';

  @override
  String get dataMonthApr => 'Apr';

  @override
  String get dataMonthMay => 'May';

  @override
  String get dataMonthJun => 'Jun';

  @override
  String get dataMonthJul => 'Jul';

  @override
  String get dataMonthAug => 'Aug';

  @override
  String get dataMonthSep => 'Sep';

  @override
  String get dataMonthOct => 'Oct';

  @override
  String get dataMonthNov => 'Nov';

  @override
  String get dataMonthDec => 'Dec';

  @override
  String get dataEventTitleVillageOuting => 'Village outing';

  @override
  String get dataEventTitleFamilyDinner => 'Family dinner';

  @override
  String get dataEventTime4pm => '4:00 PM';

  @override
  String get dataEventTime8pm => '8:00 PM';

  @override
  String get dataTime930pm => '9:30 PM';

  @override
  String get dataPlaceKingSalmanPark => 'King Salman Park';

  @override
  String get dataPlaceCafeAlDar => 'Café Al-Dar';

  @override
  String get dataPlaceStrikeBowling => 'Strike Bowling';

  @override
  String get dataPlaceSufratAlBayt => 'Sufrat Al-Bayt';

  @override
  String get dataPlaceWhyPark =>
      '4 of 6 family members like this type of place';

  @override
  String get dataPlaceWhyCafe => 'Suits everyone, a good choice';

  @override
  String get dataPlaceWhyBowling => '3 of 6 love games and group activities';

  @override
  String get dataPlaceWhyRestaurant => 'Homestyle food and family seating';

  @override
  String get dataOutingTypeNature => 'Nature';

  @override
  String get dataOutingTypeRestaurants => 'Restaurants';

  @override
  String get dataOutingTypeCafes => 'Cafés';

  @override
  String get dataOutingTypeEntertainment => 'Entertainment';

  @override
  String get dataBadgeMostInteractive => 'Most interactive';

  @override
  String get dataBadgeLammaSpirit => 'Lamma spirit';

  @override
  String get dataBadgeWeeklyListener => 'Weekly listener';

  @override
  String get dataBadgeWeekWinner => 'Week winner';

  @override
  String get dataBadgeTalksKing => 'Talks king';

  @override
  String get dataBadgeReader => 'Reader';

  @override
  String get dataAziz1 => 'What\'s the strangest food you\'ve ever tried?';

  @override
  String get dataAziz2 => 'Which trip would you repeat tomorrow?';

  @override
  String get dataAziz3 => 'What\'s a small thing that makes your day?';

  @override
  String get dataAziz4 => 'Who in the family makes you laugh the most?';

  @override
  String get dataSinJim1 => 'How old is your grandfather?';

  @override
  String get dataSinJim2 => 'What\'s Dad\'s favorite dish?';

  @override
  String get dataSinJim3 => 'What\'s Mom\'s favorite color?';

  @override
  String get dataSinJim4 => 'Who is the biggest sleeper in the family?';

  @override
  String get dataTopic1 =>
      'If you could travel anywhere now, where would we go?';

  @override
  String get dataTopic2 => 'What\'s the family moment you\'d never forget?';

  @override
  String get dataTopic3 => 'What tradition should we start this year?';

  @override
  String get dataTopic4 => 'What\'s one thing you\'ve never told us?';

  @override
  String get dataMomentCaptionSarah => 'Went out today with the girls';

  @override
  String get dataMomentCaptionMohammed => 'Study break at the café';

  @override
  String get dataMomentCaptionAmina => 'Fresh coffee, quiet morning';

  @override
  String get dataMomentCaptionAbdullah => 'Evening in the majlis';

  @override
  String get dataMomentCaptionYousef => 'My new Lego!';

  @override
  String get dataMomentCaptionNoura => 'Baking with Mom';

  @override
  String get dataTimeTodayAt410pm => 'Today, 4:10 PM';

  @override
  String get dataTimeTodayAt130pm => 'Today, 1:30 PM';

  @override
  String get dataTimeTodayAt815am => 'Today, 8:15 AM';

  @override
  String get dataTimeYesterday => 'Yesterday';

  @override
  String get dataTimeToday => 'Today';

  @override
  String get dataTime2DaysAgo => '2 days ago';

  @override
  String get dataTalkSarah => 'What do you want to eat on Thursday?';

  @override
  String get dataTalkAmina => 'Who wants to come with me to the market?';

  @override
  String get dataCommentAbdullah => 'Nice!';

  @override
  String get dataCommentAmina => 'God protect you all';

  @override
  String get dataCommentMohammed => 'Take me with you';

  @override
  String get dataInterestCoffee => 'Coffee';

  @override
  String get dataInterestGames => 'Games';

  @override
  String get dataInterestReading => 'Reading';

  @override
  String get dataInterestWalking => 'Walking';

  @override
  String get dataInterestPodcasts => 'Podcasts';

  @override
  String get dataInterestMovies => 'Movies';

  @override
  String get dataInterestCooking => 'Cooking';

  @override
  String get dataInterestDrawing => 'Drawing';

  @override
  String get dataInterestFootball => 'Football';

  @override
  String get dataInterestSwimming => 'Swimming';

  @override
  String get dataInterestMusic => 'Music';

  @override
  String get dataInterestTravel => 'Travel';

  @override
  String get dataFamilyFallback => 'Your family';

  @override
  String get dataFamilyDefault => 'Al-Otaibi family';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String leaderboardCycleReward(String cycle) {
    return '$cycle reward';
  }

  @override
  String leaderboardLastWinner(String winner, String reward) {
    return 'Winner: $winner · $reward';
  }

  @override
  String get leaderboardRanking => 'Ranking';

  @override
  String leaderboardPts(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points pts',
      one: '1 pt',
      zero: '0 pts',
    );
    return '$_temp0';
  }

  @override
  String get leaderboardNoWinnerYet => 'No winner yet';

  @override
  String leaderboardRewardNow(String name) {
    return 'Reward $name (#1) now';
  }

  @override
  String leaderboardRewardSnackbar(String name, String reward) {
    return '$name gets: $reward';
  }

  @override
  String get parentControlsPhoneFreeTime => 'Phone-free time';

  @override
  String get parentControlsFrom => 'From';

  @override
  String get parentControlsUntil => 'Until';

  @override
  String get parentControlsIfPhoneUsed => 'If someone uses their phone';

  @override
  String get parentControlsLosePointsChoice => 'Lose points';

  @override
  String get parentControlsPointsLost => 'Points lost';

  @override
  String get parentControlsOrWriteOwn => 'Or write your own';

  @override
  String get parentControlsRecordViolation => 'Record a phone violation';

  @override
  String parentControlsTakeAwayPoints(int penalty) {
    String _temp0 = intl.Intl.pluralLogic(
      penalty,
      locale: localeName,
      other: 'Take away $penalty points',
      one: 'Take away 1 point',
    );
    return '$_temp0';
  }

  @override
  String get parentControlsGivePunishment => 'Give punishment';

  @override
  String get parentControlsRecent => 'Recent';

  @override
  String get parentControlsDone => 'Done';

  @override
  String get parentControlsLeaderboardReward => 'Leaderboard reward';

  @override
  String get parentControlsWinningCycle => 'Winning cycle';

  @override
  String get parentControlsRewardForWinner => 'Reward for the winner';

  @override
  String get parentControlsOrWriteOwnReward => 'Or write your own reward';

  @override
  String parentControlsViolationSnackbar(
    String who,
    String kind,
    String detail,
  ) {
    return '$who: $kind ($detail)';
  }

  @override
  String get violationKindLostPoints => 'Lost points';

  @override
  String get violationKindPunishment => 'Punishment';

  @override
  String get dataCycleWeekly => 'Weekly';

  @override
  String get dataCycleMonthly => 'Monthly';

  @override
  String get dataTimeJustNow => 'Just now';

  @override
  String get dataPunishmentDishes => 'Wash the dishes';

  @override
  String get dataPunishmentNoGames => 'No games tonight';

  @override
  String get dataPunishmentCleanRoom => 'Clean your room';

  @override
  String get dataPunishmentEarlyBedtime => 'Early bedtime';

  @override
  String get dataPunishmentHelpCook => 'Help cook dinner';

  @override
  String get dataRewardDinnerPlace => 'Choose the family dinner place';

  @override
  String get dataRewardMovie => 'Pick the movie for movie night';

  @override
  String get dataRewardSkipChore => 'Skip a chore';

  @override
  String get dataRewardOuting => 'Choose the weekend outing';

  @override
  String get dataRewardGameTime => 'Extra game time';

  @override
  String get chatSeedSarahCooking => 'What are we cooking tonight?';

  @override
  String get chatSeedMeGoPark => 'Let\'s go to the park!';

  @override
  String get chatSeedAminaDinner => 'Dinner will be ready soon';

  @override
  String get chatSeedMeComing => 'Coming!';
}
