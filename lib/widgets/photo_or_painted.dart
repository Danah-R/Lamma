import 'package:flutter/material.dart';

/// A bundled photo that fades in over a drawn stand-in. If the asset isn't
/// there (yet), nothing breaks: the stand-in simply stays, with no error.
class PhotoOrPainted extends StatelessWidget {
  final String? assetPath;

  /// What shows when there's no photo (and underneath while it loads).
  final Widget fallback;
  final BoxFit fit;
  final Alignment
  alignment; // which part of the photo stays in view when it is cropped
  const PhotoOrPainted({
    super.key,
    required this.assetPath,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path == null) return fallback;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(
      builder: (context, c) => Stack(
        fit: StackFit.expand,
        children: [
          fallback,
          Image.asset(
            path,
            fit: fit,
            alignment: alignment,
            // decode no bigger than it is shown
            cacheWidth: c.maxWidth.isFinite ? (c.maxWidth * dpr).round() : null,
            frameBuilder: (context, child, frame, sync) {
              if (sync) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: Duration(milliseconds: reduce ? 0 : 250),
                child: child,
              );
            },
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
