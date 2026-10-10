import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';

class WhoAmICategory {
  final String id;
  final Color bg, tint;
  final Color? iconBg; // defaults to [bg]
  final Color tagInk; // text colour of the "word N" tag
  final IconData icon;
  final List<String> words;
  const WhoAmICategory({
    required this.id,
    required this.bg,
    required this.tint,
    required this.icon,
    required this.words,
    this.iconBg,
    this.tagInk = AC.ink,
  });

  String label(AppLocalizations l) => switch (id) {
    'animals' => l.whoAmICatAnimals,
    'food' => l.whoAmICatFood,
    'jobs' => l.whoAmICatJobs,
    _ => l.whoAmICatPlaces,
  };
}

const whoAmICategories = <WhoAmICategory>[
  WhoAmICategory(
    id: 'animals',
    bg: AC.teal,
    tint: AC.tealTint,
    icon: Icons.pets,
    tagInk: AC.teal,
    words: [
      'جمل',
      'زرافة',
      'بطريق',
      'أسد',
      'صقر',
      'دلفين',
      'قنفذ',
      'فيل',
      'غزال',
      'سلحفاة',
    ],
  ),
  WhoAmICategory(
    id: 'food',
    bg: AC.brick,
    tint: AC.salmonTint,
    icon: Icons.ramen_dining,
    tagInk: AC.brick,
    words: [
      'كبسة',
      'شاورما',
      'جريش',
      'بيتزا',
      'مرقوق',
      'تمر',
      'لقيمات',
      'قهوة عربية',
      'سمبوسة',
      'آيس كريم',
    ],
  ),
  WhoAmICategory(
    id: 'jobs',
    bg: AC.navy,
    tint: Color(0xFFD9DEEA),
    icon: Icons.work_outline,
    tagInk: AC.navy,
    words: [
      'طيار',
      'طبيب',
      'معلّم',
      'رائد فضاء',
      'طبّاخ',
      'مهندس',
      'رسّام',
      'إطفائي',
      'مزارع',
      'مصوّر',
    ],
  ),
  WhoAmICategory(
    id: 'places',
    bg: Color(0xFF8C6A24),
    tint: AC.mustardTint,
    iconBg: AC.mustard,
    icon: Icons.place_outlined,
    tagInk: Color(0xFF5A4E36),
    words: [
      'البحر',
      'المطار',
      'الصحراء',
      'المستشفى',
      'المدرسة',
      'المول',
      'الملعب',
      'المكتبة',
      'الحديقة',
      'المخيم',
    ],
  ),
];
