import 'package:flutter/material.dart';

import '../../../widgets.dart' show Avatar;

import '../../../data.dart' show profile;
import '../../../l10n/app_localizations.dart';
import '../../../widgets.dart' show PeopleList;
import '../../../screens/activities_colors.dart';
import '../clubs_controller.dart';
import '../motion.dart';

/// "مين سمعها؟": listen progress for the week's episode, plus a personal
/// "سمعتها" toggle. [heardBy], [iHeard] and [total] come from the clubs
/// controller, so this card always reflects the shared state.
class PodcastHeardCard extends StatelessWidget {
  final List<ClubReader> heardBy;
  final bool iHeard;
  final int total;
  final VoidCallback onToggleHeard;
  const PodcastHeardCard({
    super.key,
    required this.heardBy,
    required this.iHeard,
    required this.total,
    required this.onToggleHeard,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final count = heardBy.length + (iHeard ? 1 : 0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AC.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.clubsWhoHeardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AC.ink,
                  ),
                ),
              ),
              Text(
                l.clubsScoreOutOf(count, total),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AC.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: count / total),
              duration: clubsMotionDuration(context, 300),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                color: AC.teal,
                backgroundColor: AC.track,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // tap the pictures to see who heard it, right here
          Builder(
            builder: (context) {
              var listOpen = false; // lives in this little builder, so only the list redraws
              return StatefulBuilder(
                builder: (context, setOpen) {
                  final names = [
                    for (final r in heardBy) r.name,
                    if (iHeard) profile.name,
                  ];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Semantics(
                            label: l.clubsWhoHeardAvatarsLabel,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: names.isEmpty
                                  ? null
                                  : () => setOpen(() => listOpen = !listOpen),
                              child: Row(
                                children: [_AvatarStack(readers: heardBy)],
                              ),
                            ),
                          ),
                          const Spacer(),
                          _HeardButton(heard: iHeard, onTap: onToggleHeard),
                        ],
                      ),
                      if (listOpen && names.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: PeopleList(names),
                        ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AC.tealTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 14, color: AC.textSoft),
                children: [
                  TextSpan(
                    text: l.activitiesPodcastYourTurnBold,
                    style: const TextStyle(
                      color: AC.tealDeep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: ' ${l.clubsHalfFamilyFinished}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final List<ClubReader> readers;
  const _AvatarStack({required this.readers});
  static const _size = 32.0;
  static const _overlap = 10.0;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: readers.isEmpty
        ? 0
        : (readers.length - 1) * (_size - _overlap) + _size,
    height: _size,
    child: Stack(
      children: [
        for (var i = 0; i < readers.length; i++)
          PositionedDirectional(
            start: i * (_size - _overlap),
            child: Avatar(readers[i].name, size: _size), // real profile picture
          ),
      ],
    ),
  );
}

class _HeardButton extends StatelessWidget {
  final bool heard;
  final VoidCallback onTap;
  const _HeardButton({required this.heard, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      toggled: heard,
      child: Material(
        color: heard ? AC.teal : AC.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AC.teal),
            ),
            child: Text(
              heard ? l.clubsHeardButtonOn : l.clubsHeardButton,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: heard ? Colors.white : AC.tealDeep,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
