import 'package:flutter/widgets.dart';

import '../data.dart';
import 'app_localizations.dart';

/// Display-only localization for values that live in `data.dart`.
///
/// `data.dart` holds plain English string literals that are also used for
/// equality checks, filters and selection sets (e.g. `Choice` labels,
/// `p.type == _f`). Those literals must never change, so this maps the
/// ORIGINAL English value to its Arabic label purely for rendering — it is
/// never used to mutate, store or compare data.
///
/// Usage: `Text(ld(context, event.title))`. Unknown values pass through
/// unchanged (e.g. a user-entered name), so this is always safe to call.
String ld(BuildContext context, String english) {
  final l = AppLocalizations.of(context);
  return _map(l)[english] ?? english;
}

/// Localized equivalent of `dateLabel()` (lib/data.dart): composes the
/// translated weekday + month abbreviation with the day number, since
/// `dateLabel()`'s own English punctuation/order can't be pattern-matched
/// by [ld] directly.
String localizedDateLabel(BuildContext context, DateTime d) {
  return '${ld(context, weekdayName(d))}, ${ld(context, monthName(d))} ${d.day}';
}

Map<String, String> _map(AppLocalizations l) => {
      // characters (lib/data.dart `characters`)
      'Sister': l.dataCharacterSister,
      'Big brother': l.dataCharacterBigBrother,
      'Father': l.dataCharacterFather,
      'Mother': l.dataCharacterMother,
      'Little girl': l.dataCharacterLittleGirl,
      'Son': l.dataCharacterSon,

      // member seed names (lib/data.dart `members`) — display only; Member.name
      // itself is never changed, so avatarAsset()/profile.name matching is safe.
      'Noura': l.dataMemberNoura,
      'Mohammed': l.dataMemberMohammed,
      'Abdullah': l.dataMemberAbdullah,
      'Amina': l.dataMemberAmina,
      'Sarah': l.dataMemberSarah,
      'Yousef': l.dataMemberYousef,

      // event types (lib/data.dart `eventTypes`)
      'Gathering': l.dataEventTypeGathering,
      'Outing': l.dataEventTypeOuting,
      'Dinner': l.dataEventTypeDinner,
      'Games': l.dataEventTypeGames,
      'Trip': l.dataEventTypeTrip,
      'Movie': l.dataEventTypeMovie,
      'Occasion': l.dataEventTypeOccasion,

      // weekday / month abbreviations (lib/data.dart `_weekdays`, `_months`,
      // used by weekdayName()/monthName()/dateLabel()) — composed into a full
      // date string by localizedDateLabel() below, not translated inline,
      // since dateLabel()'s own English punctuation/order can't be pattern-matched.
      'Mon': l.dataWeekdayMon,
      'Tue': l.dataWeekdayTue,
      'Wed': l.dataWeekdayWed,
      'Thu': l.dataWeekdayThu,
      'Fri': l.dataWeekdayFri,
      'Sat': l.dataWeekdaySat,
      'Sun': l.dataWeekdaySun,
      'Jan': l.dataMonthJan,
      'Feb': l.dataMonthFeb,
      'Mar': l.dataMonthMar,
      'Apr': l.dataMonthApr,
      'May': l.dataMonthMay,
      'Jun': l.dataMonthJun,
      'Jul': l.dataMonthJul,
      'Aug': l.dataMonthAug,
      'Sep': l.dataMonthSep,
      'Oct': l.dataMonthOct,
      'Nov': l.dataMonthNov,
      'Dec': l.dataMonthDec,

      // event titles (lib/data.dart `events`)
      'Village outing': l.dataEventTitleVillageOuting,
      'Family dinner': l.dataEventTitleFamilyDinner,
      '4:00 PM': l.dataEventTime4pm,
      '8:00 PM': l.dataEventTime8pm,
      '9:30 PM': l.dataTime930pm,

      // places (lib/data.dart `places`)
      'King Salman Park': l.dataPlaceKingSalmanPark,
      'Café Al-Dar': l.dataPlaceCafeAlDar,
      'Strike Bowling': l.dataPlaceStrikeBowling,
      'Sufrat Al-Bayt': l.dataPlaceSufratAlBayt,
      '4 of 6 family members like this type of place': l.dataPlaceWhyPark,
      'Suits everyone, a good choice': l.dataPlaceWhyCafe,
      '3 of 6 love games and group activities': l.dataPlaceWhyBowling,
      'Homestyle food and family seating': l.dataPlaceWhyRestaurant,

      // outing / place types (lib/data.dart `places`, also onboarding & filters)
      'Nature': l.dataOutingTypeNature,
      'Restaurants': l.dataOutingTypeRestaurants,
      'Cafés': l.dataOutingTypeCafes,
      'Entertainment': l.dataOutingTypeEntertainment,

      // badges (lib/data.dart `badges`)
      'Most interactive': l.dataBadgeMostInteractive,
      'Lamma spirit': l.dataBadgeLammaSpirit,
      'Weekly listener': l.dataBadgeWeeklyListener,
      'Week winner': l.dataBadgeWeekWinner,
      'Talks king': l.dataBadgeTalksKing,
      'Reader': l.dataBadgeReader,

      // Talks with Aziz questions (lib/data.dart `azizQuestions`)
      "What's the strangest food you've ever tried?": l.dataAziz1,
      'Which trip would you repeat tomorrow?': l.dataAziz2,
      "What's a small thing that makes your day?": l.dataAziz3,
      'Who in the family makes you laugh the most?': l.dataAziz4,

      // Sin Jim questions (lib/data.dart `sinJimQuestions`)
      'How old is your grandfather?': l.dataSinJim1,
      "What's Dad's favorite dish?": l.dataSinJim2,
      "What's Mom's favorite color?": l.dataSinJim3,
      'Who is the biggest sleeper in the family?': l.dataSinJim4,

      // talk topics (lib/data.dart `topics`)
      'If you could travel anywhere now, where would we go?': l.dataTopic1,
      "What's the family moment you'd never forget?": l.dataTopic2,
      'What tradition should we start this year?': l.dataTopic3,
      "What's one thing you've never told us?": l.dataTopic4,

      // moment captions (lib/data.dart `moments`)
      'Went out today with the girls': l.dataMomentCaptionSarah,
      'Study break at the café': l.dataMomentCaptionMohammed,
      'Fresh coffee, quiet morning': l.dataMomentCaptionAmina,
      'Evening in the majlis': l.dataMomentCaptionAbdullah,
      'My new Lego!': l.dataMomentCaptionYousef,
      'Baking with Mom': l.dataMomentCaptionNoura,

      // relative time labels (lib/data.dart `moments`, `talks`)
      'Today, 4:10 PM': l.dataTimeTodayAt410pm,
      'Today, 1:30 PM': l.dataTimeTodayAt130pm,
      'Today, 8:15 AM': l.dataTimeTodayAt815am,
      'Yesterday': l.dataTimeYesterday,
      'Today': l.dataTimeToday,
      '2 days ago': l.dataTime2DaysAgo,

      // family talk texts (lib/data.dart `talks`)
      'What do you want to eat on Thursday?': l.dataTalkSarah,
      'Who wants to come with me to the market?': l.dataTalkAmina,

      // comments (lib/data.dart `comments`)
      'Nice!': l.dataCommentAbdullah,
      'God protect you all': l.dataCommentAmina,
      'Take me with you': l.dataCommentMohammed,

      // interests (lib/data.dart `Profile.interests` default, onboarding `_interests`)
      'Coffee': l.dataInterestCoffee,
      'Reading': l.dataInterestReading,
      'Walking': l.dataInterestWalking,
      'Podcasts': l.dataInterestPodcasts,
      'Movies': l.dataInterestMovies,
      'Cooking': l.dataInterestCooking,
      'Drawing': l.dataInterestDrawing,
      'Football': l.dataInterestFootball,
      'Swimming': l.dataInterestSwimming,
      'Music': l.dataInterestMusic,
      'Travel': l.dataInterestTravel,

      // family name fallbacks (lib/data.dart `Profile.family`, onboarding `_finish`)
      'Your family': l.dataFamilyFallback,
      'Al-Otaibi family': l.dataFamilyDefault,

      // family chat seed messages (lib/screens/lamma.dart `_msgs`)
      'What are we cooking tonight?': l.chatSeedSarahCooking,
      "Let's go to the park!": l.chatSeedMeGoPark,
      'Dinner will be ready soon': l.chatSeedAminaDinner,
      'Coming!': l.chatSeedMeComing,

      // roulette modes & wheel items (lib/screens/activities.dart `_modes`) —
      // used for both display (Choice/wheel labels) and comparison (`_mode == m`),
      // so like data.dart content these route through the lookup, not raw ARB.
      'Who starts?': l.rouletteModeWhoStarts,
      'Challenge': l.rouletteModeChallenge,
      'Decision': l.rouletteModeDecision,
      'Tell a joke': l.rouletteChallengeJoke,
      'Sing a line': l.rouletteChallengeSing,
      'Imitate someone': l.rouletteChallengeImitate,
      'Dance 10 sec': l.rouletteChallengeDance,
      'Tell a secret': l.rouletteChallengeSecret,
      'Draw in 10 sec': l.rouletteChallengeDraw,
      'Stay home': l.rouletteDecisionStayHome,
      'Go out': l.rouletteDecisionGoOut,
      'Cook': l.rouletteDecisionCook,
      'Order food': l.rouletteDecisionOrderFood,
      'Watch a movie': l.rouletteDecisionMovie,
      'Play games': l.rouletteDecisionGames,

      // 'Just now' timestamp (lib/screens/lamma.dart ShareMomentPage)
      'Just now': l.dataTimeJustNow,

      // parent controls / leaderboard (lib/screens/leaderboard.dart, lib/data.dart `Rules`) —
      // compared (rules.cycle == c, rules.punishment == p, v.kind == 'Punishment') as well as
      // displayed, so these route through the lookup rather than plain ARB getters.
      'Lost points': l.violationKindLostPoints,
      'Punishment': l.violationKindPunishment,
      'Weekly': l.dataCycleWeekly,
      'Monthly': l.dataCycleMonthly,
      'Wash the dishes': l.dataPunishmentDishes,
      'No games tonight': l.dataPunishmentNoGames,
      'Clean your room': l.dataPunishmentCleanRoom,
      'Early bedtime': l.dataPunishmentEarlyBedtime,
      'Help cook dinner': l.dataPunishmentHelpCook,
      'Choose the family dinner place': l.dataRewardDinnerPlace,
      'Pick the movie for movie night': l.dataRewardMovie,
      'Skip a chore': l.dataRewardSkipChore,
      'Choose the weekend outing': l.dataRewardOuting,
      'Extra game time': l.dataRewardGameTime,
    };
