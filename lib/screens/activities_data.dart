// Sample/mock content for the redesigned Activities page, kept separate
// from `data.dart` so it's easy to swap for real data later. Values are
// placeholders, not translated strings — wire this up to the real content
// source when it exists.

import 'package:flutter/material.dart';

import 'activities_colors.dart';

/// Which illustration/colors a weekend place card uses.
enum OutingScene { park, wadi, city }

/// A candidate place for the weekend family outing, with its running vote
/// count (not counting the current viewer's own vote, see [WeekendPlace.baseVotes]).
class WeekendPlace {
  final String name;
  final String tag;
  final int baseVotes;
  final OutingScene scene;
  final Color sky;
  final Color barColor;
  const WeekendPlace({
    required this.name,
    required this.tag,
    required this.baseVotes,
    required this.scene,
    required this.sky,
    required this.barColor,
  });
}

const weekendPlaces = <WeekendPlace>[
  WeekendPlace(
    name: 'حديقة الملك سلمان',
    tag: 'مناسبة لكل الأعمار',
    baseVotes: 4,
    scene: OutingScene.park,
    sky: AC.sageTint,
    barColor: AC.sage,
  ),
  WeekendPlace(
    name: 'وادي حنيفة',
    tag: 'جلسة طبيعة وشواء',
    baseVotes: 3,
    scene: OutingScene.wadi,
    sky: AC.wadiSky,
    barColor: AC.wadiBar,
  ),
  WeekendPlace(
    name: 'البوليفارد',
    tag: 'سهرة عائلية',
    baseVotes: 2,
    scene: OutingScene.city,
    sky: AC.navy,
    barColor: AC.mustard,
  ),
];
