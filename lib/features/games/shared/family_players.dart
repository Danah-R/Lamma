import 'package:flutter/material.dart';

import '../../../data/family_members.dart';

export '../../../data/family_members.dart' show Gender, genderOfName;

class FamilyPlayer {
  final String name, initial;
  final Color color, ink;
  final Gender gender;
  const FamilyPlayer(this.name, this.initial, this.color, this.ink, this.gender);
}

/// The players of the family games: the shared family list.
final familyPlayers = <FamilyPlayer>[
  for (final m in familyMembers)
    FamilyPlayer(m.name, m.initial, m.color, m.ink, m.gender),
];
