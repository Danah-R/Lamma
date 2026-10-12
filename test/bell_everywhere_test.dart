import 'package:lamma/features/moments/widgets/camera_coach.dart'
    show CoachSession;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lamma/features/notifications/notifications_controller.dart';
import 'package:lamma/main.dart';
import 'package:lamma/widgets/notification_bell.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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

  testWidgets('the same bell on every tab; reading is shared', (t) async {
    final h = t.ensureSemantics();
    SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
    await t.binding.setSurfaceSize(const Size(390, 844));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    await t.pumpAndSettle();
    final c = t.element(find.byType(Shell)).read<NotificationsController>();
    final label2 = find.bySemanticsLabel(RegExp('الإشعارات، 2 جديدة'));

    Future<void> checkTab(String tab) async {
      await t.tap(find.text(tab).last);
      await t.pumpAndSettle();
      expect(find.byType(NotificationBell), findsOneWidget, reason: tab);
      expect(label2, findsOneWidget, reason: tab);
    }

    await checkTab('لمّه');
    await checkTab('صندوق الأنشطة');
    await checkTab('الحساب');
    await checkTab('الرئيسية');
    // the camera tab (moments)
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    expect(label2, findsOneWidget);

    // open the box here, read all here ...
    await t.tap(label2);
    await t.pumpAndSettle();
    expect(c.panelOpen, isTrue);
    await t.tap(find.text('قريت الكل'));
    await t.pumpAndSettle();
    expect(c.unreadCount, 0);
    c.closePanel();
    await t.pumpAndSettle();
    // ... and every other tab shows no count
    for (final tab in ['الرئيسية', 'الحساب', 'صندوق الأنشطة', 'لمّه']) {
      await t.tap(find.text(tab).last);
      await t.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp('الإشعارات(?!،)')),
        findsOneWidget,
        reason: tab,
      );
    }
    h.dispose();
  });

  testWidgets('the box opens from the home bell and reaches the full screen', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
    await t.binding.setSurfaceSize(const Size(390, 844));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    await t.pumpAndSettle();
    await t.tap(find.byType(NotificationBell));
    await t.pumpAndSettle();
    expect(find.text('عرض كل الإشعارات'), findsOneWidget);
    await t.tap(find.text('عرض كل الإشعارات'));
    await t.pumpAndSettle();
    expect(find.text('صار شي جديد بالعائلة'), findsOneWidget);
  });
}
