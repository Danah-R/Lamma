import 'package:flutter/material.dart';

import 'theme.dart';

const _dir = 'assets/characters/';

/// The six family characters from the character sheet.
const characters = <(String name, String asset)>[
  ('Sister', '${_dir}sister.jpg'),
  ('Big brother', '${_dir}big_brother.jpg'),
  ('Father', '${_dir}father.jpg'),
  ('Mother', '${_dir}mother.jpg'),
  ('Little girl', '${_dir}girl.jpg'),
  ('Son', '${_dir}son.jpg'),
];

/// Where each character's head starts (fraction of the picture's height) and the colour of
/// its backdrop at the top edge. Used to frame the face with some empty space above the head.
const characterFraming = <String, (double hairTop, Color backdrop)>{
  '${_dir}sister.jpg': (0.043, Color(0xFFCCA076)),
  '${_dir}big_brother.jpg': (0.113, Color(0xFFCEB08D)),
  '${_dir}father.jpg': (0.068, Color(0xFFBB9D80)),
  '${_dir}mother.jpg': (0.033, Color(0xFFB99672)),
  '${_dir}girl.jpg': (0.028, Color(0xFFD0A67E)),
  '${_dir}son.jpg': (0.030, Color(0xFFCCA983)),
};
const familyScene = '${_dir}family_scene.jpg';

class Member {
  final String key, name, role, asset;
  final String?
  id; // the member row in the database (null for the offline sample family)
  final int age;
  int points;
  final bool? parent; // from the database; null means "decide from the role"
  Member(
    this.key,
    this.name,
    this.role,
    this.age,
    this.asset,
    this.points, {
    this.id,
    this.parent,
  });
  bool get isParent => parent ?? (key == 'mom' || key == 'dad');
}

/// Sample family. The person using the app takes over the slot matching their role.
final members = <Member>[
  // same people and order as the shared family list in data/family_members.dart
  Member('brother', 'محمد', 'Son', 19, characters[1].$2, 245),
  Member('girl', 'سارة', 'Daughter', 8, characters[4].$2, 280),
  Member(
    'mom',
    'أمينة',
    'Mom',
    44,
    characters[0].$2,
    120,
  ), // Amina has the Sister picture
  Member('boy', 'يوسف', 'Son', 6, characters[5].$2, 160),
  Member(
    'daughter',
    'نورة',
    'Daughter',
    16,
    characters[3].$2,
    210,
  ), // Noura has the Mother picture
  Member('dad', 'عبدالله', 'Dad', 47, characters[2].$2, 90),
];

/// Name of the family member holding a role key (mom, dad, daughter, brother, girl, boy).
String n(String key) =>
    members.where((m) => m.key == key).firstOrNull?.name ??
    members.firstOrNull?.name ??
    '';

void addPoints(String name, int delta) {
  for (final m in members) {
    if (m.name == name) m.points = (m.points + delta).clamp(0, 99999);
  }
}

/// Set once the app is connected to the family's database: from then on, points, claims, events,
/// moments, rules and questions are shared with the rest of the family.
bool sharedLive = false;

/// A topic someone in the family wants to talk about (shared through the database).
class FamilyTopic {
  final String id, text;
  final String? authorId; // the member row of whoever added it
  final bool discussed;
  const FamilyTopic(this.id, this.text, this.authorId, this.discussed);
}

/// Everyone's topics, oldest first (empty until the family is connected).
List<FamilyTopic> sharedTopics = const [];

/// Outings the family suggested (names), on top of the built-in places.
List<String> suggestedOutings = const [];

/// Questions the family added to the podcast club (after the built-in ones).
List<String> sharedQuestions = const [];

/// Bumped every time shared data was refreshed from the database, so screens can redraw.
final sharedTick = ValueNotifier<int>(0);

/// Talks to the database (set by Backend.init). Each returns the database's answer, or null when
/// it could not be reached, in which case the app falls back to its local copy.
Future<Map<String, dynamic>?> Function(String key)? remoteClaim;
Future<Map<String, dynamic>?> Function(String key)? remoteRevoke;
Future<void> Function(String memberId, int delta)? remoteAdjust;
Future<void> Function(String memberId, int points)? remoteAward;
void Function()? remoteSaveRules;
Future<void> Function()? remotePhoneFreeDone;

