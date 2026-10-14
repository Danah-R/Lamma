import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data.dart';
import 'package:lamma/features/notifications/notification_model.dart';
import 'package:lamma/features/notifications/notifications_controller.dart';
import 'package:lamma/features/survey/survey_controller.dart';
import 'package:lamma/features/survey/survey_model.dart';
import 'package:lamma/main.dart';
import 'package:lamma/widgets/form_controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a new month sends one notification, and answering it makes the survey go away', () async {
    var now = DateTime(2026, 10, 3);
    final n = NotificationsController();
    final s = SurveyController(notifications: n, clock: () => now);

    await s.init();
    expect(s.due, isTrue);
    expect(n.items.where((x) => x.type == NotificationType.survey).length, 1);
    expect(n.items.first.targetRoute, NotificationRoute.profile);

    // opening the app again in the same month does not announce it again
    final again = NotificationsController();
    await SurveyController(notifications: again, clock: () => now).init();
    expect(
      again.items.where((x) => x.type == NotificationType.survey),
      isEmpty,
    );

    final a = SurveyAnswers()
      ..closest.add('نورة')
      ..closeness = 4;
    await s.submit(a);
    expect(s.done, isTrue);
    expect(s.due, isFalse);

    // still answered after a restart, but next month it is due again (with its own notification)
    final restarted = SurveyController(
      notifications: NotificationsController(),
      clock: () => now,
    );
    await restarted.init();
    expect(restarted.done, isTrue);
    now = DateTime(2026, 11, 1);
    final nextMonth = NotificationsController();
    final november = SurveyController(
      notifications: nextMonth,
      clock: () => now,
    );
    await november.init();
    expect(november.due, isTrue);
    expect(
      nextMonth.items.where((x) => x.type == NotificationType.survey).length,
      1,
    );
  });

  test('the answers carry everything that was asked', () {
    final a = SurveyAnswers()
      ..closest.addAll(['سارة', 'يوسف'])
      ..wantCloser.add('عبدالله')
      ..liked.add('games')
      ..disliked.add('book')
      ..outings.add(surveyNone)
      ..games.addAll(['charades', 'whoami'])
      ..closeness = 5
      ..comment = ' شكرًا ';
    final j = a.toJson();
    expect(j['closest'], ['سارة', 'يوسف']);
    expect(j['want_closer'], ['عبدالله']);
    expect(j['liked'], ['games']);
    expect(j['disliked'], ['book']);
    expect(j['outings'], ['none']);
    expect(j['games'], ['charades', 'whoami']);
    expect(j['closeness'], 5);
    expect(j['comment'], 'شكرًا');
    expect(SurveyAnswers().isEmpty, isTrue);
    expect(surveyMonthKey(DateTime(2026, 3, 9)), '2026-03');
  });

  testWidgets(
    'the profile shows the survey, it can be filled in, and then it is done',
    (t) async {
      seedSample();
      await t.binding.setSurfaceSize(const Size(400, 1400));
      // the camera button pulses forever, so wait with plain pumps instead of pumpAndSettle
      await t.pumpWidget(
        const LammaApp(
          skipSplash: true,
          skipOnboarding: true,
          demoNotifications: false,
        ),
      );
      await t.pump(const Duration(seconds: 1));
      await t.tap(find.byTooltip('الحساب'));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('كيف كان شهرك مع العيلة؟'), findsOneWidget);

      await t.tap(find.text('كيف كان شهرك مع العيلة؟'));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('استبيان الشهر'), findsOneWidget);
      expect(find.text('مين كنت الأقرب له هالشهر؟'), findsOneWidget);
      expect(find.text('مين تبي تقرب منه أكثر؟'), findsOneWidget);
      expect(find.text('أي ميزات في التطبيق استمتعت فيها؟'), findsOneWidget);
      expect(find.text('أي ميزات ما عجبتك؟'), findsOneWidget);

      // the person using the app is not offered as someone they got close to
      expect(find.widgetWithText(ChoiceTag, 'نورة'), findsNothing);
      expect(find.widgetWithText(ChoiceTag, 'سارة'), findsWidgets);
      await t.tap(find.text('سارة').first);
      await t.pump();
      // the rest of the questions are further down
      for (final q in [
        'أي طلعات استمتعت فيها أكثر؟',
        'أي ألعاب استمتعت فيها أكثر؟',
        'قد إيش حسّيت إنك قريب من عيلتك هالشهر؟',
        'فيه شي ثاني تبي تقوله؟',
      ]) {
        await t.dragUntilVisible(
          find.text(q),
          find.byType(Scrollable).first,
          const Offset(0, -300),
        );
        expect(find.text(q), findsOneWidget);
        if (q.startsWith('قد إيش')) {
          await t.tap(find.text('5'));
          await t.pump();
        }
      }
      await t.tap(find.text('أرسل إجاباتي'));
      await t.pump(const Duration(milliseconds: 500));

      expect(find.text('شكرًا لك! نشوفك الشهر الجاي.'), findsOneWidget);
      expect(find.text('كيف كان شهرك مع العيلة؟'), findsNothing);
      expect(
        find.text('جاوبت على استبيان هالشهر، نشوفك الشهر الجاي!'),
        findsOneWidget,
      );
    },
  );
}
