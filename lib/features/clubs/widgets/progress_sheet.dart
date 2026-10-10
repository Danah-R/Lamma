import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';

/// "سجّل وين وصلت": a floating card (same presentation as [SuggestSheet])
/// where you drag to your current page and save. Returns the chosen page
/// count, or null if cancelled.
class ProgressSheet extends StatefulWidget {
  final String bookTitle;
  final int totalPages;
  final int initialPage;
  const ProgressSheet({
    super.key,
    required this.bookTitle,
    required this.totalPages,
    required this.initialPage,
  });

  static Future<int?> show(
    BuildContext context, {
    required String bookTitle,
    required int totalPages,
    required int initialPage,
  }) => showGeneralDialog<int>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => ProgressSheet(
      bookTitle: bookTitle,
      totalPages: totalPages,
      initialPage: initialPage,
    ),
    transitionBuilder: (context, animation, _, child) {
      if (MediaQuery.of(context).disableAnimations) {
        return FadeTransition(opacity: animation, child: child);
      }
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, .06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      );
    },
  );

  @override
  State<ProgressSheet> createState() => _ProgressSheetState();
}

class _ProgressSheetState extends State<ProgressSheet> {
  late int _page = widget.initialPage.clamp(0, widget.totalPages);

  void _markFinished() => setState(() => _page = widget.totalPages);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    // Clears the Shell's floating bottom nav bar (76 tall + 6 bottom
    // padding) plus its own safe-area inset, with a little breathing room.
    final navBarClearance = 96.0 + media.padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          navBarClearance + media.viewInsets.bottom,
        ),
        child: Material(
          color: AC.card,
          borderRadius: BorderRadius.circular(26),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AC.brick,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l.clubsLogProgressSheetTitle(widget.bookTitle),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AC.ink,
                          ),
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: l.clubsClose,
                      child: Material(
                        color: AC.card,
                        shape: const CircleBorder(
                          side: BorderSide(color: AC.border),
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AC.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    l.clubsPageOfTotal(_page, widget.totalPages),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AC.brick,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AC.brick,
                    thumbColor: AC.brick,
                    inactiveTrackColor: AC.track,
                  ),
                  child: Slider(
                    value: _page.toDouble(),
                    min: 0,
                    max: widget.totalPages.toDouble(),
                    onChanged: (v) => setState(() => _page = v.round()),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _markFinished,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AC.brick,
                      side: const BorderSide(color: AC.brick),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l.clubsMarkAsFinished,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_page),
                    style: FilledButton.styleFrom(
                      backgroundColor: AC.brick,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l.clubsSaveButton,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
