import 'package:flutter/material.dart';

import '../family_chat_controller.dart';

class ChatAvatar extends StatelessWidget {
  final ChatMember member;
  final double size;
  const ChatAvatar({super.key, required this.member, this.size = 30});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: member.color, shape: BoxShape.circle),
    child: Text(
      member.initial,
      style: TextStyle(
        fontSize: (size * .42).roundToDouble(),
        fontWeight: FontWeight.w800,
        color: member.ink,
        height: 1.1,
      ),
    ),
  );
}
