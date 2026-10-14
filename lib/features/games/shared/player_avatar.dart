import 'package:flutter/material.dart';

import '../../../widgets.dart' show Avatar;
import 'family_players.dart';

/// The player's real profile picture.
class PlayerAvatar extends StatelessWidget {
  final FamilyPlayer player;
  final double size;
  final double opacity;
  const PlayerAvatar({
    super.key,
    required this.player,
    this.size = 34,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: opacity,
    child: Avatar(player.name, size: size),
  );
}
