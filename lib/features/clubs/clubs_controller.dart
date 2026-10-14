// Single source of truth for the Clubs feature (book club + podcast club).
// Shared, in-memory, observable state: the Activities-page preview cards
// and the ClubsScreen both read (and write) through this controller, so a
// change in one place is reflected in the other immediately.

import 'package:flutter/material.dart';

import '../../backend/backend.dart';
import '../../data.dart' as app;
import '../../widgets/podcast_listen.dart' show fahemAppleUrl;
import '../../screens/activities_colors.dart';
import '../notifications/notification_events.dart';
import '../notifications/notifications_controller.dart';

class Book {
  final String title, author, category, about;
  final int votes;
  final int totalPages;
  final Color coverColor, inkColor, subColor;
  const Book({
    required this.title,
    required this.author,
    required this.category,
    required this.about,
    required this.votes,
    this.totalPages = 0,
    required this.coverColor,
    required this.inkColor,
    required this.subColor,
  });
}

/// A family member, and (depending on context) their reading progress for
/// the book of the month or whether they've heard the week's episode.
class ClubReader {
  final String initial, name;
  final int percent;
  final Color color;
  final bool isMe;
  const ClubReader({
    required this.initial,
    required this.name,
    required this.percent,
    required this.color,
    this.isMe = false,
  });

  ClubReader copyWith({int? percent}) => ClubReader(
    initial: initial,
    name: name,
    percent: percent ?? this.percent,
    color: color,
    isMe: isMe,
  );
}

/// A book the family already finished together.
class ReadBeforeEntry {
  final String title, author, note;
  final int completed, total;
  final Color coverColor;
  const ReadBeforeEntry({
    required this.title,
    required this.author,
    required this.note,
    required this.completed,
    required this.total,
    required this.coverColor,
  });
}

/// A podcast episode shared with the family.
class PodcastEpisode {
  final String host, platform, title, duration, about, youtubeUrl;
  final String? appleUrl;
  const PodcastEpisode({
    required this.host,
    required this.platform,
    required this.title,
    required this.duration,
    required this.about,
    required this.youtubeUrl,
    this.appleUrl,
  });
}

/// A candidate podcast for next week.
class PodcastSuggestion {
  final String title, note, about;
  final int votes;
  final Color iconColor;

  /// The channel's picture, and where to listen (null: a search is used instead).
  final String? logo, youtubeUrl, appleUrl;
  const PodcastSuggestion({
    required this.title,
    required this.note,
    this.about = '',
    required this.votes,
    required this.iconColor,
    this.logo,
    this.youtubeUrl,
    this.appleUrl,
  });
}

/// The day/time of a club's recurring discussion session, plus whether a
/// reminder is set for it.
class ClubDiscussion {
  final String dayName, dayNumber, time;
  final bool reminderOn;
  const ClubDiscussion({
    required this.dayName,
    required this.dayNumber,
    required this.time,
    this.reminderOn = false,
  });

  ClubDiscussion copyWith({bool? reminderOn}) => ClubDiscussion(
    dayName: dayName,
    dayNumber: dayNumber,
    time: time,
    reminderOn: reminderOn ?? this.reminderOn,
  );
}

/// Cover (bg, ink, sub) triples cycled for books/podcasts added through
/// the suggestion form.
const suggestionCoverPalette = <(Color, Color, Color)>[
  (AC.navy, Colors.white, AC.heroDescText),
  (AC.mustard, AC.navy, AC.lettersDesc),
  (AC.gamesTeal, Colors.white, AC.tealTint),
];

/// Shared, observable state for both clubs. Lives above [MaterialApp] (see
/// `main.dart`), so the Activities page and ClubsScreen — which sit under
/// different nested Navigators — always read the same instance.
class ClubsController extends ChangeNotifier {
  final NotificationsController? _notifications;

  ClubsController({this._notifications}) {
    // redraw whenever the family's shared data was refreshed from the database
    app.sharedTick.addListener(notifyListeners);
  }

  @override
  void dispose() {
    app.sharedTick.removeListener(notifyListeners);
    super.dispose();
  }

  /// "باقي X أيام على نقاش …": the title and days come from the current book.
  void announceDiscussionReminder({DateTime? at, bool announce = true}) {
    _notifications?.add(
      NotificationEvents.clubReminder(
        bookTitle: _currentBook.title,
        daysLeft: _daysLeft,
        at: at ?? DateTime.now(),
      ),
      announce: announce,
    );
  }

