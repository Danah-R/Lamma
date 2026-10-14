// The one list of family members. Games, moments, chat and notifications
// all read it, so a name, a colour or a gender lives in exactly one place.

import 'package:flutter/material.dart';

import '../data.dart' as app;

enum Gender { male, female }

class FamilyMember {
  final String id, name, initial;
  final Gender gender;

  /// Avatar circle colour and the letter colour on it.
  final Color color, ink;

  /// The colour this person's name takes in comments and chat.
  final Color nameColor;
  const FamilyMember({
    required this.id,
    required this.name,
    required this.initial,
    required this.gender,
    required this.color,
    required this.ink,
    required this.nameColor,
  });
}

/// The id of the person using the app.
const familyMeId = 'mo';

/// The built-in sample family. Order = the order the games show them in.
const _sampleMembers = <FamilyMember>[
  FamilyMember(
    id: 'mo',
    name: 'محمد',
    initial: 'م',
    gender: Gender.male,
    color: Color(0xFF9A4A3E),
    ink: Color(0xFFFFFFFF),
    nameColor: Color(0xFF9A4A3E),
  ),
  FamilyMember(
    id: 'sa',
    name: 'سارة',
    initial: 'س',
    gender: Gender.female,
    color: Color(0xFF1E2A47),
    ink: Color(0xFFFFFFFF),
    nameColor: Color(0xFF1E2A47),
  ),
  FamilyMember(
    id: 'am',
    name: 'أمينة',
    initial: 'أ',
    gender: Gender.female,
    color: Color(0xFF3E7A75),
    ink: Color(0xFFFFFFFF),
    nameColor: Color(0xFF2F6662),
  ),
  FamilyMember(
    id: 'yo',
    name: 'يوسف',
    initial: 'ي',
    gender: Gender.male,
    color: Color(0xFFE29079),
    ink: Color(0xFF2B211E),
    nameColor: Color(0xFF9A4A3E),
  ),
  FamilyMember(
    id: 'no',
    name: 'نورة',
    initial: 'ن',
    gender: Gender.female,
    color: Color(0xFFDEB461),
    ink: Color(0xFF2B211E),
    nameColor: Color(0xFF6E5418),
  ),
  FamilyMember(
    id: 'ab',
    name: 'عبدالله',
    initial: 'ع',
    gender: Gender.male,
    color: Color(0xFF8FA580),
    ink: Color(0xFF2B211E),
    nameColor: Color(0xFF3F5634),
  ),
];

List<FamilyMember>? _real;
String _realSignature = '';

/// The family everyone in the app reads (chat, moments, notifications, games).
///
/// Offline it is the sample family above. Once the real family is loaded from the database, the same
/// six slots (so the sample messages and moments keep their authors) are filled with the real people:
/// you are always the first slot, then the others in order, repeating if the family has fewer than six.
/// Names and pictures therefore always come from the real profiles.
List<FamilyMember> get familyMembers {
  if (!app.sharedLive || app.members.isEmpty) return _sampleMembers;
  final me = app.members.where(
    (m) => app.profile.memberId != null
        ? m.id == app.profile.memberId
        : m.name == app.profile.name,
  );
  final real = [...me, ...app.members.where((m) => !me.contains(m))];
  final sig = real.map((m) => '${m.id ?? m.name}|${m.name}|${m.key}').join(',');
  if (_real != null && sig == _realSignature) return _real!;
  _realSignature = sig;
  return _real = [
    for (var i = 0; i < _sampleMembers.length; i++)
      FamilyMember(
        id: _sampleMembers[i].id,
        name: real[i % real.length].name,
        initial: real[i % real.length].name.isEmpty
            ? ''
            : real[i % real.length].name.characters.first,
        gender: _genderOfRole(real[i % real.length].key),
        color: _sampleMembers[i].color,
        ink: _sampleMembers[i].ink,
        nameColor: _sampleMembers[i].nameColor,
      ),
  ];
}

Gender _genderOfRole(String key) => switch (key) {
  'mom' || 'daughter' || 'girl' => Gender.female,
  _ => Gender.male,
};

FamilyMember familyMemberById(String id) =>
    familyMembers.firstWhere((m) => m.id == id);

/// Gender by name. The real family (from the database) is checked first, by each person's
/// role; unknown names read as male (the plain verb form).
Gender genderOfName(String name) {
  for (final m in app.members) {
    if (m.name == name) return _genderOfRole(m.key);
  }
  return _sampleMembers
      .firstWhere((m) => m.name == name, orElse: () => _sampleMembers.first)
      .gender;
}
