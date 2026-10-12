// The one list of family members. Games, moments, chat and notifications
// all read it, so a name, a colour or a gender lives in exactly one place.

import 'package:flutter/material.dart';

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

/// Order = the order the games show them in.
const familyMembers = <FamilyMember>[
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

FamilyMember familyMemberById(String id) =>
    familyMembers.firstWhere((m) => m.id == id);

/// Gender by name; unknown names read as male (the plain verb form).
Gender genderOfName(String name) => familyMembers
    .firstWhere(
      (m) => m.name == name,
      orElse: () => familyMembers.first,
    )
    .gender;