/// "First come, most points": the first person to finish something gets the most, the next
/// a little less, and so on. [key] names what was done (one podcast episode, one event, ...).
/// With the database connected the race is decided there, so it is shared by the whole family.
const firstComePoints = [
  20,
  15,
  10,
]; // 1st, 2nd, 3rd; everyone after gets [laterPoints]
const laterPoints = 5;
final _finishers = <String, List<String>>{}; // key -> names, first to last
final _earned = <String, Map<String, int>>{};

/// Who finished [key], first to last.
List<String> finishersOf(String key) =>
    List.unmodifiable(_finishers[key] ?? const <String>[]);

/// Replaces the local ledger with the family's (after a refresh from the database).
void setFinishers(Map<String, List<String>> byKey) {
  _finishers
    ..clear()
    ..addAll({
      for (final e in byKey.entries) e.key: [...e.value],
    });
}

/// Records that [name] finished [key] and gives the points for their place.
/// Returns the points earned (0 if they were already counted).
Future<int> claimFirst(String key, String name) async {
  final list = _finishers.putIfAbsent(key, () => []);
  if (list.contains(name)) return 0;
  final remote = remoteClaim;
  final r = remote == null ? null : await remote(key);
  if (list.contains(name)) return 0;
  int pts;
  if (r != null) {
    if (r['already'] == true) {
      if (!list.contains(name)) list.add(name);
      return 0;
    }
    pts = (r['points'] as num).toInt();
  } else {
    // offline: work it out here
    pts = list.length < firstComePoints.length
        ? firstComePoints[list.length]
        : laterPoints;
  }
  list.add(name);
  _earned.putIfAbsent(key, () => {})[name] = pts;
  addPoints(name, pts);
  return pts;
}

/// Takes back a claim (for example an accidental tap) together with its points.
Future<void> revokeFirst(String key, String name) async {
  final list = _finishers[key];
  if (list == null || !list.remove(name)) return;
  final remote = remoteRevoke;
  final r = remote == null ? null : await remote(key);
  final pts = r != null
      ? (r['points'] as num?)?.toInt() ?? 0
      : (_earned[key]?.remove(name) ?? 0);
  _earned[key]?.remove(name);
  addPoints(name, -pts);
}

/// Points a family member earns in a game (a right answer, winning). Shared like the rest.
Future<void> awardPoints(String name, int points) async {
  addPoints(name, points);
  final id = members.where((m) => m.name == name).firstOrNull?.id;
  final remote = remoteAward;
  if (id != null && remote != null) await remote(id, points);
}

/// Parents adding or removing points (penalties, corrections). Shared like everything else.
Future<void> adjustPoints(String name, int delta) async {
  addPoints(name, delta);
  final id = members.where((m) => m.name == name).firstOrNull?.id;
  final remote = remoteAdjust;
  if (id != null && remote != null) await remote(id, delta);
}

/// A key part that changes every day, for things that can be done once a day.
String get dayKey => '${today.year}-${today.month}-${today.day}';

String? avatarAsset(String name) {
  for (final m in members) {
    if (m.name == name) return m.asset;
  }
  return null;
}

/// Filled in during onboarding.
class Profile {
  String phone = '';
  String family = 'Al-Otaibi family';
  String familyCode = 'LAMMA-48';
  String name = 'نورة';
  String role = 'daughter'; // mom, dad, daughter, brother
  int age = 16;
  String job = 'Student';
  bool livesWithFamily = true;
  Set<String> interests = {'Coffee', 'Games', 'Reading', 'Walking', 'Podcasts'};
  Set<String> outingTypes = {'Nature', 'Cafés'};
  String prefer = 'Games';
  int avatar = 0;
  String? memberId; // set once the profile lives in the database
  bool? parent; // from the database; null means "decide from the role"
  bool get isParent => parent ?? (role == 'mom' || role == 'dad');
}

final profile = Profile();

