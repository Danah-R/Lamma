import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/l10n/app_localizations.dart';
import 'package:lamma/main.dart';
import 'package:lamma/screens/activities.dart';

final _navBar = find.byIcon(Icons.camera_alt_rounded);

Finder _tile(String title) =>
    find.descendant(of: find.byType(GameTile), matching: find.text(title));

Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 300));
  }
}

Future<void> _tap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f.first);
  await t.pump();
  await t.tap(f.first);
  await _settle(t);
}

Future<void> _tapText(WidgetTester t, String s) => _tap(t, find.text(s));

/// Taps and advances a single zero-time frame, so a timer that resumes on
/// this tap has not ticked yet when the caller reads it.
Future<void> _tapNoTime(WidgetTester t, String s) async {
  await t.tap(find.text(s).first);
  await t.pump();
}

/// Games list on its own (the Activities page's weekend cards overflow under
/// the wide test font at 360, which is unrelated to the games).
Future<void> _openGamesDirect(WidgetTester t, Size size) async {
  await t.binding.setSurfaceSize(size);
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const GamesPage(),
    ),
  );
  await t.pump(const Duration(seconds: 1));
}

Future<void> _openGames(WidgetTester t, Size size) async {
  await t.binding.setSurfaceSize(size);
  await t.pumpWidget(const LammaApp(skipOnboarding: true));
  await t.pump(const Duration(seconds: 1));
  await _tap(t, find.text('صندوق الأنشطة').last);
  await _tapText(t, 'عرض الكل');
}

/// Seconds shown in the charades play screen ("NN ث").
int _charadesSeconds(WidgetTester t) {
  final f = find.byWidgetPredicate(
    (w) => w is Text && RegExp(r'^\d+ ث$').hasMatch(w.data ?? ''),
  );
  return int.parse((t.widget<Text>(f.first).data!).replaceAll(' ث', ''));
}

/// The big number in the who-am-i timer.
int _whoAmISeconds(WidgetTester t) {
  final f = find.byWidgetPredicate(
    (w) =>
        w is Text &&
        RegExp(r'^\d+$').hasMatch(w.data ?? '') &&
        (w.style?.fontSize == 30),
  );
  return int.parse(t.widget<Text>(f.first).data!);
}

