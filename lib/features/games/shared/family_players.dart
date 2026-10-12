import 'package:flutter/material.dart';

import '../../../screens/activities_colors.dart';

class FamilyPlayer {
  final String name, initial;
  final Color color, ink;
  const FamilyPlayer(this.name, this.initial, this.color, this.ink);
}

// No shared family list exists in the app yet; swap this out when one does.
const familyPlayers = <FamilyPlayer>[
  FamilyPlayer('محمد', 'م', AC.brick, Colors.white),
  FamilyPlayer('سارة', 'س', AC.navy, Colors.white),
  FamilyPlayer('آمنة', 'آ', AC.teal, Colors.white),
  FamilyPlayer('يوسف', 'ي', AC.mustard, AC.ink),
  FamilyPlayer('نوف', 'ن', AC.salmon, AC.ink),
  FamilyPlayer('عبدالله', 'ع', AC.sage, AC.ink),
];
