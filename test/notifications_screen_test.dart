import 'package:lamma/features/moments/widgets/camera_coach.dart'
    show CoachSession;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/features/clubs/clubs_controller.dart';
import 'package:lamma/features/family_chat/family_chat_controller.dart';
import 'package:lamma/features/moments/moments_controller.dart';
import 'package:lamma/features/notifications/notification_model.dart';
import 'package:lamma/features/notifications/notification_seed.dart';
import 'package:lamma/features/notifications/notifications_controller.dart';
import 'package:lamma/features/notifications/notifications_screen.dart';
import 'package:lamma/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<NotificationsController> _openScreen(
  WidgetTester t, {
  Size size = const Size(360, 800),
}) async {
  SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
  await t.binding.setSurfaceSize(size);
  await t.pumpWidget(const LammaApp(skipSplash: true, skipOnboarding: true));
  await t.pumpAndSettle();
  await t.tap(find.byIcon(Icons.camera_alt_rounded));
  await t.pumpAndSettle();
  await t.tap(find.bySemanticsLabel(RegExp('^الإشعارات')));
  await t.pumpAndSettle();
  await t.tap(find.text('عرض كل الإشعارات'));
  await t.pumpAndSettle();
  return t
      .element(find.byType(NotificationsScreen))
      .read<NotificationsController>();
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

  testWidgets('screen: header, hero, sections, cards; no bottom bar', (
    t,
  ) async {
    final h = t.ensureSemantics();
    final c = await _openScreen(t, size: const Size(360, 1500));
    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsNothing); // no tab bar
    expect(find.text('الإشعارات'), findsWidgets);
    expect(find.text('قريت الكل'), findsOneWidget);
    expect(find.text('صار شي جديد بالعائلة'), findsOneWidget);
    expect(find.text('عندك إشعارين جداد'), findsOneWidget);
    // sections follow the real calendar: just after midnight, "5 minutes ago"
    // already belongs to yesterday, so count what is really today
    final now = DateTime.now();
    final today = c.items
        .where(
          (n) =>
              DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day) ==
              DateTime(now.year, now.month, now.day),
        )
        .length;
    final yesterday = c.items.length - today;
    expect(find.text('اليوم'), today > 0 ? findsOneWidget : findsNothing);
    expect(find.text('أمس'), yesterday > 0 ? findsOneWidget : findsNothing);
    expect(find.text('إشعار واحد'), findsNothing);
    // tags and times
    expect(find.text('لحظة'), findsOneWidget);
    expect(find.text('نادي الكتاب'), findsOneWidget);
    expect(find.text('قبل 5 دقايق'), findsOneWidget);
    // each card is one labelled button; unread ones start with "جديد: "
    expect(
      find.bySemanticsLabel(RegExp('^جديد: سارة شاركت لحظة')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('^نورة صوّتت على طلعة الويكند')),
      findsOneWidget,
    );
    expect(c.unreadCount, 2);
    h.dispose();
  });

  testWidgets('read-all here updates the box and the bells; and back', (
    t,
  ) async {
    final c = await _openScreen(t);
    await t.tap(find.text('قريت الكل'));
    await t.pumpAndSettle();
    expect(c.unreadCount, 0);
    expect(find.text('قريت الكل'), findsNothing); // button hidden
    expect(find.text('ما فيه شي فاتك'), findsOneWidget);
    expect(find.text('كل شي مقروء'), findsOneWidget);
    await t.tap(find.byIcon(Icons.chevron_right_rounded));
    await t.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsNothing);
    // feed bell has no count; the chat tab's bell too
    expect(find.bySemanticsLabel('الإشعارات'), findsOneWidget);
    await t.tap(find.text('لمّه').last);
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel('الإشعارات'), findsOneWidget);
  });

  testWidgets('read-all from outside refreshes the open screen', (t) async {
    final c = await _openScreen(t);
    c.markAllRead();
    await t.pumpAndSettle();
    expect(find.text('ما فيه شي فاتك'), findsOneWidget);
    expect(find.text('قريت الكل'), findsNothing);
  });

  testWidgets('tapping a card reads it and goes to its place', (t) async {
    final c = await _openScreen(t);
    await t.tap(find.textContaining('أمينة في المحادثة'));
    await t.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsNothing);
    expect(find.text('محادثة العائلة · 3 متواجدين'), findsOneWidget);
    expect(c.byId('chat-3')!.isRead, isTrue);
    expect(c.unreadCount, 2); // it was already read
    // an unread one: moment of Sarah
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel(RegExp('^الإشعارات')));
    await t.pumpAndSettle();
    await t.tap(find.text('عرض كل الإشعارات'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('سارة شاركت لحظة'));
    await t.pumpAndSettle();
    expect(find.text('لحظات يومنا'), findsOneWidget);
    expect(c.byId('moment-2')!.isRead, isTrue);
    expect(c.unreadCount, 1);
  });

  testWidgets('360: 44px targets and no overflow', (t) async {
    await _openScreen(t, size: const Size(360, 1500));
    for (final e in find.byType(InkWell).evaluate()) {
      final box = e.renderObject! as RenderBox;
      if (!box.hasSize) continue;
      expect(
        box.size.height >= 43.5 && box.size.width >= 43.5,
        isTrue,
        reason: 'target ${box.size}',
      );
    }
  });

  test('every seeded text matches content that really exists', () {
    final n = NotificationsController();
    final moments = MomentsController(notifications: n);
    final chat = FamilyChatController(notifications: n);
    final clubs = ClubsController(notifications: n);
    seedNotifications(
      notifications: n,
      moments: moments,
      chat: chat,
      clubs: clubs,
    );
    for (final x in n.items) {
      switch (x.type) {
        case NotificationType.moment:
          final m = moments.byId(int.parse(x.targetId!))!;
          expect(x.text.endsWith(m.caption), isTrue);
          expect(x.actorId, m.authorId);
        case NotificationType.comment:
          final parts = x.id.split('-');
          final m = moments.byId(int.parse(parts[1]))!;
          final cm = m.comments[int.parse(parts[2])];
          expect(x.text.endsWith(cm.text), isTrue);
          expect(x.actorId, cm.authorId);
        case NotificationType.chat:
          final msg = chat.messageById(int.parse(x.targetId!))!;
          expect(x.text.endsWith(msg.text), isTrue);
          expect(x.actorId, msg.authorId);
        case NotificationType.club:
          expect(x.text.contains(clubs.currentBook.title), isTrue);
          expect(x.text.contains('${clubs.daysLeft}'), isTrue);
        case NotificationType.game:
        case NotificationType.event:
        case NotificationType.vote:
          break;
      }
    }
  });
}
