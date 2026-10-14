import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../../../widgets/podcast_listen.dart';
import '../clubs_controller.dart';

/// "حلقة الأسبوع": the same episode as the home page (cover, title, length) with the same
/// "Start listening" button, which asks YouTube or Apple Podcasts.
class EpisodeCard extends StatelessWidget {
  final PodcastEpisode episode;
  const EpisodeCard({super.key, required this.episode});

  Future<void> _listen(BuildContext context) => chooseListenApp(
    context,
    youtubeUrl: episode.youtubeUrl,
    appleUrl: episode.appleUrl ?? fahemAppleUrl,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AC.card,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AC.tealTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              l.clubsEpisodeOfWeekBadge,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AC.teal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // the cover: tapping it works like "Start listening"
          Semantics(
            button: true,
            label: l.homeStartListening,
            child: GestureDetector(
              onTap: () => _listen(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/podcast/episode_thumbnail.jpg',
                        fit: BoxFit.cover,
                      ),
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            episode.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: AC.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l.homePodcastEpisode,
            style: const TextStyle(fontSize: 13, color: AC.muted),
          ),
          const SizedBox(height: 16),
          Text(
            l.clubsAboutEpisodeHeading,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AC.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            episode.about,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: AC.textSoft,
            ),
          ),
          const SizedBox(height: 16),
          StartListeningButton(onPressed: () => _listen(context)),
        ],
      ),
    );
  }
}
