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
import 'package:lamma/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

({
  NotificationsController n,
  MomentsController moments,
  FamilyChatController chat,
  ClubsController clubs,
})
_world({bool seed = false}) {
  final n = NotificationsController();
  final moments = MomentsController(notifications: n);
  final chat = FamilyChatController(notifications: n);
  final clubs = ClubsController(notifications: n);
  if (seed) {
    seedNotifications(
      notifications: n,
      moments: moments,
      chat: chat,
      clubs: clubs,
    );
  }
  return (n: n, moments: moments, chat: chat, clubs: clubs);
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

  test('starting data: six notifications, newest first, two unread', () {
    final w = _world(seed: true);
    final texts = [for (final x in w.n.items) x.text];
    expect(texts, [
      'سارة شاركت لحظة: أول مشي بالحديقة بعد الصيف، الجو خيال',
      'يوسف علّق على لحظة سارة: المرة الجاية خذوني',
      'أمينة في المحادثة: القهوة جاهزة، مين بيجينا العصر؟',
      'نادي الكتاب: باقي 5 أيام على نقاش العادات الذرية',
      'عبدالله يبيكم تلعبون ولا كلمة الليلة',
      'نورة صوّتت على طلعة الويكند',
    ]);
    expect(w.n.unreadCount, 2);
    expect(
      [for (final x in w.n.items) x.createdAt],
      orderedEquals(
        [for (final x in w.n.items) x.createdAt]
          ..sort((a, b) => b.compareTo(a)),
      ),
    );
    final moment = w.n.items.first;
    expect(moment.type, NotificationType.moment);
    expect(moment.thumbnail?.scene, 'park');
    expect(moment.targetRoute, NotificationRoute.moments);
    expect(moment.targetId, '2');
  });

  test('verbs agree with gender', () {
    final w = _world();
    w.moments.addMoment(caption: 'س', authorId: 'sa');
    w.moments.addMoment(caption: 'ع', authorId: 'ab');
    expect(w.n.items.map((x) => x.text), [
      'عبدالله شارك لحظة: ع',
      'سارة شاركت لحظة: س',
    ]);
  });

  test('nothing is announced about what I do', () {
    final w = _world();
    w.moments.addMoment(caption: 'لحظتي');
    w.moments.addComment(2, 'تعليقي');
    w.chat.send('رسالتي');
    expect(w.n.items, isEmpty);
    // even if something tries
    w.n.add(
      AppNotification(
        id: 'x',
        type: NotificationType.chat,
        actorId: notificationMeId,
        text: 't',
        targetRoute: NotificationRoute.chat,
        createdAt: DateTime.now(),
      ),
    );
    expect(w.n.items, isEmpty);
  });

  test('comments: on someone else’s moment, and on mine', () {
    final w = _world();
    w.moments.addComment(2, 'حلو', authorId: 'am');
    expect(w.n.items.first.text, 'أمينة علّقت على لحظة سارة: حلو');
    w.moments.addMoment(caption: 'لحظتي');
    final mine = w.moments.moments.first.id;
    w.moments.addComment(mine, 'يا سلام', authorId: 'yo');
    expect(w.n.items.first.text, 'يوسف علّق على لحظتك: يا سلام');
    expect(w.n.items.first.targetId, '$mine');
  });

  test('chat: others notify with the first 40 characters', () {
    final w = _world();
    w.chat.receive('no', 'ا' * 55);
    expect(w.n.items.first.text, 'نورة في المحادثة: ${'ا' * 40}…');
    expect(w.n.items.first.targetRoute, NotificationRoute.chat);
  });

  test('read state is shared; onNew fires only for live events', () async {
    final w = _world(seed: true);
    final seen = <String>[];
    final sub = w.n.onNew.listen((x) => seen.add(x.text));
    var changes = 0;
    w.n.addListener(() => changes++);
    w.chat.receive('am', 'هلا');
    await Future<void>.delayed(Duration.zero);
    expect(seen, ['أمينة في المحادثة: هلا']);
    expect(w.n.unreadCount, 3);
    w.n.markRead(w.n.items.first.id);
    expect(w.n.unreadCount, 2);
    w.n.markAllRead();
    expect(w.n.unreadCount, 0);
    expect(changes, 3);
    await sub.cancel();
  });

  testWidgets('demo notification arrives after 4 seconds', (t) async {
    SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
    await t.binding.setSurfaceSize(const Size(360, 800));
    await t.pumpWidget(
      const LammaApp(skipOnboarding: true, demoNotifications: true),
    );
    final c = t.element(find.byType(Shell)).read<NotificationsController>();
    expect(c.items.length, 6);
    final live = <AppNotification>[];
    c.onNew.listen(live.add);
    await t.pump(const Duration(seconds: 3));
    expect(c.items.length, 6);
    await t.pump(const Duration(seconds: 2));
    expect(c.items.length, 7);
    expect(c.items.first.text, 'يوسف اقترح طلعة الويكند: وادي حنيفة');
    expect(c.unreadCount, 3);
    expect(live.length, 1);
  });

  testWidgets('opening a notification marks it read and goes there', (t) async {
    SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
    await t.binding.setSurfaceSize(const Size(360, 800));
    await t.pumpWidget(const LammaApp(skipOnboarding: true));
    await t.pumpAndSettle();
    final c = t.element(find.byType(Shell)).read<NotificationsController>();
    final moments = t.element(find.byType(Shell)).read<MomentsController>();
    // a moment far down the feed: opening it scrolls the feed to it
    final target = c.items.firstWhere((n) => n.id == 'comment-2-1');
    c.open(c.items.firstWhere((n) => n.type == NotificationType.chat));
    await t.pumpAndSettle();
    expect(find.text('محادثة العائلة · 3 متواجدين'), findsOneWidget);
    expect(c.unreadCount, 2);
    c.open(target);
    await t.pumpAndSettle();
    expect(find.text('لحظات يومنا'), findsOneWidget);
    expect(c.byId('comment-2-1')!.isRead, isTrue);
    expect(c.unreadCount, 1);
    // the last card (from yesterday) is brought into view
    c.open(NotificationEventsForTest.moment(moments.moments.last));
    await t.pumpAndSettle();
    expect(find.text(moments.moments.last.caption), findsOneWidget);
  });
}

class NotificationEventsForTest {
  static AppNotification moment(Moment m) => AppNotification(
    id: 'moment-${m.id}',
    type: NotificationType.moment,
    actorId: m.authorId,
    text: 'x',
    targetRoute: NotificationRoute.moments,
    targetId: '${m.id}',
    createdAt: DateTime.now(),
  );
}
