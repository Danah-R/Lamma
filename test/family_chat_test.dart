import 'package:lamma/features/moments/widgets/camera_coach.dart'
    show CoachSession;
import 'package:flutter/material.dart';
import 'package:lamma/features/notifications/notifications_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/features/family_chat/family_chat_controller.dart';
import 'package:lamma/features/family_chat/family_chat_screen.dart';
import 'package:lamma/l10n/app_localizations.dart';
import 'package:lamma/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _host(FamilyChatController c) => MultiProvider(
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
    home: const FamilyChatScreen(),
  ),
);

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

  test('controller: poll is one vote, toggles off; answer marks answered', () {
    final c = FamilyChatController();
    expect(c.totalVotes, 5);
    c.vote('kabsa');
    expect(c.totalVotes, 6);
    expect(c.votesFor(c.pollOptions.first), 3);
    c.vote('burger');
    expect(c.votesFor(c.pollOptions.first), 2);
    expect(c.totalVotes, 6);
    c.vote('burger');
    expect(c.myVote, isNull);
    expect(c.totalVotes, 5);
    c.replyToQuestion();
    c.send('  أحلى شي القهوة ');
    expect(c.messages.last.kind, ChatKind.reply);
    expect(c.messages.last.text, 'أحلى شي القهوة');
    expect(c.answered, isTrue);
    expect(c.replyingToQuestion, isFalse);
    c.send('   ');
    expect(c.messages.length, 7);
  });

  testWidgets('chat screen: layout, answer, send, poll, 360 width', (t) async {
    await t.binding.setSurfaceSize(const Size(360, 800));
    final c = FamilyChatController();
    await t.pumpWidget(_host(c));
    await t.pumpAndSettle();
    expect(find.text('لمّه'), findsOneWidget);
    expect(find.text('محادثة العائلة · 3 متواجدين'), findsOneWidget);
    expect(find.text('مشويات أكيد'), findsOneWidget);
    expect(find.text('عبدالله يكتب'), findsOneWidget);
    expect(find.text('اكتب للعائلة…'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);
    // poll
    await t.tap(find.text('كبسة'));
    await t.pumpAndSettle();
    expect(find.text('6 أصوات'), findsOneWidget);
    await t.tap(find.text('كبسة'));
    await t.pumpAndSettle();
    expect(find.text('5 أصوات'), findsOneWidget);
    // answer the question
    await t.scrollUntilVisible(
      find.text('جاوب'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.text('جاوب'));
    await t.pumpAndSettle();
    expect(find.text('ترد على سؤال اليوم'), findsOneWidget);
    expect(find.text('اكتب ردك…'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'الرحلة');
    await t.pump();
    await t.tap(find.bySemanticsLabel('إرسال'));
    await t.pumpAndSettle();
    expect(find.text('ترد على سؤال اليوم'), findsNothing);
    expect(find.text('الرحلة'), findsOneWidget);
    expect(find.text('الحين'), findsWidgets);
    await t.scrollUntilVisible(
      find.text('جاوبت عليه'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('جاوبت عليه'), findsOneWidget);
  });

  testWidgets('chat tab is selected; camera opens the moments feed', (t) async {
    SharedPreferences.setMockInitialValues({'moments_coach_seen': true});
    await t.binding.setSurfaceSize(const Size(360, 800));
    await t.pumpWidget(const LammaApp(skipSplash: true, skipOnboarding: true));
    await t.tap(find.text('لمّه').last);
    await t.pumpAndSettle();
    expect(find.text('محادثة العائلة · 3 متواجدين'), findsOneWidget);
    await t.tap(find.byIcon(Icons.camera_alt_rounded));
    await t.pumpAndSettle();
    expect(find.text('لحظات يومنا'), findsOneWidget);
    expect(find.text('لحظة جديدة'), findsNothing);
  });
}