class Ev {
  final String? id; // the database row (null for local-only events)
  final String title, time, type;
  final DateTime date;
  final Color color;
  final List<String> going;
  Ev(
    this.title,
    this.date,
    this.time,
    this.type,
    this.color,
    this.going, {
    this.id,
  });
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
String weekdayName(DateTime d) => _weekdays[d.weekday - 1];
String monthName(DateTime d) => _months[d.month - 1];
String dateLabel(DateTime d) => '${weekdayName(d)}, ${monthName(d)} ${d.day}';
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
DateTime get today => DateTime.now();

const eventTypes = [
  'Gathering',
  'Outing',
  'Dinner',
  'Games',
  'Trip',
  'Movie',
  'Occasion',
];

final events = <Ev>[];

class Moment {
  final String? id;
  final String who, caption, time;
  final Color a, b;
  int likes, comments;
  bool liked = false;
  Moment(
    this.who,
    this.caption,
    this.time,
    this.a,
    this.b,
    this.likes,
    this.comments, {
    this.id,
  });
}

final moments = <Moment>[];

class Talk {
  final String who, text, time;
  int likes, comments;
  Talk(this.who, this.text, this.time, this.likes, this.comments);
}

final talks = <Talk>[];
final comments = <(String, String)>[];

class Place {
  final String name, type, why;
  final IconData icon;
  final Color color;
  const Place(this.name, this.type, this.why, this.icon, this.color);
}

const places = <Place>[
  Place(
    'King Salman Park',
    'Nature',
    '4 of 6 family members like this type of place',
    Icons.park_rounded,
    C.sage,
  ),
  Place(
    'Café Al-Dar',
    'Cafés',
    'Suits everyone, a good choice',
    Icons.coffee_rounded,
    C.peach,
  ),
  Place(
    'Strike Bowling',
    'Entertainment',
    '3 of 6 love games and group activities',
    Icons.sports_score_rounded,
    C.lavender,
  ),
  Place(
    'Sufrat Al-Bayt',
    'Restaurants',
    'Homestyle food and family seating',
    Icons.restaurant_rounded,
    C.yellow,
  ),
];
final ourOutings = <Place>[];

const badges = <(String, IconData, Color, bool)>[
  ('Weekly listener', Icons.headphones_rounded, C.teal, true),
  ('Week winner', Icons.military_tech_rounded, C.navy, true),
  ('Reader', Icons.menu_book_rounded, C.inkSoft, true),
  ('Talks king', Icons.forum_rounded, C.brick, true),
];

/// Pictures for the badges that have one (the others use an icon).
const badgeImages = <String, String>{
  'Reader': 'assets/badges/reader.jpg',
  'Talks king': 'assets/badges/talks_king.jpg',
  'Weekly listener': 'assets/badges/listener.jpg',
  'Week winner': 'assets/badges/winner.jpg',
};

const azizQuestions = [
  "What's the strangest food you've ever tried?",
  'Which trip would you repeat tomorrow?',
  "What's a small thing that makes your day?",
  'Who in the family makes you laugh the most?',
];
const sinJimQuestions = [
  'How old is your grandfather?',
  "What's Dad's favorite dish?",
  "What's Mom's favorite color?",
  'Who is the biggest sleeper in the family?',
];
const topics = [
  'If you could travel anywhere now, where would we go?',
  "What's the family moment you'd never forget?",
  'What tradition should we start this year?',
  "What's one thing you've never told us?",
];

/// Parent controls: phone-free time, consequences and leaderboard rewards.
class Violation {
  final String who, kind, detail, when;
  bool done = false;
  Violation(this.who, this.kind, this.detail, this.when);
}

class Rules {
  bool phoneFree = true;
  TimeOfDay from = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay to = const TimeOfDay(hour: 21, minute: 30);
  bool _wasActive = false;

  /// True only while the switch is on AND the clock is inside the window
  /// (a window can run past midnight, e.g. 22:00 to 01:00).
  bool isActiveAt(DateTime now) {
    if (!phoneFree) return false;
    final m = now.hour * 60 + now.minute;
    final a = from.hour * 60 + from.minute, b = to.hour * 60 + to.minute;
    return a <= b ? (m >= a && m < b) : (m >= a || m < b);
  }

  /// Call every now and then. Once a running window ends, the switch turns itself off,
  /// so parents turn it on again for the next time. Returns true when something changed.
  bool tick(DateTime now) {
    final active = isActiveAt(now);
    var changed = active != _wasActive;
    if (_wasActive && !active && phoneFree) {
      phoneFree = false; // the time is up
      remotePhoneFreeDone?.call(); // and for everyone else in the family
      changed = true;
    }
    _wasActive = active;
    return changed;
  }

  String consequence = 'points'; // 'points' or 'punishment'
  int penalty = 10;
  String punishment = 'Wash the dishes';
  String cycle = 'Weekly'; // 'Weekly' or 'Monthly'
  String reward = 'Choose the family dinner place';
  String? lastWinner, lastReward;
  final violations = <Violation>[];
  final punishments = <String, String>{}; // member name -> active punishment

  String _hm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  TimeOfDay _parse(String? v, TimeOfDay fallback) {
    final p = v?.split(':');
    if (p == null || p.length != 2) return fallback;
    return TimeOfDay(
      hour: int.tryParse(p[0]) ?? fallback.hour,
      minute: int.tryParse(p[1]) ?? fallback.minute,
    );
  }

