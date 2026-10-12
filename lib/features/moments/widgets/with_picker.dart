import 'package:flutter/material.dart';

import '../../../screens/activities_colors.dart';
import '../moments_controller.dart';
import 'moment_avatar.dart';

/// "مين معك؟": the family (without me) in one row; tap to toggle, many allowed.
class WithPicker extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const WithPicker({super.key, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      for (final m in momentsMembers)
        if (m.id != momentsMeId)
          _Person(
            member: m,
            on: selected.contains(m.id),
            onTap: () => onToggle(m.id),
          ),
    ],
  );
}

class _Person extends StatelessWidget {
  final MomentsMember member;
  final bool on;
  final VoidCallback onTap;
  const _Person({required this.member, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    toggled: on,
    label: member.name,
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 58,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (on) ...const [
                          BoxShadow(color: AC.brick, spreadRadius: 5),
                          BoxShadow(color: AC.background, spreadRadius: 3),
                        ],
                      ],
                    ),
                    child: MomentAvatar(member: member, size: 44),
                  ),
                  if (on)
                    Positioned(
                      bottom: -2,
                      left: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AC.brick,
                          shape: BoxShape.circle,
                          border: Border.all(color: AC.background, width: 2),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                member.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AC.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
