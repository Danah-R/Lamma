import 'package:flutter/material.dart';

/// Single source of truth for the Lamma palette. Adjust here to match the
/// reference image exactly.
class C {
  static const cream = Color(0xFFFBF4E8);
  static const beige = Color(0xFFEFE2CC);
  static const sand = Color(0xFFE2D0B2);
  static const terracotta = Color(0xFFA4443B);
  static const coral = Color(0xFFEE8D75);
  static const teal = Color(0xFF2E8B88);
  static const green = Color(0xFF86A57E);
  static const mustard = Color(0xFFE6B350);
  static const ink = Color(0xFF3D2B23);
  static const inkSoft = Color(0xFF7D6A5E);
  static const navy = Color(0xFF1B2A45);
  static const card = Color(0xFFFFFBF4);

  // soft tints for card backgrounds
  static const coralTint = Color(0xFFF8D9CC);
  static const tealTint = Color(0xFFCDE4E0);
  static const greenTint = Color(0xFFDCE6D3);
  static const mustardTint = Color(0xFFF6E3B5);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: C.terracotta,
    primary: C.terracotta,
    secondary: C.teal,
    surface: C.cream,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.cream,
    fontFamilyFallback: const ['SF Arabic', 'Geeza Pro', 'Noto Sans Arabic', 'Roboto'],
    textTheme: Typography.blackMountainView.apply(bodyColor: C.ink, displayColor: C.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: C.cream,
      foregroundColor: C.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: C.ink, fontSize: 18, fontWeight: FontWeight.w800),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.navy,
      indicatorColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontSize: 11,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
            color: s.contains(WidgetState.selected) ? C.coral : const Color(0xFFA9B3C6),
          )),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? C.coral : const Color(0xFFA9B3C6),
          )),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: C.sand),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: C.sand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: C.terracotta, width: 1.5),
      ),
    ),
  );
}
