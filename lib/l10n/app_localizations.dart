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
  /// **'Activity Box'**
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

  /// No description provided for @homeFeedPhoto.
  ///
  /// In en, this message translates to:
  /// **'{name} shared a photo'**
  String homeFeedPhoto(String name);

  /// No description provided for @homeFeedChallenge.
  ///
  /// In en, this message translates to:
  /// **'{name} finished today\'s challenge'**
  String homeFeedChallenge(String name);

  /// No description provided for @homeFeedPodcast.
  ///
  /// In en, this message translates to:
  /// **'{name} listened to the weekly podcast'**
  String homeFeedPodcast(String name);

  /// No description provided for @homePhoneFreeBanner.
  ///
  /// In en, this message translates to:
  /// **'Phone-free time · {from} – {to}'**
  String homePhoneFreeBanner(String from, String to);

  /// No description provided for @homePunishmentBanner.
  ///
  /// In en, this message translates to:
  /// **'Your punishment: {detail}'**
  String homePunishmentBanner(String detail);

  /// No description provided for @homeLeaderboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeLeaderboardSeeAll;

  /// No description provided for @notifMomentShared.
  ///
  /// In en, this message translates to:
  /// **'{name} shared a moment'**
  String notifMomentShared(String name);

  /// No description provided for @addEventDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get addEventDateLabel;

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

  /// No description provided for @accountParentSection.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get accountParentSection;

  /// No description provided for @accountParentControlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent controls'**
  String get accountParentControlsTitle;

  /// No description provided for @accountParentControlsDesc.
  ///
  /// In en, this message translates to:
  /// **'Phone-free time, consequences, rewards'**
  String get accountParentControlsDesc;

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
  /// **'What should we do together today?'**
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

  /// No description provided for @activitiesNewTopic.
  ///
  /// In en, this message translates to:
  /// **'New topic'**
  String get activitiesNewTopic;

  /// No description provided for @activitiesClubsSection.
  ///
  /// In en, this message translates to:
  /// **'Clubs'**
  String get activitiesClubsSection;

  /// No description provided for @clubsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reading and listening together, then talking about it'**
  String get clubsSubtitle;

  /// No description provided for @clubsDiscussionSession.
  ///
  /// In en, this message translates to:
  /// **'Discussion session'**
  String get clubsDiscussionSession;

  /// No description provided for @clubsRemindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get clubsRemindMe;

  /// No description provided for @clubsRemindMeOn.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you'**
  String get clubsRemindMeOn;

  /// No description provided for @clubsBookOfMonthBadge.
  ///
  /// In en, this message translates to:
  /// **'Book of the month'**
  String get clubsBookOfMonthBadge;

  /// No description provided for @clubsAboutHeading.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get clubsAboutHeading;

  /// No description provided for @clubsReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get clubsReadMore;

  /// No description provided for @clubsReadLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get clubsReadLess;

  /// No description provided for @clubsFinishedCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} finished'**
  String clubsFinishedCount(int done, int total);

  /// No description provided for @clubsCatchUpBold.
  ///
  /// In en, this message translates to:
  /// **'Catch up!'**
  String get clubsCatchUpBold;

  /// No description provided for @clubsLogProgress.
  ///
  /// In en, this message translates to:
  /// **'Log your progress'**
  String get clubsLogProgress;

  /// No description provided for @clubsLogProgressSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'How far are you in {title}?'**
  String clubsLogProgressSheetTitle(String title);

  /// No description provided for @clubsPageOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String clubsPageOfTotal(int page, int total);

  /// No description provided for @clubsMarkAsFinished.
  ///
  /// In en, this message translates to:
  /// **'Mark as finished'**
  String get clubsMarkAsFinished;

  /// No description provided for @clubsSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get clubsSaveButton;

  /// No description provided for @clubsMyDoneWaitingRest.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the discussion'**
  String get clubsMyDoneWaitingRest;

  /// No description provided for @clubsDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get clubsDoneLabel;

  /// No description provided for @clubsPagesLeft.
  ///
  /// In en, this message translates to:
  /// **'{pages, plural, one{1 page left for you} other{{pages} pages left for you}}'**
  String clubsPagesLeft(int pages);

  /// No description provided for @clubsFamilyProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'How far has the family gotten?'**
  String get clubsFamilyProgressTitle;

  /// No description provided for @clubsThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get clubsThursday;

  /// No description provided for @clubsBookDiscussionTime.
  ///
  /// In en, this message translates to:
  /// **'After dinner · 9:00 PM'**
  String get clubsBookDiscussionTime;

  /// No description provided for @clubsNextMonthSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Next month\'s suggestions'**
  String get clubsNextMonthSuggestions;

  /// No description provided for @clubsNotVotedYet.
  ///
  /// In en, this message translates to:
  /// **'Haven\'t voted yet'**
  String get clubsNotVotedYet;

  /// No description provided for @clubsVotedForCount.
  ///
  /// In en, this message translates to:
  /// **'Voted for {count}'**
  String clubsVotedForCount(int count);

  /// No description provided for @clubsVoteForMoreHint.
  ///
  /// In en, this message translates to:
  /// **'Vote for more than one book — the most-voted becomes the book of the month'**
  String get clubsVoteForMoreHint;

  /// No description provided for @clubsSuggestBook.
  ///
  /// In en, this message translates to:
  /// **'Suggest a book'**
  String get clubsSuggestBook;

  /// No description provided for @clubsSuggestBookHint.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t find what you had in mind?'**
  String get clubsSuggestBookHint;

  /// No description provided for @clubsReadBeforeTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ve read before'**
  String get clubsReadBeforeTitle;

  /// No description provided for @clubsScoreOutOf.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total}'**
  String clubsScoreOutOf(int completed, int total);

  /// No description provided for @clubsSuggestPodcastHeading.
  ///
  /// In en, this message translates to:
  /// **'Suggest a podcast'**
  String get clubsSuggestPodcastHeading;

  /// No description provided for @clubsSuggestFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It\'ll reach the family and join the suggestions'**
  String get clubsSuggestFormSubtitle;

  /// No description provided for @clubsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get clubsClose;

  /// No description provided for @clubsBookNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Book name'**
  String get clubsBookNameLabel;

  /// No description provided for @clubsBookNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. I Missed a Prayer'**
  String get clubsBookNameHint;

  /// No description provided for @clubsBookAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author (optional)'**
  String get clubsBookAuthorLabel;

  /// No description provided for @clubsBookAuthorHint.
  ///
  /// In en, this message translates to:
  /// **'Author\'s name'**
  String get clubsBookAuthorHint;

  /// No description provided for @clubsPodcastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Podcast or episode name'**
  String get clubsPodcastNameLabel;

  /// No description provided for @clubsPodcastNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. How relationships succeed'**
  String get clubsPodcastNameHint;

  /// No description provided for @clubsPodcastHostLabel.
  ///
  /// In en, this message translates to:
  /// **'Host or channel (optional)'**
  String get clubsPodcastHostLabel;

  /// No description provided for @clubsPodcastHostHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Yasser Al-Huzaimi'**
  String get clubsPodcastHostHint;

  /// No description provided for @clubsCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get clubsCategoryLabel;

  /// No description provided for @clubsAboutShort.
  ///
  /// In en, this message translates to:
  /// **'Short blurb'**
  String get clubsAboutShort;

  /// No description provided for @clubsBookAboutHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s the book about? Why does it suit the family?'**
  String get clubsBookAboutHint;

  /// No description provided for @clubsPodcastAboutHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s the episode about? Why\'s it worth hearing together?'**
  String get clubsPodcastAboutHint;

  /// No description provided for @clubsAddToSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Add to suggestions'**
  String get clubsAddToSuggestions;

  /// No description provided for @clubsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get clubsCancel;

  /// No description provided for @clubsSuggestionAdded.
  ///
  /// In en, this message translates to:
  /// **'Your suggestion was added'**
  String get clubsSuggestionAdded;

  /// No description provided for @clubsYourSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Your suggestion'**
  String get clubsYourSuggestion;

  /// No description provided for @clubsCatNovel.
  ///
  /// In en, this message translates to:
  /// **'Novel'**
  String get clubsCatNovel;

  /// No description provided for @clubsCatBiographyHistory.
  ///
  /// In en, this message translates to:
  /// **'Biography and history'**
  String get clubsCatBiographyHistory;

  /// No description provided for @clubsCatLiteratureEssays.
  ///
  /// In en, this message translates to:
  /// **'Literature and essays'**
  String get clubsCatLiteratureEssays;

  /// No description provided for @clubsCatSelfDev.
  ///
  /// In en, this message translates to:
  /// **'Self-development'**
  String get clubsCatSelfDev;

  /// No description provided for @clubsCatFaith.
  ///
  /// In en, this message translates to:
  /// **'Faith'**
  String get clubsCatFaith;

  /// No description provided for @clubsCatManners.
  ///
  /// In en, this message translates to:
  /// **'Manners and conduct'**
  String get clubsCatManners;

  /// No description provided for @clubsCatRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get clubsCatRelationships;

  /// No description provided for @clubsCatCulture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get clubsCatCulture;

  /// No description provided for @clubsCatStories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get clubsCatStories;

  /// No description provided for @clubsCatReligion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get clubsCatReligion;

  /// No description provided for @clubsCatParenting.
  ///
  /// In en, this message translates to:
  /// **'Parenting'**
  String get clubsCatParenting;

  /// No description provided for @clubsCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get clubsCatOther;

  /// No description provided for @clubsCustomCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Type your category'**
  String get clubsCustomCategoryHint;

  /// No description provided for @clubsEpisodeOfWeekBadge.
  ///
  /// In en, this message translates to:
  /// **'Episode of the week'**
  String get clubsEpisodeOfWeekBadge;

  /// No description provided for @clubsAboutEpisodeHeading.
  ///
  /// In en, this message translates to:
  /// **'About the episode'**
  String get clubsAboutEpisodeHeading;

  /// No description provided for @clubsApplePodcasts.
  ///
  /// In en, this message translates to:
  /// **'Apple Podcasts'**
  String get clubsApplePodcasts;

  /// No description provided for @clubsYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get clubsYoutube;

  /// No description provided for @clubsWhoHeardTitle.
  ///
  /// In en, this message translates to:
  /// **'Who\'s heard it?'**
  String get clubsWhoHeardTitle;

  /// No description provided for @clubsHeardButton.
  ///
  /// In en, this message translates to:
  /// **'I heard it'**
  String get clubsHeardButton;

  /// No description provided for @clubsHeardButtonOn.
  ///
  /// In en, this message translates to:
  /// **'I heard it ✓'**
  String get clubsHeardButtonOn;

  /// No description provided for @clubsHalfFamilyFinished.
  ///
  /// In en, this message translates to:
  /// **'Half the family finished it'**
  String get clubsHalfFamilyFinished;

  /// No description provided for @clubsWhatToDiscussTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we discuss?'**
  String get clubsWhatToDiscussTitle;

  /// No description provided for @clubsWhoHeardAvatarsLabel.
  ///
  /// In en, this message translates to:
  /// **'Who\'s heard it'**
  String get clubsWhoHeardAvatarsLabel;

  /// No description provided for @clubsPodcastDiscussionTime.
  ///
  /// In en, this message translates to:
  /// **'Over coffee · 5:00 PM'**
  String get clubsPodcastDiscussionTime;

  /// No description provided for @clubsNextWeekSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Next week\'s suggestions'**
  String get clubsNextWeekSuggestions;

  /// No description provided for @clubsVoteForMorePodcastHint.
  ///
  /// In en, this message translates to:
  /// **'Vote for more than one podcast'**
  String get clubsVoteForMorePodcastHint;

  /// No description provided for @clubsAddDiscussionPoint.
  ///
  /// In en, this message translates to:
  /// **'Add a discussion point'**
  String get clubsAddDiscussionPoint;

  /// No description provided for @clubsAddQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Type your question here'**
  String get clubsAddQuestionHint;

  /// No description provided for @activitiesBookClubCount.
  ///
  /// In en, this message translates to:
  /// **'3 of 6 reading'**
  String get activitiesBookClubCount;

  /// No description provided for @activitiesPodcastClubDetail.
  ///
  /// In en, this message translates to:
  /// **'Episode 12 · What makes us laugh together?'**
  String get activitiesPodcastClubDetail;

  /// No description provided for @activitiesGroupGamesDescFull.
  ///
  /// In en, this message translates to:
  /// **'Roulette, Talks with Aziz and Sin Jim'**
  String get activitiesGroupGamesDescFull;

  /// No description provided for @activitiesSpinRoulette.
  ///
  /// In en, this message translates to:
  /// **'Spin the roulette'**
  String get activitiesSpinRoulette;

  /// No description provided for @activitiesTonightTopicBadge.
  ///
  /// In en, this message translates to:
  /// **'Tonight\'s topic'**
  String get activitiesTonightTopicBadge;

  /// No description provided for @activitiesTopicCounter.
  ///
  /// In en, this message translates to:
  /// **'Topic {index} of {total}'**
  String activitiesTopicCounter(int index, int total);

  /// No description provided for @activitiesChatNow.
  ///
  /// In en, this message translates to:
  /// **'Let\'s chat'**
  String get activitiesChatNow;

  /// No description provided for @activitiesChangeTopic.
  ///
  /// In en, this message translates to:
  /// **'Change it'**
  String get activitiesChangeTopic;

  /// No description provided for @activitiesPrevTopic.
  ///
  /// In en, this message translates to:
  /// **'Previous topic'**
  String get activitiesPrevTopic;

  /// No description provided for @activitiesRouletteBadge.
  ///
  /// In en, this message translates to:
  /// **'Whose turn tonight?'**
  String get activitiesRouletteBadge;

  /// No description provided for @activitiesRouletteCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Who starts, a challenge, or a family decision'**
  String get activitiesRouletteCardDesc;

  /// No description provided for @activitiesSinJimCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Questions about each other — who knows best?'**
  String get activitiesSinJimCardDesc;

  /// No description provided for @activitiesLettersAzizTitle.
  ///
  /// In en, this message translates to:
  /// **'Letters with Aziz'**
  String get activitiesLettersAzizTitle;

  /// No description provided for @activitiesLettersAzizDesc.
  ///
  /// In en, this message translates to:
  /// **'Two teams compete, each answer starts with a letter'**
  String get activitiesLettersAzizDesc;

  /// No description provided for @activitiesBookClubDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{1 day left} other{{days} days left}}'**
  String activitiesBookClubDaysLeft(int days);

  /// No description provided for @activitiesClubCatchUpBold.
  ///
  /// In en, this message translates to:
  /// **'Catch up!'**
  String get activitiesClubCatchUpBold;

  /// No description provided for @activitiesClubFinishedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No one finished yet} one{1 finished before you} other{{count} finished before you}}'**
  String activitiesClubFinishedCount(int count);

  /// No description provided for @activitiesPodcastEpisodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Podcast club · Episode {episode}'**
  String activitiesPodcastEpisodeLabel(int episode);

  /// No description provided for @activitiesPodcastCardQuestion.
  ///
  /// In en, this message translates to:
  /// **'What makes us laugh together?'**
  String get activitiesPodcastCardQuestion;

  /// No description provided for @activitiesPodcastYourTurnBold.
  ///
  /// In en, this message translates to:
  /// **'Your turn to listen!'**
  String get activitiesPodcastYourTurnBold;

  /// No description provided for @activitiesPodcastHalfDone.
  ///
  /// In en, this message translates to:
  /// **'Half the family finished it — discussion on Thursday'**
  String get activitiesPodcastHalfDone;

  /// No description provided for @clubsPodcastClubLabel.
  ///
  /// In en, this message translates to:
  /// **'Podcast club · {host}'**
  String clubsPodcastClubLabel(String host);

  /// No description provided for @clubsBookDoneWaitingBold.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get clubsBookDoneWaitingBold;

  /// No description provided for @clubsBookDoneWaitingRest.
  ///
  /// In en, this message translates to:
  /// **'{remaining, plural, one{1 left to finish the club} other{{remaining} left to finish the club}}'**
  String clubsBookDoneWaitingRest(int remaining);

  /// No description provided for @clubsBookAllDoneBold.
  ///
  /// In en, this message translates to:
  /// **'Everyone\'s done!'**
  String get clubsBookAllDoneBold;

  /// No description provided for @clubsBookAllDoneRest.
  ///
  /// In en, this message translates to:
  /// **'See you {day}'**
  String clubsBookAllDoneRest(String day);

  /// No description provided for @clubsPodcastYourTurnRest.
  ///
  /// In en, this message translates to:
  /// **'{heard} of {total} listened, discussion {day}'**
  String clubsPodcastYourTurnRest(int heard, int total, String day);

  /// No description provided for @clubsPodcastHeardBold.
  ///
  /// In en, this message translates to:
  /// **'Listened ✓'**
  String get clubsPodcastHeardBold;

  /// No description provided for @clubsPodcastHeardRest.
  ///
  /// In en, this message translates to:
  /// **'See you {day} {time}'**
  String clubsPodcastHeardRest(String day, String time);

  /// No description provided for @activitiesPlayPodcastTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get activitiesPlayPodcastTooltip;

  /// No description provided for @activitiesWeekendOutingTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekend outing'**
  String get activitiesWeekendOutingTitle;

  /// No description provided for @activitiesPrevPlace.
  ///
  /// In en, this message translates to:
  /// **'Previous place'**
  String get activitiesPrevPlace;

  /// No description provided for @activitiesNextPlace.
  ///
  /// In en, this message translates to:
  /// **'Next place'**
  String get activitiesNextPlace;

  /// No description provided for @activitiesPlaceCounter.
  ///
  /// In en, this message translates to:
  /// **'{index} of {total}'**
  String activitiesPlaceCounter(int index, int total);

  /// No description provided for @activitiesWeekendVoteText.
  ///
  /// In en, this message translates to:
  /// **'{votes, plural, one{1 of 6 wants to go Friday} other{{votes} of 6 want to go Friday}}'**
  String activitiesWeekendVoteText(int votes);

  /// No description provided for @activitiesWeekendVoteButton.
  ///
  /// In en, this message translates to:
  /// **'I\'m in'**
  String get activitiesWeekendVoteButton;

  /// No description provided for @activitiesWeekendVotedButton.
  ///
  /// In en, this message translates to:
  /// **'You\'re in'**
  String get activitiesWeekendVotedButton;

  /// No description provided for @activitiesWhoVotedLabel.
  ///
  /// In en, this message translates to:
  /// **'Who voted'**
  String get activitiesWhoVotedLabel;

  /// No description provided for @gamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get gamesTitle;

  /// No description provided for @gamesPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick tonight\'s game'**
  String get gamesPageSubtitle;

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

  /// No description provided for @gamesTonightBadge.
  ///
  /// In en, this message translates to:
  /// **'Tonight\'s game'**
  String get gamesTonightBadge;

  /// No description provided for @gamesRouletteHeroDesc.
  ///
  /// In en, this message translates to:
  /// **'Who starts, a challenge, or a decision.. the wheel decides'**
  String get gamesRouletteHeroDesc;

  /// No description provided for @gamesSpinItButton.
  ///
  /// In en, this message translates to:
  /// **'Spin it'**
  String get gamesSpinItButton;

  /// No description provided for @gamesAzizTitle.
  ///
  /// In en, this message translates to:
  /// **'Letters with Aziz'**
  String get gamesAzizTitle;

  /// No description provided for @gamesAzizDesc.
  ///
  /// In en, this message translates to:
  /// **'Two teams, each answer starts with a letter'**
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

  /// No description provided for @gamesCharadesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Talking'**
  String get gamesCharadesTitle;

  /// No description provided for @gamesCharadesDesc.
  ///
  /// In en, this message translates to:
  /// **'Act out the word without speaking'**
  String get gamesCharadesDesc;

  /// No description provided for @gamesPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Who\'s in the Photo?'**
  String get gamesPhotoTitle;

  /// No description provided for @gamesPhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Family childhood photos, guess who'**
  String get gamesPhotoDesc;

  /// No description provided for @gamesWhoAmITitle.
  ///
  /// In en, this message translates to:
  /// **'Who Am I?'**
  String get gamesWhoAmITitle;

  /// No description provided for @gamesWhoAmIDesc.
  ///
  /// In en, this message translates to:
  /// **'Phone on your forehead, everyone hints'**
  String get gamesWhoAmIDesc;

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

  /// No description provided for @gamesAllGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'All games'**
  String get gamesAllGamesTitle;

  /// No description provided for @gamesCountText.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 game} other{{count} games}}'**
  String gamesCountText(int count);

  /// No description provided for @gamesFilterGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Game type'**
  String get gamesFilterGroupLabel;

  /// No description provided for @gamesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get gamesFilterAll;

  /// No description provided for @gamesFilterMove.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get gamesFilterMove;

  /// No description provided for @gamesFilterChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get gamesFilterChallenge;

  /// No description provided for @gamesFilterFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get gamesFilterFamily;

  /// No description provided for @gamesSoonBadge.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get gamesSoonBadge;

  /// No description provided for @gamesSoonSnack.
  ///
  /// In en, this message translates to:
  /// **'Coming soon! We\'re getting it ready'**
  String get gamesSoonSnack;

  /// No description provided for @gamesTileSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'{title}, {time}'**
  String gamesTileSemanticsLabel(String title, String time);

  /// No description provided for @confirmEndYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, end it'**
  String get confirmEndYes;

  /// No description provided for @confirmEndKeepPlaying.
  ///
  /// In en, this message translates to:
  /// **'Keep playing'**
  String get confirmEndKeepPlaying;

  /// No description provided for @confirmEndTimerPaused.
  ///
  /// In en, this message translates to:
  /// **'Timer paused until you decide'**
  String get confirmEndTimerPaused;

  /// No description provided for @whoAmIBadge.
  ///
  /// In en, this message translates to:
  /// **'One player + everyone hints'**
  String get whoAmIBadge;

  /// No description provided for @whoAmIHeroDesc.
  ///
  /// In en, this message translates to:
  /// **'Phone on your forehead, everyone hints'**
  String get whoAmIHeroDesc;

  /// No description provided for @whoAmIHow1.
  ///
  /// In en, this message translates to:
  /// **'Phone on your forehead'**
  String get whoAmIHow1;

  /// No description provided for @whoAmIHow2.
  ///
  /// In en, this message translates to:
  /// **'Hints without the word'**
  String get whoAmIHow2;

  /// No description provided for @whoAmIHow3.
  ///
  /// In en, this message translates to:
  /// **'Guess before time\'s up'**
  String get whoAmIHow3;

  /// No description provided for @whoAmIChooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get whoAmIChooseCategory;

  /// No description provided for @whoAmICatAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get whoAmICatAnimals;

  /// No description provided for @whoAmICatFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get whoAmICatFood;

  /// No description provided for @whoAmICatJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get whoAmICatJobs;

  /// No description provided for @whoAmICatPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get whoAmICatPlaces;

  /// No description provided for @whoAmIWordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String whoAmIWordsCount(int count);

  /// No description provided for @whoAmIRoundTime.
  ///
  /// In en, this message translates to:
  /// **'Round length'**
  String get whoAmIRoundTime;

  /// No description provided for @whoAmISeconds.
  ///
  /// In en, this message translates to:
  /// **'{n}s'**
  String whoAmISeconds(int n);

  /// No description provided for @whoAmIStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get whoAmIStart;

  /// No description provided for @whoAmITime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get whoAmITime;

  /// No description provided for @whoAmIScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get whoAmIScoreLabel;

  /// No description provided for @whoAmIWordNo.
  ///
  /// In en, this message translates to:
  /// **'Word {n}'**
  String whoAmIWordNo(int n);

  /// No description provided for @whoAmIFlashCorrect.
  ///
  /// In en, this message translates to:
  /// **'Got it! +1'**
  String get whoAmIFlashCorrect;

  /// No description provided for @whoAmIFlashSkip.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get whoAmIFlashSkip;

  /// No description provided for @whoAmISkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get whoAmISkip;

  /// No description provided for @whoAmIGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get whoAmIGotIt;

  /// No description provided for @whoAmITimeLeft.
  ///
  /// In en, this message translates to:
  /// **'{n} seconds left'**
  String whoAmITimeLeft(int n);

  /// No description provided for @whoAmIEndRound.
  ///
  /// In en, this message translates to:
  /// **'End round'**
  String get whoAmIEndRound;

  /// No description provided for @whoAmIEndTitle.
  ///
  /// In en, this message translates to:
  /// **'End the round?'**
  String get whoAmIEndTitle;

  /// No description provided for @whoAmIEndMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll go to the results with what you\'ve got so far.'**
  String get whoAmIEndMessage;

  /// No description provided for @whoAmITimesUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get whoAmITimesUp;

  /// No description provided for @whoAmIVerdictTop.
  ///
  /// In en, this message translates to:
  /// **'Guessing legend!'**
  String get whoAmIVerdictTop;

  /// No description provided for @whoAmIVerdictGood.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get whoAmIVerdictGood;

  /// No description provided for @whoAmIVerdictLow.
  ///
  /// In en, this message translates to:
  /// **'Better luck next time!'**
  String get whoAmIVerdictLow;

  /// No description provided for @whoAmIKnew.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get whoAmIKnew;

  /// No description provided for @whoAmISkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get whoAmISkipped;

  /// No description provided for @whoAmIRoundWords.
  ///
  /// In en, this message translates to:
  /// **'Round words'**
  String get whoAmIRoundWords;

  /// No description provided for @whoAmIAgain.
  ///
  /// In en, this message translates to:
  /// **'Another round'**
  String get whoAmIAgain;

  /// No description provided for @whoAmIBackToGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get whoAmIBackToGames;

  /// No description provided for @charadesSetupDesc.
  ///
  /// In en, this message translates to:
  /// **'Act the word out for your team without speaking'**
  String get charadesSetupDesc;

  /// No description provided for @charadesTeamLabelA.
  ///
  /// In en, this message translates to:
  /// **'First team name'**
  String get charadesTeamLabelA;

  /// No description provided for @charadesTeamLabelB.
  ///
  /// In en, this message translates to:
  /// **'Second team name'**
  String get charadesTeamLabelB;

  /// No description provided for @charadesDefaultTeamA.
  ///
  /// In en, this message translates to:
  /// **'Falcons'**
  String get charadesDefaultTeamA;

  /// No description provided for @charadesDefaultTeamB.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get charadesDefaultTeamB;

  /// No description provided for @charadesFallbackTeamA.
  ///
  /// In en, this message translates to:
  /// **'Team 1'**
  String get charadesFallbackTeamA;

  /// No description provided for @charadesFallbackTeamB.
  ///
  /// In en, this message translates to:
  /// **'Team 2'**
  String get charadesFallbackTeamB;

  /// No description provided for @charadesMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nobody} one{1 member} other{{count} members}}'**
  String charadesMembersCount(int count);

  /// No description provided for @charadesWhoWithWho.
  ///
  /// In en, this message translates to:
  /// **'Who\'s with who?'**
  String get charadesWhoWithWho;

  /// No description provided for @charadesTapToPick.
  ///
  /// In en, this message translates to:
  /// **'Tap each person to pick their team'**
  String get charadesTapToPick;

  /// No description provided for @charadesPlayerTeamGroup.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s team'**
  String charadesPlayerTeamGroup(String name);

  /// No description provided for @charadesRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get charadesRounds;

  /// No description provided for @charadesRoundsOption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 round} other{{count} rounds}}'**
  String charadesRoundsOption(int count);

  /// No description provided for @charadesStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get charadesStart;

  /// No description provided for @charadesNeedMembers.
  ///
  /// In en, this message translates to:
  /// **'Each team needs at least one player'**
  String get charadesNeedMembers;

  /// No description provided for @charadesRoundOf.
  ///
  /// In en, this message translates to:
  /// **'Round {n} of {total}'**
  String charadesRoundOf(int n, int total);

  /// No description provided for @charadesEndGame.
  ///
  /// In en, this message translates to:
  /// **'End game'**
  String get charadesEndGame;

  /// No description provided for @charadesTeamTurn.
  ///
  /// In en, this message translates to:
  /// **'Team turn:'**
  String get charadesTeamTurn;

  /// No description provided for @charadesActorThisTime.
  ///
  /// In en, this message translates to:
  /// **'Acting this time'**
  String get charadesActorThisTime;

  /// No description provided for @charadesPassPhone.
  ///
  /// In en, this message translates to:
  /// **'Pass the phone to {name}; everyone else, don\'t look'**
  String charadesPassPhone(String name);

  /// No description provided for @charadesImReady.
  ///
  /// In en, this message translates to:
  /// **'I\'m {name}, ready'**
  String charadesImReady(String name);

  /// No description provided for @charadesActing.
  ///
  /// In en, this message translates to:
  /// **'{name} is acting'**
  String charadesActing(String name);

  /// No description provided for @charadesSecondsShort.
  ///
  /// In en, this message translates to:
  /// **'{n}s'**
  String charadesSecondsShort(int n);

  /// No description provided for @charadesActIt.
  ///
  /// In en, this message translates to:
  /// **'Act it out!'**
  String get charadesActIt;

  /// No description provided for @charadesTapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to see the word'**
  String get charadesTapToReveal;

  /// No description provided for @charadesNoTalking.
  ///
  /// In en, this message translates to:
  /// **'No talking or pointing at letters'**
  String get charadesNoTalking;

  /// No description provided for @charadesSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get charadesSkip;

  /// No description provided for @charadesCorrect.
  ///
  /// In en, this message translates to:
  /// **'Got it! +1'**
  String get charadesCorrect;

  /// No description provided for @charadesEndTurn.
  ///
  /// In en, this message translates to:
  /// **'End turn'**
  String get charadesEndTurn;

  /// No description provided for @charadesEndTurnTitle.
  ///
  /// In en, this message translates to:
  /// **'End the turn?'**
  String get charadesEndTurnTitle;

  /// No description provided for @charadesEndTurnMessage.
  ///
  /// In en, this message translates to:
  /// **'The turn passes to {team}.'**
  String charadesEndTurnMessage(String team);

  /// No description provided for @charadesEndGameTitle.
  ///
  /// In en, this message translates to:
  /// **'End the game?'**
  String get charadesEndGameTitle;

  /// No description provided for @charadesEndGameMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ll count the points so far and pick the winner.'**
  String get charadesEndGameMessage;

  /// No description provided for @charadesWinnerTeam.
  ///
  /// In en, this message translates to:
  /// **'Winning team'**
  String get charadesWinnerTeam;

  /// No description provided for @charadesTie.
  ///
  /// In en, this message translates to:
  /// **'It\'s a tie!'**
  String get charadesTie;

  /// No description provided for @charadesEveryoneWon.
  ///
  /// In en, this message translates to:
  /// **'Everyone wins'**
  String get charadesEveryoneWon;

  /// No description provided for @charadesPlayerPoints.
  ///
  /// In en, this message translates to:
  /// **'Points per player'**
  String get charadesPlayerPoints;

  /// No description provided for @charadesStarPlayer.
  ///
  /// In en, this message translates to:
  /// **'Star player'**
  String get charadesStarPlayer;

  /// No description provided for @charadesBackToGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get charadesBackToGames;

  /// No description provided for @charadesNewGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get charadesNewGame;

  /// No description provided for @seenDesc.
  ///
  /// In en, this message translates to:
  /// **'Answer on behalf of someone and see who knows the family best'**
  String get seenDesc;

  /// No description provided for @seenWhoPlays.
  ///
  /// In en, this message translates to:
  /// **'Who\'s playing?'**
  String get seenWhoPlays;

  /// No description provided for @seenPlayersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 player} other{{count} players}}'**
  String seenPlayersCount(int count);

  /// No description provided for @seenPickAtLeast3.
  ///
  /// In en, this message translates to:
  /// **'pick at least 3'**
  String get seenPickAtLeast3;

  /// No description provided for @seenQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'Number of questions'**
  String get seenQuestionCount;

  /// No description provided for @seenQuestionsOption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 question} other{{count} questions}}'**
  String seenQuestionsOption(int count);

  /// No description provided for @seenStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get seenStart;

  /// No description provided for @seenQuestionNo.
  ///
  /// In en, this message translates to:
  /// **'Question {n} of {total}'**
  String seenQuestionNo(int n, int total);

  /// No description provided for @seenAbout.
  ///
  /// In en, this message translates to:
  /// **'Question about'**
  String get seenAbout;

  /// No description provided for @seenAnswersAloud.
  ///
  /// In en, this message translates to:
  /// **'answers out loud'**
  String get seenAnswersAloud;

  /// No description provided for @seenIsAnswerRight.
  ///
  /// In en, this message translates to:
  /// **'{name}, is the answer right?'**
  String seenIsAnswerRight(String name);

  /// No description provided for @seenWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get seenWrong;

  /// No description provided for @seenRight.
  ///
  /// In en, this message translates to:
  /// **'Right! +1'**
  String get seenRight;

  /// No description provided for @seenEndTitle.
  ///
  /// In en, this message translates to:
  /// **'End the game?'**
  String get seenEndTitle;

  /// No description provided for @seenEndMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ll rank everyone on the questions answered so far.'**
  String get seenEndMessage;

  /// No description provided for @seenWinnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Knows the family best'**
  String get seenWinnerLabel;

  /// No description provided for @seenPointsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 point} other{{count} points}}'**
  String seenPointsCount(int count);

  /// No description provided for @seenBackToGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get seenBackToGames;

  /// No description provided for @seenPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get seenPlayAgain;

  /// No description provided for @seenCloseLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get seenCloseLabel;

  /// No description provided for @topicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation, the rest is up to you'**
  String get topicsSubtitle;

  /// No description provided for @topicsGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic type'**
  String get topicsGroupLabel;

  /// No description provided for @topicsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get topicsAll;

  /// No description provided for @topicsCatMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get topicsCatMemories;

  /// No description provided for @topicsCatDreams.
  ///
  /// In en, this message translates to:
  /// **'Dreams & travel'**
  String get topicsCatDreams;

  /// No description provided for @topicsCatFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get topicsCatFood;

  /// No description provided for @topicsCatFun.
  ///
  /// In en, this message translates to:
  /// **'Laughs'**
  String get topicsCatFun;

  /// No description provided for @topicsCatWyr.
  ///
  /// In en, this message translates to:
  /// **'Would you rather'**
  String get topicsCatWyr;

  /// No description provided for @topicsCatMine.
  ///
  /// In en, this message translates to:
  /// **'Our topics'**
  String get topicsCatMine;

  /// No description provided for @topicsSave.
  ///
  /// In en, this message translates to:
  /// **'Save topic'**
  String get topicsSave;

  /// No description provided for @topicsCountOf.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total}'**
  String topicsCountOf(int n, int total);

  /// No description provided for @topicsDiscussedBadge.
  ///
  /// In en, this message translates to:
  /// **'We talked about it'**
  String get topicsDiscussedBadge;

  /// No description provided for @topicsLetsTalk.
  ///
  /// In en, this message translates to:
  /// **'Let\'s talk'**
  String get topicsLetsTalk;

  /// No description provided for @topicsDiscussedButton.
  ///
  /// In en, this message translates to:
  /// **'We talked about it'**
  String get topicsDiscussedButton;

  /// No description provided for @topicsPrev.
  ///
  /// In en, this message translates to:
  /// **'Previous topic'**
  String get topicsPrev;

  /// No description provided for @topicsShuffle.
  ///
  /// In en, this message translates to:
  /// **'Change it'**
  String get topicsShuffle;

  /// No description provided for @topicsTrendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Trending now'**
  String get topicsTrendingTitle;

  /// No description provided for @topicsTrendingSub.
  ///
  /// In en, this message translates to:
  /// **'Most talked about this week'**
  String get topicsTrendingSub;

  /// No description provided for @topicsTalkAboutIt.
  ///
  /// In en, this message translates to:
  /// **'Let\'s talk about it'**
  String get topicsTalkAboutIt;

  /// No description provided for @topicsSuggestTitle.
  ///
  /// In en, this message translates to:
  /// **'Got a topic in mind?'**
  String get topicsSuggestTitle;

  /// No description provided for @topicsSuggestSub.
  ///
  /// In en, this message translates to:
  /// **'Write it and it joins your family\'s topics'**
  String get topicsSuggestSub;

  /// No description provided for @topicsSuggestHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. What was your first salary?'**
  String get topicsSuggestHint;

  /// No description provided for @topicsSuggestFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Your topic'**
  String get topicsSuggestFieldLabel;

  /// No description provided for @topicsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get topicsAdd;

  /// No description provided for @topicsAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Your topic was added'**
  String get topicsAddedSnack;

  /// No description provided for @topicsDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'We talked about these'**
  String get topicsDoneTitle;

  /// No description provided for @topicsDoneCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No topics yet} one{1 topic} other{{count} topics}}'**
  String topicsDoneCount(int count);

  /// No description provided for @topicsDoneEmpty.
  ///
  /// In en, this message translates to:
  /// **'When you tap \"Let\'s talk\" on a topic,\nit\'s saved here so you remember what you talked about'**
  String get topicsDoneEmpty;

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

  /// No description provided for @rouletteGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get rouletteGotIt;

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

  /// No description provided for @onboardingAgeHint.
  ///
  /// In en, this message translates to:
  /// **'Your age'**
  String get onboardingAgeHint;

  /// No description provided for @onboardingRoleQuestion.
  ///
  /// In en, this message translates to:
  /// **'I\'m the family\'s...'**
  String get onboardingRoleQuestion;

  /// No description provided for @roleMomLabel.
  ///
  /// In en, this message translates to:
  /// **'Mom'**
  String get roleMomLabel;

  /// No description provided for @roleDadLabel.
  ///
  /// In en, this message translates to:
  /// **'Dad'**
  String get roleDadLabel;

  /// No description provided for @roleDaughterLabel.
  ///
  /// In en, this message translates to:
  /// **'Daughter'**
  String get roleDaughterLabel;

  /// No description provided for @roleSonLabel.
  ///
  /// In en, this message translates to:
  /// **'Son'**
  String get roleSonLabel;

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

  /// No description provided for @dataWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dataWeekdayMon;

  /// No description provided for @dataWeekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dataWeekdayTue;

  /// No description provided for @dataWeekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dataWeekdayWed;

  /// No description provided for @dataWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dataWeekdayThu;

  /// No description provided for @dataWeekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dataWeekdayFri;

  /// No description provided for @dataWeekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get dataWeekdaySat;

  /// No description provided for @dataWeekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get dataWeekdaySun;

  /// No description provided for @dataMonthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get dataMonthJan;

  /// No description provided for @dataMonthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get dataMonthFeb;

  /// No description provided for @dataMonthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get dataMonthMar;

  /// No description provided for @dataMonthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get dataMonthApr;

  /// No description provided for @dataMonthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get dataMonthMay;

  /// No description provided for @dataMonthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get dataMonthJun;

  /// No description provided for @dataMonthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get dataMonthJul;

  /// No description provided for @dataMonthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get dataMonthAug;

  /// No description provided for @dataMonthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get dataMonthSep;

  /// No description provided for @dataMonthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get dataMonthOct;

  /// No description provided for @dataMonthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get dataMonthNov;

  /// No description provided for @dataMonthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dataMonthDec;

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

  /// No description provided for @dataTime930pm.
  ///
  /// In en, this message translates to:
  /// **'9:30 PM'**
  String get dataTime930pm;

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

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardCycleReward.
  ///
  /// In en, this message translates to:
  /// **'{cycle} reward'**
  String leaderboardCycleReward(String cycle);

  /// No description provided for @leaderboardLastWinner.
  ///
  /// In en, this message translates to:
  /// **'Winner: {winner} · {reward}'**
  String leaderboardLastWinner(String winner, String reward);

  /// No description provided for @leaderboardRanking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get leaderboardRanking;

  /// No description provided for @leaderboardPts.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, zero{0 pts} one{1 pt} other{{points} pts}}'**
  String leaderboardPts(int points);

  /// No description provided for @leaderboardNoWinnerYet.
  ///
  /// In en, this message translates to:
  /// **'No winner yet'**
  String get leaderboardNoWinnerYet;

  /// No description provided for @leaderboardRewardNow.
  ///
  /// In en, this message translates to:
  /// **'Reward {name} (#1) now'**
  String leaderboardRewardNow(String name);

  /// No description provided for @leaderboardRewardSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{name} gets: {reward}'**
  String leaderboardRewardSnackbar(String name, String reward);

  /// No description provided for @parentControlsPhoneFreeTime.
  ///
  /// In en, this message translates to:
  /// **'Phone-free time'**
  String get parentControlsPhoneFreeTime;

  /// No description provided for @parentControlsFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get parentControlsFrom;

  /// No description provided for @parentControlsUntil.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get parentControlsUntil;

  /// No description provided for @parentControlsIfPhoneUsed.
  ///
  /// In en, this message translates to:
  /// **'If someone uses their phone'**
  String get parentControlsIfPhoneUsed;

  /// No description provided for @parentControlsLosePointsChoice.
  ///
  /// In en, this message translates to:
  /// **'Lose points'**
  String get parentControlsLosePointsChoice;

  /// No description provided for @parentControlsPointsLost.
  ///
  /// In en, this message translates to:
  /// **'Points lost'**
  String get parentControlsPointsLost;

  /// No description provided for @parentControlsOrWriteOwn.
  ///
  /// In en, this message translates to:
  /// **'Or write your own'**
  String get parentControlsOrWriteOwn;

  /// No description provided for @parentControlsRecordViolation.
  ///
  /// In en, this message translates to:
  /// **'Record a phone violation'**
  String get parentControlsRecordViolation;

  /// No description provided for @parentControlsTakeAwayPoints.
  ///
  /// In en, this message translates to:
  /// **'{penalty, plural, one{Take away 1 point} other{Take away {penalty} points}}'**
  String parentControlsTakeAwayPoints(int penalty);

  /// No description provided for @parentControlsGivePunishment.
  ///
  /// In en, this message translates to:
  /// **'Give punishment'**
  String get parentControlsGivePunishment;

  /// No description provided for @parentControlsRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get parentControlsRecent;

  /// No description provided for @parentControlsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get parentControlsDone;

  /// No description provided for @parentControlsLeaderboardReward.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard reward'**
  String get parentControlsLeaderboardReward;

  /// No description provided for @parentControlsWinningCycle.
  ///
  /// In en, this message translates to:
  /// **'Winning cycle'**
  String get parentControlsWinningCycle;

  /// No description provided for @parentControlsRewardForWinner.
  ///
  /// In en, this message translates to:
  /// **'Reward for the winner'**
  String get parentControlsRewardForWinner;

  /// No description provided for @parentControlsOrWriteOwnReward.
  ///
  /// In en, this message translates to:
  /// **'Or write your own reward'**
  String get parentControlsOrWriteOwnReward;

  /// No description provided for @parentControlsViolationSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{who}: {kind} ({detail})'**
  String parentControlsViolationSnackbar(
    String who,
    String kind,
    String detail,
  );

  /// No description provided for @violationKindLostPoints.
  ///
  /// In en, this message translates to:
  /// **'Lost points'**
  String get violationKindLostPoints;

  /// No description provided for @violationKindPunishment.
  ///
  /// In en, this message translates to:
  /// **'Punishment'**
  String get violationKindPunishment;

  /// No description provided for @dataCycleWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get dataCycleWeekly;

  /// No description provided for @dataCycleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get dataCycleMonthly;

  /// No description provided for @dataTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get dataTimeJustNow;

  /// No description provided for @dataPunishmentDishes.
  ///
  /// In en, this message translates to:
  /// **'Wash the dishes'**
  String get dataPunishmentDishes;

  /// No description provided for @dataPunishmentNoGames.
  ///
  /// In en, this message translates to:
  /// **'No games tonight'**
  String get dataPunishmentNoGames;

  /// No description provided for @dataPunishmentCleanRoom.
  ///
  /// In en, this message translates to:
  /// **'Clean your room'**
  String get dataPunishmentCleanRoom;

  /// No description provided for @dataPunishmentEarlyBedtime.
  ///
  /// In en, this message translates to:
  /// **'Early bedtime'**
  String get dataPunishmentEarlyBedtime;

  /// No description provided for @dataPunishmentHelpCook.
  ///
  /// In en, this message translates to:
  /// **'Help cook dinner'**
  String get dataPunishmentHelpCook;

  /// No description provided for @dataRewardDinnerPlace.
  ///
  /// In en, this message translates to:
  /// **'Choose the family dinner place'**
  String get dataRewardDinnerPlace;

  /// No description provided for @dataRewardMovie.
  ///
  /// In en, this message translates to:
  /// **'Pick the movie for movie night'**
  String get dataRewardMovie;

  /// No description provided for @dataRewardSkipChore.
  ///
  /// In en, this message translates to:
  /// **'Skip a chore'**
  String get dataRewardSkipChore;

  /// No description provided for @dataRewardOuting.
  ///
  /// In en, this message translates to:
  /// **'Choose the weekend outing'**
  String get dataRewardOuting;

  /// No description provided for @dataRewardGameTime.
  ///
  /// In en, this message translates to:
  /// **'Extra game time'**
  String get dataRewardGameTime;

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
