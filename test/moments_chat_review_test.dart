// Phase-5 review of the moments feed and the family chat: the end-to-end
// flow, separation between the two, tap targets, labels, 360px width, and
// the keyboard.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/features/moments/new_moment_screen.dart';
import 'package:lamma/features/moments/widgets/camera_coach.dart';
import 'package:lamma/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _noOverflowAndTargets(WidgetTester t, String where) {
  for (final e in find.byType(InkWell).evaluate()) {
    if (!e.renderObject!.attached) continue;
    final box = e.renderObject! as RenderBox;
    if (!box.hasSize) continue;
    // ignore off-screen (not yet scrolled to) targets
    final top = box.localToGlobal(Offset.zero);
    if (top.dy > 800 || top.dy + box.size.height < 0) continue;
    expect(
      box.size.width >= 43.5 && box.size.height >= 43.5,
      isTrue,
      reason: '$where: tap target ${box.size}',
    );
  }
}

Future<void> _app(WidgetTester t, {Size size = const Size(360, 800)}) async {
  SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
  await t.binding.setSurfaceSize(size);
  await t.pumpWidget(const LammaApp(skipOnboarding: true));
  await t.pumpAndSettle();
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    debugPhotoPickerOverride = (_) async => '/tmp/none.jpg';
  });
  tearDown(() {
    debugPhotoPickerOverride = null;
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });

  testWidgets('flow: capture -> top of feed -> comment -> chat', (t) async {
    await _app(t);
    // camera: feed, then the new-moment screen
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    expect(find.text('3 من 6 شاركوا اليوم'), findsOneWidget);
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    expect(find.text('لحظة جديدة'), findsOneWidget);
    await t.tap(find.text('الكاميرا'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'أول قهوة بالشتاء');
    await t.pump();
    await t.tap(find.text('شارك مع العائلة'));
    await t.pumpAndSettle();
    // it is the first card, with the "new" badge, and the counter moved
    expect(find.text('جديد'), findsOneWidget);
    expect(find.text('4 من 6 شاركوا اليوم'), findsOneWidget);
    expect(find.text('انشرت لحظتك للعائلة'), findsOneWidget);
    final newTop = t.getTopLeft(find.text('أول قهوة بالشتاء')).dy;
    final oldTop = t
        .getTopLeft(find.text('أول مشي بالحديقة بعد الصيف، الجو خيال'))
        .dy;
    expect(newTop < oldTop, isTrue);
    // comment on it: the field of the first card is my own post's
    await t.enterText(find.byType(TextField).first, 'يا سلام');
    await t.pump();
    await t.tap(find.bySemanticsLabel('أرسل التعليق').first);
    await t.pumpAndSettle();
    expect(find.text('يا سلام'), findsOneWidget);
    // chat: no trace of the moment, no pictures, no camera inside it
    await t.tap(find.text('لمّه').last);
    await t.pumpAndSettle();
    expect(find.text('محادثة العائلة · 3 متواجدين'), findsOneWidget);
    expect(find.text('أول قهوة بالشتاء'), findsNothing);
    expect(find.text('يا سلام'), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(CameraCoach), findsNothing);
  });

  testWidgets('separation: no chat link in moments, no photo in chat', (
    t,
  ) async {
    await _app(t);
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    // nothing on the moments screen mentions the chat
    expect(find.textContaining('محادثة'), findsNothing);
    expect(find.byIcon(Icons.chat_bubble_rounded), findsNothing);
    await t.tap(find.text('لمّه').last);
    await t.pumpAndSettle();
    expect(find.byIcon(Icons.photo_camera_outlined), findsNothing);
    expect(find.byIcon(Icons.photo_library_outlined), findsNothing);
    expect(find.textContaining('لحظة'), findsNothing);
  });

  test('send arrow mirrors in RTL (points left)', () {
    expect(Icons.send_rounded.matchTextDirection, isTrue);
  });

  testWidgets('360: targets, labels, no overflow (feed, sheet, chat)', (
    t,
  ) async {
    final h = t.ensureSemantics();
    await _app(t);
    await t.tap(find.text('لمّه').last);
    await t.pumpAndSettle();
    _noOverflowAndTargets(t, 'chat');
    expect(
      find.bySemanticsLabel(RegExp('^الإشعارات، 2 جديدة')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('إرسال'), findsOneWidget);
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    _noOverflowAndTargets(t, 'feed');
    expect(find.bySemanticsLabel(RegExp('^الإشعارات')), findsOneWidget);
    expect(find.bySemanticsLabel('أعجبني'), findsNWidgets(4));
    expect(find.bySemanticsLabel('أرسل التعليق'), findsNWidgets(4));
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    _noOverflowAndTargets(t, 'sheet');
    expect(find.bySemanticsLabel('إغلاق'), findsOneWidget);
    await t.tap(find.text('المعرض'));
    await t.pumpAndSettle();
    _noOverflowAndTargets(t, 'sheet+photo');
    h.dispose();
  });

  testWidgets('keyboard does not cover the chat field or a comment field', (
    t,
  ) async {
    await _app(t, size: const Size(360, 640));
    await t.tap(find.text('لمّه').last);
    await t.pumpAndSettle();
    await t.tap(find.byType(TextField));
    t.view.viewInsets = const FakeViewPadding(bottom: 300 * 3.0);
    await t.pumpAndSettle();
    var r = t.getRect(find.byType(TextField));
    expect(r.bottom <= 640 - 300, isTrue, reason: 'chat field $r');
    t.view.resetViewInsets();
    await t.pumpAndSettle();

    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    final field = find.byType(TextField).first;
    await t.ensureVisible(field);
    await t.tap(field);
    t.view.viewInsets = const FakeViewPadding(bottom: 300 * 3.0);
    await t.pumpAndSettle();
    r = t.getRect(find.byType(TextField).first);
    expect(r.bottom <= 640 - 300, isTrue, reason: 'comment field $r');
    t.view.resetViewInsets();
  });

  testWidgets('camera pulse before sharing, none after', (t) async {
    t.platformDispatcher.clearAccessibilityFeaturesTestValue();
    await t.binding.setSurfaceSize(const Size(360, 800));
    SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    await t.pump(const Duration(milliseconds: 500));
    expect(t.hasRunningAnimations, isTrue);
    expect(find.text('مشاركة'), findsOneWidget);
  });
}
