import 'package:flutter/material.dart';

import '../../../screens/activities_colors.dart';

class DateChip extends StatelessWidget {
  final String text;
  const DateChip(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AC.track,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AC.muted,
        ),
      ),
    ),
  );
}
