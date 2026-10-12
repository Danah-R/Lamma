import 'package:flutter/material.dart';
import 'package:lamma/features/notifications/notifications_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:lamma/features/moments/moments_screen.dart';
import 'package:lamma/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/features/moments/moments_controller.dart';
import 'package:lamma/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lamma/features/moments/widgets/camera_coach.dart';
import 'package:lamma/features/moments/widgets/share_pulse.dart';

void main() {
  // The camera button pulses forever while nothing was shared today; tests
  // run with reduced motion so pumpAndSettle can finish.
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });

  _sheetTests();
  _coachTests();
  test('controller: counts, like, comment, addMoment', () {
    final c = MomentsController();
    expect(c.moments.length, 4);
    expect(c.sharedTodayCount, 3);
    expect(c.didIShareToday, isFalse);
    final m = c.moments.first;
    expect(c.isLiked(m), isFalse);
    c.toggleLike(m.id);
    expect(c.isLiked(c.moments.first), isTrue);
    c.toggleLike(m.id);
    expect(c.isLiked(c.moments.first), isFalse);
    c.addComment(m.id, '  هلا  ');
    expect(c.moments.first.comments.last.text, 'هلا');
    c.addComment(m.id, '   ');
    expect(c.moments.first.comments.length, 3);
    c.addMoment(caption: 'لحظتي');
    expect(c.moments.first.isNew, isTrue);
    expect(c.didIShareToday, isTrue);
    expect(c.sharedTodayCount, 4);
  });

  testWidgets('camera button opens the moments feed (no chat)', (t) async {
    SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
    await t.binding.setSurfaceSize(const Size(360, 800));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    expect(find.text('لحظات يومنا'), findsOneWidget);
    expect(find.text('3 من 6 شاركوا اليوم'), findsOneWidget);
    expect(find.text('أول مشي بالحديقة بعد الصيف، الجو خيال'), findsOneWidget);
    expect(find.textContaining('مع أمينة'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^الإشعارات')), findsOneWidget);
    // like: count goes 4 -> 5 on the first card
    await t.tap(find.bySemanticsLabel('أعجبني').first);
    await t.pumpAndSettle();
    expect(find.text('5'), findsWidgets);
    // quick reply becomes a comment
    await t.ensureVisible(find.text('خيال!').first);
    await t.pumpAndSettle();
    final before = find.text('خيال!').evaluate().length;
    await t.tap(find.text('خيال!').first);
    await t.pump();
    await t.pumpAndSettle();
    expect(find.text('خيال!').evaluate().length, before + 1);
    expect(t.takeException(), isNull);
  });
}

Widget _host(MomentsController c, GlobalKey<MomentsScreenState> key) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: c),
        ChangeNotifierProvider(create: (_) => NotificationsController()),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MomentsScreen(key: key),
      ),
    );

void _sheetTests() {
  testWidgets('new moment: pick, caption, with, share', (t) async {
    await t.binding.setSurfaceSize(const Size(360, 800));
    final c = MomentsController();
    final key = GlobalKey<MomentsScreenState>();
    await t.pumpWidget(_host(c, key));
    key.currentState!.openNewMoment(pickPhoto: (_) async => '/tmp/none.jpg');
    await t.pumpAndSettle();
    expect(find.text('لحظة جديدة'), findsOneWidget);
    expect(find.text('اختار صورة عشان تقدر تشارك'), findsOneWidget);
    expect(find.text('وين كنت؟'), findsNothing);
    // disabled until a photo is picked
    await t.tap(find.text('شارك مع العائلة'));
    await t.pumpAndSettle();
    expect(find.text('لحظة جديدة'), findsOneWidget);
    await t.tap(find.text('المعرض'));
    await t.pumpAndSettle();
    expect(find.text('تغيير الصورة'), findsOneWidget);
    expect(find.text('اختار صورة عشان تقدر تشارك'), findsNothing);
    await t.enterText(find.byType(TextField), 'أول قهوة');
    await t.pump();
    expect(find.text('8/80'), findsOneWidget);
    await t.tap(find.text('أمينة'));
    await t.tap(find.text('نورة'));
    await t.pump();
    await t.tap(find.text('شارك مع العائلة'));
    await t.pumpAndSettle();
    expect(find.text('لحظة جديدة'), findsNothing);
    expect(find.text('انشرت لحظتك للعائلة'), findsOneWidget);
    expect(find.text('جديد'), findsOneWidget);
    expect(find.text('أول قهوة'), findsOneWidget);
    expect(find.text('4 من 6 شاركوا اليوم'), findsOneWidget);
    expect(c.moments.first.withIds, ['am', 'no']);
  });

  testWidgets('camera permission denied: snackbar with settings', (t) async {
    await t.binding.setSurfaceSize(const Size(360, 800));
    final key = GlobalKey<MomentsScreenState>();
    await t.pumpWidget(_host(MomentsController(), key));
    key.currentState!.openNewMoment(
      pickPhoto: (_) async =>
          throw PlatformException(code: 'camera_access_denied'),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('الكاميرا'));
    await t.pumpAndSettle();
    expect(find.text('نحتاج إذن الكاميرا عشان تصوّر'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
  });
}

void _coachTests() {
  testWidgets('coach shows once on first visit; later closes it', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(360, 800));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    expect(find.text('مشاركة'), findsOneWidget);
    expect(find.byType(CameraCoach), findsNothing);
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    expect(find.byType(CameraCoach), findsOneWidget);
    expect(find.text('اضغط الكاميرا تحت وشاركها العائلة'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getBool('moments_coach_seen'),
      isTrue,
    );
    await t.tap(find.text('بعدين'));
    await t.pumpAndSettle();
    expect(find.byType(CameraCoach), findsNothing);
    // leave and come back: never again
    await t.tap(find.text('الرئيسية').last);
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    expect(find.byType(CameraCoach), findsNothing);
  });

  testWidgets('coach "صوّر الحين" opens the new-moment screen', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(360, 800));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    await t.tap(find.text('صوّر الحين'));
    await t.pumpAndSettle();
    expect(find.byType(CameraCoach), findsNothing);
    expect(find.text('لحظة جديدة'), findsOneWidget);
  });

  testWidgets('camera button: semantics label, pulse until shared', (t) async {
    SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
    t.platformDispatcher.clearAccessibilityFeaturesTestValue();
    final h = t.ensureSemantics();
    await t.binding.setSurfaceSize(const Size(360, 800));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    expect(find.bySemanticsLabel('مشاركة: صوّر لحظة'), findsOneWidget);
    SharePulse pulse() => t.widget<SharePulse>(find.byType(SharePulse));
    expect(pulse().active, isTrue);
    await t.pump(const Duration(milliseconds: 600));
    expect(t.hasRunningAnimations, isTrue);
    // sharing stops it
    final c = t.element(find.byType(SharePulse)).read<MomentsController>();
    c.addMoment(caption: 'x');
    await t.pump();
    expect(pulse().active, isFalse);
    await t.pumpAndSettle();
    h.dispose();
  });
}
