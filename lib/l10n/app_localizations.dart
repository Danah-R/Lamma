import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lamma'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLamma.
  ///
  /// In en, this message translates to:
  /// **'Lamma'**
  String get navLamma;

  /// No description provided for @navActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get navActivities;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @navShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get navShare;

  /// No description provided for @commonComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commonComments;

  /// No description provided for @commonWriteCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get commonWriteCommentHint;

  /// No description provided for @commonShareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShareAction;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeTodayWithFamily.
  ///
  /// In en, this message translates to:
  /// **'Today with the family'**
  String get homeTodayWithFamily;

  /// No description provided for @homeFamilyNightTime.
  ///
  /// In en, this message translates to:
  /// **'Family night · 8:00 PM'**
  String get homeFamilyNightTime;

  /// No description provided for @homeAttendingCount.
  ///
  /// In en, this message translates to:
  /// **'{attending, plural, zero{None of {total} attending} one{1 of {total} attending} other{{attending} of {total} attending}}'**
  String homeAttendingCount(int attending, int total);

  /// No description provided for @homeStreak.
  ///
  /// In en, this message translates to:
  /// **'7 day streak'**
  String get homeStreak;

  /// No description provided for @homeInteractions.
  ///
  /// In en, this message translates to:
  /// **'12 interactions this week'**
  String get homeInteractions;

  /// No description provided for @homeFamilyCalendar.
  ///
  /// In en, this message translates to:
  /// **'Family calendar'**
  String get homeFamilyCalendar;

  /// No description provided for @homeAddEvent.
  ///
  /// In en, this message translates to:
  /// **'+ Add event'**
  String get homeAddEvent;

  /// No description provided for @homeWeeklyPodcast.
  ///
  /// In en, this message translates to:
  /// **'Weekly podcast'**
  String get homeWeeklyPodcast;

  /// No description provided for @homePodcastTitle.
  ///
  /// In en, this message translates to:
  /// **'What makes us laugh together?'**
  String get homePodcastTitle;

  /// No description provided for @homePodcastEpisode.
  ///
  /// In en, this message translates to:
  /// **'Episode 12 · 32 min'**
  String get homePodcastEpisode;

  /// No description provided for @homePodcastListenedCount.
  ///
  /// In en, this message translates to:
  /// **'3 of 6 listened'**
  String get homePodcastListenedCount;

  /// No description provided for @homeStartListening.
  ///
  /// In en, this message translates to:
  /// **'Start listening'**
  String get homeStartListening;

  /// No description provided for @homeMemoriesQuote.
  ///
  /// In en, this message translates to:
  /// **'The best memories start with a simple question'**
  String get homeMemoriesQuote;

  /// No description provided for @homeFamilyActivity.
  ///
  /// In en, this message translates to:
  /// **'Family activity'**
  String get homeFamilyActivity;

  /// No description provided for @homeFeedSarahPhoto.
  ///
  /// In en, this message translates to:
  /// **'Sarah shared a photo'**
  String get homeFeedSarahPhoto;

  /// No description provided for @homeFeedMohammedChallenge.
  ///
  /// In en, this message translates to:
  /// **'Mohammed finished today\'s challenge'**
  String get homeFeedMohammedChallenge;

  /// No description provided for @homeFeedAminaPodcast.
  ///
  /// In en, this message translates to:
  /// **'Amina listened to the weekly podcast'**
  String get homeFeedAminaPodcast;

  /// No description provided for @homeYourWeekButton.
  ///
  /// In en, this message translates to:
  /// **'Your week in Lamma'**
  String get homeYourWeekButton;

  /// No description provided for @homeDayToday.
  ///
  /// In en, this message translates to:
  /// **'· Today'**
  String get homeDayToday;

  /// No description provided for @homeNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get homeNoEvents;

  /// No description provided for @eventDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Event details'**
  String get eventDetailsTitle;

  /// No description provided for @eventDetailsDateLine.
  ///
  /// In en, this message translates to:
  /// **'{day} {dayNum} · {time}'**
  String eventDetailsDateLine(String day, int dayNum, String time);

  /// No description provided for @eventDetailsGoingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{None of the family are coming} one{1 of the family is coming} other{{count} of the family are coming}}'**
  String eventDetailsGoingCount(int count);

  /// No description provided for @eventDetailsImIn.
  ///
  /// In en, this message translates to:
  /// **'You\'re in'**
  String get eventDetailsImIn;

  /// No description provided for @eventDetailsImComing.
  ///
  /// In en, this message translates to:
  /// **'I\'m coming'**
  String get eventDetailsImComing;

  /// No description provided for @addEventTitle.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get addEventTitle;

  /// No description provided for @addEventTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Event type'**
  String get addEventTypeLabel;

  /// No description provided for @addEventNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addEventNameLabel;

  /// No description provided for @addEventNameHint.
  ///
  /// In en, this message translates to:
  /// **'Event name...'**
  String get addEventNameHint;

  /// No description provided for @addEventDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get addEventDayLabel;

  /// No description provided for @addEventTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get addEventTimeLabel;

  /// No description provided for @addEventSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get addEventSubmit;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notifEpisodeReady.
  ///
  /// In en, this message translates to:
  /// **'This week\'s episode is ready'**
  String get notifEpisodeReady;

  /// No description provided for @notifSarahMoment.
  ///
  /// In en, this message translates to:
  /// **'Sarah shared a moment'**
  String get notifSarahMoment;

  /// No description provided for @notifBadgeEarned.
  ///
  /// In en, this message translates to:
  /// **'You earned the Lamma spirit badge'**
  String get notifBadgeEarned;

  /// No description provided for @notifEmpty.
  ///
  /// In en, this message translates to:
  /// **'That\'s all for now'**
  String get notifEmpty;

  /// No description provided for @recapTitle.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get recapTitle;

  /// No description provided for @recapHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your week in Lamma'**
  String get recapHeroTitle;

  /// No description provided for @recapChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get recapChats;

  /// No description provided for @recapPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get recapPhotos;

  /// No description provided for @recapActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get recapActiveDays;

  /// No description provided for @recapListened.
  ///
  /// In en, this message translates to:
  /// **'Listened'**
  String get recapListened;

  /// No description provided for @recapMostShared.
  ///
  /// In en, this message translates to:
  /// **'Most shared: Talks with Aziz'**
  String get recapMostShared;

  /// No description provided for @recapEveryonePlayed.
  ///
  /// In en, this message translates to:
  /// **'Everyone played it'**
  String get recapEveryonePlayed;

  /// No description provided for @recapSeeBadges.
  ///
  /// In en, this message translates to:
  /// **'See badges'**
  String get recapSeeBadges;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Lamma profile'**
  String get accountSubtitle;

  /// No description provided for @accountAgeSpirit.
  ///
  /// In en, this message translates to:
  /// **'{age} years · Lamma spirit'**
  String accountAgeSpirit(int age);

  /// No description provided for @accountDesignCharacter.
  ///
  /// In en, this message translates to:
  /// **'Design your character'**
  String get accountDesignCharacter;

  /// No description provided for @accountMyInterests.
  ///
  /// In en, this message translates to:
  /// **'My interests'**
  String get accountMyInterests;

  /// No description provided for @accountPlacesToVisit.
  ///
  /// In en, this message translates to:
  /// **'Places I\'d like to visit'**
  String get accountPlacesToVisit;

  /// No description provided for @accountNothingPicked.
  ///
  /// In en, this message translates to:
  /// **'Nothing picked yet'**
  String get accountNothingPicked;

  /// No description provided for @accountAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get accountAchievements;

  /// No description provided for @accountStatDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get accountStatDays;

  /// No description provided for @accountStatGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get accountStatGames;

  /// No description provided for @accountAllBadges.
  ///
  /// In en, this message translates to:
  /// **'All badges and achievements'**
  String get accountAllBadges;

  /// No description provided for @designCharacterTitle.
  ///
  /// In en, this message translates to:
  /// **'My character'**
  String get designCharacterTitle;

  /// No description provided for @designCharacterSection.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get designCharacterSection;

  /// No description provided for @designOutfitsSection.
  ///
  /// In en, this message translates to:
  /// **'Outfits'**
  String get designOutfitsSection;

  /// No description provided for @designSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get designSave;

  /// No description provided for @badgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges and achievements'**
  String get badgesTitle;

  /// No description provided for @lammaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s chat'**
  String get lammaSubtitle;

  /// No description provided for @lammaFamilyTalk.
  ///
  /// In en, this message translates to:
  /// **'Family talk'**
  String get lammaFamilyTalk;

  /// No description provided for @lammaOpenFamilyChat.
  ///
  /// In en, this message translates to:
  /// **'Open family chat'**
  String get lammaOpenFamilyChat;

  /// No description provided for @lammaMomentsOfOurDay.
  ///
  /// In en, this message translates to:
  /// **'Moments of our day'**
  String get lammaMomentsOfOurDay;

  /// No description provided for @lammaShareMomentAction.
  ///
  /// In en, this message translates to:
  /// **'+ Share moment'**
  String get lammaShareMomentAction;

  /// No description provided for @momentTitle.
  ///
  /// In en, this message translates to:
  /// **'Moment'**
  String get momentTitle;

  /// No description provided for @shareMomentTitle.
  ///
  /// In en, this message translates to:
  /// **'Share a moment'**
  String get shareMomentTitle;

  /// No description provided for @shareMomentPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Take or choose a photo'**
  String get shareMomentPhotoHint;

  /// No description provided for @shareMomentTextHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind? (a word or two)'**
  String get shareMomentTextHint;

  /// No description provided for @shareMomentTagCafe.
  ///
  /// In en, this message translates to:
  /// **'At the café'**
  String get shareMomentTagCafe;

  /// No description provided for @shareMomentTagWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get shareMomentTagWalking;

  /// No description provided for @shareMomentTagCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get shareMomentTagCooking;

  /// No description provided for @shareMomentSubmit.
  ///
  /// In en, this message translates to:
  /// **'Share with family'**
  String get shareMomentSubmit;

  /// No description provided for @shareMomentFallbackCaption.
  ///
  /// In en, this message translates to:
  /// **'A moment'**
  String get shareMomentFallbackCaption;

  /// No description provided for @familyChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Family chat'**
  String get familyChatTitle;

  /// No description provided for @familyChatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get familyChatInputHint;

  /// No description provided for @activitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activitiesTitle;

  /// No description provided for @activitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What can we do together?'**
  String get activitiesSubtitle;

  /// No description provided for @activitiesGroupGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Group games'**
  String get activitiesGroupGamesTitle;

  /// No description provided for @activitiesGroupGamesDesc.
  ///
  /// In en, this message translates to:
  /// **'Roulette, Sin Jim and more'**
  String get activitiesGroupGamesDesc;

  /// No description provided for @activitiesBookClubTitle.
  ///
  /// In en, this message translates to:
  /// **'Book club'**
  String get activitiesBookClubTitle;

  /// No description provided for @activitiesBookClubDesc.
  ///
  /// In en, this message translates to:
  /// **'A Thousand Splendid Suns'**
  String get activitiesBookClubDesc;

  /// No description provided for @activitiesPodcastClubTitle.
  ///
  /// In en, this message translates to:
  /// **'Podcast club'**
  String get activitiesPodcastClubTitle;

  /// No description provided for @activitiesPodcastDesc.
  ///
  /// In en, this message translates to:
  /// **'Episode 12 · 3 of 6 listened'**
  String get activitiesPodcastDesc;

  /// No description provided for @activitiesTalkTopicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Talk topics'**
  String get activitiesTalkTopicsTitle;

  /// No description provided for @activitiesTalkTopicsDesc.
  ///
  /// In en, this message translates to:
  /// **'Conversation starters'**
  String get activitiesTalkTopicsDesc;

  /// No description provided for @activitiesOutingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Outings'**
  String get activitiesOutingsTitle;

  /// No description provided for @activitiesOutingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Places that suit the whole family'**
  String get activitiesOutingsDesc;

  /// No description provided for @gamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get gamesTitle;

  /// No description provided for @gamesRouletteTitle.
  ///
  /// In en, this message translates to:
  /// **'Roulette'**
  String get gamesRouletteTitle;

  /// No description provided for @gamesRouletteDesc.
  ///
  /// In en, this message translates to:
  /// **'Who starts? Who takes the challenge?'**
  String get gamesRouletteDesc;

  /// No description provided for @gamesAzizTitle.
  ///
  /// In en, this message translates to:
  /// **'Talks with Aziz'**
  String get gamesAzizTitle;

  /// No description provided for @gamesAzizDesc.
  ///
  /// In en, this message translates to:
  /// **'Funny and surprising questions'**
  String get gamesAzizDesc;

  /// No description provided for @gamesSinJimTitle.
  ///
  /// In en, this message translates to:
  /// **'Sin Jim'**
  String get gamesSinJimTitle;

  /// No description provided for @gamesSinJimDesc.
  ///
  /// In en, this message translates to:
  /// **'Answer on behalf of someone'**
  String get gamesSinJimDesc;

  /// No description provided for @gamesThabbitTitle.
  ///
  /// In en, this message translates to:
  /// **'Thabbit'**
  String get gamesThabbitTitle;

  /// No description provided for @gamesThabbitDesc.
  ///
  /// In en, this message translates to:
  /// **'Hold the pose!'**
  String get gamesThabbitDesc;

  /// No description provided for @gamesShiddahTitle.
  ///
  /// In en, this message translates to:
  /// **'Shiddah'**
  String get gamesShiddahTitle;

  /// No description provided for @gamesShiddahDesc.
  ///
  /// In en, this message translates to:
  /// **'Fast-paced card game'**
  String get gamesShiddahDesc;

  /// No description provided for @gamesTimeRange5to10.
  ///
  /// In en, this message translates to:
  /// **'5–10 min'**
  String get gamesTimeRange5to10;

  /// No description provided for @gamesTimeRange10to15.
  ///
  /// In en, this message translates to:
  /// **'10–15 min'**
  String get gamesTimeRange10to15;

  /// No description provided for @gamesTime5min.
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get gamesTime5min;

  /// No description provided for @gamesTime10min.
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get gamesTime10min;

  /// No description provided for @gamesStartPlaying.
  ///
  /// In en, this message translates to:
  /// **'Start playing'**
  String get gamesStartPlaying;

  /// No description provided for @soonPageMessage.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get soonPageMessage;

  /// No description provided for @azizNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get azizNext;

  /// No description provided for @azizSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get azizSkip;

  /// No description provided for @sinJimAnswerOnBehalf.
  ///
  /// In en, this message translates to:
  /// **'Answer on behalf of'**
  String get sinJimAnswerOnBehalf;

  /// No description provided for @sinJimQPrefix.
  ///
  /// In en, this message translates to:
  /// **'Q:'**
  String get sinJimQPrefix;

  /// No description provided for @sinJimEveryoneAnswered.
  ///
  /// In en, this message translates to:
  /// **'Everyone answered'**
  String get sinJimEveryoneAnswered;

  /// No description provided for @sinJimAnswersRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No answers recorded} one{1 answer recorded} other{{count} answers recorded}}'**
  String sinJimAnswersRecorded(int count);

  /// No description provided for @rouletteModeWhoStarts.
  ///
  /// In en, this message translates to:
  /// **'Who starts?'**
  String get rouletteModeWhoStarts;

  /// No description provided for @rouletteModeChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get rouletteModeChallenge;

  /// No description provided for @rouletteModeDecision.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get rouletteModeDecision;

  /// No description provided for @rouletteChallengeJoke.
  ///
  /// In en, this message translates to:
  /// **'Tell a joke'**
  String get rouletteChallengeJoke;

  /// No description provided for @rouletteChallengeSing.
  ///
  /// In en, this message translates to:
  /// **'Sing a line'**
  String get rouletteChallengeSing;

  /// No description provided for @rouletteChallengeImitate.
  ///
  /// In en, this message translates to:
  /// **'Imitate someone'**
  String get rouletteChallengeImitate;

  /// No description provided for @rouletteChallengeDance.
  ///
  /// In en, this message translates to:
  /// **'Dance 10 sec'**
  String get rouletteChallengeDance;

  /// No description provided for @rouletteChallengeSecret.
  ///
  /// In en, this message translates to:
  /// **'Tell a secret'**
  String get rouletteChallengeSecret;

  /// No description provided for @rouletteChallengeDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw in 10 sec'**
  String get rouletteChallengeDraw;

  /// No description provided for @rouletteDecisionStayHome.
  ///
  /// In en, this message translates to:
  /// **'Stay home'**
  String get rouletteDecisionStayHome;

  /// No description provided for @rouletteDecisionGoOut.
  ///
  /// In en, this message translates to:
  /// **'Go out'**
  String get rouletteDecisionGoOut;

  /// No description provided for @rouletteDecisionCook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get rouletteDecisionCook;

  /// No description provided for @rouletteDecisionOrderFood.
  ///
  /// In en, this message translates to:
  /// **'Order food'**
  String get rouletteDecisionOrderFood;

  /// No description provided for @rouletteDecisionMovie.
  ///
  /// In en, this message translates to:
  /// **'Watch a movie'**
  String get rouletteDecisionMovie;

  /// No description provided for @rouletteDecisionGames.
  ///
  /// In en, this message translates to:
  /// **'Play games'**
  String get rouletteDecisionGames;

  /// No description provided for @rouletteResultStarts.
  ///
  /// In en, this message translates to:
  /// **'{name} starts!'**
  String rouletteResultStarts(String name);

  /// No description provided for @rouletteSpin.
  ///
  /// In en, this message translates to:
  /// **'Spin the wheel'**
  String get rouletteSpin;

  /// No description provided for @bookClubCurrentBook.
  ///
  /// In en, this message translates to:
  /// **'Current book'**
  String get bookClubCurrentBook;

  /// No description provided for @bookClubReadingStatus.
  ///
  /// In en, this message translates to:
  /// **'3 of 6 reading · discussion on Thursday'**
  String get bookClubReadingStatus;

  /// No description provided for @bookClubJoinDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Join the discussion'**
  String get bookClubJoinDiscussion;

  /// No description provided for @discussionQuestionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Discussion questions'**
  String get discussionQuestionsHeading;

  /// No description provided for @bookClubQ1.
  ///
  /// In en, this message translates to:
  /// **'Which character are you closest to?'**
  String get bookClubQ1;

  /// No description provided for @bookClubQ2.
  ///
  /// In en, this message translates to:
  /// **'If the ending changed, what would it be?'**
  String get bookClubQ2;

  /// No description provided for @podcastThisWeekEpisode.
  ///
  /// In en, this message translates to:
  /// **'This week\'s episode'**
  String get podcastThisWeekEpisode;

  /// No description provided for @podcastDuration.
  ///
  /// In en, this message translates to:
  /// **'32 min'**
  String get podcastDuration;

  /// No description provided for @podcastListenedLabel.
  ///
  /// In en, this message translates to:
  /// **'Listened'**
  String get podcastListenedLabel;

  /// No description provided for @podcastListenedFraction.
  ///
  /// In en, this message translates to:
  /// **'{count}/6'**
  String podcastListenedFraction(int count);

  /// No description provided for @podcastNextGathering.
  ///
  /// In en, this message translates to:
  /// **'Next gathering: Friday after dinner. We will all talk about it.'**
  String get podcastNextGathering;

  /// No description provided for @podcastQ1.
  ///
  /// In en, this message translates to:
  /// **'When did we last laugh until we cried?'**
  String get podcastQ1;

  /// No description provided for @podcastQ2.
  ///
  /// In en, this message translates to:
  /// **'Who in the family tells the best jokes?'**
  String get podcastQ2;

  /// No description provided for @talkTopicsGiveMeTopic.
  ///
  /// In en, this message translates to:
  /// **'Give me a topic'**
  String get talkTopicsGiveMeTopic;

  /// No description provided for @talkTopicsTrendingNow.
  ///
  /// In en, this message translates to:
  /// **'Trending now'**
  String get talkTopicsTrendingNow;

  /// No description provided for @talkTopicsTrend1.
  ///
  /// In en, this message translates to:
  /// **'Best Ramadan memory'**
  String get talkTopicsTrend1;

  /// No description provided for @talkTopicsTrend2.
  ///
  /// In en, this message translates to:
  /// **'Mom\'s favorite dish'**
  String get talkTopicsTrend2;

  /// No description provided for @outingsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get outingsFilterAll;

  /// No description provided for @outingsPlacesMap.
  ///
  /// In en, this message translates to:
  /// **'Places map'**
  String get outingsPlacesMap;

  /// No description provided for @outingsOurOutings.
  ///
  /// In en, this message translates to:
  /// **'Our outings'**
  String get outingsOurOutings;

  /// No description provided for @suggestPlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestion for the family'**
  String get suggestPlaceTitle;

  /// No description provided for @suggestPlaceWhyHeading.
  ///
  /// In en, this message translates to:
  /// **'Why we suggested it'**
  String get suggestPlaceWhyHeading;

  /// No description provided for @suggestPlaceAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to \"Our outings\"'**
  String get suggestPlaceAdd;

  /// No description provided for @suggestPlaceAddedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Added to Our outings'**
  String get suggestPlaceAddedSnackbar;

  /// No description provided for @ourOutingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.\nAdd a place from Outings.'**
  String get ourOutingsEmpty;

  /// No description provided for @onboardingSplashLogo.
  ///
  /// In en, this message translates to:
  /// **'Lamma'**
  String get onboardingSplashLogo;

  /// No description provided for @onboardingSplashTagline.
  ///
  /// In en, this message translates to:
  /// **'Let\'s gather'**
  String get onboardingSplashTagline;

  /// No description provided for @onboardingSplashStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingSplashStart;

  /// No description provided for @onboardingAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you'**
  String get onboardingAboutTitle;

  /// No description provided for @onboardingAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few quick questions'**
  String get onboardingAboutSubtitle;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingInterestsTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you like?'**
  String get onboardingInterestsTitle;

  /// No description provided for @onboardingInterestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick what suits your experience'**
  String get onboardingInterestsSubtitle;

  /// No description provided for @onboardingSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get onboardingSignupTitle;

  /// No description provided for @onboardingSignupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll text you a verification code'**
  String get onboardingSignupSubtitle;

  /// No description provided for @onboardingCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get onboardingCreateAccount;

  /// No description provided for @onboardingFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your family'**
  String get onboardingFamilyTitle;

  /// No description provided for @onboardingFamilySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a family space or join one'**
  String get onboardingFamilySubtitle;

  /// No description provided for @onboardingCharacterTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your character'**
  String get onboardingCharacterTitle;

  /// No description provided for @onboardingCharacterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change it any time in Account'**
  String get onboardingCharacterSubtitle;

  /// No description provided for @onboardingLetsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get onboardingLetsGo;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get onboardingNameHint;

  /// No description provided for @onboardingAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get onboardingAgeLabel;

  /// No description provided for @onboardingJobQuestion.
  ///
  /// In en, this message translates to:
  /// **'What do you do?'**
  String get onboardingJobQuestion;

  /// No description provided for @onboardingJobWork.
  ///
  /// In en, this message translates to:
  /// **'I work'**
  String get onboardingJobWork;

  /// No description provided for @onboardingJobStudent.
  ///
  /// In en, this message translates to:
  /// **'I\'m a student'**
  String get onboardingJobStudent;

  /// No description provided for @onboardingJobHome.
  ///
  /// In en, this message translates to:
  /// **'I stay at home'**
  String get onboardingJobHome;

  /// No description provided for @onboardingThingsYouLove.
  ///
  /// In en, this message translates to:
  /// **'Things you love'**
  String get onboardingThingsYouLove;

  /// No description provided for @onboardingTypeOfOutings.
  ///
  /// In en, this message translates to:
  /// **'Type of outings'**
  String get onboardingTypeOfOutings;

  /// No description provided for @onboardingIPrefer.
  ///
  /// In en, this message translates to:
  /// **'I prefer...'**
  String get onboardingIPrefer;

  /// No description provided for @onboardingPreferGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get onboardingPreferGames;

  /// No description provided for @onboardingPreferDiscussions.
  ///
  /// In en, this message translates to:
  /// **'Discussions'**
  String get onboardingPreferDiscussions;

  /// No description provided for @onboardingPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'05 ••• ••• ••'**
  String get onboardingPhoneHint;

  /// No description provided for @onboardingSigninInstead.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get onboardingSigninInstead;

  /// No description provided for @onboardingStartFamily.
  ///
  /// In en, this message translates to:
  /// **'Start a family'**
  String get onboardingStartFamily;

  /// No description provided for @onboardingFamilyNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Al-Otaibi family'**
  String get onboardingFamilyNameHint;

  /// No description provided for @onboardingCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get onboardingCreate;

  /// No description provided for @onboardingHaveInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Have an invite code?'**
  String get onboardingHaveInviteCode;

  /// No description provided for @onboardingInviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'LAMMA-48'**
  String get onboardingInviteCodeHint;

  /// No description provided for @onboardingJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get onboardingJoin;

  /// No description provided for @dataCharacterSister.
  ///
  /// In en, this message translates to:
  /// **'Sister'**
  String get dataCharacterSister;

  /// No description provided for @dataCharacterBigBrother.
  ///
  /// In en, this message translates to:
  /// **'Big brother'**
  String get dataCharacterBigBrother;

  /// No description provided for @dataCharacterFather.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get dataCharacterFather;

  /// No description provided for @dataCharacterMother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get dataCharacterMother;

  /// No description provided for @dataCharacterLittleGirl.
  ///
  /// In en, this message translates to:
  /// **'Little girl'**
  String get dataCharacterLittleGirl;

  /// No description provided for @dataCharacterSon.
  ///
  /// In en, this message translates to:
  /// **'Son'**
  String get dataCharacterSon;

  /// No description provided for @dataMemberNoura.
  ///
  /// In en, this message translates to:
  /// **'Noura'**
  String get dataMemberNoura;

  /// No description provided for @dataMemberMohammed.
  ///
  /// In en, this message translates to:
  /// **'Mohammed'**
  String get dataMemberMohammed;

  /// No description provided for @dataMemberAbdullah.
  ///
  /// In en, this message translates to:
  /// **'Abdullah'**
  String get dataMemberAbdullah;

  /// No description provided for @dataMemberAmina.
  ///
  /// In en, this message translates to:
  /// **'Amina'**
  String get dataMemberAmina;

  /// No description provided for @dataMemberSarah.
  ///
  /// In en, this message translates to:
  /// **'Sarah'**
  String get dataMemberSarah;

  /// No description provided for @dataMemberYousef.
  ///
  /// In en, this message translates to:
  /// **'Yousef'**
  String get dataMemberYousef;

  /// No description provided for @dataEventTypeGathering.
  ///
  /// In en, this message translates to:
  /// **'Gathering'**
  String get dataEventTypeGathering;

  /// No description provided for @dataEventTypeOuting.
  ///
  /// In en, this message translates to:
  /// **'Outing'**
  String get dataEventTypeOuting;

  /// No description provided for @dataEventTypeDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dataEventTypeDinner;

  /// No description provided for @dataEventTypeGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get dataEventTypeGames;

  /// No description provided for @dataEventTypeTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get dataEventTypeTrip;

  /// No description provided for @dataEventTypeMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get dataEventTypeMovie;

  /// No description provided for @dataEventTypeOccasion.
  ///
  /// In en, this message translates to:
  /// **'Occasion'**
  String get dataEventTypeOccasion;

  /// No description provided for @dataDaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get dataDaySat;

  /// No description provided for @dataDaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get dataDaySun;

  /// No description provided for @dataDayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dataDayMon;

  /// No description provided for @dataEventTitleVillageOuting.
  ///
  /// In en, this message translates to:
  /// **'Village outing'**
  String get dataEventTitleVillageOuting;

  /// No description provided for @dataEventTitleFamilyDinner.
  ///
  /// In en, this message translates to:
  /// **'Family dinner'**
  String get dataEventTitleFamilyDinner;

  /// No description provided for @dataEventTime4pm.
  ///
  /// In en, this message translates to:
  /// **'4:00 PM'**
  String get dataEventTime4pm;

  /// No description provided for @dataEventTime8pm.
  ///
  /// In en, this message translates to:
  /// **'8:00 PM'**
  String get dataEventTime8pm;

  /// No description provided for @dataPlaceKingSalmanPark.
  ///
  /// In en, this message translates to:
  /// **'King Salman Park'**
  String get dataPlaceKingSalmanPark;

  /// No description provided for @dataPlaceCafeAlDar.
  ///
  /// In en, this message translates to:
  /// **'Café Al-Dar'**
  String get dataPlaceCafeAlDar;

  /// No description provided for @dataPlaceStrikeBowling.
  ///
  /// In en, this message translates to:
  /// **'Strike Bowling'**
  String get dataPlaceStrikeBowling;

  /// No description provided for @dataPlaceSufratAlBayt.
  ///
  /// In en, this message translates to:
  /// **'Sufrat Al-Bayt'**
  String get dataPlaceSufratAlBayt;

  /// No description provided for @dataPlaceWhyPark.
  ///
  /// In en, this message translates to:
  /// **'4 of 6 family members like this type of place'**
  String get dataPlaceWhyPark;

  /// No description provided for @dataPlaceWhyCafe.
  ///
  /// In en, this message translates to:
  /// **'Suits everyone, a good choice'**
  String get dataPlaceWhyCafe;

  /// No description provided for @dataPlaceWhyBowling.
  ///
  /// In en, this message translates to:
  /// **'3 of 6 love games and group activities'**
  String get dataPlaceWhyBowling;

  /// No description provided for @dataPlaceWhyRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Homestyle food and family seating'**
  String get dataPlaceWhyRestaurant;

  /// No description provided for @dataOutingTypeNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get dataOutingTypeNature;

  /// No description provided for @dataOutingTypeRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get dataOutingTypeRestaurants;

  /// No description provided for @dataOutingTypeCafes.
  ///
  /// In en, this message translates to:
  /// **'Cafés'**
  String get dataOutingTypeCafes;

  /// No description provided for @dataOutingTypeEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get dataOutingTypeEntertainment;

  /// No description provided for @dataBadgeMostInteractive.
  ///
  /// In en, this message translates to:
  /// **'Most interactive'**
  String get dataBadgeMostInteractive;

  /// No description provided for @dataBadgeLammaSpirit.
  ///
  /// In en, this message translates to:
  /// **'Lamma spirit'**
  String get dataBadgeLammaSpirit;

  /// No description provided for @dataBadgeWeeklyListener.
  ///
  /// In en, this message translates to:
  /// **'Weekly listener'**
  String get dataBadgeWeeklyListener;

  /// No description provided for @dataBadgeWeekWinner.
  ///
  /// In en, this message translates to:
  /// **'Week winner'**
  String get dataBadgeWeekWinner;

  /// No description provided for @dataBadgeTalksKing.
  ///
  /// In en, this message translates to:
  /// **'Talks king'**
  String get dataBadgeTalksKing;

  /// No description provided for @dataBadgeReader.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get dataBadgeReader;

  /// No description provided for @dataAziz1.
  ///
  /// In en, this message translates to:
  /// **'What\'s the strangest food you\'ve ever tried?'**
  String get dataAziz1;

  /// No description provided for @dataAziz2.
  ///
  /// In en, this message translates to:
  /// **'Which trip would you repeat tomorrow?'**
  String get dataAziz2;

  /// No description provided for @dataAziz3.
  ///
  /// In en, this message translates to:
  /// **'What\'s a small thing that makes your day?'**
  String get dataAziz3;

  /// No description provided for @dataAziz4.
  ///
  /// In en, this message translates to:
  /// **'Who in the family makes you laugh the most?'**
  String get dataAziz4;

  /// No description provided for @dataSinJim1.
  ///
  /// In en, this message translates to:
  /// **'How old is your grandfather?'**
  String get dataSinJim1;

  /// No description provided for @dataSinJim2.
  ///
  /// In en, this message translates to:
  /// **'What\'s Dad\'s favorite dish?'**
  String get dataSinJim2;

  /// No description provided for @dataSinJim3.
  ///
  /// In en, this message translates to:
  /// **'What\'s Mom\'s favorite color?'**
  String get dataSinJim3;

  /// No description provided for @dataSinJim4.
  ///
  /// In en, this message translates to:
  /// **'Who is the biggest sleeper in the family?'**
  String get dataSinJim4;

  /// No description provided for @dataTopic1.
  ///
  /// In en, this message translates to:
  /// **'If you could travel anywhere now, where would we go?'**
  String get dataTopic1;

  /// No description provided for @dataTopic2.
  ///
  /// In en, this message translates to:
  /// **'What\'s the family moment you\'d never forget?'**
  String get dataTopic2;

  /// No description provided for @dataTopic3.
  ///
  /// In en, this message translates to:
  /// **'What tradition should we start this year?'**
  String get dataTopic3;

  /// No description provided for @dataTopic4.
  ///
  /// In en, this message translates to:
  /// **'What\'s one thing you\'ve never told us?'**
  String get dataTopic4;

  /// No description provided for @dataMomentCaptionSarah.
  ///
  /// In en, this message translates to:
  /// **'Went out today with the girls'**
  String get dataMomentCaptionSarah;

  /// No description provided for @dataMomentCaptionMohammed.
  ///
  /// In en, this message translates to:
  /// **'Study break at the café'**
  String get dataMomentCaptionMohammed;

  /// No description provided for @dataMomentCaptionAmina.
  ///
  /// In en, this message translates to:
  /// **'Fresh coffee, quiet morning'**
  String get dataMomentCaptionAmina;

  /// No description provided for @dataMomentCaptionAbdullah.
  ///
  /// In en, this message translates to:
  /// **'Evening in the majlis'**
  String get dataMomentCaptionAbdullah;

  /// No description provided for @dataMomentCaptionYousef.
  ///
  /// In en, this message translates to:
  /// **'My new Lego!'**
  String get dataMomentCaptionYousef;

  /// No description provided for @dataMomentCaptionNoura.
  ///
  /// In en, this message translates to:
  /// **'Baking with Mom'**
  String get dataMomentCaptionNoura;

  /// No description provided for @dataTimeTodayAt410pm.
  ///
  /// In en, this message translates to:
  /// **'Today, 4:10 PM'**
  String get dataTimeTodayAt410pm;

  /// No description provided for @dataTimeTodayAt130pm.
  ///
  /// In en, this message translates to:
  /// **'Today, 1:30 PM'**
  String get dataTimeTodayAt130pm;

  /// No description provided for @dataTimeTodayAt815am.
  ///
  /// In en, this message translates to:
  /// **'Today, 8:15 AM'**
  String get dataTimeTodayAt815am;

  /// No description provided for @dataTimeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dataTimeYesterday;

  /// No description provided for @dataTimeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dataTimeToday;

  /// No description provided for @dataTime2DaysAgo.
  ///
  /// In en, this message translates to:
  /// **'2 days ago'**
  String get dataTime2DaysAgo;

  /// No description provided for @dataTalkSarah.
  ///
  /// In en, this message translates to:
  /// **'What do you want to eat on Thursday?'**
  String get dataTalkSarah;

  /// No description provided for @dataTalkAmina.
  ///
  /// In en, this message translates to:
  /// **'Who wants to come with me to the market?'**
  String get dataTalkAmina;

  /// No description provided for @dataCommentAbdullah.
  ///
  /// In en, this message translates to:
  /// **'Nice!'**
  String get dataCommentAbdullah;

  /// No description provided for @dataCommentAmina.
  ///
  /// In en, this message translates to:
  /// **'God protect you all'**
  String get dataCommentAmina;

  /// No description provided for @dataCommentMohammed.
  ///
  /// In en, this message translates to:
  /// **'Take me with you'**
  String get dataCommentMohammed;

  /// No description provided for @dataInterestCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get dataInterestCoffee;

  /// No description provided for @dataInterestGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get dataInterestGames;

  /// No description provided for @dataInterestReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get dataInterestReading;

  /// No description provided for @dataInterestWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get dataInterestWalking;

  /// No description provided for @dataInterestPodcasts.
  ///
  /// In en, this message translates to:
  /// **'Podcasts'**
  String get dataInterestPodcasts;

  /// No description provided for @dataInterestMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get dataInterestMovies;

  /// No description provided for @dataInterestCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get dataInterestCooking;

  /// No description provided for @dataInterestDrawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get dataInterestDrawing;

  /// No description provided for @dataInterestFootball.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get dataInterestFootball;

  /// No description provided for @dataInterestSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get dataInterestSwimming;

  /// No description provided for @dataInterestMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get dataInterestMusic;

  /// No description provided for @dataInterestTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get dataInterestTravel;

  /// No description provided for @dataFamilyFallback.
  ///
  /// In en, this message translates to:
  /// **'Your family'**
  String get dataFamilyFallback;

  /// No description provided for @dataFamilyDefault.
  ///
  /// In en, this message translates to:
  /// **'Al-Otaibi family'**
  String get dataFamilyDefault;

  /// No description provided for @chatSeedSarahCooking.
  ///
  /// In en, this message translates to:
  /// **'What are we cooking tonight?'**
  String get chatSeedSarahCooking;

  /// No description provided for @chatSeedMeGoPark.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go to the park!'**
  String get chatSeedMeGoPark;

  /// No description provided for @chatSeedAminaDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner will be ready soon'**
  String get chatSeedAminaDinner;

  /// No description provided for @chatSeedMeComing.
  ///
  /// In en, this message translates to:
  /// **'Coming!'**
  String get chatSeedMeComing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
