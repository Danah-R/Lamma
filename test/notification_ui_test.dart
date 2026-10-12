import 'package:lamma/features/moments/widgets/camera_coach.dart'
    show CoachSession;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/features/notifications/notification_model.dart';
import 'package:lamma/features/notifications/notifications_controller.dart';
import 'package:lamma/features/notifications/widgets/notification_banner.dart';
import 'package:lamma/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppNotification _note(String id) => AppNotification(
  id: id,
  type: NotificationType.chat,
  actorId: 'am',
  lead: 'أمينة',
  text: 'أمينة في المحادثة: $id',
  targetRoute: NotificationRoute.chat,
  createdAt: DateTime.now(),
);

bool _bannerShown(WidgetTester t) =>
    t
        .widget<IgnorePointer>(
          find
              .descendant(
                of: find.byType(NotificationBannerHost),
                matching: find.byType(IgnorePointer),
              )
              .first,
        )
        .ignoring ==
    false;

final _bell = find.bySemanticsLabel(RegExp('^الإشعارات'));

Future<NotificationsController> _openFeed(
  WidgetTester t, {
  bool demo = false,
  Size size = const Size(390, 844),
}) async {
  SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
  await t.binding.setSurfaceSize(size);
  await t.pumpWidget(LammaApp(skipOnboarding: true, demoNotifications: demo));
  await t.pumpAndSettle();
  await t.tap(find.byIcon(Icons.camera_alt_rounded));
  await t.pumpAndSettle();
  return t.element(find.byType(Shell)).read<NotificationsController>();
}

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

  testWidgets('bell: count badge and Arabic label follow the controller', (
    t,
  ) async {
    final h = t.ensureSemantics();
    final c = await _openFeed(t);
    expect(find.bySemanticsLabel('الإشعارات، 2 جديدة'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    c.markAllRead();
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel('الإشعارات'), findsOneWidget);
    h.dispose();
  });

  testWidgets('box: content, read-all, scrim closes, shared with chat bell', (
    t,
  ) async {
    final c = await _openFeed(t);
    await t.tap(_bell);
    await t.pumpAndSettle();
    expect(c.panelOpen, isTrue);
    expect(find.text('إشعارين جداد'), findsOneWidget);
    expect(find.text('قريت الكل'), findsOneWidget);
    expect(find.text('عرض كل الإشعارات'), findsOneWidget);
    expect(find.textContaining('سارة شاركت لحظة'), findsOneWidget);
    expect(find.text('قبل 5 دقايق'), findsOneWidget);
    expect(find.text('قبل 20 دقيقة'), findsOneWidget);
    // width 336 (390 - 24 would allow more), under the bell
    final panel = find.ancestor(
      of: find.text('عرض كل الإشعارات'),
      matching: find.byType(Container),
    );
    expect(t.getSize(panel.last).width, 336);
    // read all: the box and the badge update at once
    await t.tap(find.text('قريت الكل'));
    await t.pumpAndSettle();
    expect(find.text('كل شي مقروء'), findsOneWidget);
    expect(find.text('قريت الكل'), findsNothing);
    expect(c.unreadCount, 0);
    // scrim closes it
    await t.tapAt(const Offset(200, 780));
    await t.pumpAndSettle();
    expect(c.panelOpen, isFalse);
    expect(find.text('عرض كل الإشعارات'), findsNothing);
    // the chat tab's bell reads the same controller
    await t.tap(find.text('لمّه').last);
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel('الإشعارات'), findsOneWidget);
  });

  testWidgets('box: max height 470 and it scrolls on a short screen', (
    t,
  ) async {
    final c = await _openFeed(t, size: const Size(360, 640));
    for (var i = 0; i < 8; i++) {
      c.add(_note('extra-$i'), announce: false);
    }
    await t.tap(_bell);
    await t.pumpAndSettle();
    final panel = find.ancestor(
      of: find.text('عرض كل الإشعارات'),
      matching: find.byType(Container),
    );
    expect(t.getSize(panel.last).height <= 470, isTrue);
    expect(t.getSize(panel.last).width, 336);
  });

  testWidgets('tapping a row marks it read, closes the box and goes there', (
    t,
  ) async {
    final c = await _openFeed(t);
    await t.tap(_bell);
    await t.pumpAndSettle();
    await t.tap(find.textContaining('في المحادثة'));
    await t.pumpAndSettle();
    expect(c.panelOpen, isFalse);
    expect(find.text('محادثة العائلة · 3 متواجدين'), findsOneWidget);
    expect(c.items.firstWhere((n) => n.id == 'chat-3').isRead, isTrue);
  });

  testWidgets('banner: arrives, opens the box on tap, leaves after 3.5s', (
    t,
  ) async {
    final c = await _openFeed(t, demo: true);
    expect(find.text('إشعار جديد · الحين'), findsNothing);
    await t.pump(const Duration(seconds: 4));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('إشعار جديد · الحين'), findsOneWidget);
    expect(_bannerShown(t), isTrue);
    expect(c.unreadCount, 3);
    // leaves by itself
    await t.pump(const Duration(milliseconds: 3600));
    expect(_bannerShown(t), isFalse);
  });

  testWidgets('banner tap opens the box; no banner while it is open', (
    t,
  ) async {
    final c = await _openFeed(t, demo: true);
    await t.pump(const Duration(seconds: 4));
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(find.text('إشعار جديد · الحين'));
    await t.pumpAndSettle();
    expect(c.panelOpen, isTrue);
    expect(find.text('3 إشعارات جديدة'), findsOneWidget);
    // another one arrives while the box is open: no banner
    c.markAllRead();
    c.closePanel();
    await t.pumpAndSettle();
    c.openPanel();
    await t.pumpAndSettle();
    c.add(_note('late'));
    await t.pump(const Duration(milliseconds: 500));
    expect(_bannerShown(t), isFalse);
  });
}
