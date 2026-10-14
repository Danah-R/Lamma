import 'package:flutter/material.dart';

import '../../../data.dart' as app;
import '../../../widgets.dart' show Avatar;
import '../moments_controller.dart';

/// A family member's profile picture (the same one the rest of the app shows).
/// Falls back to their initial in a colored circle if there is no picture for that name.
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
  Widget build(BuildContext context) {
    // "me" is whoever is signed in, whatever name they chose
    final name = member.id == momentsMeId ? app.profile.name : member.name;
    final picture = Avatar(name, size: size);
    if (ring == null) return picture;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring!, width: 2),
      ),
      child: ClipOval(child: picture),
    );
  }
}
