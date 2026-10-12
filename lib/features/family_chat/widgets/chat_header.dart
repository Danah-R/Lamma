import 'package:flutter/material.dart';

import '../../../screens/activities_colors.dart';
import '../../notifications/widgets/notification_bell.dart';

/// "لمّه" + online line, with the notifications bell.
class ChatHeader extends StatelessWidget {
  final String title, subtitle;
  const ChatHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AC.border)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: AC.ink,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AC.teal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AC.muted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const NotificationBell(),
      ],
    ),
  );
}
