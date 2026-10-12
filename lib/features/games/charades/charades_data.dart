import 'package:flutter/material.dart';

import '../../../screens/activities_colors.dart';

const charadesWords = <String>[
  'يصب قهوة',
  'يطبخ كبسة',
  'يركب جمل',
  'يصور سلفي',
  'يلعب كورة',
  'ينام بالمجلس',
  'يسبح',
  'يتسوق بالمول',
  'يرسم',
  'يسوق سيارة',
  'يصيد سمك',
  'يحمل شنطة سفر',
  'يغسل صحون',
  'يزرع شجرة',
];

const charadesTurnSeconds = 60;
const charadesRoundOptions = [2, 3, 5];

class TeamStyle {
  final Color color, tint, ink, border;
  const TeamStyle(this.color, this.tint, this.ink, this.border);
}

const charadesTeams = <TeamStyle>[
  TeamStyle(AC.brick, AC.salmonTint, Color(0xFF7A3A30), Color(0xFFE9BFAF)),
  TeamStyle(AC.navy, Color(0xFFD9DEEA), AC.navy, Color(0xFFBFC7DA)),
];
