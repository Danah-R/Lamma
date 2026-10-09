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
const familyScene = '${_dir}family_scene.jpg';

class Member {
  final String key, name, role, asset;
  final int age;
  int points;
  Member(this.key, this.name, this.role, this.age, this.asset, this.points);
  bool get isParent => key == 'mom' || key == 'dad';
}

/// Sample family. The person using the app takes over the slot matching their role.
final members = <Member>[
  Member('daughter', 'Noura', 'Daughter', 16, characters[0].$2, 210),
  Member('brother', 'Mohammed', 'Son', 19, characters[1].$2, 245),
  Member('dad', 'Abdullah', 'Dad', 47, characters[2].$2, 90),
  Member('mom', 'Amina', 'Mom', 44, characters[3].$2, 120),
  Member('girl', 'Sarah', 'Daughter', 8, characters[4].$2, 280),
  Member('boy', 'Yousef', 'Son', 6, characters[5].$2, 160),
];

/// Name of the family member holding a role key (mom, dad, daughter, brother, girl, boy).
String n(String key) => members.firstWhere((m) => m.key == key).name;

void addPoints(String name, int delta) {
  for (final m in members) {
    if (m.name == name) m.points = (m.points + delta).clamp(0, 99999);
  }
}

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
  String name = 'Noura';
  String role = 'daughter'; // mom, dad, daughter, brother
  int age = 16;
  String job = 'Student';
  Set<String> interests = {'Coffee', 'Games', 'Reading', 'Walking', 'Podcasts'};
  Set<String> outingTypes = {'Nature', 'Cafés'};
  String prefer = 'Games';
  int avatar = 0;
  bool get isParent => role == 'mom' || role == 'dad';
}

final profile = Profile();

class Ev {
  final String title, time, type;
  final DateTime date;
  final Color color;
  final List<String> going;
  Ev(this.title, this.date, this.time, this.type, this.color, this.going);
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String weekdayName(DateTime d) => _weekdays[d.weekday - 1];
String monthName(DateTime d) => _months[d.month - 1];
String dateLabel(DateTime d) => '${weekdayName(d)}, ${monthName(d)} ${d.day}';
bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
DateTime get today => DateTime.now();

const eventTypes = ['Gathering', 'Outing', 'Dinner', 'Games', 'Trip', 'Movie', 'Occasion'];

final events = <Ev>[];

class Moment {
  final String who, caption, time;
  final Color a, b;
  int likes, comments;
  bool liked = false;
  Moment(this.who, this.caption, this.time, this.a, this.b, this.likes, this.comments);
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
  Place('King Salman Park', 'Nature', '4 of 6 family members like this type of place',
      Icons.park_rounded, C.green),
  Place('Café Al-Dar', 'Cafés', 'Suits everyone, a good choice', Icons.coffee_rounded, C.mustard),
  Place('Strike Bowling', 'Entertainment', '3 of 6 love games and group activities',
      Icons.sports_score_rounded, C.teal),
  Place('Sufrat Al-Bayt', 'Restaurants', 'Homestyle food and family seating',
      Icons.restaurant_rounded, C.terracotta),
];
final ourOutings = <Place>[];

const badges = <(String, IconData, Color, bool)>[
  ('Most interactive', Icons.emoji_events_rounded, C.mustard, true),
  ('Lamma spirit', Icons.favorite_rounded, C.terracotta, true),
  ('Weekly listener', Icons.headphones_rounded, C.teal, true),
  ('Week winner', Icons.military_tech_rounded, C.coral, true),
  ('Talks king', Icons.forum_rounded, C.green, true),
  ('Reader', Icons.menu_book_rounded, C.inkSoft, false),
];

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
  String from = '8:00 PM', to = '9:30 PM';
  String consequence = 'points'; // 'points' or 'punishment'
  int penalty = 10;
  String punishment = 'Wash the dishes';
  String cycle = 'Weekly'; // 'Weekly' or 'Monthly'
  String reward = 'Choose the family dinner place';
  String? lastWinner, lastReward;
  final violations = <Violation>[];
  final punishments = <String, String>{}; // member name -> active punishment
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
  events
    ..clear()
    ..addAll([
      Ev('Village outing', today, '4:00 PM', 'Outing', C.green,
          [n('daughter'), n('brother'), n('mom'), n('girl'), n('boy')]),
      Ev('Family dinner', today.add(const Duration(days: 2)), '8:00 PM', 'Dinner', C.coral,
          [n('daughter'), n('dad'), n('mom'), n('girl')]),
    ]);
  moments
    ..clear()
    ..addAll([
      Moment(n('girl'), 'Went out today with the girls', 'Today, 4:10 PM', C.green, C.tealTint, 13, 6),
      Moment(n('brother'), 'Study break at the café', 'Today, 1:30 PM', C.coral, C.mustardTint, 8, 3),
      Moment(n('mom'), 'Fresh coffee, quiet morning', 'Today, 8:15 AM', C.mustard, C.coralTint, 11, 4),
      Moment(n('dad'), 'Evening in the majlis', 'Yesterday', C.teal, C.greenTint, 9, 2),
      Moment(n('boy'), 'My new Lego!', 'Yesterday', C.coral, C.coralTint, 15, 7),
      Moment(n('daughter'), 'Baking with Mom', '2 days ago', C.mustard, C.mustardTint, 10, 5),
    ]);
  talks
    ..clear()
    ..addAll([
      Talk(n('girl'), 'What do you want to eat on Thursday?', 'Yesterday', 4, 6),
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
