import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';

enum SuggestType { book, podcast }

/// What the "اقترح كتاب/بودكاست" form collected.
class SuggestResult {
  final String title, by, category, about;
  const SuggestResult({
    required this.title,
    required this.by,
    required this.category,
    required this.about,
  });
}

/// A floating card for suggesting a book or a podcast — generic over
/// [SuggestType] so the same form serves both clubs. Shown as a floating
/// box (not an edge-to-edge bottom sheet) so it never sits behind the
/// bottom navigation bar, and stays within this tab's own navigator so
/// it doesn't escape to the root.
class SuggestSheet extends StatefulWidget {
  final SuggestType type;
  const SuggestSheet({super.key, required this.type});

  /// Shows the card and resolves to the submitted result, or null if the
  /// person cancelled / dismissed it.
  static Future<SuggestResult?> show(
    BuildContext context,
    SuggestType type,
  ) => showGeneralDialog<SuggestResult>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => SuggestSheet(type: type),
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
  State<SuggestSheet> createState() => _SuggestSheetState();
}

class _SuggestSheetState extends State<SuggestSheet> {
  final _title = TextEditingController();
  final _by = TextEditingController();
  final _about = TextEditingController();
  final _customCategory = TextEditingController();
  String? _selectedChip;

  bool get _isBook => widget.type == SuggestType.book;
  bool get _isOther =>
      _selectedChip != null &&
      _selectedChip == _otherLabel(AppLocalizations.of(context));
  Color get _accent => _isBook ? AC.brick : AC.teal;
  Color get _disabledAccent =>
      _isBook ? AC.bookFormDisabled : AC.podcastFormDisabled;

  String _otherLabel(AppLocalizations l) => l.clubsCatOther;

  List<String> _categories(AppLocalizations l) => [
    ..._isBook
        ? [
            l.clubsCatNovel,
            l.clubsCatBiographyHistory,
            l.clubsCatLiteratureEssays,
            l.clubsCatSelfDev,
            l.clubsCatFaith,
            l.clubsCatManners,
          ]
        : [
            l.clubsCatRelationships,
            l.clubsCatSelfDev,
            l.clubsCatCulture,
            l.clubsCatStories,
            l.clubsCatReligion,
            l.clubsCatParenting,
          ],
    l.clubsCatOther,
  ];

  String? get _category {
    final l = AppLocalizations.of(context);
    if (_selectedChip == null) return null;
    if (_selectedChip == l.clubsCatOther) {
      final custom = _customCategory.text.trim();
      return custom.isEmpty ? null : custom;
    }
    return _selectedChip;
  }

  @override
  void initState() {
    super.initState();
    _title.addListener(_refresh);
    _customCategory.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _title.dispose();
    _by.dispose();
    _about.dispose();
    _customCategory.dispose();
    super.dispose();
  }

  void _submit() {
    final category = _category;
    if (_title.text.trim().isEmpty || category == null) return;
    Navigator.of(context).pop(
      SuggestResult(
        title: _title.text.trim(),
        by: _by.text.trim(),
        category: category,
        about: _about.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ready = _title.text.trim().isNotEmpty && _category != null;
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
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * .72),
          child: Material(
            color: AC.card,
            borderRadius: BorderRadius.circular(26),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
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
                          color: _accent,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isBook
                                  ? l.clubsSuggestBook
                                  : l.clubsSuggestPodcastHeading,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AC.ink,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              l.clubsSuggestFormSubtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AC.muted,
                              ),
                            ),
                          ],
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
                  const SizedBox(height: 14),
                  _FormField(
                    label: _isBook
                        ? l.clubsBookNameLabel
                        : l.clubsPodcastNameLabel,
                    hint: _isBook
                        ? l.clubsBookNameHint
                        : l.clubsPodcastNameHint,
                    controller: _title,
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    label: _isBook
                        ? l.clubsBookAuthorLabel
                        : l.clubsPodcastHostLabel,
                    hint: _isBook
                        ? l.clubsBookAuthorHint
                        : l.clubsPodcastHostHint,
                    controller: _by,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l.clubsCategoryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AC.textSoft,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final cat in _categories(l))
                        _CategoryChip(
                          label: cat,
                          selected: _selectedChip == cat,
                          accent: _accent,
                          onTap: () => setState(() => _selectedChip = cat),
                        ),
                    ],
                  ),
                  if (_isOther) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _customCategory,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: l.clubsCustomCategoryHint,
                          filled: true,
                          fillColor: AC.background,
                          contentPadding: const EdgeInsetsDirectional.only(
                            start: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AC.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AC.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _accent, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        l.clubsAboutShort,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AC.textSoft,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_about.text.length}/160',
                        maxLines: 1,
                        style: const TextStyle(fontSize: 12, color: AC.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _about,
                    maxLength: 160,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: _isBook
                          ? l.clubsBookAboutHint
                          : l.clubsPodcastAboutHint,
                      filled: true,
                      fillColor: AC.background,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AC.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AC.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _accent, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: ready ? _submit : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: _accent,
                              disabledBackgroundColor: _disabledAccent,
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              l.clubsAddToSuggestions,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AC.card,
                            foregroundColor: AC.ink,
                            side: const BorderSide(color: AC.border),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            l.clubsCancel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AC.textSoft,
        ),
      ),
      const SizedBox(height: 6),
      SizedBox(
        height: 48,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AC.background,
            contentPadding: const EdgeInsetsDirectional.only(start: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AC.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AC.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AC.border, width: 1.5),
            ),
          ),
        ),
      ),
    ],
  );
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        // The visual chip stays compact; the tappable area around it
        // still meets the 44×44 minimum via this outer constraint.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(minHeight: 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? accent : AC.card,
                borderRadius: BorderRadius.circular(18),
                border: selected ? null : Border.all(color: AC.border),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AC.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