  // ===================== shared household roster =====================

  /// Household size, shared by both clubs (there's one family).
  int get memberCount => _bookMembers.length;

  // =========================== book club ==============================

  final Book _currentBook = const Book(
    title: 'العادات الذرية',
    author: 'جيمس كلير',
    category: 'تطوير الذات',
    about:
        'كتاب يشرح كيف نبني عادات صغيرة تتراكم وتغيّر حياتنا على المدى الطويل، '
        'عن طريق تحسينات بسيطة ١٪ كل يوم. مناسب نقرأه مع بعض لأنه يفتح لنا '
        'نقاش عن العادات اللي نبي نبنيها كعائلة، وكيف نشجّع بعض عليها.',
    votes: 0,
    totalPages: 300,
    coverColor: AC.mustard,
    inkColor: AC.navy,
    subColor: AC.lettersDesc,
  );
  Book get currentBook => _currentBook;

  final int _daysLeft = 5;
  int get daysLeft => _daysLeft;

  /// The signed-in person's own reading progress (0-100). It is the only real number here.
  int _myPercent = 60;

  /// Stand-in progress for the other family members, until reading progress is saved
  /// in the database. The people themselves are the app's real family members.
  static const _samplePercents = [100, 100, 100, 35, 10, 80];

  bool _isMe(app.Member m) =>
      m.id != null ? m.id == app.profile.memberId : m.name == app.profile.name;

  List<ClubReader> get _bookMembers {
    var k = 0;
    return [
      for (final m in app.members)
        ClubReader(
          initial: m.name.isEmpty ? '' : m.name.characters.first,
          name: m.name,
          percent: _isMe(m)
              ? _myPercent
              : _samplePercents[k++ % _samplePercents.length],
          color: AC.sage,
          isMe: _isMe(m),
        ),
    ];
  }

  List<ClubReader> get bookMembers => List.unmodifiable(_bookMembers);

  ClubDiscussion _bookDiscussion = const ClubDiscussion(
    dayName: 'الخميس',
    dayNumber: '29',
    time: 'بعد العشاء · 9:00 م',
  );
  ClubDiscussion get bookDiscussion => _bookDiscussion;

  List<Book> _bookSuggestions = const [
    Book(
      title: 'عندما التقيت عمر بن الخطاب',
      author: 'أدهم شرقاوي',
      category: 'سيرة وتاريخ إسلامي',
      about: '',
      votes: 4,
      coverColor: AC.navy,
      inkColor: Colors.white,
      subColor: AC.heroDescText,
    ),
    Book(
      title: 'مع الناس',
      author: 'علي الطنطاوي',
      category: 'أدب ومقالات',
      about: '',
      votes: 3,
      coverColor: AC.brick,
      inkColor: Colors.white,
      subColor: AC.salmonTint,
    ),
    Book(
      title: 'الرجل النبيل',
      author: 'علي الفيفي',
      category: 'أخلاق وفن التعامل',
      about: '',
      votes: 2,
      coverColor: AC.gamesTeal,
      inkColor: Colors.white,
      subColor: AC.tealTint,
    ),
    Book(
      title: 'مُت فارغًا',
      author: 'تود هنري',
      category: 'تطوير الذات',
      about: '',
      votes: 2,
      coverColor: AC.mustardTint,
      inkColor: AC.ink,
      subColor: AC.muted,
    ),
    Book(
      title: 'محاط بالحمقى',
      author: 'توماس إريكسون',
      category: 'تطوير الذات',
      about: '',
      votes: 1,
      coverColor: AC.salmon,
      inkColor: AC.ink,
      subColor: AC.salmonCoverSub,
    ),
  ];
  List<Book> get bookSuggestions => List.unmodifiable(_bookSuggestions);

  final Set<int> _bookVotes = {};
  Set<int> get bookVotes => Set.unmodifiable(_bookVotes);

