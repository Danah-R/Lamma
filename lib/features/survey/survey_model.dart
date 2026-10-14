/// What the monthly survey asks about: the app's features, and the games.
const surveyFeatures = [
  'chat',
  'moments',
  'games',
  'podcast',
  'book',
  'topics',
  'outings',
  'calendar',
  'points',
];
const surveyGames = ['whoami', 'charades', 'seen', 'roulette'];

/// "none": nothing from this month (an answer in itself, so it clears the other picks).
const surveyNone = 'none';

/// One person's answers for one month. People are stored by name, features and games by id.
class SurveyAnswers {
  final Set<String> closest = {}; // who I got closest to
  final Set<String> wantCloser = {}; // who I want to get closer to
  final Set<String> liked = {}; // app features I enjoyed
  final Set<String> disliked = {}; // app features I did not enjoy
  final Set<String> outings = {}; // outings I enjoyed most
  final Set<String> games = {}; // games I enjoyed most
  int? closeness; // 1 to 5: how close I felt to my family this month
  String comment = '';

  bool get isEmpty =>
      closest.isEmpty &&
      wantCloser.isEmpty &&
      liked.isEmpty &&
      disliked.isEmpty &&
      outings.isEmpty &&
      games.isEmpty &&
      closeness == null &&
      comment.trim().isEmpty;

  Map<String, dynamic> toJson() => {
    'closest': closest.toList(),
    'want_closer': wantCloser.toList(),
    'liked': liked.toList(),
    'disliked': disliked.toList(),
    'outings': outings.toList(),
    'games': games.toList(),
    'closeness': closeness,
    'comment': comment.trim(),
  };
}

/// "2026-10": the month a survey belongs to.
String surveyMonthKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
