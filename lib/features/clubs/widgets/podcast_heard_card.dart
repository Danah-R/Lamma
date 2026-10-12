import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
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
        border: Border.all(color: AC.border),
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
                    fontWeight: FontWeight.w800,
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
                  fontWeight: FontWeight.w800,
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
          Row(
            children: [
              Semantics(
                label: l.clubsWhoHeardAvatarsLabel,
                child: _AvatarStack(readers: heardBy),
              ),
              const Spacer(),
              _HeardButton(heard: iHeard, onTap: onToggleHeard),
            ],
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
                      fontWeight: FontWeight.w800,
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
            child: Container(
              width: _size,
              height: _size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: readers[i].color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                readers[i].initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
                fontWeight: FontWeight.w800,
                color: heard ? Colors.white : AC.tealDeep,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
