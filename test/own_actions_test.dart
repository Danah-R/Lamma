import 'package:lamma/features/moments/widgets/camera_coach.dart'
    show CoachSession;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/features/games/games_controller.dart';
import 'package:lamma/features/notifications/notifications_controller.dart';
import 'package:lamma/features/notifications/notification_model.dart';
import 'package:lamma/features/outings/outing_controller.dart';
import 'package:lamma/main.dart';
import 'package:provider/provider.dart';
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

  test(
    'outing: a new vote and a suggestion are logged as read; undo is not',
    () {
      final n = NotificationsController();
      final live = <AppNotification>[];
      n.onNew.listen(live.add);
      final o = OutingController(notifications: n);
      o.toggleVote(1);
      expect(n.items.single.text, 'محمد صوّت على طلعة الويكند');
      expect(n.items.single.type, NotificationType.vote);
      expect(n.items.single.isRead, isTrue);
      o.toggleVote(1); // take it back
      expect(n.items.length, 1);
      expect(o.hasVoted(1), isFalse);
      o.suggest('وادي حنيفة');
      expect(n.items.first.text, 'محمد اقترح طلعة الويكند: وادي حنيفة');
      expect(n.items.first.type, NotificationType.event);
      expect(n.unreadCount, 0); // no badge for my own acts
      expect(live, isEmpty); // no banner either
    },
  );

  test('games: starting a game is logged with its name', () {
    final n = NotificationsController();
    final g = GamesController(notifications: n);
    g.start('ولا كلمة');
    expect(n.items.single.text, 'محمد يبيكم تلعبون ولا كلمة الليلة');
    expect(n.items.single.type, NotificationType.game);
    expect(n.items.single.isRead, isTrue);
    expect(g.lastStarted, 'ولا كلمة');
  });

  testWidgets('in the app: voting and starting a game reach the list', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
    await t.binding.setSurfaceSize(const Size(400, 1400));
    await t.pumpWidget(const LammaApp(skipSplash: true, skipOnboarding: true));
    await t.pumpAndSettle();
    final c = t.element(find.byType(Shell)).read<NotificationsController>();
    final before = c.items.length;
    await t.tap(find.text('صندوق الأنشطة').last);
    await t.pumpAndSettle();
    final vote = find.text('بجي معكم!').first;
    await t.scrollUntilVisible(
      vote,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(vote);
    await t.pumpAndSettle();
    expect(c.items.first.text, 'محمد صوّت على طلعة الويكند');
    expect(c.items.length, before + 1);
    // a game
    await t.scrollUntilVisible(
      find.text('عرض الكل').first,
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.text('عرض الكل').first);
    await t.pumpAndSettle();
    await t.tap(find.text('ولا كلمة').first);
    await t.pumpAndSettle();
    expect(c.items.first.text, 'محمد يبيكم تلعبون ولا كلمة الليلة');
    expect(c.unreadCount, 2);
  });
}
