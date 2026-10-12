import 'package:flutter/material.dart';

/// Single source of truth for the Lamma color system.
///
/// How the palette is meant to be used (roughly 55% neutral, 20% brick,
/// 15% teal + navy, 10% supporting colors):
///  * ivory is the page, white is for containers
///  * brick: primary buttons, selected states, progress, important actions
///  * teal: secondary actions, activity highlights
///  * navy: headings, the tab bar, dark panels
///  * peach, sage, yellow, lavender: used selectively to tell content apart.
///    They are mostly *fills*: they are too light to carry text or icons on white.
class C {
  // ---- surfaces
  static const cream = Color(0xFFF6F6F6); // neutral, slightly dimmed white: the page, so white containers stand out
  static const card = Color(0xFFFFFFFF); // containers

  // ---- brand
  static const brick = Color(0xFFB84A3A);
  static const teal = Color(0xFF176B6B);
  static const navy = Color(0xFF263B63);

  // ---- supporting colors
  static const peach = Color(0xFFF3C09C);
  static const sage = Color(0xFFA7C4A2);
  static const yellow = Color(0xFFF4D27F);
  static const lavender = Color(0xFFD8D0E8);

  // ---- text
  static const ink = Color(0xFF29313D); // primary text
  static const inkSoft = Color(0xFF746F6B); // secondary text

  // ---- derived (a palette color blended into the ivory page)
  static const line = Color(0xFFECE4DE); // dividers and progress tracks
  static const sand = Color(0xFFDCD5D0); // disabled fills
  static const field = Color(0xFFFCEBDE); // input fields: a subtle warm neutral
  static const brickTint = Color(0xFFF5DFD7);
  static const peachTint = Color(0xFFFBE6D8);
  static const tealTint = Color(0xFFD8E6E6); // teal at ~17% on white: the light version of teal
  static const sageTint = Color(0xFFDCE3D1);
  static const yellowTint = Color(0xFFFBE9C6);
  static const sageDark = Color(0xFF33582D); // sage, deepened: chosen interests
  static const lavenderTint = Color(0xFFEDE5ED);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: C.brick,
    brightness: Brightness.light,
  ).copyWith(
    primary: C.brick,
    onPrimary: Colors.white,
    secondary: C.teal,
    onSecondary: Colors.white,
    tertiary: C.yellow,
    onTertiary: C.ink,
    surface: C.cream,
    onSurface: C.ink,
    outline: C.line,
    outlineVariant: C.line,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.cream,
    fontFamily: 'Thmanyah',
    fontFamilyFallback: const ['SF Arabic', 'Geeza Pro', 'Noto Sans Arabic', 'Roboto'],
    textTheme: Typography.blackMountainView
        .apply(bodyColor: C.ink, displayColor: C.navy, fontFamily: 'Thmanyah'),
    appBarTheme: const AppBarTheme(
      backgroundColor: C.cream,
      foregroundColor: C.navy,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: 'Thmanyah', color: C.navy, fontSize: 18, fontWeight: FontWeight.w700),
    ),
    dividerTheme: const DividerThemeData(color: C.line, thickness: 1),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? C.teal : C.sand),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: C.brick, linearTrackColor: C.line),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.card, // text fields are white
      hintStyle: const TextStyle(color: C.inkSoft),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
}
