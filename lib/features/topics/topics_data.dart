import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class TopicCategory {
  final String id;
  final Color color, tint, ink;
  const TopicCategory({
    required this.id,
    required this.color,
    required this.tint,
    required this.ink,
  });

  String label(AppLocalizations l) => switch (id) {
    'memories' => l.topicsCatMemories,
    'dreams' => l.topicsCatDreams,
    'food' => l.topicsCatFood,
    'fun' => l.topicsCatFun,
    'wyr' => l.topicsCatWyr,
    _ => l.topicsCatMine,
  };
}

class Topic {
  final String id, categoryId, text;
  final bool isMine;
  const Topic({
    required this.id,
    required this.categoryId,
    required this.text,
    this.isMine = false,
  });
}

const mineCategoryId = 'mine';

const topicCategories = <TopicCategory>[
  TopicCategory(
    id: 'memories',
    color: Color(0xFF9A4A3E),
    tint: Color(0xFFF6DDD3),
    ink: Color(0xFF7A3A30),
  ),
  TopicCategory(
    id: 'dreams',
    color: Color(0xFF3E7A75),
    tint: Color(0xFFD6E7E4),
    ink: Color(0xFF2F6662),
  ),
  TopicCategory(
    id: 'food',
    color: Color(0xFFDEB461),
    tint: Color(0xFFF5E7C4),
    ink: Color(0xFF5A4E36),
  ),
  TopicCategory(
    id: 'fun',
    color: Color(0xFFE29079),
    tint: Color(0xFFFBE3DA),
    ink: Color(0xFF7A3A30),
  ),
  TopicCategory(
    id: 'wyr',
    color: Color(0xFF1E2A47),
    tint: Color(0xFFD9DEEA),
    ink: Color(0xFF1E2A47),
  ),
  TopicCategory(
    id: mineCategoryId,
    color: Color(0xFF8FA580),
    tint: Color(0xFFE1E9D8),
    ink: Color(0xFF3F5634),
  ),
];

const _seed = <(String, String)>[
  ('memories', 'وش أحلى ذكرى عندك من رمضان؟'),
  ('memories', 'وش أول شي تتذكره من طفولتك؟'),
  ('memories', 'وش أحلى رحلة عائلية سويناها؟'),
  ('memories', 'مين أكثر شخص أثّر فيك وأنت صغير؟'),
  ('dreams', 'لو تقدر تسافر لأي مكان الحين، وين بتروح؟'),
  ('dreams', 'وش الحلم اللي ودك تحققه هالسنة؟'),
  ('dreams', 'لو تعيش في مدينة ثانية، وين تختار؟'),
  ('dreams', 'وش المهارة اللي ودك تتعلمها؟'),
  ('food', 'وش أكلة أمي المفضلة عندك؟'),
  ('food', 'لو تاكل أكلة وحدة طول حياتك، وش هي؟'),
  ('food', 'وش أغرب أكلة جربتها؟'),
  ('food', 'مين أحسن طبّاخ بالعائلة؟'),
  ('fun', 'وش أكثر موقف ضحّكنا كلنا مع بعض؟'),
  ('fun', 'مين أكثر واحد بالعائلة يضحكك؟ وليش؟'),
  ('fun', 'وش أغرب حلم حلمت فيه؟'),
  ('fun', 'وش الكلمة اللي تقولها كثير بدون ما تحس؟'),
  ('wyr', 'لو خيّروك بين البحر والبر، وش تختار؟'),
  ('wyr', 'لو خيّروك تعيش بالماضي ولا المستقبل؟'),
  ('wyr', 'لو خيّروك قوة خارقة وحدة، وش تكون؟'),
  ('wyr', 'لو خيّروك بين قهوة الصبح وشاي العصر؟'),
];

final baseTopics = <Topic>[
  for (var i = 0; i < _seed.length; i++)
    Topic(id: 'b$i', categoryId: _seed[i].$1, text: _seed[i].$2),
];

/// "رائج الحين": most-discussed topics this week.
const trendingTopicIds = ['b0', 'b8', 'b16', 'b13'];

/// Topics shown in "سالفة الليلة" on the Activities page.
const tonightTopicIds = ['b4', 'b0', 'b7', 'b13', 'b8'];
