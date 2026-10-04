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
  final String name, role, asset;
  final int age;
  const Member(this.name, this.role, this.age, this.asset);
}

final members = <Member>[
  Member('Noura', 'You', 16, characters[0].$2),
  Member('Mohammed', 'Brother', 19, characters[1].$2),
  Member('Abdullah', 'Dad', 47, characters[2].$2),
  Member('Amina', 'Mom', 44, characters[3].$2),
  Member('Sarah', 'Sister', 8, characters[4].$2),
  Member('Yousef', 'Brother', 6, characters[5].$2),
];

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
  int age = 16;
  String job = 'Student';
  Set<String> interests = {'Coffee', 'Games', 'Reading', 'Walking', 'Podcasts'};
  Set<String> outingTypes = {'Nature', 'Cafés'};
  String prefer = 'Games';
  int avatar = 0;
}

final profile = Profile();

class Ev {
  final String title, time, type;
  final int day; // day of the month shown in the family calendar
  final Color color;
  final List<String> going;
  Ev(this.title, this.day, this.time, this.type, this.color, this.going);
}

const calendarDays = <(int, String)>[(12, 'Sat'), (13, 'Sun'), (14, 'Mon')];
const eventTypes = ['Gathering', 'Outing', 'Dinner', 'Games', 'Trip', 'Movie', 'Occasion'];

final events = <Ev>[
  Ev('Village outing', 12, '4:00 PM', 'Outing', C.green,
      ['Noura', 'Mohammed', 'Amina', 'Sarah', 'Yousef']),
  Ev('Family dinner', 14, '8:00 PM', 'Dinner', C.coral,
      ['Noura', 'Abdullah', 'Amina', 'Sarah']),
];

class Moment {
  final String who, caption, time;
  final Color a, b;
  int likes, comments;
  bool liked = false;
  Moment(this.who, this.caption, this.time, this.a, this.b, this.likes, this.comments);
}

final moments = <Moment>[
  Moment('Sarah', 'Went out today with the girls', 'Today, 4:10 PM', C.green, C.tealTint, 13, 6),
  Moment('Mohammed', 'Study break at the café', 'Today, 1:30 PM', C.coral, C.mustardTint, 8, 3),
  Moment('Amina', 'Fresh coffee, quiet morning', 'Today, 8:15 AM', C.mustard, C.coralTint, 11, 4),
  Moment('Abdullah', 'Evening in the majlis', 'Yesterday', C.teal, C.greenTint, 9, 2),
  Moment('Yousef', 'My new Lego!', 'Yesterday', C.coral, C.coralTint, 15, 7),
  Moment('Noura', 'Baking with Mom', '2 days ago', C.mustard, C.mustardTint, 10, 5),
];

class Talk {
  final String who, text, time;
  int likes, comments;
  Talk(this.who, this.text, this.time, this.likes, this.comments);
}

final talks = <Talk>[
  Talk('Sarah', 'What do you want to eat on Thursday?', 'Yesterday', 4, 6),
  Talk('Amina', 'Who wants to come with me to the market?', 'Today', 2, 3),
];

const comments = <(String, String)>[
  ('Abdullah', 'Nice!'),
  ('Amina', 'God protect you all'),
  ('Mohammed', 'Take me with you'),
];

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
