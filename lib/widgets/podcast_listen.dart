import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets.dart' show LCard;

/// The Apple Podcasts page of the show behind this week's episode (فاهم).
const fahemAppleUrl =
    'https://podcasts.apple.com/sa/podcast/%D9%81%D8%A7%D9%87%D9%85/id1657745574';

/// A YouTube search for [text] (used when a podcast has no link of its own).
String youtubeSearchUrl(String text) =>
    'https://www.youtube.com/results?search_query=${Uri.encodeQueryComponent(text)}';

/// An Apple Podcasts search for [text] (used when a podcast has no link of its own).
String appleSearchUrl(String text) =>
    'https://podcasts.apple.com/sa/search?term=${Uri.encodeQueryComponent(text)}';

/// The YouTube (red play mark) or Apple Podcasts logo, as a small rounded square.
class PlatformLogo extends StatelessWidget {
  final bool apple;
  final double size;
  const PlatformLogo({super.key, required this.apple, required this.size});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * .25),
    child: SizedBox(
      width: size,
      height: size,
      child: apple
          ? Transform.scale(
              scale: 1.12,
              child: Image.asset(
                'assets/podcast/apple_podcasts.jpg',
                fit: BoxFit.cover,
              ),
            )
          : ColoredBox(
              color: const Color(0xFFFF0000),
              child: Center(
                child: Container(
                  width: size * .6,
                  height: size * .43,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size * .13),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: const Color(0xFFFF0000),
                    size: size * .36,
                  ),
                ),
              ),
            ),
    ),
  );
}

/// The big "Start listening" button with the two tiny app logos inside it.
class StartListeningButton extends StatelessWidget {
  final VoidCallback onPressed;
  const StartListeningButton({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: C.navy,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 24),
            const SizedBox(width: 6),
            Text(
              l.homeStartListening,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 12),
            const PlatformLogo(apple: false, size: 20),
            const SizedBox(width: 6),
            const PlatformLogo(apple: true, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Asks "where do you want to listen?" (YouTube or Apple Podcasts) and opens the one picked.
Future<void> chooseListenApp(
  BuildContext context, {
  required String youtubeUrl,
  required String appleUrl,
}) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final url = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: C.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.podcastWhereToListen,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: C.navy,
              ),
            ),
            const SizedBox(height: 12),
            // two separate, narrower cards side by side with a clear gap
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final o in [
                    (false, 'YouTube', youtubeUrl),
                    (true, 'Apple Podcasts', appleUrl),
                  ]) ...[
                    if (o.$1) const SizedBox(width: 16),
                    Expanded(
                      child: LCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
                        onTap: () => Navigator.pop(ctx, o.$3),
                        child: Column(
                          children: [
                            PlatformLogo(apple: o.$1, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              o.$2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (url == null) return;
  final ok = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  if (!ok) messenger.showSnackBar(SnackBar(content: Text(l.soonPageMessage)));
}
