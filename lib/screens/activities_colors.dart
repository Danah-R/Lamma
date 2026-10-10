import 'package:flutter/material.dart';

/// Palette for the redesigned Activities page ("صندوق الأنشطة"), matching
/// design/activities_design_reference.html pixel-for-pixel. Scoped to this
/// page only — the rest of the app keeps using [C] from `theme.dart`.
class AC {
  static const background = Color(0xFFFBF4EA);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFEADFCF);
  static const ink = Color(0xFF2B211E);
  static const muted = Color(0xFF6B5D55);
  static const brick = Color(0xFF9A4A3E);
  static const navy = Color(0xFF1E2A47);
  static const mustard = Color(0xFFDEB461);
  static const salmon = Color(0xFFE29079);
  static const teal = Color(0xFF3E7A75);
  static const sage = Color(0xFF8FA580);
  static const track = Color(0xFFF1E8DA);

  static const salmonTint = Color(0xFFF6DDD3);
  static const tealTint = Color(0xFFD6E7E4);
  static const mustardTint = Color(0xFFF5E7C4);
  static const sageTint = Color(0xFFE1E9D8);

  // one-off accents from the reference that aren't part of the main swatch
  static const dotInactive = Color(0xFFE5D7C3);
  static const textSoft = Color(0xFF5A4A44); // roulette card desc, tree trunk
  static const brickDeep = Color(0xFF7A3A30); // "whose turn tonight" badge text
  static const sinJimDesc = Color(0xFF45524F);
  static const lettersDesc = Color(0xFF5A4E36);
  static const sageLight = Color(0xFFC7D6B8); // back hill in the outing scene
  static const treeGreen = Color(0xFF6E8A60);
  static const votedText = Color(0xFF3F5634);
  static const cardShadow = Color(0x1A5B3A28);

  // weekend-outing place scenes (park reuses sageTint/sage/treeGreen/textSoft above)
  static const wadiSky = Color(0xFFF3E2C7);
  static const wadiBar = Color(0xFFC49A6C);
  static const wadiDune = Color(0xFFD9B98C);
  static const wadiWater = Color(0xFF9CC3C0);
  static const citySkyline = Color(0xFF2E3B5E);
  static const cityForeground = Color(0xFF1A2440);

  // games page ("الألعاب") — navy2 is the same shade as citySkyline above
  static const navy2 = citySkyline;
  static const gamesTeal = Color(0xFF4A8A85);
  static const heroDescText = Color(0xFFC9CFDD);

  static const huroofArt = Color(0xFFEED9A6);
  static const seenArt = Color(0xFFBFD9D5);
  static const freezeArt = Color(0xFFCBD9BE);
  static const freezeFigure = Color(0xFF5A7050);
  static const charadesDesc = Color(0xFFD5DAE6);
  static const photoArt = Color(0xFFEFC6B6);

  // clubs page ("النوادي")
  static const reminderBorder = Color(0xFF3A4766);
  static const salmonCoverSub = Color(
    0xFF5A2E24,
  ); // author text on the salmon book cover
  static const bookFormDisabled = Color(0xFFC9A79F);
  static const podcastFormDisabled = Color(0xFF9DBDB9);
  static const handleBar = Color(0xFFE5D7C3); // bottom-sheet drag handle
  static const tealDeep = Color(0xFF2F6662); // "سمعتها" button text
}
