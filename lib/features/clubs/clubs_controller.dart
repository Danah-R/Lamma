// Single source of truth for the Clubs feature (book club + podcast club).
// Shared, in-memory, observable state: the Activities-page preview cards
// and the ClubsScreen both read (and write) through this controller, so a
// change in one place is reflected in the other immediately.

import 'package:flutter/material.dart';

import '../../screens/activities_colors.dart';

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
  final String? url;
  const PodcastSuggestion({
    required this.title,
    required this.note,
    this.about = '',
    required this.votes,
    required this.iconColor,
    this.url,
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

  List<ClubReader> _bookMembers = const [
    ClubReader(initial: 'م', name: 'محمد', percent: 100, color: AC.brick),
    ClubReader(initial: 'س', name: 'سارة', percent: 100, color: AC.navy),
    ClubReader(initial: 'آ', name: 'آمنة', percent: 100, color: AC.teal),
    ClubReader(
      initial: 'أ',
      name: 'أنت',
      percent: 60,
      color: AC.mustard,
      isMe: true,
    ),
    ClubReader(initial: 'ي', name: 'يوسف', percent: 35, color: AC.sage),
    ClubReader(initial: 'ن', name: 'نوف', percent: 10, color: AC.salmon),
  ];
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

  ClubReader get _me => _bookMembers.firstWhere((m) => m.isMe);

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
    final i = _bookMembers.indexWhere((m) => m.isMe);
    if (i == -1) return;
    final percent = (progress.clamp(0, 1) * 100).round();
    _bookMembers = [
      for (var j = 0; j < _bookMembers.length; j++)
        if (j == i)
          _bookMembers[j].copyWith(percent: percent)
        else
          _bookMembers[j],
    ];
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
    duration: 'ساعتين',
    about:
        'حلقة عن استعادة التركيز وسط الجوالات والتنبيهات. اخترناها لأنها تفتح '
        'سالفة: كيف نرجع نحضر مع بعض فعلًا وقت الجلسة؟',
    youtubeUrl: 'https://youtu.be/f0AHyAhNulc',
  );
  PodcastEpisode get currentEpisode => _currentEpisode;

  /// Other members who've already heard the week's episode (mirrors the
  /// book club's member → color convention). Whether *I* heard it is
  /// tracked separately in [iHeard].
  final List<ClubReader> _heardBy = const [
    ClubReader(initial: 'م', name: 'محمد', percent: 100, color: AC.brick),
    ClubReader(initial: 'س', name: 'سارة', percent: 100, color: AC.navy),
    ClubReader(initial: 'آ', name: 'آمنة', percent: 100, color: AC.teal),
  ];
  List<ClubReader> get heardBy => List.unmodifiable(_heardBy);

  bool _iHeard = false;
  bool get iHeard => _iHeard;

  /// How many members (others + me) have heard the week's episode.
  int get heardCount => _heardBy.length + (_iHeard ? 1 : 0);

  List<String> _questions = const [
    'وش أكثر شي يشتّتنا وحنا جالسين مع بعض؟',
    'وش رأيكم نخلي جلسة العشاء بدون جوالات؟',
    'وش عادة وحدة نبدأ فيها هالأسبوع؟',
  ];
  List<String> get questions => List.unmodifiable(_questions);

  void addDiscussionQuestion(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _questions = [..._questions, trimmed];
    notifyListeners();
  }

  ClubDiscussion _podDiscussion = const ClubDiscussion(
    dayName: 'الخميس',
    dayNumber: '15',
    time: 'على القهوة · 5:00 م',
  );
  ClubDiscussion get podDiscussion => _podDiscussion;

  List<PodcastSuggestion> _podSuggestions = const [
    PodcastSuggestion(
      title: 'كيف تنجح العلاقات',
      note: 'ياسر الحزيمي · يوتيوب',
      votes: 4,
      iconColor: AC.brick,
      url: 'https://youtu.be/pJ0auP7dbcY',
    ),
    PodcastSuggestion(
      title: 'فنجان',
      note: 'ثمانية · حوارات طويلة',
      votes: 2,
      iconColor: AC.navy,
    ),
    PodcastSuggestion(
      title: 'أسمار',
      note: 'ثمانية · قصص وحكايات',
      votes: 1,
      iconColor: AC.gamesTeal,
    ),
  ];
  List<PodcastSuggestion> get podSuggestions =>
      List.unmodifiable(_podSuggestions);

  final Set<int> _podVotes = {};
  Set<int> get podVotes => Set.unmodifiable(_podVotes);

  void toggleHeard() {
    _iHeard = !_iHeard;
    notifyListeners();
  }

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
