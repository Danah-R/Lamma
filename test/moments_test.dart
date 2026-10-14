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
    // not about the camera hint: keep it out of the way
    CoachSession.dismissed = true;
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
    await t.pumpWidget(const LammaApp(skipSplash: true, skipOnboarding: true));
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    expect(find.text('لحظات يومنا'), findsOneWidget);
    expect(find.text('3 من 6 شاركوا اليوم'), findsOneWidget);
    expect(find.text('أول مشي بالحديقة بعد الصيف، الجو خيال'), findsOneWidget);
    expect(find.textContaining('مع أمينة'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^الإشعارات')), findsOneWidget);
    // react with a heart: the reactions count goes 4 -> 5 on the first card
    expect(find.text('4'), findsWidgets);
    await t.tap(find.bySemanticsLabel('قلب').first);
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
  Future<void> launch(
    WidgetTester t, {
    Map<String, Object> prefs = const {},
    bool demo = true,
    bool demoNotifications = false,
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    await t.binding.setSurfaceSize(const Size(360, 800));
    await t.pumpWidget(
      LammaApp(
        skipSplash: true,
        skipOnboarding: true,
        coachDemoMode: demo,
        demoNotifications: demoNotifications,
      ),
    );
    await t.pumpAndSettle();
  }

  // the first camera tap only opens the moments page
  Future<void> openMoments(WidgetTester t) async {
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pump();
  }

  Future<bool?> seen() async =>
      (await SharedPreferences.getInstance()).getBool('moments_coach_seen');

  setUp(CoachSession.reset); // each test is a fresh launch

  testWidgets('not on the home page; on the moments page after 600ms', (
    t,
  ) async {
    await launch(t);
    await t.pump(const Duration(seconds: 2));
    expect(find.byType(CameraCoach), findsNothing); // home: never
    await openMoments(t);
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byType(CameraCoach), findsNothing); // not yet
    await t.pump(const Duration(milliseconds: 150));
    await t.pump(const Duration(milliseconds: 20));
    expect(find.byType(CameraCoach), findsOneWidget);
    expect(find.text('صوّر لحظة من يومك'), findsOneWidget);
    expect(find.text('اضغط الكاميرا تحت وشاركها العائلة'), findsOneWidget);
    expect(find.text('مشاركة'), findsOneWidget);
    expect(t.getSize(find.byType(CameraCoach)).width, 270);
    // buttons hug their text (the wide test font may wrap them to two rows;
    // on the simulator they sit on one row)
    final laterBtn = t.getSize(
      find
          .ancestor(of: find.text('بعدين'), matching: find.byType(Container))
          .first,
    );
    expect(laterBtn.height, 40);
    expect(laterBtn.width < 140, isTrue);
    // leaving the page hides it; coming back shows it again (not dismissed)
    await t.tap(find.text('الرئيسية').last);
    await t.pump();
    expect(find.byType(CameraCoach), findsNothing);
    await openMoments(t);
    await t.pump(const Duration(milliseconds: 700));
    expect(find.byType(CameraCoach), findsOneWidget);
  });

  testWidgets('fades and scales in from 0.9', (t) async {
    await launch(t);
    t.platformDispatcher.clearAccessibilityFeaturesTestValue();
    await openMoments(t);
    await t.pump(const Duration(milliseconds: 600));
    await t.pump(const Duration(milliseconds: 16));
    await t.pump(const Duration(milliseconds: 16));
    final fade = t.widget<FadeTransition>(
      find
          .descendant(
            of: find.byType(CameraCoach),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value > 0 && fade.opacity.value < 1, isTrue);
    final scale = t.widget<ScaleTransition>(
      find
          .descendant(
            of: find.byType(CameraCoach),
            matching: find.byType(ScaleTransition),
          )
          .first,
    );
    expect(scale.scale.value >= .9 && scale.scale.value < 1, isTrue);
    await t.pump(const Duration(milliseconds: 400));
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
  });

  testWidgets('demo: "بعدين" hides it for the session, nothing is saved; '
      'it is back on the next cold start', (t) async {
    await launch(t);
    await openMoments(t);
    await t.pump(const Duration(milliseconds: 700));
    await t.tap(find.text('بعدين'));
    await t.pump();
    expect(find.byType(CameraCoach), findsNothing);
    expect(CoachSession.dismissed, isTrue);
    expect(await seen(), isNull); // no shared_preferences in demo mode
    // same session: leave and come back
    await t.tap(find.text('الرئيسية').last);
    await t.pump();
    await openMoments(t);
    await t.pump(const Duration(seconds: 2));
    expect(find.byType(CameraCoach), findsNothing);
    // close the app completely and open it again
    await t.pumpWidget(const SizedBox());
    CoachSession.reset(); // a new process starts with a clean memory
    await launch(t);
    await openMoments(t);
    await t.pump(const Duration(milliseconds: 700));
    expect(find.byType(CameraCoach), findsOneWidget);
  });

  testWidgets('"صوّر الحين" hides it and opens the new-moment screen', (
    t,
  ) async {
    await launch(t);
    await openMoments(t);
    await t.pump(const Duration(milliseconds: 700));
    await t.tap(find.text('صوّر الحين'));
    await t.pumpAndSettle();
    expect(find.byType(CameraCoach), findsNothing);
    expect(find.text('لحظة جديدة'), findsOneWidget);
    expect(CoachSession.dismissed, isTrue);
  });

  testWidgets('pressing the camera while it shows hides it for the session', (
    t,
  ) async {
    await launch(t);
    await openMoments(t); // this press only navigates: it must not dismiss
    await t.pump(const Duration(milliseconds: 700));
    expect(find.byType(CameraCoach), findsOneWidget);
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    expect(find.byType(CameraCoach), findsNothing);
    expect(CoachSession.dismissed, isTrue);
  });

  testWidgets('sharing a moment hides it, and it does not come back', (
    t,
  ) async {
    await launch(t);
    await openMoments(t);
    await t.pump(const Duration(milliseconds: 700));
    expect(find.byType(CameraCoach), findsOneWidget);
    t
        .element(find.byType(Shell))
        .read<MomentsController>()
        .addMoment(caption: 'x');
    await t.pump();
    expect(find.byType(CameraCoach), findsNothing);
    await t.tap(find.text('الرئيسية').last);
    await t.pump();
    await openMoments(t);
    await t.pump(const Duration(seconds: 2));
    expect(find.byType(CameraCoach), findsNothing);
  });

  testWidgets('the notifications box hides it for now; it returns on close', (
    t,
  ) async {
    await launch(t);
    await openMoments(t);
    await t.pump(const Duration(milliseconds: 700));
    expect(find.byType(CameraCoach), findsOneWidget);
    await t.tap(find.bySemanticsLabel(RegExp('^الإشعارات')));
    await t.pumpAndSettle();
    expect(find.byType(CameraCoach), findsNothing);
    expect(CoachSession.dismissed, isFalse);
    t.element(find.byType(Shell)).read<NotificationsController>().closePanel();
    await t.pumpAndSettle();
    expect(find.byType(CameraCoach), findsOneWidget);
  });

  testWidgets('the banner does not close it and does not overlap it', (
    t,
  ) async {
    await launch(t, demoNotifications: true);
    await openMoments(t);
    await t.pump(const Duration(milliseconds: 700));
    expect(find.byType(CameraCoach), findsOneWidget);
    await t.pump(const Duration(milliseconds: 3000)); // banner at 3.5s
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('إشعار جديد · الحين'), findsOneWidget);
    expect(find.byType(CameraCoach), findsOneWidget);
    final banner = t.getRect(
      find
          .ancestor(
            of: find.text('إشعار جديد · الحين'),
            matching: find.byType(Material),
          )
          .first,
    );
    final coach = t.getRect(find.byType(CameraCoach));
    expect(banner.bottom < coach.top, isTrue); // banner on top, hint below
    await t.pump(const Duration(seconds: 4)); // banner leaves
    expect(find.byType(CameraCoach), findsOneWidget);
  });

  testWidgets('the sample data has no moment of mine today', (t) async {
    final c = MomentsController();
    expect(c.didIShareToday, isFalse);
    expect(c.moments.any((m) => m.authorId == 'mo'), isFalse);
  });

  testWidgets('old behaviour (demo off): once, remembered on disk', (t) async {
    await launch(t, demo: false);
    await openMoments(t);
    await t.pump(const Duration(milliseconds: 700));
    expect(find.byType(CameraCoach), findsOneWidget);
    await t.tap(find.text('بعدين'));
    await t.pump();
    await t.pump();
    expect(await seen(), isTrue);
    // a new launch: not again
    await t.pumpWidget(const SizedBox());
    CoachSession.reset();
    await launch(t, demo: false, prefs: {'moments_coach_seen': true});
    await openMoments(t);
    await t.pump(const Duration(seconds: 2));
    expect(find.byType(CameraCoach), findsNothing);
  });

  testWidgets('camera button: semantics label, pulse until shared', (t) async {
    SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
    t.platformDispatcher.clearAccessibilityFeaturesTestValue();
    final h = t.ensureSemantics();
    await t.binding.setSurfaceSize(const Size(360, 800));
    await t.pumpWidget(const LammaApp(skipSplash: true, skipOnboarding: true));
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
