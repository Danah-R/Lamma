// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'لمّه';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navLamma => 'لمّه';

  @override
  String get navActivities => 'صندوق الأنشطة';

  @override
  String get navAccount => 'الحساب';

  @override
  String get navShare => 'مشاركة';

  @override
  String get commonComments => 'التعليقات';

  @override
  String get commonWriteCommentHint => 'اكتب تعليقًا...';

  @override
  String get commonShareAction => 'مشاركة';

  @override
  String get commonComingSoon => 'قريبًا';

  @override
  String homeGreeting(String name) {
    return 'مساء الخير، $name';
  }

  @override
  String get homeTodayWithFamily => 'اليوم مع العائلة';

  @override
  String get homeFamilyNightTime => 'سهرة العائلة · 8:00 مساءً';

  @override
  String homeAttendingCount(int attending, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      attending,
      locale: localeName,
      other: '$attending من $total حاضر',
      many: '$attending من $total حاضر',
      few: '$attending من $total حاضرين',
      two: 'اثنان من $total حاضرون',
      one: 'واحد من $total حاضر',
      zero: 'محد من $total حاضر',
    );
    return '$_temp0';
  }

  @override
  String get homeStreak => '7 أيام متتالية';

  @override
  String get homeInteractions => '12 تفاعل هذا الأسبوع';

  @override
  String get homeFamilyCalendar => 'تقويم العائلة';

  @override
  String get homeAddEvent => '+ إضافة فعالية';

  @override
  String get homeWeeklyPodcast => 'البودكاست الأسبوعي';

  @override
  String get homePodcastTitle => 'إيش يضحكنا مع بعض؟';

  @override
  String get homePodcastEpisode => 'الحلقة 12 · 32 دقيقة';

  @override
  String get homePodcastListenedCount => 'استمع 3 من 6';

  @override
  String get homeStartListening => 'ابدأ الاستماع';

  @override
  String get homeMemoriesQuote => 'أجمل الذكريات تبدأ بسؤال بسيط';

  @override
  String get homeFamilyActivity => 'نشاط العائلة';

  @override
  String get homeFeedSarahPhoto => 'شاركت سارة صورة';

  @override
  String get homeFeedMohammedChallenge => 'أنهى محمد تحدي اليوم';

  @override
  String get homeFeedAminaPodcast => 'استمعت أمينة للبودكاست الأسبوعي';

  @override
  String homeFeedPhoto(String name) {
    return 'شارك $name صورة';
  }

  @override
  String homeFeedChallenge(String name) {
    return 'أنهى $name تحدي اليوم';
  }

  @override
  String homeFeedPodcast(String name) {
    return 'استمع $name للبودكاست الأسبوعي';
  }

  @override
  String homePhoneFreeBanner(String from, String to) {
    return 'وقت بدون جوال · $from – $to';
  }

  @override
  String homePunishmentBanner(String detail) {
    return 'عقوبتك: $detail';
  }

  @override
  String get homeLeaderboardSeeAll => 'عرض الكل';

  @override
  String notifMomentShared(String name) {
    return 'شارك $name لحظة';
  }

  @override
  String get addEventDateLabel => 'التاريخ';

  @override
  String get homeYourWeekButton => 'أسبوعك في لمّه';

  @override
  String get homeDayToday => '· اليوم';

  @override
  String get homeNoEvents => 'لا توجد فعاليات';

  @override
  String get eventDetailsTitle => 'تفاصيل الفعالية';

  @override
  String eventDetailsDateLine(String day, int dayNum, String time) {
    return '$day $dayNum · $time';
  }

  @override
  String eventDetailsGoingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count من العائلة قادم',
      many: '$count من العائلة قادم',
      few: '$count من العائلة قادمين',
      two: 'اثنان من العائلة قادمون',
      one: 'واحد من العائلة قادم',
      zero: 'محد من العائلة قادم',
    );
    return '$_temp0';
  }

  @override
  String get eventDetailsImIn => 'أنت مشارك';

  @override
  String get eventDetailsImComing => 'أنا قادم';

  @override
  String get addEventTitle => 'فعالية جديدة';

  @override
  String get addEventTypeLabel => 'نوع الفعالية';

  @override
  String get addEventNameLabel => 'الاسم';

  @override
  String get addEventNameHint => 'اسم الفعالية...';

  @override
  String get addEventDayLabel => 'اليوم';

  @override
  String get addEventTimeLabel => 'الوقت';

  @override
  String get addEventSubmit => 'إضافة إلى التقويم';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notifEpisodeReady => 'حلقة هذا الأسبوع جاهزة';

  @override
  String get notifSarahMoment => 'شاركت سارة لحظة';

  @override
  String get notifBadgeEarned => 'حصلت على وسام روح لمّه';

  @override
  String get notifEmpty => 'هذا كل شي حاليًا';

  @override
  String get recapTitle => 'أسبوعك';

  @override
  String get recapHeroTitle => 'أسبوعك في لمّه';

  @override
  String get recapChats => 'المحادثات';

  @override
  String get recapPhotos => 'الصور';

  @override
  String get recapActiveDays => 'أيام النشاط';

  @override
  String get recapListened => 'استماع';

  @override
  String get recapMostShared => 'الأكثر مشاركة: حديث مع عزيز';

  @override
  String get recapEveryonePlayed => 'الكل لعبها';

  @override
  String get recapSeeBadges => 'عرض الأوسمة';

  @override
  String get accountTitle => 'الحساب';

  @override
  String get accountSubtitle => 'ملفك في لمّه';

  @override
  String accountAgeSpirit(int age) {
    return '$age سنة · روح لمّه';
  }

  @override
  String get accountDesignCharacter => 'صمم شخصيتك';

  @override
  String get accountMyInterests => 'اهتماماتي';

  @override
  String get accountPlacesToVisit => 'أماكن أحب أزورها';

  @override
  String get accountNothingPicked => 'لم يتم اختيار شيء بعد';

  @override
  String get accountParentSection => 'الوالدين';

  @override
  String get accountParentControlsTitle => 'ضوابط الوالدين';

  @override
  String get accountParentControlsDesc => 'وقت بدون جوال، عقوبات، مكافآت';

  @override
  String get accountAchievements => 'الإنجازات';

  @override
  String get accountStatDays => 'أيام';

  @override
  String get accountStatGames => 'ألعاب';

  @override
  String get accountAllBadges => 'كل الأوسمة والإنجازات';

  @override
  String get designCharacterTitle => 'شخصيتي';

  @override
  String get designCharacterSection => 'الشخصية';

  @override
  String get designOutfitsSection => 'الأزياء';

  @override
  String get designSave => 'حفظ';

  @override
  String get badgesTitle => 'الأوسمة والإنجازات';

  @override
  String get lammaSubtitle => 'يلا نسولف';

  @override
  String get lammaFamilyTalk => 'سوالف العائلة';

  @override
  String get lammaOpenFamilyChat => 'فتح محادثة العائلة';

  @override
  String get lammaMomentsOfOurDay => 'لحظات يومنا';

  @override
  String get lammaShareMomentAction => '+ شارك لحظة';

  @override
  String get momentTitle => 'اللحظة';

  @override
  String get shareMomentTitle => 'شارك لحظة';

  @override
  String get shareMomentPhotoHint => 'التقط أو اختر صورة';

  @override
  String get shareMomentTextHint => 'وش في بالك؟ (كلمة أو كلمتين)';

  @override
  String get shareMomentTagCafe => 'في الكافيه';

  @override
  String get shareMomentTagWalking => 'تمشية';

  @override
  String get shareMomentTagCooking => 'طبخ';

  @override
  String get shareMomentSubmit => 'شارك مع العائلة';

  @override
  String get shareMomentFallbackCaption => 'لحظة';

  @override
  String get familyChatTitle => 'محادثة العائلة';

  @override
  String get familyChatInputHint => 'اكتب رسالة...';

  @override
  String get activitiesTitle => 'الأنشطة';

  @override
  String get activitiesSubtitle => 'وش نسوي مع بعض؟';

  @override
  String get activitiesGroupGamesTitle => 'ألعاب جماعية';

  @override
  String get activitiesGroupGamesDesc => 'روليت، سين جيم والمزيد';

  @override
  String get activitiesBookClubTitle => 'نادي الكتاب';

  @override
  String get activitiesBookClubDesc => 'ألف شمس مشرقة';

  @override
  String get activitiesPodcastClubTitle => 'نادي البودكاست';

  @override
  String get activitiesPodcastDesc => 'الحلقة 12 · استمع 3 من 6';

  @override
  String get activitiesTalkTopicsTitle => 'مواضيع للحديث';

  @override
  String get activitiesTalkTopicsDesc => 'بدايات للسوالف';

  @override
  String get activitiesOutingsTitle => 'الخرجات';

  @override
  String get activitiesOutingsDesc => 'أماكن تناسب العائلة كلها';

  @override
  String get activitiesNewTopic => 'موضوع جديد';

  @override
  String get activitiesClubsSection => 'النوادي';

  @override
  String get activitiesBookClubCount => 'يقرأ 3 من 6';

  @override
  String get activitiesPodcastClubDetail => 'الحلقة 12 · إيش يضحكنا مع بعض؟';

  @override
  String get activitiesGroupGamesDescFull => 'روليت، حديث مع عزيز وسين جيم';

  @override
  String get activitiesSpinRoulette => 'دور الروليت';

  @override
  String get gamesTitle => 'الألعاب';

  @override
  String get gamesRouletteTitle => 'الروليت';

  @override
  String get gamesRouletteDesc => 'مين يبدأ؟ مين ياخذ التحدي؟';

  @override
  String get gamesAzizTitle => 'حديث مع عزيز';

  @override
  String get gamesAzizDesc => 'أسئلة طريفة ومفاجئة';

  @override
  String get gamesSinJimTitle => 'سين جيم';

  @override
  String get gamesSinJimDesc => 'جاوب نيابة عن أحد';

  @override
  String get gamesThabbitTitle => 'ثبّت';

  @override
  String get gamesThabbitDesc => 'وقف على وضعك!';

  @override
  String get gamesShiddahTitle => 'شدة';

  @override
  String get gamesShiddahDesc => 'لعبة ورق سريعة';

  @override
  String get gamesTimeRange5to10 => '5-10 دقايق';

  @override
  String get gamesTimeRange10to15 => '10-15 دقيقة';

  @override
  String get gamesTime5min => '5 دقايق';

  @override
  String get gamesTime10min => '10 دقايق';

  @override
  String get gamesStartPlaying => 'ابدأ اللعب';

  @override
  String get soonPageMessage => 'قريبًا';

  @override
  String get azizNext => 'التالي';

  @override
  String get azizSkip => 'تخطي';

  @override
  String get sinJimAnswerOnBehalf => 'جاوب نيابة عن';

  @override
  String get sinJimQPrefix => 'س:';

  @override
  String get sinJimEveryoneAnswered => 'الكل جاوب';

  @override
  String sinJimAnswersRecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إجابة مسجلة',
      many: '$count إجابة مسجلة',
      few: '$count إجابات مسجلة',
      two: 'إجابتين مسجلتين',
      one: 'إجابة وحدة مسجلة',
      zero: 'ما فيه إجابات مسجلة',
    );
    return '$_temp0';
  }

  @override
  String get rouletteModeWhoStarts => 'مين يبدأ؟';

  @override
  String get rouletteModeChallenge => 'تحدي';

  @override
  String get rouletteModeDecision => 'قرار';

  @override
  String get rouletteChallengeJoke => 'احكِ نكتة';

  @override
  String get rouletteChallengeSing => 'غنِّ سطر';

  @override
  String get rouletteChallengeImitate => 'قلّد أحد';

  @override
  String get rouletteChallengeDance => 'ارقص 10 ثواني';

  @override
  String get rouletteChallengeSecret => 'احكِ سر';

  @override
  String get rouletteChallengeDraw => 'ارسم في 10 ثواني';

  @override
  String get rouletteDecisionStayHome => 'نبقى في البيت';

  @override
  String get rouletteDecisionGoOut => 'نطلع';

  @override
  String get rouletteDecisionCook => 'نطبخ';

  @override
  String get rouletteDecisionOrderFood => 'نطلب أكل';

  @override
  String get rouletteDecisionMovie => 'نشوف فلم';

  @override
  String get rouletteDecisionGames => 'نلعب';

  @override
  String rouletteResultStarts(String name) {
    return '$name يبدأ!';
  }

  @override
  String get rouletteSpin => 'دور العجلة';

  @override
  String get bookClubCurrentBook => 'الكتاب الحالي';

  @override
  String get bookClubReadingStatus => 'يقرأ 3 من 6 · النقاش يوم الخميس';

  @override
  String get bookClubJoinDiscussion => 'انضم للنقاش';

  @override
  String get discussionQuestionsHeading => 'أسئلة للنقاش';

  @override
  String get bookClubQ1 => 'أي شخصية تحس إنك قريب منها؟';

  @override
  String get bookClubQ2 => 'لو تغيرت النهاية، وش كانت تكون؟';

  @override
  String get podcastThisWeekEpisode => 'حلقة هذا الأسبوع';

  @override
  String get podcastDuration => '32 دقيقة';

  @override
  String get podcastListenedLabel => 'استمع';

  @override
  String podcastListenedFraction(int count) {
    return '$count/6';
  }

  @override
  String get podcastNextGathering =>
      'التجمع الجاي: يوم الجمعة بعد العشاء. بنسولف عنها كلنا.';

  @override
  String get podcastQ1 => 'متى آخر مرة ضحكنا لين دمعت عيوننا؟';

  @override
  String get podcastQ2 => 'مين في العائلة يحكي أحلى النكت؟';

  @override
  String get talkTopicsGiveMeTopic => 'عطني موضوع';

  @override
  String get talkTopicsTrendingNow => 'رائج الحين';

  @override
  String get talkTopicsTrend1 => 'أحلى ذكرى رمضان';

  @override
  String get talkTopicsTrend2 => 'أكلة أمي المفضلة';

  @override
  String get outingsFilterAll => 'الكل';

  @override
  String get outingsPlacesMap => 'خريطة الأماكن';

  @override
  String get outingsOurOutings => 'خرجاتنا';

  @override
  String get suggestPlaceTitle => 'اقتراح للعائلة';

  @override
  String get suggestPlaceWhyHeading => 'ليش اقترحناه';

  @override
  String get suggestPlaceAdd => 'إضافة إلى «خرجاتنا»';

  @override
  String get suggestPlaceAddedSnackbar => 'تمت الإضافة إلى خرجاتنا';

  @override
  String get ourOutingsEmpty => 'ماكو شي هنا بعد.\nأضف مكان من صفحة الخرجات.';

  @override
  String get onboardingSplashLogo => 'لمّه';

  @override
  String get onboardingSplashTagline => 'يلا نتلمّ';

  @override
  String get onboardingSplashStart => 'ابدأ';

  @override
  String get onboardingAboutTitle => 'خلنا نتعرف عليك';

  @override
  String get onboardingAboutSubtitle => 'بس كم سؤال بسيط';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingInterestsTitle => 'وش يعجبك؟';

  @override
  String get onboardingInterestsSubtitle => 'اختر اللي يناسب تجربتك';

  @override
  String get onboardingSignupTitle => 'أهلًا وسهلًا!';

  @override
  String get onboardingSignupSubtitle => 'بنرسل لك رمز التحقق برسالة';

  @override
  String get onboardingCreateAccount => 'إنشاء حساب';

  @override
  String get onboardingFamilyTitle => 'عائلتك';

  @override
  String get onboardingFamilySubtitle => 'أنشئ مساحة لعائلتك أو انضم لوحدة';

  @override
  String get onboardingCharacterTitle => 'اختر شخصيتك';

  @override
  String get onboardingCharacterSubtitle => 'تقدر تغيّرها بأي وقت من الحساب';

  @override
  String get onboardingLetsGo => 'يلا نبدأ';

  @override
  String get onboardingNameLabel => 'اسمك';

  @override
  String get onboardingNameHint => 'الاسم';

  @override
  String get onboardingAgeLabel => 'العمر';

  @override
  String get onboardingAgeHint => 'عمرك';

  @override
  String get onboardingRoleQuestion => 'أنا في العائلة...';

  @override
  String get roleMomLabel => 'أم';

  @override
  String get roleDadLabel => 'أب';

  @override
  String get roleDaughterLabel => 'ابنة';

  @override
  String get roleSonLabel => 'ابن';

  @override
  String get onboardingJobQuestion => 'وش تسوي؟';

  @override
  String get onboardingJobWork => 'أشتغل';

  @override
  String get onboardingJobStudent => 'طالب/ة';

  @override
  String get onboardingJobHome => 'أبقى في البيت';

  @override
  String get onboardingThingsYouLove => 'أشياء تحبها';

  @override
  String get onboardingTypeOfOutings => 'نوع الخرجات';

  @override
  String get onboardingIPrefer => 'أفضّل...';

  @override
  String get onboardingPreferGames => 'الألعاب';

  @override
  String get onboardingPreferDiscussions => 'النقاشات';

  @override
  String get onboardingPhoneHint => '05 ••• ••• ••';

  @override
  String get onboardingSigninInstead => 'عندك حساب؟ سجّل دخول';

  @override
  String get onboardingStartFamily => 'ابدأ عائلة';

  @override
  String get onboardingFamilyNameHint => 'مثال: عائلة العتيبي';

  @override
  String get onboardingCreate => 'إنشاء';

  @override
  String get onboardingHaveInviteCode => 'عندك رمز دعوة؟';

  @override
  String get onboardingInviteCodeHint => 'LAMMA-48';

  @override
  String get onboardingJoin => 'انضمام';

  @override
  String get dataCharacterSister => 'الأخت';

  @override
  String get dataCharacterBigBrother => 'الأخ الكبير';

  @override
  String get dataCharacterFather => 'الأب';

  @override
  String get dataCharacterMother => 'الأم';

  @override
  String get dataCharacterLittleGirl => 'البنت الصغيرة';

  @override
  String get dataCharacterSon => 'الابن';

  @override
  String get dataMemberNoura => 'نورة';

  @override
  String get dataMemberMohammed => 'محمد';

  @override
  String get dataMemberAbdullah => 'عبدالله';

  @override
  String get dataMemberAmina => 'أمينة';

  @override
  String get dataMemberSarah => 'سارة';

  @override
  String get dataMemberYousef => 'يوسف';

  @override
  String get dataEventTypeGathering => 'تجمّع';

  @override
  String get dataEventTypeOuting => 'خرجة';

  @override
  String get dataEventTypeDinner => 'عشاء';

  @override
  String get dataEventTypeGames => 'ألعاب';

  @override
  String get dataEventTypeTrip => 'رحلة';

  @override
  String get dataEventTypeMovie => 'فلم';

  @override
  String get dataEventTypeOccasion => 'مناسبة';

  @override
  String get dataDaySat => 'السبت';

  @override
  String get dataDaySun => 'الأحد';

  @override
  String get dataDayMon => 'الإثنين';

  @override
  String get dataWeekdayMon => 'الإثنين';

  @override
  String get dataWeekdayTue => 'الثلاثاء';

  @override
  String get dataWeekdayWed => 'الأربعاء';

  @override
  String get dataWeekdayThu => 'الخميس';

  @override
  String get dataWeekdayFri => 'الجمعة';

  @override
  String get dataWeekdaySat => 'السبت';

  @override
  String get dataWeekdaySun => 'الأحد';

  @override
  String get dataMonthJan => 'يناير';

  @override
  String get dataMonthFeb => 'فبراير';

  @override
  String get dataMonthMar => 'مارس';

  @override
  String get dataMonthApr => 'أبريل';

  @override
  String get dataMonthMay => 'مايو';

  @override
  String get dataMonthJun => 'يونيو';

  @override
  String get dataMonthJul => 'يوليو';

  @override
  String get dataMonthAug => 'أغسطس';

  @override
  String get dataMonthSep => 'سبتمبر';

  @override
  String get dataMonthOct => 'أكتوبر';

  @override
  String get dataMonthNov => 'نوفمبر';

  @override
  String get dataMonthDec => 'ديسمبر';

  @override
  String get dataEventTitleVillageOuting => 'خرجة إلى القرية';

  @override
  String get dataEventTitleFamilyDinner => 'عشاء عائلي';

  @override
  String get dataEventTime4pm => '4:00 مساءً';

  @override
  String get dataEventTime8pm => '8:00 مساءً';

  @override
  String get dataTime930pm => '9:30 مساءً';

  @override
  String get dataPlaceKingSalmanPark => 'حديقة الملك سلمان';

  @override
  String get dataPlaceCafeAlDar => 'مقهى الدار';

  @override
  String get dataPlaceStrikeBowling => 'سترايك بولينج';

  @override
  String get dataPlaceSufratAlBayt => 'سفرة البيت';

  @override
  String get dataPlaceWhyPark => '4 من 6 أفراد العائلة يحبون هالنوع من الأماكن';

  @override
  String get dataPlaceWhyCafe => 'يناسب الكل، خيار موفق';

  @override
  String get dataPlaceWhyBowling => '3 من 6 يحبون الألعاب والأنشطة الجماعية';

  @override
  String get dataPlaceWhyRestaurant => 'أكل بيتي وجلسة عائلية';

  @override
  String get dataOutingTypeNature => 'الطبيعة';

  @override
  String get dataOutingTypeRestaurants => 'المطاعم';

  @override
  String get dataOutingTypeCafes => 'المقاهي';

  @override
  String get dataOutingTypeEntertainment => 'الترفيه';

  @override
  String get dataBadgeMostInteractive => 'الأكثر تفاعلًا';

  @override
  String get dataBadgeLammaSpirit => 'روح لمّه';

  @override
  String get dataBadgeWeeklyListener => 'مستمع الأسبوع';

  @override
  String get dataBadgeWeekWinner => 'بطل الأسبوع';

  @override
  String get dataBadgeTalksKing => 'ملك السوالف';

  @override
  String get dataBadgeReader => 'القارئ';

  @override
  String get dataAziz1 => 'وش أغرب أكلة جربتها بحياتك؟';

  @override
  String get dataAziz2 => 'أي رحلة ممكن تسويها مرة ثانية بكرة؟';

  @override
  String get dataAziz3 => 'وش الشي البسيط اللي يسعّد يومك؟';

  @override
  String get dataAziz4 => 'مين في العائلة يضحكك أكثر؟';

  @override
  String get dataSinJim1 => 'كم عمر جدك؟';

  @override
  String get dataSinJim2 => 'وش أكلة بابا المفضلة؟';

  @override
  String get dataSinJim3 => 'وش لون ماما المفضل؟';

  @override
  String get dataSinJim4 => 'مين أكثر واحد ينام في العائلة؟';

  @override
  String get dataTopic1 => 'لو تقدر تسافر لأي مكان الحين، وين بنروح؟';

  @override
  String get dataTopic2 => 'وش لحظة العائلة اللي ما تقدر تنساها؟';

  @override
  String get dataTopic3 => 'وش عادة لازم نبدأها هالسنة؟';

  @override
  String get dataTopic4 => 'وش الشي اللي ما حكيته لنا قبل؟';

  @override
  String get dataMomentCaptionSarah => 'طلعت اليوم مع البنات';

  @override
  String get dataMomentCaptionMohammed => 'استراحة مذاكرة في الكافيه';

  @override
  String get dataMomentCaptionAmina => 'قهوة جديدة وصباح هادئ';

  @override
  String get dataMomentCaptionAbdullah => 'مسا في المجلس';

  @override
  String get dataMomentCaptionYousef => 'ليقو الجديد حقي!';

  @override
  String get dataMomentCaptionNoura => 'أخبز مع ماما';

  @override
  String get dataTimeTodayAt410pm => 'اليوم، 4:10 مساءً';

  @override
  String get dataTimeTodayAt130pm => 'اليوم، 1:30 مساءً';

  @override
  String get dataTimeTodayAt815am => 'اليوم، 8:15 صباحًا';

  @override
  String get dataTimeYesterday => 'أمس';

  @override
  String get dataTimeToday => 'اليوم';

  @override
  String get dataTime2DaysAgo => 'قبل يومين';

  @override
  String get dataTalkSarah => 'وش تبون تاكلون يوم الخميس؟';

  @override
  String get dataTalkAmina => 'مين ينزل معاي للسوق؟';

  @override
  String get dataCommentAbdullah => 'حلو!';

  @override
  String get dataCommentAmina => 'الله يحفظكم';

  @override
  String get dataCommentMohammed => 'وديني وياكم';

  @override
  String get dataInterestCoffee => 'قهوة';

  @override
  String get dataInterestGames => 'ألعاب';

  @override
  String get dataInterestReading => 'قراءة';

  @override
  String get dataInterestWalking => 'مشي';

  @override
  String get dataInterestPodcasts => 'بودكاست';

  @override
  String get dataInterestMovies => 'أفلام';

  @override
  String get dataInterestCooking => 'طبخ';

  @override
  String get dataInterestDrawing => 'رسم';

  @override
  String get dataInterestFootball => 'كرة قدم';

  @override
  String get dataInterestSwimming => 'سباحة';

  @override
  String get dataInterestMusic => 'موسيقى';

  @override
  String get dataInterestTravel => 'سفر';

  @override
  String get dataFamilyFallback => 'عائلتك';

  @override
  String get dataFamilyDefault => 'عائلة العتيبي';

  @override
  String get leaderboardTitle => 'لوحة المتصدرين';

  @override
  String leaderboardCycleReward(String cycle) {
    return 'مكافأة $cycle';
  }

  @override
  String leaderboardLastWinner(String winner, String reward) {
    return 'الفائز: $winner · $reward';
  }

  @override
  String get leaderboardRanking => 'الترتيب';

  @override
  String leaderboardPts(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points نقطة',
      many: '$points نقطة',
      few: '$points نقاط',
      two: 'نقطتين',
      one: 'نقطة وحدة',
      zero: '0 نقطة',
    );
    return '$_temp0';
  }

  @override
  String get leaderboardNoWinnerYet => 'لا يوجد فائز بعد';

  @override
  String leaderboardRewardNow(String name) {
    return 'كافئ $name (الأول) الحين';
  }

  @override
  String leaderboardRewardSnackbar(String name, String reward) {
    return '$name يحصل على: $reward';
  }

  @override
  String get parentControlsPhoneFreeTime => 'وقت بدون جوال';

  @override
  String get parentControlsFrom => 'من';

  @override
  String get parentControlsUntil => 'إلى';

  @override
  String get parentControlsIfPhoneUsed => 'إذا أحد استخدم جواله';

  @override
  String get parentControlsLosePointsChoice => 'خصم نقاط';

  @override
  String get parentControlsPointsLost => 'النقاط المخصومة';

  @override
  String get parentControlsOrWriteOwn => 'أو اكتب عقوبتك';

  @override
  String get parentControlsRecordViolation => 'سجّل مخالفة جوال';

  @override
  String parentControlsTakeAwayPoints(int penalty) {
    String _temp0 = intl.Intl.pluralLogic(
      penalty,
      locale: localeName,
      other: 'اخصم $penalty نقطة',
      many: 'اخصم $penalty نقطة',
      few: 'اخصم $penalty نقاط',
      two: 'اخصم نقطتين',
      one: 'اخصم نقطة وحدة',
    );
    return '$_temp0';
  }

  @override
  String get parentControlsGivePunishment => 'طبّق العقوبة';

  @override
  String get parentControlsRecent => 'الأخيرة';

  @override
  String get parentControlsDone => 'تم';

  @override
  String get parentControlsLeaderboardReward => 'مكافأة لوحة المتصدرين';

  @override
  String get parentControlsWinningCycle => 'دورة الفوز';

  @override
  String get parentControlsRewardForWinner => 'مكافأة الفائز';

  @override
  String get parentControlsOrWriteOwnReward => 'أو اكتب مكافأتك';

  @override
  String parentControlsViolationSnackbar(
    String who,
    String kind,
    String detail,
  ) {
    return '$who: $kind ($detail)';
  }

  @override
  String get violationKindLostPoints => 'خصم نقاط';

  @override
  String get violationKindPunishment => 'عقوبة';

  @override
  String get dataCycleWeekly => 'أسبوعية';

  @override
  String get dataCycleMonthly => 'شهرية';

  @override
  String get dataTimeJustNow => 'الحين';

  @override
  String get dataPunishmentDishes => 'غسل الصحون';

  @override
  String get dataPunishmentNoGames => 'بدون ألعاب الليلة';

  @override
  String get dataPunishmentCleanRoom => 'ترتيب الغرفة';

  @override
  String get dataPunishmentEarlyBedtime => 'نوم بدري';

  @override
  String get dataPunishmentHelpCook => 'المساعدة في الطبخ';

  @override
  String get dataRewardDinnerPlace => 'يختار مكان عشاء العائلة';

  @override
  String get dataRewardMovie => 'يختار فلم ليلة السينما';

  @override
  String get dataRewardSkipChore => 'إعفاء من مهمة';

  @override
  String get dataRewardOuting => 'يختار خرجة نهاية الأسبوع';

  @override
  String get dataRewardGameTime => 'وقت إضافي للألعاب';

  @override
  String get chatSeedSarahCooking => 'وش بنطبخ الليلة؟';

  @override
  String get chatSeedMeGoPark => 'يلا نروح الحديقة!';

  @override
  String get chatSeedAminaDinner => 'العشاء بيجهز الحين';

  @override
  String get chatSeedMeComing => 'جاي!';
}
