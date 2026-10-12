import 'package:flutter/material.dart';

import '../../../screens/activities_colors.dart';

enum Gender { male, female }

class FamilyPlayer {
  final String name, initial;
  final Color color, ink;
  final Gender gender;
  const FamilyPlayer(
    this.name,
    this.initial,
    this.color,
    this.ink,
    this.gender,
  );
}

// No shared family list exists in the app yet; swap this out when one does.
const familyPlayers = <FamilyPlayer>[
  FamilyPlayer('محمد', 'م', AC.brick, Colors.white, Gender.male),
  FamilyPlayer('سارة', 'س', AC.navy, Colors.white, Gender.female),
  FamilyPlayer('آمنة', 'آ', AC.teal, Colors.white, Gender.female),
  FamilyPlayer('يوسف', 'ي', AC.mustard, AC.ink, Gender.male),
  FamilyPlayer('نوف', 'ن', AC.salmon, AC.ink, Gender.female),
  FamilyPlayer('عبدالله', 'ع', AC.sage, AC.ink, Gender.male),
];

// The moments and chat features spell two names differently (أمينة / نورة).
const _nameAlias = {'أمينة': 'آمنة', 'نورة': 'نوف'};

/// Gender of a family member by name, from [familyPlayers].
Gender genderOfName(String name) {
  final n = _nameAlias[name] ?? name;
  return familyPlayers
      .firstWhere((p) => p.name == n, orElse: () => familyPlayers.first)
      .gender;
}
