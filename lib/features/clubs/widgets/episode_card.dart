import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../clubs_controller.dart';

/// "حلقة الأسبوع": the week's podcast pick, with Apple Podcasts / YouTube
/// links.
class EpisodeCard extends StatelessWidget {
  final PodcastEpisode episode;
  const EpisodeCard({super.key, required this.episode});

  Future<void> _openYoutube(BuildContext context) async {
    final uri = Uri.parse(episode.youtubeUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.soonPageMessage)));
    }
  }

  Future<void> _appleTap(BuildContext context) async {
    final appleUrl = episode.appleUrl;
    if (appleUrl == null) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.soonPageMessage)));
      return;
    }
    await launchUrl(Uri.parse(appleUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AC.card,
        border: Border.all(color: AC.border),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 108,
                height: 108,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AC.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const CustomPaint(
                  size: Size(108, 108),
                  painter: _EpisodeArtPainter(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AC.tealTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l.clubsEpisodeOfWeekBadge,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AC.teal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${episode.host} · ${episode.platform}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AC.muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      episode.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                        color: AC.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AC.muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          episode.duration,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AC.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l.clubsAboutEpisodeHeading,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
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
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () => _appleTap(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AC.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l.clubsApplePodcasts,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () => _openYoutube(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AC.brick,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l.clubsYoutube,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EpisodeArtPainter extends CustomPainter {
  const _EpisodeArtPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final ringPaint = Paint()
      ..color = AC.gamesTeal
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
      c,
      size.width * .407,
      ringPaint..strokeWidth = size.width * .093,
    );
    canvas.drawCircle(
      c,
      size.width * .241,
      ringPaint..strokeWidth = size.width * .074,
    );

    final micPaint = Paint()..color = Colors.white;
    final micWidth = size.width * .056, micHeight = size.width * .102;
    final micRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy - size.height * .11),
      width: micWidth,
      height: micHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(micRect, Radius.circular(micWidth / 2)),
      micPaint,
    );
    final standPath = Path()
      ..moveTo(c.dx - size.width * .065, c.dy - size.height * .02)
      ..arcToPoint(
        Offset(c.dx + size.width * .065, c.dy - size.height * .02),
        radius: Radius.circular(size.width * .065),
        clockwise: true,
      );
    canvas.drawPath(
      standPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .015
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(c.dx, c.dy - size.height * .02 + size.width * .065),
      Offset(c.dx, c.dy + size.height * .09),
      Paint()
        ..color = Colors.white
        ..strokeWidth = size.width * .015
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _EpisodeArtPainter oldDelegate) => false;
}
