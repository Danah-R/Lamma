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
  String get navActivities => 'Activities';

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
  String get activitiesSubtitle => 'What can we do together?';

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
  String get gamesTitle => 'Games';

  @override
  String get gamesRouletteTitle => 'Roulette';

  @override
  String get gamesRouletteDesc => 'Who starts? Who takes the challenge?';

  @override
  String get gamesAzizTitle => 'Talks with Aziz';

  @override
  String get gamesAzizDesc => 'Funny and surprising questions';

  @override
  String get gamesSinJimTitle => 'Sin Jim';

  @override
  String get gamesSinJimDesc => 'Answer on behalf of someone';

  @override
  String get gamesThabbitTitle => 'Thabbit';

  @override
  String get gamesThabbitDesc => 'Hold the pose!';

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
  String get dataEventTitleVillageOuting => 'Village outing';

  @override
  String get dataEventTitleFamilyDinner => 'Family dinner';

  @override
  String get dataEventTime4pm => '4:00 PM';

  @override
  String get dataEventTime8pm => '8:00 PM';

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
  String get chatSeedSarahCooking => 'What are we cooking tonight?';

  @override
  String get chatSeedMeGoPark => 'Let\'s go to the park!';

  @override
  String get chatSeedAminaDinner => 'Dinner will be ready soon';

  @override
  String get chatSeedMeComing => 'Coming!';
}