  final List<ReadBeforeEntry> _readBefore = const [
    ReadBeforeEntry(
      title: 'فاتتني صلاة',
      author: 'إسلام جمال',
      note: 'قرأناه الشهر الماضي',
      completed: 6,
      total: 6,
      coverColor: AC.gamesTeal,
    ),
    ReadBeforeEntry(
      title: 'حياة في الإدارة',
      author: 'غازي القصيبي',
      note: 'قبل شهرين',
      completed: 5,
      total: 6,
      coverColor: AC.mustard,
    ),
  ];
  List<ReadBeforeEntry> get readBefore => List.unmodifiable(_readBefore);

  ClubReader get _me => _bookMembers.firstWhere(
    (m) => m.isMe,
    orElse: () => ClubReader(
      initial: '',
      name: app.profile.name,
      percent: _myPercent,
      color: AC.sage,
      isMe: true,
    ),
  );

  /// 0..1. The signed-in member's own reading progress.
  double get myBookProgress => _me.percent / 100;

  /// How many members have finished the book of the month.
  int get finishedCount => _bookMembers.where((m) => m.percent >= 100).length;

  /// 0..1 average progress across the whole household.
  double get groupProgress {
    if (_bookMembers.isEmpty) return 0;
    final sum = _bookMembers.fold<double>(0, (s, m) => s + m.percent / 100);
    return sum / _bookMembers.length;
  }

  /// Pages left for *me* to finish the current book, rounded.
  int get myPagesLeft =>
      (_currentBook.totalPages * (1 - myBookProgress)).round();

  void updateMyProgress(double progress) {
    final was = _myPercent;
    _myPercent = (progress.clamp(0, 1) * 100).round();
    // finishing the book counts like any other "first one done"
    if (was < 100 && _myPercent >= 100)
      app.claimFirst('book', app.profile.name);
    if (was >= 100 && _myPercent < 100)
      app.revokeFirst('book', app.profile.name);
    notifyListeners();
  }

  void toggleBookVote(int id) {
    if (!_bookVotes.add(id)) _bookVotes.remove(id);
    notifyListeners();
  }

  void addBookSuggestion({
    required String title,
    required String author,
    required String category,
    required String about,
  }) {
    final palette =
        suggestionCoverPalette[_bookSuggestions.length %
            suggestionCoverPalette.length];
    _bookSuggestions = [
      ..._bookSuggestions,
      Book(
        title: title,
        author: author,
        category: category,
        about: about,
        votes: 0,
        coverColor: palette.$1,
        inkColor: palette.$2,
        subColor: palette.$3,
      ),
    ];
    _bookVotes.add(_bookSuggestions.length - 1);
    notifyListeners();
  }

  void toggleBookReminder() {
    _bookDiscussion = _bookDiscussion.copyWith(
      reminderOn: !_bookDiscussion.reminderOn,
    );
    notifyListeners();
  }

  // ========================== podcast club =============================

  final PodcastEpisode _currentEpisode = const PodcastEpisode(
    host: 'أمجد سمير',
    platform: 'يوتيوب',
    title: 'التحرر من التشتت',
    duration: '117 دقيقة',
    about:
        'حلقة عن استعادة التركيز وسط الجوالات والتنبيهات. اخترناها لأنها تفتح '
        'سالفة: كيف نرجع نحضر مع بعض فعلًا وقت الجلسة؟',
    youtubeUrl: 'https://youtu.be/f0AHyAhNulc',
    appleUrl: fahemAppleUrl,
  );
  PodcastEpisode get currentEpisode => _currentEpisode;

  /// Other members who've already heard the week's episode (mirrors the
  /// book club's member → color convention). Whether *I* heard it is
  /// tracked separately in [iHeard].
  List<ClubReader> get _heardBy => [
    // connected: the family members who really marked it; offline: a few sample people
    for (final m in app.members.where(
      (m) =>
          !_isMe(m) &&
          (app.sharedLive
              ? app.finishersOf('podcast').contains(m.name)
              : false),
    ))
      ClubReader(
        initial: m.name.isEmpty ? '' : m.name.characters.first,
        name: m.name,
        percent: 100,
        color: AC.sage,
      ),
    if (!app.sharedLive)
      for (final m in app.members.where((m) => !_isMe(m)).take(3))
        ClubReader(
          initial: m.name.isEmpty ? '' : m.name.characters.first,
          name: m.name,
          percent: 100,
          color: AC.sage,
        ),
  ];
  List<ClubReader> get heardBy => List.unmodifiable(_heardBy);

  bool get iHeard => app.finishersOf('podcast').contains(app.profile.name);

