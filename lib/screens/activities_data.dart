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

  /// Bundled photo (assets/images/outings/); the drawn scene shows until it exists.
  final String imagePath;

  /// What Google Maps searches for when the card is tapped (the place's own name as Google lists it,
  /// so it opens the one main place), unless [mapsUrl] gives the exact link, and the place's Google Maps rating
  /// (stars, number of reviews). The rating is a snapshot, null when it has not been checked yet.
  final String mapsQuery;
  final String?
  mapsUrl; // an exact Google Maps share link for the place, when we have one
  final double? rating;
  final int? ratingCount;
  const WeekendPlace({
    required this.name,
    required this.tag,
    required this.baseVotes,
    required this.scene,
    required this.sky,
    required this.barColor,
    required this.imagePath,
    required this.mapsQuery,
    this.mapsUrl,
    this.rating,
    this.ratingCount,
  });
}

final weekendPlaces = <WeekendPlace>[
  WeekendPlace(
    name: 'حديقة الملك سلمان',
    tag: 'مناسبة لكل الأعمار',
    baseVotes: 4,
    scene: OutingScene.park,
    sky: AC.sageTint,
    barColor: AC.sage,
    imagePath: 'assets/images/outings/king_salman_park.jpg',
    mapsQuery: 'King Salman Park, Riyadh',
  ),
  WeekendPlace(
    name: 'وادي حنيفة',
    tag: 'جلسة طبيعة وشواء',
    baseVotes: 3,
    scene: OutingScene.wadi,
    sky: AC.wadiSky,
    barColor: AC.wadiBar,
    imagePath: 'assets/images/outings/wadi_hanifa.jpg',
    mapsQuery: 'Wadi Hanifah, Riyadh',
    rating: 4.3,
    ratingCount: 2000,
  ),
  WeekendPlace(
    name: 'البوليفارد',
    tag: 'سهرة عائلية',
    baseVotes: 2,
    scene: OutingScene.city,
    sky: AC.navy,
    barColor: AC.mustard,
    imagePath: 'assets/images/outings/boulevard.jpg',
    mapsQuery: 'Boulevard Riyadh City',
    rating: 4.6,
    ratingCount: 64000,
  ),
];
