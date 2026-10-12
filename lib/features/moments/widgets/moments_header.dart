import 'package:flutter/material.dart';

import '../../../screens/activities_colors.dart';
import '../../notifications/widgets/notification_bell.dart';

/// "لحظات يومنا": title + "X من 6 شاركوا اليوم", bell on the far side.
class MomentsHeader extends StatelessWidget {
  final String title, subtitle;
  const MomentsHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
    decoration: const BoxDecoration(
      color: AC.background,
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
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AC.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: AC.muted),
              ),
            ],
          ),
        ),
        const NotificationBell(),
      ],
    ),
  );
}