  /// How many members (others + me) have heard the week's episode.
  int get heardCount => _heardBy.length + (iHeard ? 1 : 0);

  /// How many questions come built in; anything after them was added by a member.
  static const defaultQuestionCount = 3;
  static const _baseQuestions = [
    'وش أكثر شي يشتّتنا وحنا جالسين مع بعض؟',
    'وش رأيكم نخلي جلسة العشاء بدون جوالات؟',
    'وش عادة وحدة نبدأ فيها هالأسبوع؟',
  ];
  final List<String> _localQuestions =
      []; // used while the database is not connected
  List<String> get questions => List.unmodifiable([
    ..._baseQuestions,
    ...(app.sharedLive ? app.sharedQuestions : _localQuestions),
  ]);

  void addDiscussionQuestion(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (app.sharedLive) {
      Backend.addQuestion(
        trimmed,
      ); // shared with the family; the refresh redraws the list
    } else {
      _localQuestions.add(trimmed);
    }
    notifyListeners();
  }

  ClubDiscussion _podDiscussion = const ClubDiscussion(
    dayName: 'الخميس',
    dayNumber: '15',
    time: 'على القهوة · 5:00 م',
  );
  ClubDiscussion get podDiscussion => _podDiscussion;

  static const _fenjanApple =
      'https://podcasts.apple.com/sa/podcast/%D9%81%D9%86%D8%AC%D8%A7%D9%86-%D9%85%D8%B9-%D8%B9%D8%A8%D8%AF%D8%A7%D9%84%D8%B1%D8%AD%D9%85%D9%86-%D8%A3%D8%A8%D9%88%D9%85%D8%A7%D9%84%D8%AD/id985515827';

  List<PodcastSuggestion> _podSuggestions = const [
    PodcastSuggestion(
      title: 'كيف تنجح العلاقات',
      note: 'ياسر الحزيمي · يوتيوب',
      votes: 4,
      iconColor: AC.brick,
      logo: 'assets/podcast/channels/fenjan.jpg',
      youtubeUrl: 'https://youtu.be/pJ0auP7dbcY',
      appleUrl: _fenjanApple,
    ),
    PodcastSuggestion(
      title: 'فنجان',
      note: 'ثمانية · حوارات طويلة',
      votes: 2,
      iconColor: AC.navy,
      logo: 'assets/podcast/channels/fenjan.jpg',
      youtubeUrl: 'https://www.youtube.com/@thmanyahPodcasts',
      appleUrl: _fenjanApple,
    ),
    PodcastSuggestion(
      title: 'أسمار',
      note: 'ثمانية · قصص وحكايات',
      votes: 1,
      iconColor: AC.gamesTeal,
      logo: 'assets/podcast/channels/asmar.jpg',
      appleUrl: 'https://podcasts.apple.com/sa/podcast/%D8%A3%D8%B3%D9%85%D8%A7%D8%B1/id1482564772',
    ),
  ];
  List<PodcastSuggestion> get podSuggestions =>
      List.unmodifiable(_podSuggestions);

  final Set<int> _podVotes = {};
  Set<int> get podVotes => Set.unmodifiable(_podVotes);

  /// Marks the episode as heard (or not) for me. Heard counts as finishing it: the first person in the
  /// family gets the most points. Returns the points earned.
  Future<int> markHeard(bool heard) async {
    var pts = 0;
    if (heard) {
      pts = await app.claimFirst('podcast', app.profile.name);
    } else {
      await app.revokeFirst('podcast', app.profile.name);
    }
    notifyListeners();
    return pts;
  }

  void toggleHeard() => markHeard(!iHeard);

  void togglePodVote(int id) {
    if (!_podVotes.add(id)) _podVotes.remove(id);
    notifyListeners();
  }

  void addPodSuggestion({
    required String title,
    required String note,
    required String about,
  }) {
    _podSuggestions = [
      ..._podSuggestions,
      PodcastSuggestion(
        title: title,
        note: note,
        about: about,
        votes: 0,
        iconColor: AC.gamesTeal,
      ),
    ];
    _podVotes.add(_podSuggestions.length - 1);
    notifyListeners();
  }

  void togglePodReminder() {
    _podDiscussion = _podDiscussion.copyWith(
      reminderOn: !_podDiscussion.reminderOn,
    );
    notifyListeners();
  }
}
