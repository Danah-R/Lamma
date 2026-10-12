// Game catalog for the Games page ("الألعاب"). One list, easy to extend:
// add a GameInfo entry here and an illustration case in game_illustrations.dart.

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'activities_colors.dart';

class GameInfo {
  final String id;
  final String title, desc, time;
  final List<String> tags; // move | challenge | family
  final bool isSoon;
  final Color bg, art;
  final bool dark;
  const GameInfo({
    required this.id,
    required this.title,
    required this.desc,
    required this.time,
    required this.tags,
    required this.bg,
    required this.art,
    this.isSoon = false,
    this.dark = false,
  });
}

List<GameInfo> buildGamesList(AppLocalizations l) => [
  GameInfo(
    id: 'whoami',
    title: l.gamesWhoAmITitle,
    desc: l.gamesWhoAmIDesc,
    time: l.gamesTime5min,
    tags: const ['challenge'],
    bg: AC.track,
    art: AC.dotInactive,
  ),
  GameInfo(
    id: 'charades',
    title: l.gamesCharadesTitle,
    desc: l.gamesCharadesDesc,
    time: l.gamesTimeRange10to15,
    tags: const ['move', 'challenge'],
    bg: AC.navy,
    art: AC.navy2,
    dark: true,
  ),
  GameInfo(
    id: 'seen',
    title: l.gamesSinJimTitle,
    desc: l.gamesSinJimDesc,
    time: l.gamesTimeRange10to15,
    tags: const ['family'],
    bg: AC.tealTint,
    art: AC.seenArt,
  ),
  GameInfo(
    id: 'huroof',
    title: l.gamesAzizTitle,
    desc: l.gamesAzizDesc,
    time: l.gamesTimeRange5to10,
    tags: const ['challenge'],
    isSoon: true,
    bg: AC.mustardTint,
    art: AC.huroofArt,
  ),
  GameInfo(
    id: 'freeze',
    title: l.gamesThabbitTitle,
    desc: l.gamesThabbitDesc,
    time: l.gamesTime5min,
    tags: const ['move'],
    isSoon: true,
    bg: AC.sageTint,
    art: AC.freezeArt,
  ),
  GameInfo(
    id: 'photo',
    title: l.gamesPhotoTitle,
    desc: l.gamesPhotoDesc,
    time: l.gamesTimeRange5to10,
    tags: const ['family'],
    isSoon: true,
    bg: AC.salmonTint,
    art: AC.photoArt,
  ),
];
