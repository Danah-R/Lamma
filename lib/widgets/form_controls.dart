import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Form controls shared by onboarding and "Edit your account": iPhone-style 17pt
/// text, 52pt inputs, a segmented control, an inset grouped list, tags and cards.
const kInterests = [
  'Coffee',
  'Games',
  'Reading',
  'Walking',
  'Podcasts',
  'Movies',
  'Cooking',
  'Drawing',
  'Football',
  'Swimming',
  'Music',
  'Travel',
];
const kOutingTypes = ['Nature', 'Restaurants', 'Cafés', 'Entertainment'];

// ---------------------------------------------------------------------------
class FormStyle {
  static const margin = 20.0;
  static const title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -.4,
    color: C.ink,
  );
  static const subtitle = TextStyle(
    fontSize: 16,
    height: 1.35,
    color: C.inkSoft,
  );
  static const body = TextStyle(fontSize: 17, height: 1.25);
  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: C.inkSoft,
  );
}

/// A small gray label above its content.
class FormSection extends StatelessWidget {
  final String label;
  final Widget child;
  const FormSection(this.label, this.child);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
        child: Text(label, style: FormStyle.label),
      ),
      child,
    ],
  );
}

class FormTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final IconData? icon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? formatters;
  final TextCapitalization textCapitalization;
  final TextDirection? textDirection; // phone numbers always read left to right
  const FormTextField({
    this.label,
    required this.hint,
    this.icon,
    this.controller,
    this.onChanged,
    this.keyboard,
    this.formatters,
    this.textCapitalization = TextCapitalization.none,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboard,
      inputFormatters: formatters,
      textCapitalization: textCapitalization,
      textDirection: textDirection,
      cursorColor: C.brick,
      style: FormStyle.body,
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: textDirection,
        hintStyle: FormStyle.body.copyWith(
          color: C.inkSoft.withValues(alpha: .6),
        ),
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: C.inkSoft, size: 22),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: C.brick, width: 1.5),
        ),
      ),
    );
    return label == null ? field : FormSection(label!, field);
  }
}

/// One rounded container with the options inside: the chosen one is the deep color,
/// the others sit on the lighter version of it.
class SegmentedChoice extends StatelessWidget {
  final List<(String, String)> options; // (key, label)
  final String? selected;
  final ValueChanged<String> onChanged;
  final Color track, on; // light and deep version of one color
  const SegmentedChoice({
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.track,
    required this.on,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: track,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        for (final o in options)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(o.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected == o.$1 ? on : Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Text(
                  o.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected == o.$1
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected == o.$1 && on.computeLuminance() < .4
                        ? Colors.white
                        : C.ink,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Inset grouped list. The chosen row is highlighted as a whole and ends in a
/// filled radio circle (dark circle, white dot).
class GroupedChoiceList extends StatelessWidget {
  final List<(String, String)> rows; // (key, label)
  final String? selected;
  final ValueChanged<String> onTap;
  final Color
  highlight,
  accent; // its own color pair, so it differs from the list/segment next to it
  const GroupedChoiceList({
    required this.rows,
    required this.selected,
    required this.onTap,
    this.highlight = C.peachTint,
    this.accent = C.brick,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Material(
      color: C.card,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: .5,
                indent: 16,
                color: C.line,
              ),
            Ink(
              color: selected == rows[i].$1 ? highlight : C.card,
              child: InkWell(
                onTap: () => onTap(rows[i].$1),
                child: SizedBox(
                  height: 44,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            rows[i].$2,
                            style: FormStyle.body.copyWith(
                              fontSize: 16,
                              fontWeight: selected == rows[i].$1
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        RadioDot(selected == rows[i].$1, accent),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Dark circle with a white dot when chosen; a plain light circle otherwise.
class RadioDot extends StatelessWidget {
  final bool on;
  final Color color;
  const RadioDot(this.on, [this.color = C.teal]);
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    width: 22,
    height: 22,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: on ? color : C.line,
      shape: BoxShape.circle,
    ),
    child: on
        ? Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          )
        : null,
  );
}

class ChoiceTag extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color idle; // resting fill: a light tint
  final Color on; // selected fill: the solid color of the same family
  const ChoiceTag(
    this.label,
    this.selected,
    this.onTap, {
    this.idle = C.sageTint,
    this.on = C.sageDark,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? on : idle,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          height: 1.25,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? Colors.white : C.ink,
        ),
      ),
    ),
  );
}

/// Full-width 50pt button with a medium-weight 17pt label.
class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool tinted;
  const ActionButton(this.label, {required this.onTap, this.tinted = false});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 50,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: tinted ? C.card : C.brick,
        foregroundColor: tinted ? C.brick : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        // build on the theme's style so the app font is kept
        textStyle: Theme.of(context).textTheme.labelLarge
            ?.copyWith(fontSize: 17, fontWeight: FontWeight.w500),
      ),
      child: Text(label),
    ),
  );
}

/// A selectable container: a colored top with the icon, a line, then the label on white.
class ChoiceCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? icon;
  final Color tint; // fill behind the icon
  final double iconSize;
  // ignore: unused_element_parameter
  const ChoiceCard(
    this.label,
    this.selected,
    this.onTap, {
    this.icon,
    this.tint = C.peachTint,
    this.iconSize = 88,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 190,
      // the border is drawn over the card and only exists while chosen
      foregroundDecoration: selected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.brick, width: 2),
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: tint,
                alignment: Alignment.center,
                child: SizedBox(height: iconSize, width: iconSize, child: icon),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: C.line),
            SizedBox(
              height: 52,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? C.brick : C.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
