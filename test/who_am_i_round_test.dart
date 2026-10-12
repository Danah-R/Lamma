import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/features/games/who_am_i/who_am_i_screen.dart';
import 'package:lamma/l10n/app_localizations.dart';

void main() {
  testWidgets('full who-am-i round', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const WhoAmIScreen(),
      ),
    );
    await tester.pump();
    expect(find.text('يلا نبدأ'), findsOneWidget);
    await tester.tap(find.text('أكلات'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('30 ث'));
    await tester.pump();
    await tester.tap(find.text('يلا نبدأ'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('كلمة 1'), findsOneWidget);
    await tester.tap(find.text('عرفتها!'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('عرفتها! +1'), findsOneWidget);
    await tester.tap(find.text('تخطّي'));
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('كلمة 3'), findsOneWidget);
    // confirm dialog pauses timer
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('تنهي الجولة؟'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.tap(find.text('كمّل اللعب'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('كلمة 3'), findsOneWidget);
    await tester.pump(const Duration(seconds: 31));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('خلص الوقت!'), findsOneWidget);
    expect(find.text('جولة ثانية'), findsOneWidget);
    await tester.tap(find.text('جولة ثانية'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('كلمة 1'), findsOneWidget);
    await tester.pump(const Duration(seconds: 31));
    await tester.pump(const Duration(seconds: 1));
  });
}
