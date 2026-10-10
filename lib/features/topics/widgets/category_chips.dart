import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/activities_colors.dart';
import '../topics_data.dart';

/// Horizontal, scrollbar-less filter bar: "الكل" + one chip per category.
class CategoryChips extends StatelessWidget {
  final List<TopicCategory> categories;
  final String? selected; // null = all
  final ValueChanged<String?> onSelect;
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: l.topicsGroupLabel,
      child: SizedBox(
        height: 44,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _Chip(
                label: l.topicsAll,
                selected: selected == null,
                activeBg: AC.navy,
                onTap: () => onSelect(null),
              ),
              for (final c in categories) ...[
                const SizedBox(width: 8),
                _Chip(
                  label: c.label(l),
                  dot: c.color,
                  selected: selected == c.id,
                  activeBg: c.color,
                  activeFg: c.id == 'food' ? AC.navy : Colors.white,
                  onTap: () => onSelect(c.id),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? dot;
  final bool selected;
  final Color activeBg;
  final Color activeFg;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.selected,
    required this.activeBg,
    required this.onTap,
    this.dot,
    this.activeFg = Colors.white,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? activeBg : AC.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? Colors.transparent : AC.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dot != null) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : dot,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? activeFg : AC.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