  /// What is stored in the database for the family.
  Map<String, dynamic> toJson() => {
    'phoneFree': phoneFree,
    'from': _hm(from),
    'to': _hm(to),
    'consequence': consequence,
    'penalty': penalty,
    'punishment': punishment,
    'cycle': cycle,
    'reward': reward,
    'lastWinner': lastWinner,
    'lastReward': lastReward,
    'punishments': punishments,
    'violations': [
      for (final v in violations.take(30))
        {
          'who': v.who,
          'kind': v.kind,
          'detail': v.detail,
          'when': v.when,
          'done': v.done,
        },
    ],
  };

  /// Applies what the database holds (an empty document leaves the defaults).
  void applyJson(Map<String, dynamic> j) {
    if (j.isEmpty) return;
    phoneFree = j['phoneFree'] as bool? ?? phoneFree;
    from = _parse(j['from'] as String?, from);
    to = _parse(j['to'] as String?, to);
    consequence = j['consequence'] as String? ?? consequence;
    penalty = (j['penalty'] as num?)?.toInt() ?? penalty;
    punishment = j['punishment'] as String? ?? punishment;
    cycle = j['cycle'] as String? ?? cycle;
    reward = j['reward'] as String? ?? reward;
    lastWinner = j['lastWinner'] as String?;
    lastReward = j['lastReward'] as String?;
    punishments
      ..clear()
      ..addAll({
        for (final e in (j['punishments'] as Map? ?? const {}).entries)
          '${e.key}': '${e.value}',
      });
    violations
      ..clear()
      ..addAll([
        for (final v in (j['violations'] as List? ?? const []))
          Violation(
            '${v['who']}',
            '${v['kind']}',
            '${v['detail']}',
            '${v['when']}',
          )..done = v['done'] == true,
      ]);
  }
}

final rules = Rules();

const punishmentOptions = [
  'Wash the dishes',
  'No games tonight',
  'Clean your room',
  'Early bedtime',
  'Help cook dinner',
];
const rewardOptions = [
  'Choose the family dinner place',
  'Pick the movie for movie night',
  'Skip a chore',
  'Choose the weekend outing',
  'Extra game time',
];

/// (Re)builds the sample feed using the current family names.
void seedSample() {
  // with the family connected, events and moments come from the database instead
  if (!sharedLive) {
    events
      ..clear()
      ..addAll([
        Ev('Village outing', today, '4:00 PM', 'Outing', C.sage, [
          n('daughter'),
          n('brother'),
          n('mom'),
          n('girl'),
          n('boy'),
        ]),
        Ev(
          'Family dinner',
          today.add(const Duration(days: 2)),
          '8:00 PM',
          'Dinner',
          C.peach,
          [n('daughter'), n('dad'), n('mom'), n('girl')],
        ),
      ]);
  }
  if (!sharedLive) {
    moments
      ..clear()
      ..addAll([
        Moment(
          n('girl'),
          'Went out today with the girls',
          'Today, 4:10 PM',
          C.sage,
          C.sageTint,
          13,
          6,
        ),
        Moment(
          n('brother'),
          'Study break at the café',
          'Today, 1:30 PM',
          C.peach,
          C.peachTint,
          8,
          3,
        ),
        Moment(
          n('mom'),
          'Fresh coffee, quiet morning',
          'Today, 8:15 AM',
          C.yellow,
          C.yellowTint,
          11,
          4,
        ),
        Moment(
          n('dad'),
          'Evening in the majlis',
          'Yesterday',
          C.lavender,
          C.lavenderTint,
          9,
          2,
        ),
        Moment(
          n('boy'),
          'My new Lego!',
          'Yesterday',
          C.teal,
          C.tealTint,
          15,
          7,
        ),
        Moment(
          n('daughter'),
          'Baking with Mom',
          '2 days ago',
          C.sage,
          C.sageTint,
          10,
          5,
        ),
      ]);
  }
  talks
    ..clear()
    ..addAll([
      Talk(
        n('girl'),
        'What do you want to eat on Thursday?',
        'Yesterday',
        4,
        6,
      ),
      Talk(n('mom'), 'Who wants to come with me to the market?', 'Today', 2, 3),
    ]);
  comments
    ..clear()
    ..addAll([
      (n('dad'), 'Nice!'),
      (n('mom'), 'God protect you all'),
      (n('brother'), 'Take me with you'),
    ]);
}
