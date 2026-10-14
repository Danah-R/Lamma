import 'package:flutter/material.dart';

import '../../../data.dart' as app;
import '../../../data/family_members.dart';
import '../../../screens/activities_colors.dart';

export '../../../data/family_members.dart' show Gender, genderOfName;

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

const _colors = [AC.brick, AC.navy, AC.teal, AC.mustard, AC.salmon, AC.sage];
const _inks = [
  Colors.white,
  Colors.white,
  Colors.white,
  AC.ink,
  AC.ink,
  AC.ink,
];

/// The app's real family members, as game players.
List<FamilyPlayer> get familyPlayers => [
  for (var i = 0; i < app.members.length; i++)
    FamilyPlayer(
      app.members[i].name,
      app.members[i].name.isEmpty ? '' : app.members[i].name.characters.first,
      _colors[i % _colors.length],
      _inks[i % _inks.length],
      genderOfName(app.members[i].name),
    ),
];