/// Every visible button (semantics) must be at least 44x44 and every
/// icon-only one must carry a label.
void _checkButtons(WidgetTester t, String where) {
  final root =
      t.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!;
  void walk(SemanticsNode n) {
    final data = n.getSemanticsData();
    if (data.flagsCollection.isButton && !n.isInvisible) {
      final r = n.rect;
      expect(
        r.width >= 43.5 && r.height >= 43.5,
        isTrue,
        reason: '$where: button "${data.label}" is ${r.size}',
      );
      expect(
        data.label.trim().isNotEmpty,
        isTrue,
        reason: '$where: unlabeled button at $r',
      );
    }
    n.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(root);
}

Future<void> _playAllGames(WidgetTester t) async {
  // ---- seen jeem
  await _tap(t, _tile('سين جيم'));
  expect(_navBar, findsNothing);
  await _tapText(t, 'يلا نبدأ');
  await _tapText(t, 'صح! +1');
  await _tapText(t, 'غلط');
  await _tap(t, find.byIcon(Icons.close_rounded));
  await _tapText(t, 'إي، أنهِ');
  expect(find.text('أكثر واحد يعرف العائلة'), findsOneWidget);
  await _tapText(t, 'الألعاب');

  // ---- who am i (all four categories render)
  await _tap(t, _tile('مين أنا؟'));
  for (final c in ['أماكن', 'مهن', 'أكلات', 'حيوانات']) {
    await _tapText(t, c);
  }
  await _tapText(t, '90 ث');
  await _tapText(t, 'يلا نبدأ');
  await _tapText(t, 'عرفتها!');
  await _tapText(t, 'تخطّي');
  await _tap(t, find.byIcon(Icons.close_rounded));
  await _tapText(t, 'إي، أنهِ');
  expect(find.text('خلص الوقت!'), findsOneWidget);
  await _tapText(t, 'الألعاب');

  // ---- charades
  await _tap(t, _tile('ولا كلمة'));
  await _tapText(t, '5 جولات');
  await _tapText(t, 'يلا نبدأ');
  await _tap(t, find.textContaining('جاهز'));
  await _tapText(t, 'اضغط وشوف الكلمة');
  await _tapText(t, 'عرفوها! +1');
  await _tapText(t, 'انهِ الدور');
  await _tapText(t, 'إي، أنهِ');
  await _tapText(t, 'إنهاء اللعبة');
  await _tapText(t, 'إي، أنهِ');
  expect(find.text('الفريق الفائز'), findsOneWidget);
  await _tapText(t, 'الألعاب');
  expect(find.text('كل الألعاب'), findsOneWidget);
}

void main() {
  group('arabic plurals', () {
    test('rounds / members / games / questions', () {
      final l = lookupAppLocalizations(const Locale('ar'));
      expect(l.charadesRoundsOption(2), 'جولتين');
      expect(l.charadesRoundsOption(3), '3 جولات');
      expect(l.charadesRoundsOption(5), '5 جولات');
      expect(l.charadesMembersCount(0), 'ما فيه أحد');
      expect(l.charadesMembersCount(1), 'عضو واحد');
      expect(l.charadesMembersCount(2), 'عضوين');
      expect(l.charadesMembersCount(3), '3 أعضاء');
      expect(l.gamesCountText(1), 'لعبة وحدة');
      expect(l.gamesCountText(2), 'لعبتين');
      expect(l.gamesCountText(3), '3 ألعاب');
      expect(l.gamesCountText(6), '6 ألعاب');
      expect(l.seenQuestionsOption(5), '5 أسئلة');
      expect(l.seenQuestionsOption(8), '8 أسئلة');
      expect(l.seenQuestionsOption(12), '12 سؤال');
      expect(l.seenPlayersCount(3), '3 لاعبين');
      expect(l.seenPointsCount(2), 'نقطتين');
    });
  });

  testWidgets('system back asks first; timers pause and resume exactly', (
    t,
  ) async {
    await _openGames(t, const Size(400, 850));

    // charades
    await _tap(t, _tile('ولا كلمة'));
    await _tapText(t, 'يلا نبدأ');
    await _tap(t, find.textContaining('جاهز'));
    await t.pump(const Duration(seconds: 3));
    final before = _charadesSeconds(t);
    await t.binding.handlePopRoute(); // device back
    await _settle(t);
    expect(find.text('تنهي اللعبة؟'), findsOneWidget);
    expect(find.text('الوقت واقف لين تقرر'), findsOneWidget);
    await t.pump(const Duration(seconds: 7));
    expect(find.text('كمّل اللعب'), findsOneWidget);
    await _tapNoTime(t, 'كمّل اللعب');
    expect(_charadesSeconds(t), before, reason: 'time stood still');
    await t.pump(const Duration(seconds: 2));
    expect(_charadesSeconds(t), before - 2, reason: 'resumes counting');
    // device back, then end
    await t.binding.handlePopRoute();
    await _settle(t);
    await _tapText(t, 'إي، أنهِ');
    expect(
      find.text('الفريق الفائز').evaluate().isNotEmpty ||
          find.text('تعادل!').evaluate().isNotEmpty,
      isTrue,
    );
    await _tapText(t, 'الألعاب');

    // who am i
    await _tap(t, _tile('مين أنا؟'));
    await _tapText(t, 'يلا نبدأ');
    await t.pump(const Duration(seconds: 4));
    final w0 = _whoAmISeconds(t);
    await t.binding.handlePopRoute();
    await _settle(t);
    expect(find.text('تنهي الجولة؟'), findsOneWidget);
    await t.pump(const Duration(seconds: 6));
    await _tapNoTime(t, 'كمّل اللعب');
    expect(_whoAmISeconds(t), w0);
    await t.pump(const Duration(seconds: 3));
    expect(_whoAmISeconds(t), w0 - 3);
    await _tap(t, find.byIcon(Icons.close_rounded));
    await _tapText(t, 'إي، أنهِ');
    expect(find.text('خلص الوقت!'), findsOneWidget);
    // from result, back leaves normally
    await t.binding.handlePopRoute();
    await _settle(t);
    expect(find.text('كل الألعاب'), findsOneWidget);
    expect(_navBar, findsOneWidget);

    // seen jeem: back asks, keep playing returns to the same question
    await _tap(t, _tile('سين جيم'));
    await _tapText(t, 'يلا نبدأ');
    await t.binding.handlePopRoute();
    await _settle(t);
    expect(find.text('تنهي اللعبة؟'), findsOneWidget);
    await _tapText(t, 'كمّل اللعب');
    expect(find.text('سؤال 1 من 8'), findsOneWidget);
  });

  testWidgets('360x640: no overflow in any game phase', (t) async {
    await _openGamesDirect(t, const Size(360, 640));
    await _playAllGames(t);
  });

  testWidgets('reduced motion: every game still plays', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _openGamesDirect(t, const Size(360, 640));
    await _playAllGames(t);
  });

  testWidgets('keyboard does not hide the team name fields', (t) async {
    await _openGamesDirect(t, const Size(360, 640));
    await _tap(t, _tile('ولا كلمة'));
    t.view.viewInsets = const FakeViewPadding(bottom: 300 * 3.0);
    addTearDown(t.view.resetViewInsets);
    t.view.devicePixelRatio = 3;
    await t.pump();
    final field = find.byType(TextField).first;
    await t.tap(field);
    await _settle(t);
    final rect = t.getRect(field);
    final visibleBottom = 640 - 300;
    expect(
      rect.bottom <= visibleBottom && rect.top >= 0,
      isTrue,
      reason: 'field $rect must sit above the keyboard',
    );
  });

  testWidgets('44x44 targets and Arabic labels on every phase', (t) async {
    final handle = t.ensureSemantics();
    await _openGamesDirect(t, const Size(400, 850));
    _checkButtons(t, 'games list');

    // seen jeem
    await _tap(t, _tile('سين جيم'));
    _checkButtons(t, 'seen intro');
    await _tapText(t, 'يلا نبدأ');
    _checkButtons(t, 'seen play');
    await _tap(t, find.byIcon(Icons.close_rounded));
    _checkButtons(t, 'seen dialog');
    await _tapText(t, 'إي، أنهِ');
    _checkButtons(t, 'seen result');
    await _tapText(t, 'الألعاب');

    // who am i
    await _tap(t, _tile('مين أنا؟'));
    _checkButtons(t, 'who am i intro');
    await _tapText(t, 'يلا نبدأ');
    _checkButtons(t, 'who am i play');
    await _tap(t, find.byIcon(Icons.close_rounded));
    await _tapText(t, 'إي، أنهِ');
    _checkButtons(t, 'who am i result');
    await _tapText(t, 'الألعاب');

    // charades
    await _tap(t, _tile('ولا كلمة'));
    await t.ensureVisible(find.text('5 جولات'));
    await _settle(t);
    _checkButtons(t, 'charades setup');
    await _tapText(t, 'يلا نبدأ');
    _checkButtons(t, 'charades handoff');
    await _tap(t, find.textContaining('جاهز'));
    _checkButtons(t, 'charades play');
    await _tapText(t, 'اضغط وشوف الكلمة');
    _checkButtons(t, 'charades word');
    await _tapText(t, 'إنهاء اللعبة');
    _checkButtons(t, 'charades dialog');
    await _tapText(t, 'إي، أنهِ');
    _checkButtons(t, 'charades result');
    handle.dispose();
  });
}
