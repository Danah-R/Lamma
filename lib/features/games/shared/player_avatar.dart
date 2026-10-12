import 'package:flutter/material.dart';

import 'family_players.dart';

/// Circle in the player's colour with the first letter of their name.
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
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: player.color, shape: BoxShape.circle),
      child: Text(
        player.initial,
        style: TextStyle(
          fontSize: size * .42,
          fontWeight: FontWeight.w800,
          color: player.ink,
        ),
      ),
    ),
  );
}
