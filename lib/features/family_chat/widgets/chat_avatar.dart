import 'package:flutter/material.dart';

import '../../../data.dart' as app;
import '../../../widgets.dart' show Avatar;
import '../family_chat_controller.dart';

/// A family member's profile picture (the same one the rest of the app shows).
/// Falls back to their initial in a colored circle if there is no picture for that name.
class ChatAvatar extends StatelessWidget {
  final ChatMember member;
  final double size;
  const ChatAvatar({super.key, required this.member, this.size = 30});

  @override
  Widget build(BuildContext context) {
    // "me" is whoever is signed in, whatever name they chose
    final name = member.id == chatMeId ? app.profile.name : member.name;
    return Avatar(name, size: size);
  }
}
