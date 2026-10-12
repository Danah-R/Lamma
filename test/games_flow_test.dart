import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/main.dart';
import 'package:lamma/screens/activities.dart';

// The bottom bar is the only place with the camera "share" button.
final _navBar = find.byIcon(Icons.camera_alt_rounded);
// Selected tab icon (filled) of "صندوق الأنشطة".
final _activitiesSelected = find.byIcon(Icons.widgets_rounded);

Future<void> _tap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f.first);
  await t.pump();
  await t.tap(f.first);
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 300));
  }
}

Finder _tile(String title) =>
    find.descendant(of: find.byType(GameTile), matching: find.text(title));

Future<void> _tapText(WidgetTester t, String s) => _tap(t, find.text(s));

void main() {
  testWidgets('games open full-screen, charades plays through', (t) async {
    await t.binding.setSurfaceSize(const Size(400, 850));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    await t.pump(const Duration(seconds: 1));
    await _tap(t, find.text('صندوق الأنشطة').last);
    await _tapText(t, 'عرض الكل');
    expect(_navBar, findsOneWidget, reason: 'games list keeps the bar');

    // ---- seen jeem
    await _tap(t, _tile('سين جيم'));
    expect(_navBar, findsNothing);
    expect(find.text('4 لاعبين'), findsOneWidget);
    // drop to 2 players: start is disabled and the hint shows
    await _tapText(t, 'يوسف');
    await _tapText(t, 'آمنة');
    expect(find.textContaining('اختار 3 على الأقل'), findsOneWidget);
    await _tapText(t, 'يلا نبدأ');
    expect(find.text('سؤال 1 من 8'), findsNothing);
    await _tapText(t, 'آمنة');
    await _tapText(t, 'يلا نبدأ');
    expect(find.text('سؤال 1 من 8'), findsOneWidget);
    expect(_navBar, findsNothing);
    await _tapText(t, 'صح! +1');
    expect(find.text('سؤال 2 من 8'), findsOneWidget);
    await _tapText(t, 'غلط');
    // quit: dialog without the paused-timer chip
    await _tap(t, find.byIcon(Icons.close_rounded));
    expect(find.text('تنهي اللعبة؟'), findsOneWidget);
    expect(find.text('الوقت واقف لين تقرر'), findsNothing);
    await _tapText(t, 'كمّل اللعب');
    expect(find.text('سؤال 3 من 8'), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      await _tapText(t, 'صح! +1');
    }
    expect(find.text('أكثر واحد يعرف العائلة'), findsOneWidget);
    expect(_navBar, findsNothing);
    await _tapText(t, 'العب مرة ثانية');
    expect(find.text('سؤال 1 من 8'), findsOneWidget);
    await _tap(t, find.byIcon(Icons.close_rounded));
    await _tapText(t, 'إي، أنهِ');
    expect(find.text('أكثر واحد يعرف العائلة'), findsOneWidget);
    await _tapText(t, 'الألعاب');
    expect(_navBar, findsOneWidget);

    // ---- who am i
    await _tap(t, _tile('مين أنا؟'));
    expect(_navBar, findsNothing);
    await _tapText(t, 'يلا نبدأ');
    expect(find.text('كلمة 1'), findsOneWidget);
    expect(_navBar, findsNothing);
    await _tap(t, find.byIcon(Icons.close_rounded));
    await _tapText(t, 'إي، أنهِ');
    expect(find.text('خلص الوقت!'), findsOneWidget);
    expect(_navBar, findsNothing);
    await _tapText(t, 'الألعاب');
    expect(_navBar, findsOneWidget);

    // ---- charades
    await _tap(t, _tile('ولا كلمة'));
    expect(_navBar, findsNothing);
    expect(find.text('عضوين'), findsNWidgets(0));
    expect(find.text('3 أعضاء'), findsNWidgets(2));
    await _tapText(t, 'يلا نبدأ'); // valid -> handoff
    expect(find.textContaining('جاهز'), findsOneWidget);
    expect(_navBar, findsNothing);
    await _tap(t, find.textContaining('جاهز'));
    expect(find.text('اضغط وشوف الكلمة'), findsOneWidget);
    expect(_navBar, findsNothing);
    await _tapText(t, 'اضغط وشوف الكلمة');
    await _tapText(t, 'عرفوها! +1');
    expect(find.text('اضغط وشوف الكلمة'), findsOneWidget); // hidden again
    // end turn: dialog pauses the timer
    await _tapText(t, 'انهِ الدور');
    expect(find.text('تنهي الدور؟'), findsOneWidget);
    expect(find.text('الدور بينتقل لفريق النجوم.'), findsOneWidget);
    await t.pump(const Duration(seconds: 5));
    await _tapText(t, 'كمّل اللعب');
    expect(find.text('55 ث'), findsNothing); // paused: time did not run
    await _tapText(t, 'انهِ الدور');
    await _tapText(t, 'إي، أنهِ');
    expect(find.text('النجوم'), findsWidgets); // handoff for team B
    expect(find.text('دور فريق'), findsOneWidget);
    expect(_navBar, findsNothing);
    // end game from handoff
    await _tapText(t, 'إنهاء اللعبة');
    expect(find.text('تنهي اللعبة؟'), findsOneWidget);
    expect(find.text('الوقت واقف لين تقرر'), findsNothing);
    await _tapText(t, 'إي، أنهِ');
    expect(find.text('الفريق الفائز'), findsOneWidget);
    expect(find.text('نجم اللعبة'), findsOneWidget);
    expect(_navBar, findsNothing);
    // new game, then end from play
    await _tapText(t, 'جولة جديدة');
    await _tap(t, find.textContaining('جاهز'));
    await _tapText(t, 'إنهاء اللعبة');
    expect(find.text('الوقت واقف لين تقرر'), findsOneWidget);
    await _tapText(t, 'كمّل اللعب');
    await _tapText(t, 'إنهاء اللعبة');
    await _tapText(t, 'إي، أنهِ');
    expect(find.text('تعادل!'), findsOneWidget);
    await _tapText(t, 'الألعاب');
    expect(_navBar, findsOneWidget);
    expect(_activitiesSelected, findsOneWidget);
    expect(find.text('كل الألعاب'), findsOneWidget);
  });
}
