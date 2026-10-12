import 'package:flutter/material.dart';

import '../moments_controller.dart';

/// A family member's initial in a colored circle.
class MomentAvatar extends StatelessWidget {
  final MomentsMember member;
  final double size;
  final Color? ring; // optional border (used for overlapped likers)
  final double? fontSize;
  const MomentAvatar({
    super.key,
    required this.member,
    required this.size,
    this.ring,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: member.color,
      shape: BoxShape.circle,
      border: ring == null ? null : Border.all(color: ring!, width: 2),
    ),
    child: Text(
      member.initial,
      style: TextStyle(
        fontSize: fontSize ?? (size * .42).roundToDouble(),
        fontWeight: FontWeight.w700,
        color: member.ink,
        height: 1.1,
      ),
    ),
  );
}
